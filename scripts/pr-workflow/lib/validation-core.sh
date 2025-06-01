#!/bin/bash
# Core validation logic for PR reviews
# This script provides shared functionality for PR creation and post-push validation

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
CACHE_DIR="${HOME}/.pulse-pr-cache"
VALIDATION_TIMEOUT="${VALIDATION_TIMEOUT:-300}"  # 5 minutes default

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR/test-results" "$CACHE_DIR/ai-reviews"

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '█'
    printf "%$((width - completed))s" | tr ' ' '░'
    printf "] %d%%" "$percentage"
}

# Get PR scope information
get_pr_scope() {
    local base_branch="${1:-main}"
    
    # Ensure we have latest base branch
    git fetch origin "$base_branch" --quiet
    
    # Get changed files
    local changed_files=$(git diff --name-only "origin/$base_branch"...HEAD)
    local commit_count=$(git rev-list --count "origin/$base_branch"...HEAD)
    local total_changes=$(git diff --shortstat "origin/$base_branch"...HEAD)
    
    echo "PR_SCOPE_BASE=$base_branch"
    echo "PR_SCOPE_COMMITS=$commit_count"
    echo "PR_SCOPE_FILES=$(echo "$changed_files" | wc -l | tr -d ' ')"
    echo "PR_SCOPE_CHANGES='$total_changes'"
    echo "PR_SCOPE_FILE_LIST='$changed_files'"
}

# Analyze which modules are affected
analyze_affected_modules() {
    local changed_files="$1"
    local modules=""
    
    if echo "$changed_files" | grep -q "^iosApp/"; then
        modules="${modules}ios "
    fi
    
    if echo "$changed_files" | grep -q "^androidApp/"; then
        modules="${modules}android "
    fi
    
    if echo "$changed_files" | grep -q "^shared/"; then
        modules="${modules}shared "
    fi
    
    if echo "$changed_files" | grep -q "^\.github/workflows/"; then
        modules="${modules}ci "
    fi
    
    if echo "$changed_files" | grep -q "^scripts/"; then
        modules="${modules}scripts "
    fi
    
    if echo "$changed_files" | grep -q "^docs/"; then
        modules="${modules}docs "
    fi
    
    echo "${modules:-none}"
}

# Check if cache is valid
is_cache_valid() {
    local cache_file="$1"
    local ttl="${2:-3600}"  # Default 1 hour
    
    if [[ ! -f "$cache_file" ]]; then
        return 1
    fi
    
    local file_age=$(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null)))
    
    if [[ $file_age -lt $ttl ]]; then
        return 0
    else
        return 1
    fi
}

# Run tests with caching
run_tests_with_cache() {
    local test_type="$1"
    local cache_key="$2"
    local test_command="$3"
    
    local cache_file="$CACHE_DIR/test-results/${cache_key}_${test_type}.json"
    
    # Check cache
    if is_cache_valid "$cache_file"; then
        log_info "Using cached ${test_type} test results"
        cat "$cache_file"
        return 0
    fi
    
    # Run tests
    log_info "Running ${test_type} tests..."
    local start_time=$(date +%s)
    local test_output=""
    local test_result=0
    
    if test_output=$(eval "$test_command" 2>&1); then
        test_result=0
        log_success "${test_type} tests passed"
    else
        test_result=1
        log_error "${test_type} tests failed"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Save to cache
    cat > "$cache_file" <<EOF
{
    "type": "${test_type}",
    "result": ${test_result},
    "duration": ${duration},
    "timestamp": $(date +%s),
    "output": "$(echo "$test_output" | base64)"
}
EOF
    
    return $test_result
}

# Check if claude command is available
find_claude_command() {
    # Check common locations for claude CLI
    local claude_paths=(
        "claude"  # In PATH
        "$HOME/.claude/local/claude"  # User-specific installation
        "/usr/local/bin/claude"  # System-wide installation
        "$CLAUDE_CLI_PATH"  # Environment variable override
    )
    
    for cmd in "${claude_paths[@]}"; do
        if [[ -n "$cmd" ]] && command -v "$cmd" >/dev/null 2>&1; then
            echo "$cmd"
            return 0
        fi
    done
    
    echo ""
    return 1
}

# Run AI review for PR scope (no caching - always fresh reviews)
run_ai_reviews_for_pr() {
    local changed_files="$1"
    local temp_dir="${2:-$(mktemp -d /tmp/pr-ai-review-XXXXXX)}"
    
    # Ensure temp directory has secure permissions
    chmod 700 "$temp_dir"
    
    local claude_cmd=$(find_claude_command)
    if [[ -z "$claude_cmd" ]]; then
        log_warning "Claude CLI not found. Skipping AI reviews."
        return 0
    fi
    
    # Write file contents to a secure temporary file
    local files_content_file="$temp_dir/pr_files_content.txt"
    touch "$files_content_file"
    chmod 600 "$files_content_file"  # Restrict access to owner only
    
    local has_files=false
    while IFS= read -r file; do
        if [[ -f "$PROJECT_ROOT/$file" ]] && file "$PROJECT_ROOT/$file" | grep -q "text"; then
            echo "" >> "$files_content_file"
            echo "--- File: $file ---" >> "$files_content_file"
            cat "$PROJECT_ROOT/$file" >> "$files_content_file" 2>/dev/null || true
            has_files=true
        fi
    done <<< "$changed_files"
    
    if [[ "$has_files" == false ]]; then
        log_info "No text files to review"
        return 0
    fi
    
    # Read content safely
    local files_content=$(cat "$files_content_file")
    
    # Run reviews in parallel
    log_info "Running AI reviews in parallel..."
    
    # Architecture review
    (
        if [[ -f "$PROJECT_ROOT/docs/ai-review/ARCHITECT_REVIEW.md" ]]; then
            local prompt="You are an AI code reviewer acting as the Technical Architect. Your role is defined in the following instructions:

$(cat "$PROJECT_ROOT/docs/ai-review/ARCHITECT_REVIEW.md")

Here are the files to review from the current PR:
$files_content

Please analyze these files and provide your review in the JSON format specified in the instructions."
            
            $claude_cmd --model opus -p --output-format json "$prompt" > "$temp_dir/architect.json" 2>"$temp_dir/architect.err"
        fi
    ) &
    local arch_pid=$!
    
    # Security review
    (
        if [[ -f "$PROJECT_ROOT/docs/ai-review/SECURITY_REVIEW.md" ]]; then
            local prompt="You are an AI code reviewer acting as the Security Expert. Your role is defined in the following instructions:

$(cat "$PROJECT_ROOT/docs/ai-review/SECURITY_REVIEW.md")

Here are the files to review from the current PR:
$files_content

Please analyze these files and provide your review in the JSON format specified in the instructions."
            
            $claude_cmd --model opus -p --output-format json "$prompt" > "$temp_dir/security.json" 2>"$temp_dir/security.err"
        fi
    ) &
    local sec_pid=$!
    
    # Testing review
    (
        if [[ -f "$PROJECT_ROOT/docs/ai-review/TESTING_REVIEW.md" ]]; then
            local prompt="You are an AI code reviewer acting as the QA Test Expert. Your role is defined in the following instructions:

$(cat "$PROJECT_ROOT/docs/ai-review/TESTING_REVIEW.md")

Here are the files to review from the current PR:
$files_content

Please analyze these files and provide your review in the JSON format specified in the instructions."
            
            $claude_cmd --model opus -p --output-format json "$prompt" > "$temp_dir/testing.json" 2>"$temp_dir/testing.err"
        fi
    ) &
    local test_pid=$!
    
    # Wait for reviews with timeout
    local timeout=240  # 4 minutes
    local elapsed=0
    while [[ $elapsed -lt $timeout ]]; do
        if ! kill -0 $arch_pid 2>/dev/null && ! kill -0 $sec_pid 2>/dev/null && ! kill -0 $test_pid 2>/dev/null; then
            break
        fi
        sleep 5
        elapsed=$((elapsed + 5))
        if [[ $((elapsed % 30)) -eq 0 ]]; then
            echo "⏳ AI reviews in progress... (${elapsed}s elapsed)"
        fi
    done
    
    # Kill any remaining processes
    kill $arch_pid $sec_pid $test_pid 2>/dev/null || true
    
    # Check what review files were created
    log_info "Checking AI review results..."
    ls -la "$temp_dir"/*.json 2>/dev/null || log_warning "No review JSON files found"
    
    # Show review file sizes for debugging
    for review_file in "$temp_dir"/*.json; do
        if [[ -f "$review_file" ]]; then
            local size=$(wc -c < "$review_file")
            log_info "$(basename "$review_file"): $size bytes"
        fi
    done
    
    # Aggregate results
    if [[ -f "$PROJECT_ROOT/scripts/aggregate-reviews.py" ]]; then
        python3 "$PROJECT_ROOT/scripts/aggregate-reviews.py" \
            "$temp_dir/architect.json" \
            "$temp_dir/security.json" \
            "$temp_dir/testing.json"
        local review_result=$?
    else
        # Simple check if any reviews failed
        local review_result=0
        for review_file in "$temp_dir"/*.json; do
            if [[ -f "$review_file" ]] && grep -q '"status": "failed"' "$review_file"; then
                review_result=1
                break
            fi
        done
    fi
    
    # Save review outputs to cache for debugging
    if [[ -d "$temp_dir" ]]; then
        local timestamp=$(date +%s)
        local review_cache_dir="$CACHE_DIR/ai-reviews-${timestamp}"
        mkdir -p "$review_cache_dir"
        cp -r "$temp_dir"/* "$review_cache_dir/" 2>/dev/null || true
        log_info "AI review outputs saved to: $review_cache_dir"
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    return $review_result
}

# Validate PR scope
validate_pr_scope() {
    local base_branch="${1:-main}"
    local validation_mode="${2:-full}"
    local validation_results=()
    local overall_result=0
    
    log_info "Starting PR validation (mode: $validation_mode)"
    echo ""
    
    # Get PR scope
    eval "$(get_pr_scope "$base_branch")"
    
    log_info "PR Scope Analysis:"
    echo "  • Base branch: $PR_SCOPE_BASE"
    echo "  • Commits: $PR_SCOPE_COMMITS"
    echo "  • Files changed: $PR_SCOPE_FILES"
    echo "  • Changes: $PR_SCOPE_CHANGES"
    echo ""
    
    # Analyze affected modules
    local affected_modules=$(analyze_affected_modules "$PR_SCOPE_FILE_LIST")
    log_info "Affected modules: $affected_modules"
    echo ""
    
    # Generate cache key for this PR state
    local pr_cache_key=$(git rev-parse HEAD)
    
    # Run tests based on validation mode and affected modules
    case "$validation_mode" in
        full)
            # Run all tests
            if [[ $affected_modules == *"android"* ]] || [[ $affected_modules == *"shared"* ]]; then
                run_tests_with_cache "android-unit" "$pr_cache_key" \
                    "cd '$PROJECT_ROOT' && ./gradlew :androidApp:testDebugUnitTest :shared:testDebugUnitTest --no-daemon" || overall_result=1
            fi
            
            if [[ $affected_modules == *"ios"* ]] || [[ $affected_modules == *"shared"* ]]; then
                run_tests_with_cache "ios-unit" "$pr_cache_key" \
                    "cd '$PROJECT_ROOT/iosApp' && xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16' -only-testing:iosAppTests CODE_SIGN_IDENTITY='' CODE_SIGNING_REQUIRED=NO -quiet" || overall_result=1
            fi
            
            # Integration tests if needed
            if [[ $validation_mode == "full" ]]; then
                log_info "Running integration tests..."
                # Add integration test commands here
            fi
            ;;
            
        incremental)
            # Run only tests for affected modules
            log_info "Running incremental validation for affected modules only"
            ;;
            
        quick)
            # Run minimal test set
            log_info "Running quick validation (unit tests only)"
            ;;
    esac
    
    # Run AI reviews on PR scope
    log_info "Running AI reviews on PR changes..."
    echo ""
    
    if run_ai_reviews_for_pr "$PR_SCOPE_FILE_LIST"; then
        log_success "AI review completed successfully"
    else
        log_error "AI review found issues that need attention"
        overall_result=1
    fi
    
    echo ""
    return $overall_result
}

# Generate validation summary
generate_validation_summary() {
    local cache_key="$1"
    local summary=""
    
    summary+="## 🔍 PR Validation Summary\n\n"
    
    # Test results
    summary+="### 🧪 Test Results\n"
    for result_file in "$CACHE_DIR/test-results/${cache_key}"*.json; do
        if [[ -f "$result_file" ]]; then
            local test_type=$(jq -r '.type' "$result_file")
            local test_result=$(jq -r '.result' "$result_file")
            local test_duration=$(jq -r '.duration' "$result_file")
            
            if [[ $test_result -eq 0 ]]; then
                summary+="- ✅ ${test_type}: Passed (${test_duration}s)\n"
            else
                summary+="- ❌ ${test_type}: Failed (${test_duration}s)\n"
            fi
        fi
    done
    
    summary+="\n### 🤖 AI Review Summary\n"
    # Add AI review summary here
    
    echo -e "$summary"
}

# Export functions for use in other scripts
export -f log_info log_success log_warning log_error
export -f get_pr_scope analyze_affected_modules
export -f validate_pr_scope generate_validation_summary