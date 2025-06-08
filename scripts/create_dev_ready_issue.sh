#!/bin/bash
# Script to create a GitHub issue and set it to Dev Ready status in project

if [ $# -lt 2 ]; then
    echo "Usage: $0 <title> <body_file>"
    echo "Example: $0 'New Feature' body.md"
    exit 1
fi

TITLE="$1"
BODY_FILE="$2"

# Check if body file exists
if [ ! -f "$BODY_FILE" ]; then
    echo "Error: Body file '$BODY_FILE' not found"
    exit 1
fi

# Load configuration
REQUIRE_GITHUB_CONFIG=true
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config-loader.sh"

# Validate configuration
if ! validate_github_config; then
    echo "Error: Invalid or missing GitHub configuration" >&2
    exit 1
fi

# Use configuration values
OWNER="$REPO_OWNER"
PROJECT_ID="$PROJECT_ID"
FIELD_ID="$STATUS_FIELD_ID"
DEV_READY_ID="$DEV_READY_OPTION_ID"

echo "Creating issue..."
ISSUE_URL=$(gh issue create --title "$TITLE" --body-file "$BODY_FILE" --assignee @me)
ISSUE_NUMBER=$(echo $ISSUE_URL | grep -o '[0-9]*$')
echo "Created issue #$ISSUE_NUMBER"

echo "Adding to $PROJECT_NAME project..."
gh issue edit $ISSUE_NUMBER --add-project "$PROJECT_NAME"

echo "Getting project item ID..."
sleep 2  # Give GitHub time to process
ITEM_ID=$(gh project item-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r ".items[] | select(.content.number==$ISSUE_NUMBER) | .id")

if [ -z "$ITEM_ID" ]; then
    echo "Error: Could not find project item ID"
    exit 1
fi

echo "Setting status to Dev Ready..."
cat > /tmp/update_status.graphql << EOF
mutation {
  updateProjectV2ItemFieldValue(
    input: {
      projectId: "$PROJECT_ID"
      itemId: "$ITEM_ID"
      fieldId: "$FIELD_ID"
      value: {
        singleSelectOptionId: "$DEV_READY_ID"
      }
    }
  ) {
    projectV2Item {
      id
    }
  }
}
EOF

gh api graphql -F query=@/tmp/update_status.graphql
rm /tmp/update_status.graphql

echo "Done! Issue #$ISSUE_NUMBER is now in Dev Ready status"
echo "URL: $ISSUE_URL"