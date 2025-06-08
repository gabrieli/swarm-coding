#!/bin/bash
# PR Creation Wrapper Script
# This script must be used for all PR creation to ensure proper validation

set -e

# Get script directory and import validation core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/validation-core.sh"

# Default values from configuration (will be loaded by validation-core.sh)
BASE_BRANCH="${DEFAULT_BASE_BRANCH:-main}"
VALIDATION_MODE="${DEFAULT_VALIDATION_MODE:-full}"
FORCE_CREATE=false
INTERACTIVE=true
DRAFT=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --base|-b)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --mode|-m)
            VALIDATION_MODE="$2"
            shift 2
            ;;
        --force|-f)
            FORCE_CREATE=true
            shift
            ;;
        --no-interactive)
            INTERACTIVE=false
            shift
            ;;
        --draft|-d)
            DRAFT=true
            shift
            ;;
        --help|-h)
            cat <<EOF
Usage: $0 [options]

Options:
  --base, -b <branch>      Base branch for PR (default: main)
  --mode, -m <mode>        Validation mode: full, incremental, quick (default: full)
  --force, -f              Force PR creation even with validation failures
  --no-interactive         Skip interactive prompts
  --draft, -d              Create PR as draft
  --help, -h               Show this help message

This script performs comprehensive validation before creating a PR:
- Runs all relevant tests based on changed files
- Performs AI code review on the entire PR scope
- Generates detailed PR description with validation results

Examples:
  $0                                    # Standard PR creation with full validation
  $0 --base develop --mode quick        # Quick validation against develop branch
  $0 --draft --force                    # Create draft PR, bypass validation failures

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Print banner
echo ""
echo "🚀 PR Swarm - Intelligent PR Creation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log_error "Not in a git repository"
    exit 1
fi

# Check if current branch is different from base
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
    log_error "Cannot create PR from base branch '$BASE_BRANCH'"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    log_warning "You have uncommitted changes"
    if [[ "$INTERACTIVE" == true ]]; then
        read -p "Commit changes before creating PR? [Y/n] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            git add -A
            git commit
        else
            log_error "Please commit or stash your changes before creating PR"
            exit 1
        fi
    else
        log_error "Uncommitted changes detected. Use --force to ignore."
        exit 1
    fi
fi

# Run validation
log_info "Running PR validation..."
echo ""

VALIDATION_OUTPUT=$(mktemp)
if validate_pr_scope "$BASE_BRANCH" "$VALIDATION_MODE" 2>&1 | tee "$VALIDATION_OUTPUT"; then
    VALIDATION_PASSED=true
    log_success "All validations passed!"
else
    VALIDATION_PASSED=false
    log_error "Validation failed!"
fi

# Generate validation summary for PR description
PR_CACHE_KEY=$(git rev-parse HEAD)
VALIDATION_SUMMARY=$(generate_validation_summary "$PR_CACHE_KEY")

# Check if we should proceed
if [[ "$VALIDATION_PASSED" == false ]] && [[ "$FORCE_CREATE" == false ]]; then
    if [[ "$INTERACTIVE" == true ]]; then
        echo ""
        log_warning "Validation failed. Do you want to:"
        echo "  1) View detailed error log"
        echo "  2) Create PR anyway (as draft)"
        echo "  3) Cancel"
        read -p "Choose [1-3]: " -n 1 -r choice
        echo
        
        case $choice in
            1)
                less "$VALIDATION_OUTPUT"
                read -p "Create PR as draft? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    DRAFT=true
                else
                    log_info "PR creation cancelled"
                    rm "$VALIDATION_OUTPUT"
                    exit 0
                fi
                ;;
            2)
                DRAFT=true
                ;;
            *)
                log_info "PR creation cancelled"
                rm "$VALIDATION_OUTPUT"
                exit 0
                ;;
        esac
    else
        log_error "Validation failed. Use --force to create PR anyway."
        rm "$VALIDATION_OUTPUT"
        exit 1
    fi
fi

# Get PR title and body
if [[ "$INTERACTIVE" == true ]]; then
    echo ""
    read -p "PR Title: " PR_TITLE
    
    # Generate suggested PR body
    SUGGESTED_BODY=$(cat <<EOF
## Summary
<!-- Describe the changes in this PR -->

## Changes
<!-- List the key changes -->

$VALIDATION_SUMMARY

## Testing
<!-- Describe how these changes were tested -->

## Checklist
- [ ] Tests pass locally
- [ ] Code follows project conventions
- [ ] Documentation updated if needed
- [ ] No sensitive data exposed

---
🤖 Generated with Swarm PR Workflow
EOF
)
    
    # Open editor for PR body
    PR_BODY_FILE=$(mktemp)
    echo "$SUGGESTED_BODY" > "$PR_BODY_FILE"
    
    ${EDITOR:-vim} "$PR_BODY_FILE"
    PR_BODY=$(cat "$PR_BODY_FILE")
    rm "$PR_BODY_FILE"
else
    # Non-interactive mode - use defaults
    PR_TITLE="$(git log -1 --pretty=%B | head -n1)"
    PR_BODY="$VALIDATION_SUMMARY"
fi

# Create the PR
log_info "Creating PR..."
echo ""

PR_ARGS=()
if [[ "$DRAFT" == true ]]; then
    PR_ARGS+=("--draft")
fi

if gh pr create \
    --base "$BASE_BRANCH" \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    "${PR_ARGS[@]}"; then
    
    log_success "PR created successfully!"
    
    # Get PR number
    PR_NUMBER=$(gh pr view --json number -q .number)
    PR_URL=$(gh pr view --json url -q .url)
    
    # Add labels based on validation results
    if [[ "$VALIDATION_PASSED" == true ]]; then
        gh pr edit "$PR_NUMBER" --add-label "$VALIDATED_LABEL"
    else
        gh pr edit "$PR_NUMBER" --add-label "$VALIDATION_FAILED_LABEL"
    fi
    
    # Add module labels
    eval "$(get_pr_scope "$BASE_BRANCH")"
    AFFECTED_MODULES=$(analyze_affected_modules "$PR_SCOPE_FILE_LIST")
    
    for module in $AFFECTED_MODULES; do
        if [[ "$module" != "none" ]]; then
            gh pr edit "$PR_NUMBER" --add-label "${MODULE_LABEL_PREFIX}$module" 2>/dev/null || true
        fi
    done
    
    echo ""
    echo "🎉 PR #$PR_NUMBER created: $PR_URL"
    
    # Clean up
    rm "$VALIDATION_OUTPUT"
    
else
    log_error "Failed to create PR"
    rm "$VALIDATION_OUTPUT"
    exit 1
fi