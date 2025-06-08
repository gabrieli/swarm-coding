#!/bin/bash

# GitHub Project Configuration
# This script loads configuration from config.json

# Set requirement flag and load configuration
REQUIRE_GITHUB_CONFIG=true
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/config-loader.sh"

# Validate that we have the required GitHub configuration
if ! validate_github_config; then
    echo "Error: Invalid or missing GitHub configuration" >&2
    echo "Please check your config.json file" >&2
    exit 1
fi

# Display loaded configuration (only if running directly)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Project configuration loaded for: $REPO_OWNER/$REPO_NAME"
    echo ""
    echo "To view field IDs for your project, run:"
    echo "gh api graphql -f query=\"\$(cat $SCRIPT_DIR/get_project_fields.graphql)\" -f projectId=\$PROJECT_ID"
fi