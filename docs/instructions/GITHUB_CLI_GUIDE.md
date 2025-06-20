# GitHub CLI Guide for Your Project

This guide provides examples and documentation for common GitHub operations to avoid errors.

## GitHub CLI Documentation
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub GraphQL API](https://docs.github.com/en/graphql)
- [GitHub Projects API](https://docs.github.com/en/graphql/reference/objects#projectv2)

## Common Operations

### 1. Create an Issue
```bash
gh issue create --title "Title" --body "Body" --assignee @me
```

### 2. Update Issue Body
```bash
# Use escape sequences for special characters
gh issue edit <number> --body "Updated body with \`code\` blocks"
```

### 3. Add Issue to Project
```bash
gh issue edit <number> --add-project "Project Name"
```

### 4. Find Project ID
```bash
gh project list --owner <username>
# Output: NUMBER  TITLE       STATE   ID
# Example: 1       Your Project  open    <project-id>
```

### 5. Get Project Field Information
```bash
# Create a GraphQL query file first
cat > get_project_fields.graphql << 'EOF'
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
EOF

# Execute the query
gh api graphql -F query=@get_project_fields.graphql -f project="PROJECT_ID"
```

### 6. Update Issue Status in Project
```bash
# First, get the project item ID for the issue
gh project item-list <project-number> --owner <username> --format json | jq '.items[] | select(.content.number==<issue-number>) | .id'

# Create update mutation
cat > update_status.graphql << 'EOF'
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
EOF

# Execute the update
gh api graphql -F query=@update_status.graphql \
  -f projectId="PROJECT_ID" \
  -f itemId="ITEM_ID" \
  -f fieldId="FIELD_ID" \
  -f optionId="OPTION_ID"
```

## Your Project Specific IDs

### Project Information
- **Project Name**: <project-name>
- **Project Number**: 1
- **Project ID**: <project-id>
- **Owner**: <github-username>

### Status Field
- **Field ID**: <status-field-id>
- **Status Options**:
  - Backlog: `<backlog-status-id>`
  - PM Refined: `<pm-refined-status-id>`
  - Dev Ready: `<dev-ready-status-id>`
  - In progress: `<in-progress-status-id>`
  - In review: `<in-review-status-id>`
  - Done: `<done-status-id>`

## Common Workflow: Create Issue and Set to Dev Ready

```bash
# 1. Create the issue
ISSUE_URL=$(gh issue create --title "Title" --body "Body" --assignee @me)
ISSUE_NUMBER=$(echo $ISSUE_URL | grep -o '[0-9]*$')

# 2. Add to Your Project
gh issue edit $ISSUE_NUMBER --add-project "<project-name>"

# 3. Get the project item ID
ITEM_ID=$(gh project item-list 1 --owner <github-username> --format json | jq -r '.items[] | select(.content.number=='$ISSUE_NUMBER') | .id')

# 4. Update status to Dev Ready
cat > update_to_dev_ready.graphql << 'EOF'
mutation {
  updateProjectV2ItemFieldValue(
    input: {
      projectId: "<project-id>"
      itemId: "REPLACE_ITEM_ID"
      fieldId: "<status-field-id>"
      value: {
        singleSelectOptionId: "<dev-ready-status-id>"
      }
    }
  ) {
    projectV2Item {
      id
    }
  }
}
EOF

# Replace the ITEM_ID placeholder
sed -i '' "s/REPLACE_ITEM_ID/$ITEM_ID/" update_to_dev_ready.graphql

# Execute
gh api graphql -F query=@update_to_dev_ready.graphql
```

## Error Prevention Tips

1. **Special Characters in Issue Bodies**
   - Use triple backticks for code blocks
   - Escape special characters when needed
   - Consider using files for complex content

2. **GraphQL Queries**
   - Always use external files for complex queries
   - Test queries in GitHub GraphQL Explorer first
   - Use proper variable substitution

3. **Project Commands**
   - Use project number (not name) for item-list
   - Include owner flag when needed
   - Parse JSON output with jq for precision

## Useful Aliases

Add these to your shell profile:

```bash
# Create issue in Dev Ready state
alias gh-create-dev-ready='function _create() {
  ISSUE_URL=$(gh issue create --title "$1" --body "$2" --assignee @me)
  ISSUE_NUMBER=$(echo $ISSUE_URL | grep -o "[0-9]*$")
  gh issue edit $ISSUE_NUMBER --add-project "<project-name>"
  # ... (add status update logic)
}; _create'
```

## Documentation Links
- [GitHub CLI Issue Commands](https://cli.github.com/manual/gh_issue)
- [GitHub CLI Project Commands](https://cli.github.com/manual/gh_project)
- [GitHub GraphQL API Explorer](https://docs.github.com/en/graphql/overview/explorer)
- [ProjectV2 GraphQL Reference](https://docs.github.com/en/graphql/reference/objects#projectv2)
- [Mutations Reference](https://docs.github.com/en/graphql/reference/mutations)

## Debugging Tips
- Use `--jq` for JSON filtering
- Add `--verbose` flag for debugging
- Check rate limits with `gh api rate_limit`
- Test GraphQL queries in the explorer first