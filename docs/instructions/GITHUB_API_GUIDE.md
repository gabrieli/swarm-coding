# GitHub API Guide for Epic and User Story Management

## Quick Reference Commands

### 1. Create Issues
```bash
# Create Epic
gh issue create --repo <github-username>/<repo-name> \
  --title "Epic: [Name]" \
  --body-file epic_content.md

# Create User Story
gh issue create --repo <github-username>/<repo-name> \
  --title "Story: [Name]" \
  --body-file story_content.md
```

### 1a. Link Sub-Issues to Epic
```bash
# Get issue IDs
EPIC_ID=$(gh issue view 1 --repo <github-username>/<repo-name> --json id -q .id)
STORY_ID=$(gh issue view 2 --repo <github-username>/<repo-name> --json id -q .id)

# Add as sub-issue via GraphQL
gh api graphql -f query='
mutation {
  addSubIssue(input: {
    issueId: "'$EPIC_ID'",
    subIssueId: "'$STORY_ID'"
  }) {
    subIssue { title }
  }
}'
```

### 2. Add Issues to Project
```bash
# CORRECT METHOD - Use project item-add
gh project item-add 1 --owner <github-username> \
  --url https://github.com/<github-username>/<repo-name>/issues/[NUMBER]

# WRONG METHOD - Don't use issue edit
# gh issue edit [NUMBER] --add-project "Project Name"  # This often fails
```

### 3. Update Project Fields

#### Set Work Item Type
```bash
# First, get the field and option IDs
gh project field-list 1 --owner <github-username> --format json | \
  jq '.fields[] | select(.name == "Work Item Type")'

# Then update the field
gh project item-edit \
  --project-id <project-id> \
  --id [ITEM_ID] \
  --field-id [FIELD_ID] \
  --single-select-option-id [OPTION_ID]
```

### 4. Get Project Item IDs
```bash
# List all items with their IDs
gh project item-list 1 --owner <github-username> --format json | \
  jq '.items[] | {id, number: .content.number, title}'
```

## Step-by-Step Workflow

### Phase 1: Create Issues
1. Create epic issue first
2. Create user story issues
3. Link stories to epic using issue numbers in body

### Phase 2: Add to Project
```bash
# Add each issue to project
gh project item-add 1 --owner <github-username> \
  --url https://github.com/<github-username>/<repo-name>/issues/2
```

### Phase 3: Set Field Values
```bash
# Get field IDs once
WORK_TYPE_FIELD=$(gh project field-list 1 --owner <github-username> --format json | \
  jq -r '.fields[] | select(.name == "Work Item Type") | .id')

USER_STORY_OPTION=$(gh project field-list 1 --owner <github-username> --format json | \
  jq -r '.fields[] | select(.name == "Work Item Type") | .options[] | select(.name == "User Story") | .id')

# Update each story
gh project item-edit \
  --project-id <project-id> \
  --id [ITEM_ID] \
  --field-id $WORK_TYPE_FIELD \
  --single-select-option-id $USER_STORY_OPTION
```

## Important Notes

### API Limitations
- **Parent Issue Field**: Use sub-issues API, not project field
- **Project Names**: Use project number (1) not name ("Your Project Name")  
- **Field Names**: Case-sensitive ("Work Item Type" not "work item type")

### Common Pitfalls
1. **Don't use** `gh issue edit --add-project`
2. **Don't try** to set parent issue field via API
3. **Always check** field names are exact matches
4. **Use project number** not project name

### Debugging Commands
```bash
# Check authentication scopes
gh auth status

# List available fields
gh project field-list 1 --owner <github-username>

# Check item details
gh project item-list 1 --owner <github-username> --format json | jq

# View specific issue fields
gh issue view [NUMBER] --repo <github-username>/<repo-name> --json projectItems
```

## Template Script

```bash
#!/bin/bash
# Create and configure epic with stories

# Variables
OWNER="<github-username>"
REPO="<repo-name>"
PROJECT_NUM="1"

# Create epic
EPIC_URL=$(gh issue create --repo $OWNER/$REPO \
  --title "Epic: $1" \
  --body-file epic.md)
EPIC_NUM=$(echo $EPIC_URL | grep -o '[0-9]*$')

# Create stories and add to project
for story in story1.md story2.md story3.md; do
  # Create story
  STORY_URL=$(gh issue create --repo $OWNER/$REPO \
    --title "Story: $(basename $story .md)" \
    --body-file $story)
  
  # Add to project
  gh project item-add $PROJECT_NUM --owner $OWNER --url $STORY_URL
  
  # Get item ID
  STORY_NUM=$(echo $STORY_URL | grep -o '[0-9]*$')
  ITEM_ID=$(gh project item-list $PROJECT_NUM --owner $OWNER --format json | \
    jq -r ".items[] | select(.content.number == $STORY_NUM) | .id")
  
  # Set work item type
  gh project item-edit \
    --project-id <project-id> \
    --id $ITEM_ID \
    --field-id <work-item-type-field-id> \
    --single-select-option-id <user-story-option-id>
done
```

## Quick Checklist

- [ ] Create issues with proper titles and bodies
- [ ] Add issues to project using `project item-add`
- [ ] Get item IDs from `project item-list`
- [ ] Update Work Item Type using `project item-edit`
- [ ] Set Parent issue manually in UI
- [ ] Verify all fields are set correctly