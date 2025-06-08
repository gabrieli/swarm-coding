# Configuration Guide

This guide explains how to configure the Swarm Coding project for your environment.

## Quick Start

1. Run the setup script:
   ```bash
   ./setup.sh
   ```

2. Follow the interactive prompts to configure your project

3. Review and update `config.json` as needed

## Configuration File Structure

The `config.json` file contains all project configuration:

```json
{
  "github": {
    "owner": "your-github-username",
    "repository": "your-repo-name",
    "project": {
      "name": "Your Project Name",
      "id": "PVT_xxxxxxxxxxxx",
      "number": 1,
      "fields": {
        // Field and option IDs from GitHub Projects
      }
    }
  },
  "pr_workflow": {
    "default_base_branch": "main",
    "validation": {
      "default_mode": "full",
      "async_mode": true,
      "notification_method": "desktop",
      "cache_dir": "~/.swarm-pr-cache"
    },
    "labels": {
      "validated": "validated",
      "validation_failed": "validation-failed",
      "module_prefix": "module:"
    }
  },
  "editor": "vim",
  "notifications": {
    "enabled": true,
    "method": "desktop"
  }
}
```

## Configuration Options

### GitHub Settings

- **owner**: Your GitHub username or organization name
- **repository**: The name of your repository
- **project**: GitHub Projects configuration (optional)
  - **name**: The name of your GitHub Project
  - **id**: The project ID (found via GraphQL query)
  - **number**: The project number (visible in the UI)
  - **fields**: Field IDs and option IDs for project columns

### PR Workflow Settings

- **default_base_branch**: Default branch for PRs (usually "main" or "master")
- **validation**:
  - **default_mode**: Default validation mode ("full", "incremental", or "quick")
  - **async_mode**: Run validations asynchronously (true/false)
  - **notification_method**: How to notify about validation results ("desktop", "terminal", or "none")
  - **cache_dir**: Directory for caching validation results
- **labels**: Label names used by the PR workflow

### General Settings

- **editor**: Default text editor for commit messages and PR descriptions
- **notifications**: Global notification settings

## Environment Variable Fallback

All configuration values can be overridden using environment variables:

- GitHub settings: `GITHUB_OWNER`, `GITHUB_REPOSITORY`, etc.
- PR workflow: `PR_DEFAULT_BASE_BRANCH`, `PR_DEFAULT_VALIDATION_MODE`, etc.

## Finding GitHub Project IDs

To find your GitHub Project IDs:

1. Run the GraphQL query provided by the setup script
2. Look for your project's ID and field IDs in the response
3. Update `config.json` with the appropriate values

Example GraphQL query:
```bash
gh api graphql -f query='{
  organization(login: "YOUR_ORG") {
    projectV2(number: PROJECT_NUMBER) {
      id
      fields(first: 20) {
        nodes {
          ... on ProjectV2Field {
            id
            name
          }
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
}'
```

## Updating Configuration

After initial setup, you can:

1. Edit `config.json` directly
2. Re-run `./setup.sh` to reconfigure
3. Use environment variables to override specific values

## Troubleshooting

### "Configuration file not found"

Make sure you've run `./setup.sh` or copied `config.example.json` to `config.json`.

### "jq is required but not installed"

Install jq using your package manager:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt-get install jq`
- RHEL/CentOS: `sudo yum install jq`

### "Invalid or missing GitHub configuration"

Check that your `config.json` contains valid GitHub owner and repository values.

### Scripts can't find configuration

Make sure you're running scripts from the project root or that `config.json` exists in the project root directory.