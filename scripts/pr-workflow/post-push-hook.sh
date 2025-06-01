#!/bin/bash
# Post-push Git hook
# Automatically validates PR scope after pushing changes

set -e

# Get script directory and import validation core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/validation-core.sh"

# Configuration
ASYNC_MODE="${PULSE_PR_ASYNC:-true}"
NOTIFY_METHOD="${PULSE_PR_NOTIFY:-desktop}"  # desktop, terminal, none
VALIDATION_MODE="${PULSE_PR_VALIDATION_MODE:-incremental}"

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Skip validation for certain branches
if [[ "$CURRENT_BRANCH" =~ ^(main|develop|master)$ ]]; then
    exit 0
fi

# Check if PR exists for current branch
PR_NUMBER=$(gh pr list --head "$CURRENT_BRANCH" --json number -q '.[0].number' 2>/dev/null || echo "")

if [[ -z "$PR_NUMBER" ]]; then
    # No PR exists, nothing to validate
    exit 0
fi

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"  # low, normal, critical
    
    case "$NOTIFY_METHOD" in
        desktop)
            if command -v osascript >/dev/null 2>&1; then
                # macOS notification
                osascript -e "display notification \"$message\" with title \"$title\""
            elif command -v notify-send >/dev/null 2>&1; then
                # Linux notification
                notify-send -u "$urgency" "$title" "$message"
            fi
            ;;
        terminal)
            echo ""
            echo "🔔 $title"
            echo "   $message"
            echo ""
            ;;
    esac
}

# Function to run validation in background
run_async_validation() {
    local pr_number="$1"
    local validation_log="${CACHE_DIR}/validation-${pr_number}-$(date +%s).log"
    
    {
        echo "Starting validation for PR #$pr_number at $(date)"
        echo "Branch: $CURRENT_BRANCH"
        echo ""
        
        # Get PR base branch
        BASE_BRANCH=$(gh pr view "$pr_number" --json baseRefName -q .baseRefName)
        
        # Run validation
        if validate_pr_scope "$BASE_BRANCH" "$VALIDATION_MODE"; then
            echo ""
            echo "✅ Validation passed!"
            
            # Update PR with success status
            gh pr comment "$pr_number" --body "✅ Post-push validation passed for commit $(git rev-parse --short HEAD)"
            
            # Remove validation-failed label if present
            gh pr edit "$pr_number" --remove-label "validation-failed" 2>/dev/null || true
            gh pr edit "$pr_number" --add-label "validated" 2>/dev/null || true
            
            send_notification "PR #$pr_number Validation" "All checks passed! ✅" "normal"
        else
            echo ""
            echo "❌ Validation failed!"
            
            # Generate summary
            PR_CACHE_KEY=$(git rev-parse HEAD)
            VALIDATION_SUMMARY=$(generate_validation_summary "$PR_CACHE_KEY")
            
            # Update PR with failure status
            gh pr comment "$pr_number" --body "❌ Post-push validation failed for commit $(git rev-parse --short HEAD)

$VALIDATION_SUMMARY

View detailed logs: \`~/.pulse-pr-cache/validation-${pr_number}-*.log\`"
            
            # Update labels
            gh pr edit "$pr_number" --add-label "validation-failed" 2>/dev/null || true
            gh pr edit "$pr_number" --remove-label "validated" 2>/dev/null || true
            
            send_notification "PR #$pr_number Validation" "Validation failed! Check PR for details. ❌" "critical"
        fi
        
        echo ""
        echo "Validation completed at $(date)"
    } > "$validation_log" 2>&1
}

# Main execution
if [[ "$ASYNC_MODE" == "true" ]]; then
    # Run validation in background
    log_info "Starting background validation for PR #$PR_NUMBER..."
    run_async_validation "$PR_NUMBER" &
    
    # Store background job PID
    echo $! > "${CACHE_DIR}/validation-${PR_NUMBER}.pid"
    
    log_info "Validation running in background (PID: $!)"
    log_info "You'll be notified when validation completes."
else
    # Run validation synchronously
    log_info "Running validation for PR #$PR_NUMBER..."
    
    # Get PR base branch
    BASE_BRANCH=$(gh pr view "$PR_NUMBER" --json baseRefName -q .baseRefName)
    
    if validate_pr_scope "$BASE_BRANCH" "$VALIDATION_MODE"; then
        log_success "Post-push validation passed!"
        
        # Update PR
        gh pr comment "$PR_NUMBER" --body "✅ Post-push validation passed for commit $(git rev-parse --short HEAD)"
        gh pr edit "$PR_NUMBER" --remove-label "validation-failed" --add-label "validated" 2>/dev/null || true
    else
        log_error "Post-push validation failed!"
        
        # Update PR
        PR_CACHE_KEY=$(git rev-parse HEAD)
        VALIDATION_SUMMARY=$(generate_validation_summary "$PR_CACHE_KEY")
        
        gh pr comment "$PR_NUMBER" --body "❌ Post-push validation failed for commit $(git rev-parse --short HEAD)

$VALIDATION_SUMMARY"
        
        gh pr edit "$PR_NUMBER" --add-label "validation-failed" --remove-label "validated" 2>/dev/null || true
        
        # Ask if user wants to see details
        if [[ -t 1 ]]; then  # Check if running in terminal
            read -p "View validation details? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Show recent test failures
                find "$CACHE_DIR/test-results" -name "*.json" -mmin -5 -exec jq -r 'select(.result != 0) | .output' {} \; | base64 -d | less
            fi
        fi
    fi
fi