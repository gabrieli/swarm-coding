#!/bin/bash

# GitHub Project Management Script
# Automates common project board operations

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/project_config.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

function log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

function log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

function get_issue_project_item_id() {
    local issue_number=$1
    
    gh api graphql -f query="
    {
      repository(owner: \"$REPO_OWNER\", name: \"$REPO_NAME\") {
        issue(number: $issue_number) {
          projectItems(first: 10) {
            nodes {
              id
              project {
                id
              }
            }
          }
        }
      }
    }" -q ".data.repository.issue.projectItems.nodes[] | select(.project.id == \"$PROJECT_ID\") | .id"
}

function set_issue_status() {
    local issue_number=$1
    local status_option_id=$2
    
    log_info "Setting issue #$issue_number status..."
    
    local item_id=$(get_issue_project_item_id $issue_number)
    
    if [ -z "$item_id" ]; then
        log_error "Issue #$issue_number not found in project"
        return 1
    fi
    
    gh api graphql -f query="
    mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: \"$PROJECT_ID\",
        itemId: \"$item_id\",
        fieldId: \"$STATUS_FIELD_ID\",
        value: { singleSelectOptionId: \"$status_option_id\" }
      }) {
        projectV2Item { id }
      }
    }" > /dev/null
    
    log_info "Updated issue #$issue_number status"
}

function set_work_item_type() {
    local issue_number=$1
    local type_option_id=$2
    
    log_info "Setting issue #$issue_number work item type..."
    
    local item_id=$(get_issue_project_item_id $issue_number)
    
    if [ -z "$item_id" ]; then
        log_error "Issue #$issue_number not found in project"
        return 1
    fi
    
    gh api graphql -f query="
    mutation {
      updateProjectV2ItemFieldValue(input: {
        projectId: \"$PROJECT_ID\",
        itemId: \"$item_id\",
        fieldId: \"$WORK_ITEM_TYPE_FIELD_ID\",
        value: { singleSelectOptionId: \"$type_option_id\" }
      }) {
        projectV2Item { id }
      }
    }" > /dev/null
    
    log_info "Updated issue #$issue_number work item type"
}

function set_dev_ready() {
    local issue_number=$1
    set_issue_status $issue_number $DEV_READY_OPTION_ID
}

function set_epic_type() {
    local issue_number=$1
    set_work_item_type $issue_number $EPIC_OPTION_ID
}

function set_user_story_type() {
    local issue_number=$1
    set_work_item_type $issue_number $USER_STORY_OPTION_ID
}

function add_issue_to_project() {
    local issue_number=$1
    
    log_info "Adding issue #$issue_number to project..."
    
    gh issue edit $issue_number --repo $REPO_OWNER/$REPO_NAME --add-project "Pulse Menu"
    
    log_info "Added issue #$issue_number to project"
}

function setup_epic() {
    local epic_number=$1
    shift
    local sub_issues=("$@")
    
    log_info "Setting up epic #$epic_number with sub-issues: ${sub_issues[*]}"
    
    # Set epic work item type and status
    set_epic_type $epic_number
    set_dev_ready $epic_number
    
    # Create task list content
    local task_list=""
    for issue in "${sub_issues[@]}"; do
        local title=$(gh issue view $issue --repo $REPO_OWNER/$REPO_NAME --json title -q .title)
        task_list="$task_list- [ ] #$issue $title\n"
    done
    
    # Get current body and append task list
    local current_body=$(gh issue view $epic_number --repo $REPO_OWNER/$REPO_NAME --json body -q .body)
    local new_body="$current_body\n\n## Sub-Issues\n$task_list"
    
    # Update epic body with task list
    echo -e "$new_body" > /tmp/epic_body.md
    gh issue edit $epic_number --repo $REPO_OWNER/$REPO_NAME --body-file /tmp/epic_body.md
    rm /tmp/epic_body.md
    
    log_info "Updated epic #$epic_number with task list"
}

function setup_user_stories() {
    local epic_number=$1
    shift
    local story_issues=("$@")
    
    log_info "Setting up user stories: ${story_issues[*]}"
    
    for issue in "${story_issues[@]}"; do
        add_issue_to_project $issue
        set_user_story_type $issue
        set_dev_ready $issue
        
        # Add comment linking to epic
        gh issue comment $issue --repo $REPO_OWNER/$REPO_NAME --body "This is a sub-issue of #$epic_number"
    done
    
    log_info "Set up all user stories"
}

function show_help() {
    cat << EOF
GitHub Project Management Script

Usage: $0 <command> [arguments]

Commands:
  add-to-project <issue_number>              Add issue to project
  set-status <issue_number> <status_id>      Set issue status
  set-dev-ready <issue_number>               Set issue to Dev Ready status
  set-epic <issue_number>                    Set work item type to Epic
  set-user-story <issue_number>              Set work item type to User Story
  setup-epic <epic_number> <sub_issue_1> [sub_issue_2...]  Setup epic with sub-issues
  setup-stories <epic_number> <story_1> [story_2...]       Setup user stories linked to epic
  get-fields                                 Show all project fields and options

Examples:
  $0 set-dev-ready 17
  $0 set-epic 17
  $0 setup-epic 17 18 19 20 21 22 23
  $0 setup-stories 17 18 19 20 21 22 23
EOF
}

# Main command processing
case "${1:-}" in
    "add-to-project")
        add_issue_to_project $2
        ;;
    "set-status")
        set_issue_status $2 $3
        ;;
    "set-dev-ready")
        set_dev_ready $2
        ;;
    "set-epic")
        set_epic_type $2
        ;;
    "set-user-story")
        set_user_story_type $2
        ;;
    "setup-epic")
        epic_number=$2
        shift 2
        setup_epic $epic_number "$@"
        ;;
    "setup-stories")
        epic_number=$2
        shift 2
        setup_user_stories $epic_number "$@"
        ;;
    "get-fields")
        gh api graphql -f query="$(cat scripts/github/get_project_fields.graphql)" -f projectId=$PROJECT_ID
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac