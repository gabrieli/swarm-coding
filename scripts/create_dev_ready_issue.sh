#!/bin/bash
# Script to create a GitHub issue and set it to Dev Ready status in Pulse Menu project

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

# Project constants
PROJECT_ID="PVT_kwHOACofRM4A5PeM"
FIELD_ID="PVTSSF_lAHOACofRM4A5PeMzguEr8I"
DEV_READY_ID="61e4505c"
OWNER="gabrieli"
PROJECT_NUMBER="1"

echo "Creating issue..."
ISSUE_URL=$(gh issue create --title "$TITLE" --body-file "$BODY_FILE" --assignee @me)
ISSUE_NUMBER=$(echo $ISSUE_URL | grep -o '[0-9]*$')
echo "Created issue #$ISSUE_NUMBER"

echo "Adding to Pulse Menu project..."
gh issue edit $ISSUE_NUMBER --add-project "Pulse Menu"

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