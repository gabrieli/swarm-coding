#!/bin/bash
# API Automation Script Template
# Purpose: Automate GitHub API operations for Swarm Coding workflow

set -e  # Exit on error

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
OWNER="<github-username>"
REPO="<repo-name>"
PROJECT_NUMBER="<project-number>"

# Field IDs (obtained from get_project_fields.graphql)
STATUS_FIELD_ID="<status-field-id>"
WORK_ITEM_TYPE_FIELD_ID="<work-item-type-field-id>"

# Status Option IDs
BACKLOG_ID="<backlog-status-id>"
PM_REFINED_ID="<pm-refined-status-id>"
DEV_READY_ID="<dev-ready-status-id>"
IN_PROGRESS_ID="<in-progress-status-id>"
IN_REVIEW_ID="<in-review-status-id>"
DONE_ID="<done-status-id>"

# Work Item Type Option IDs
EPIC_TYPE_ID="<epic-option-id>"
USER_STORY_TYPE_ID="<user-story-option-id>"
TASK_TYPE_ID="<task-option-id>"

# Validation
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Set it with: export GITHUB_TOKEN=your_token"
    exit 1
fi

# Function to create an epic with multiple user stories
create_epic_with_stories() {
    local epic_title="$1"
    local epic_body="$2"
    shift 2
    local stories=("$@")
    
    echo "Creating epic: $epic_title"
    
    # Create the epic issue
    epic_response=$(gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/$OWNER/$REPO/issues" \
        -f title="Epic: $epic_title" \
        -f body="$epic_body" \
        -f labels='["epic"]')
    
    epic_number=$(echo "$epic_response" | jq -r '.number')
    epic_node_id=$(echo "$epic_response" | jq -r '.node_id')
    
    echo "Created epic #$epic_number"
    
    # Add epic to project
    item_response=$(gh api graphql -f query="
        mutation {
            addProjectV2ItemById(input: {
                projectId: \"$PROJECT_NUMBER\"
                contentId: \"$epic_node_id\"
            }) {
                item {
                    id
                }
            }
        }")
    
    item_id=$(echo "$item_response" | jq -r '.data.addProjectV2ItemById.item.id')
    
    # Set work item type to Epic
    gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(input: {
                projectId: \"$PROJECT_NUMBER\"
                itemId: \"$item_id\"
                fieldId: \"$WORK_ITEM_TYPE_FIELD_ID\"
                value: {
                    singleSelectOptionId: \"$EPIC_TYPE_ID\"
                }
            }) {
                projectV2Item {
                    id
                }
            }
        }"
    
    # Set status to PM Refined
    gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(input: {
                projectId: \"$PROJECT_NUMBER\"
                itemId: \"$item_id\"
                fieldId: \"$STATUS_FIELD_ID\"
                value: {
                    singleSelectOptionId: \"$PM_REFINED_ID\"
                }
            }) {
                projectV2Item {
                    id
                }
            }
        }"
    
    # Create user stories
    local story_numbers=()
    for story_data in "${stories[@]}"; do
        IFS='|' read -r story_title story_body <<< "$story_data"
        
        echo "Creating user story: $story_title"
        
        # Create story issue
        story_response=$(gh api \
            --method POST \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "/repos/$OWNER/$REPO/issues" \
            -f title="User Story: $story_title" \
            -f body="$story_body

**Parent Epic**: #$epic_number" \
            -f labels='["user-story"]')
        
        story_number=$(echo "$story_response" | jq -r '.number')
        story_node_id=$(echo "$story_response" | jq -r '.node_id')
        story_numbers+=($story_number)
        
        echo "Created user story #$story_number"
        
        # Add story to project and configure
        configure_story_in_project "$story_node_id"
    done
    
    # Update epic body with story links
    local story_list=""
    for num in "${story_numbers[@]}"; do
        story_list="$story_list- [ ] #$num
"
    done
    
    gh api \
        --method PATCH \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/$OWNER/$REPO/issues/$epic_number" \
        -f body="$epic_body

## User Stories
$story_list"
    
    echo "Epic #$epic_number created with ${#story_numbers[@]} user stories"
}

# Function to configure a story in the project
configure_story_in_project() {
    local node_id="$1"
    
    # Add to project
    item_response=$(gh api graphql -f query="
        mutation {
            addProjectV2ItemById(input: {
                projectId: \"$PROJECT_NUMBER\"
                contentId: \"$node_id\"
            }) {
                item {
                    id
                }
            }
        }")
    
    item_id=$(echo "$item_response" | jq -r '.data.addProjectV2ItemById.item.id')
    
    # Set work item type to User Story
    gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(input: {
                projectId: \"$PROJECT_NUMBER\"
                itemId: \"$item_id\"
                fieldId: \"$WORK_ITEM_TYPE_FIELD_ID\"
                value: {
                    singleSelectOptionId: \"$USER_STORY_TYPE_ID\"
                }
            }) {
                projectV2Item {
                    id
                }
            }
        }"
    
    # Set status to PM Refined
    gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(input: {
                projectId: \"$PROJECT_NUMBER\"
                itemId: \"$item_id\"
                fieldId: \"$STATUS_FIELD_ID\"
                value: {
                    singleSelectOptionId: \"$PM_REFINED_ID\"
                }
            }) {
                projectV2Item {
                    id
                }
            }
        }"
}

# Function to move issue to different status
move_issue_status() {
    local issue_number="$1"
    local new_status_id="$2"
    
    echo "Moving issue #$issue_number to new status"
    
    # Get issue node ID
    issue_response=$(gh api \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "/repos/$OWNER/$REPO/issues/$issue_number")
    
    node_id=$(echo "$issue_response" | jq -r '.node_id')
    
    # Get project item ID
    item_response=$(gh api graphql -f query="
        query {
            node(id: \"$node_id\") {
                ... on Issue {
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
        }")
    
    item_id=$(echo "$item_response" | jq -r ".data.node.projectItems.nodes[] | select(.project.id == \"$PROJECT_NUMBER\") | .id")
    
    # Update status
    gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(input: {
                projectId: \"$PROJECT_NUMBER\"
                itemId: \"$item_id\"
                fieldId: \"$STATUS_FIELD_ID\"
                value: {
                    singleSelectOptionId: \"$new_status_id\"
                }
            }) {
                projectV2Item {
                    id
                }
            }
        }"
    
    echo "Issue #$issue_number status updated"
}

# Main execution
case "${1:-}" in
    "create-epic")
        # Example usage:
        # ./script.sh create-epic "Feature Name" "Epic description" "Story 1|Story 1 body" "Story 2|Story 2 body"
        shift
        epic_title="$1"
        epic_body="$2"
        shift 2
        create_epic_with_stories "$epic_title" "$epic_body" "$@"
        ;;
    
    "move-status")
        # Example usage:
        # ./script.sh move-status 123 in-progress
        issue_number="$2"
        status="$3"
        
        case "$status" in
            "backlog") status_id="$BACKLOG_ID" ;;
            "pm-refined") status_id="$PM_REFINED_ID" ;;
            "dev-ready") status_id="$DEV_READY_ID" ;;
            "in-progress") status_id="$IN_PROGRESS_ID" ;;
            "in-review") status_id="$IN_REVIEW_ID" ;;
            "done") status_id="$DONE_ID" ;;
            *) 
                echo "Unknown status: $status"
                echo "Valid statuses: backlog, pm-refined, dev-ready, in-progress, in-review, done"
                exit 1
                ;;
        esac
        
        move_issue_status "$issue_number" "$status_id"
        ;;
    
    *)
        echo "GitHub API Automation Script"
        echo ""
        echo "Usage:"
        echo "  $0 create-epic <title> <body> <story1_title|story1_body> [story2_title|story2_body] ..."
        echo "  $0 move-status <issue_number> <status>"
        echo ""
        echo "Examples:"
        echo "  $0 create-epic \"User Authentication\" \"Implement secure login\" \"Login UI|Create login form\" \"API Integration|Connect to auth service\""
        echo "  $0 move-status 123 in-progress"
        ;;
esac