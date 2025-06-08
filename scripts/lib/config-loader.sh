#!/bin/bash
# Configuration Loader Library
# Provides functions to load configuration from config.json with environment variable fallback

# Find the root directory of the project
find_project_root() {
    local current_dir="$1"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/config.json" ]] || [[ -f "$current_dir/config.example.json" ]]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    return 1
}

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=$(find_project_root "$SCRIPT_DIR")

if [[ -z "$PROJECT_ROOT" ]]; then
    echo "Error: Could not find project root directory" >&2
    exit 1
fi

# Configuration file path
CONFIG_FILE="$PROJECT_ROOT/config.json"
CONFIG_EXAMPLE_FILE="$PROJECT_ROOT/config.example.json"

# Check if config exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file not found at $CONFIG_FILE" >&2
    echo "Please copy $CONFIG_EXAMPLE_FILE to $CONFIG_FILE and update with your values" >&2
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq to continue." >&2
    exit 1
fi

# Function to get config value with fallback to environment variable
get_config() {
    local json_path="$1"
    local env_var="$2"
    local default_value="$3"
    
    # Try to get from config.json
    local config_value=$(jq -r "$json_path // empty" "$CONFIG_FILE" 2>/dev/null)
    
    # If not found in config, try environment variable
    if [[ -z "$config_value" ]] && [[ -n "$env_var" ]]; then
        config_value="${!env_var}"
    fi
    
    # If still not found, use default
    if [[ -z "$config_value" ]] && [[ -n "$default_value" ]]; then
        config_value="$default_value"
    fi
    
    # If still empty, return error
    if [[ -z "$config_value" ]]; then
        echo "Error: Configuration value not found for $json_path" >&2
        return 1
    fi
    
    echo "$config_value"
}

# Function to check required configuration
check_required_config() {
    local json_path="$1"
    local error_message="$2"
    
    if ! get_config "$json_path" "" "" >/dev/null 2>&1; then
        echo "Error: $error_message" >&2
        echo "Please update $CONFIG_FILE with the required value at: $json_path" >&2
        return 1
    fi
    return 0
}

# Load GitHub configuration
load_github_config() {
    # Repository info
    export REPO_OWNER=$(get_config '.github.owner' 'GITHUB_OWNER' '')
    export REPO_NAME=$(get_config '.github.repository' 'GITHUB_REPOSITORY' '')
    
    # Project info
    export PROJECT_NAME=$(get_config '.github.project.name' 'GITHUB_PROJECT_NAME' '')
    export PROJECT_ID=$(get_config '.github.project.id' 'GITHUB_PROJECT_ID' '')
    export PROJECT_NUMBER=$(get_config '.github.project.number' 'GITHUB_PROJECT_NUMBER' '1')
    
    # Field IDs
    export STATUS_FIELD_ID=$(get_config '.github.project.fields.status.id' 'GITHUB_STATUS_FIELD_ID' '')
    export WORK_ITEM_TYPE_FIELD_ID=$(get_config '.github.project.fields.work_item_type.id' 'GITHUB_WORK_ITEM_TYPE_FIELD_ID' '')
    
    # Status option IDs
    export BACKLOG_OPTION_ID=$(get_config '.github.project.fields.status.options.backlog' 'GITHUB_BACKLOG_OPTION_ID' '')
    export PM_REFINED_OPTION_ID=$(get_config '.github.project.fields.status.options.pm_refined' 'GITHUB_PM_REFINED_OPTION_ID' '')
    export DEV_READY_OPTION_ID=$(get_config '.github.project.fields.status.options.dev_ready' 'GITHUB_DEV_READY_OPTION_ID' '')
    export IN_PROGRESS_OPTION_ID=$(get_config '.github.project.fields.status.options.in_progress' 'GITHUB_IN_PROGRESS_OPTION_ID' '')
    export IN_REVIEW_OPTION_ID=$(get_config '.github.project.fields.status.options.in_review' 'GITHUB_IN_REVIEW_OPTION_ID' '')
    export DONE_OPTION_ID=$(get_config '.github.project.fields.status.options.done' 'GITHUB_DONE_OPTION_ID' '')
    
    # Work item type option IDs
    export EPIC_OPTION_ID=$(get_config '.github.project.fields.work_item_type.options.epic' 'GITHUB_EPIC_OPTION_ID' '')
    export USER_STORY_OPTION_ID=$(get_config '.github.project.fields.work_item_type.options.user_story' 'GITHUB_USER_STORY_OPTION_ID' '')
}

# Load PR workflow configuration
load_pr_workflow_config() {
    # Default values
    export DEFAULT_BASE_BRANCH=$(get_config '.pr_workflow.default_base_branch' 'PR_DEFAULT_BASE_BRANCH' 'main')
    export DEFAULT_VALIDATION_MODE=$(get_config '.pr_workflow.validation.default_mode' 'PR_DEFAULT_VALIDATION_MODE' 'full')
    export VALIDATION_ASYNC_MODE=$(get_config '.pr_workflow.validation.async_mode' 'PR_VALIDATION_ASYNC' 'true')
    export NOTIFICATION_METHOD=$(get_config '.pr_workflow.validation.notification_method' 'PR_NOTIFICATION_METHOD' 'desktop')
    export CACHE_DIR=$(get_config '.pr_workflow.validation.cache_dir' 'PR_CACHE_DIR' "$HOME/.swarm-pr-cache")
    
    # Labels
    export VALIDATED_LABEL=$(get_config '.pr_workflow.labels.validated' 'PR_VALIDATED_LABEL' 'validated')
    export VALIDATION_FAILED_LABEL=$(get_config '.pr_workflow.labels.validation_failed' 'PR_VALIDATION_FAILED_LABEL' 'validation-failed')
    export MODULE_LABEL_PREFIX=$(get_config '.pr_workflow.labels.module_prefix' 'PR_MODULE_LABEL_PREFIX' 'module:')
}

# Load general configuration
load_general_config() {
    export EDITOR=$(get_config '.editor' 'EDITOR' 'vim')
    export NOTIFICATIONS_ENABLED=$(get_config '.notifications.enabled' 'NOTIFICATIONS_ENABLED' 'true')
    export NOTIFICATIONS_METHOD=$(get_config '.notifications.method' 'NOTIFICATIONS_METHOD' 'desktop')
}

# Validate GitHub configuration
validate_github_config() {
    local errors=0
    
    check_required_config '.github.owner' "GitHub owner/username is required" || ((errors++))
    check_required_config '.github.repository' "GitHub repository name is required" || ((errors++))
    
    if [[ $errors -gt 0 ]]; then
        echo "Error: Missing required GitHub configuration" >&2
        return 1
    fi
    
    # Check if project configuration is needed
    if [[ -n "$PROJECT_ID" ]]; then
        check_required_config '.github.project.id' "GitHub project ID is required" || ((errors++))
        check_required_config '.github.project.fields.status.id' "Status field ID is required" || ((errors++))
    fi
    
    return $errors
}

# Export config file location for other scripts
export SWARM_CONFIG_FILE="$CONFIG_FILE"
export SWARM_PROJECT_ROOT="$PROJECT_ROOT"

# Auto-load configuration based on script requirements
# Scripts can set REQUIRE_GITHUB_CONFIG=true before sourcing this file
if [[ "${REQUIRE_GITHUB_CONFIG:-false}" == "true" ]]; then
    load_github_config
    validate_github_config || exit 1
fi

if [[ "${REQUIRE_PR_CONFIG:-false}" == "true" ]]; then
    load_pr_workflow_config
fi

# Always load general config
load_general_config

# Function to display current configuration
show_config() {
    echo "Current Configuration:"
    echo "====================="
    echo "Project Root: $PROJECT_ROOT"
    echo "Config File: $CONFIG_FILE"
    echo ""
    echo "GitHub:"
    echo "  Owner: ${REPO_OWNER:-<not set>}"
    echo "  Repository: ${REPO_NAME:-<not set>}"
    echo "  Project: ${PROJECT_NAME:-<not set>}"
    echo ""
    echo "PR Workflow:"
    echo "  Base Branch: ${DEFAULT_BASE_BRANCH:-<not set>}"
    echo "  Validation Mode: ${DEFAULT_VALIDATION_MODE:-<not set>}"
    echo "  Cache Directory: ${CACHE_DIR:-<not set>}"
    echo ""
}