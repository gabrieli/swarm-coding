# GitHub Project Management Scripts

This directory contains scripts and GraphQL queries for automating GitHub project board operations.

## Main Script: `manage_project_items.sh`

A comprehensive script for managing project board items, based on common architect workflows.

### Prerequisites

- GitHub CLI (`gh`) installed and authenticated

### Usage

```bash
# Make script executable (one-time setup)
chmod +x scripts/github/manage_project_items.sh

# Set up an epic with sub-issues
./scripts/github/manage_project_items.sh setup-epic 17 18 19 20 21 22 23

# Set up user stories linked to an epic  
./scripts/github/manage_project_items.sh setup-stories 17 18 19 20 21 22 23

# Set individual issue properties
./scripts/github/manage_project_items.sh set-dev-ready 18
./scripts/github/manage_project_items.sh set-epic 17
./scripts/github/manage_project_items.sh set-user-story 18

# Add issue to project board
./scripts/github/manage_project_items.sh add-to-project 25

# View all project fields and options
./scripts/github/manage_project_items.sh get-fields
```

### Common Workflows

#### Setting up a new Epic with User Stories

1. Create epic and user story issues manually
2. Run the epic setup:
   ```bash
   ./scripts/github/manage_project_items.sh setup-epic 17 18 19 20 21 22 23
   ```
3. This will:
   - Set epic work item type to "Epic"
   - Set epic status to "Dev Ready"
   - Add task list to epic body with checkboxes for all sub-issues

4. Set up the user stories:
   ```bash
   ./scripts/github/manage_project_items.sh setup-stories 17 18 19 20 21 22 23
   ```
5. This will:
   - Add all issues to project board
   - Set work item types to "User Story"
   - Set statuses to "Dev Ready"
   - Add comments linking back to epic

## Configuration

Edit `project_config.sh` to update project IDs and field mappings when project structure changes.

### Updating Configuration

1. Get current project fields:
   ```bash
   ./scripts/github/manage_project_items.sh get-fields
   ```

2. Copy the relevant field IDs and option IDs to `project_config.sh`

## GraphQL Queries

### Individual Query Files

- `get_project_fields.graphql` - Get all project fields and options
- `get_issue_project_item.graphql` - Get project item ID for an issue
- `set_work_item_type.graphql` - Set work item type (Epic/User Story)
- `update_item_status.graphql` - Update issue status

### Legacy Files

- `set_parent.graphql` / `set_parent.json` - ❌ Not functional (parent_issue field not supported)
- `update_to_in_progress.graphql` - ✅ Works (same as update_item_status.graphql)
- `update_project_status.graphql` - ✅ Query only (same as get_project_fields.graphql)

## Architecture Patterns

These scripts implement the proven patterns from successful architect workflows:

### Epic Management
- Epics include discovery content in issue body
- Task lists with checkboxes for automatic progress tracking
- Proper work item type classification

### User Story Linking  
- Sub-issues linked via comments (GitHub's supported method)
- All issues properly categorized and in project board
- Clear status progression through development lifecycle

### Batch Operations
- Efficient handling of multiple related issues
- Consistent application of project board standards
- Reduced manual overhead for common operations

## Troubleshooting

### Common Issues

1. **"Issue not found in project"**
   - Ensure issue is added to project board first
   - Use `add-to-project` command before other operations

2. **Permission errors**
   - Ensure GitHub CLI is authenticated: `gh auth status`
   - Verify project access permissions

3. **Field ID errors**
   - Project structure may have changed
   - Run `get-fields` and update `project_config.sh`

### Debug Mode

Set `set -x` at the top of the script to see detailed execution steps.

## Integration with Architect Role

These scripts automate the GitHub integration requirements from `ROLE_ARCHITECT.md`:

- ✅ Set work item types appropriately (Epic/User Story)  
- ✅ Set status to Dev Ready when complete
- ✅ Create task list in epic linking sub-issues
- ✅ Ensure proper parent-child relationships are visible