# GitHub Quick Reference for Pulse Project

## Common Commands

### Create Issue in Dev Ready Status
```bash
# Option 1: Use the script
./scripts/create_dev_ready_issue.sh "Issue Title" body.md

# Option 2: Manual steps
ISSUE_URL=$(gh issue create --title "Title" --body "Body" --assignee @me)
ISSUE_NUMBER=$(echo $ISSUE_URL | grep -o '[0-9]*$')
gh issue edit $ISSUE_NUMBER --add-project "Pulse Menu"
# Then update status (see full guide)
```

### Update Issue Status
```bash
# Get item ID
ITEM_ID=$(gh project item-list 1 --owner gabrieli --format json | jq -r '.items[] | select(.content.number==14) | .id')

# Update to Dev Ready
gh api graphql -F query=@update_status.graphql \
  -f projectId="PVT_kwHOACofRM4A5PeM" \
  -f itemId="$ITEM_ID" \
  -f fieldId="PVTSSF_lAHOACofRM4A5PeMzguEr8I" \
  -f optionId="61e4505c"
```

### View Project Items
```bash
gh project item-list 1 --owner gabrieli --format json | jq '.items[] | {number: .content.number, title: .content.title, status: .fieldValues.Status}'
```

## Project Constants
- **Project ID**: PVT_kwHOACofRM4A5PeM
- **Status Field ID**: PVTSSF_lAHOACofRM4A5PeMzguEr8I
- **Dev Ready Option**: 61e4505c

## GraphQL Templates

### Update Status Template
```graphql
mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
  updateProjectV2ItemFieldValue(
    input: {
      projectId: $projectId
      itemId: $itemId
      fieldId: $fieldId
      value: {
        singleSelectOptionId: $optionId
      }
    }
  ) {
    projectV2Item {
      id
    }
  }
}
```

### Get Fields Template
```graphql
query($project: ID!) {
  node(id: $project) {
    ... on ProjectV2 {
      fields(first: 20) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
            options {
              id
              name
            }
          }
        }
      }
    }
  }
}
```

## Error Solutions

### "Expected VAR_SIGN" Error
- Use external files for GraphQL queries
- Don't use inline multi-line strings

### "Invalid number" Error
- Use project number (1) not name ("Pulse Menu")
- Include --owner flag

### Special Characters in Body
- Use --body-file for complex content
- Escape backticks in inline content

## Full Documentation
- See `GITHUB_CLI_GUIDE.md` for complete guide
- See `GITHUB_WORKFLOW.md` for workflow details