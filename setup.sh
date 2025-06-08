#!/bin/bash
# Setup script for Swarm Coding project
# This script helps users configure the project for their environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
CONFIG_EXAMPLE="$SCRIPT_DIR/config.example.json"

echo ""
echo "🚀 Swarm Coding Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error:${NC} jq is required but not installed."
    echo "Please install jq to continue:"
    echo "  macOS: brew install jq"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  RHEL/CentOS: sudo yum install jq"
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error:${NC} GitHub CLI (gh) is required but not installed."
    echo "Please install gh to continue:"
    echo "  macOS: brew install gh"
    echo "  Ubuntu/Debian: sudo apt-get install gh"
    echo "  Or visit: https://cli.github.com/"
    exit 1
fi

# Check if config.json already exists
if [[ -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}Warning:${NC} config.json already exists."
    read -p "Do you want to overwrite it? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Copy example config
cp "$CONFIG_EXAMPLE" "$CONFIG_FILE"
echo -e "${GREEN}✓${NC} Created config.json from example"

# Interactive configuration
echo ""
echo "Let's configure your GitHub settings:"
echo ""

# Get GitHub username
read -p "GitHub username/organization: " github_owner
jq ".github.owner = \"$github_owner\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

# Get repository name
read -p "Repository name: " repo_name
jq ".github.repository = \"$repo_name\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

# Ask about GitHub Project configuration
echo ""
read -p "Do you use GitHub Projects? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "GitHub Project Configuration"
    echo "----------------------------"
    
    # Get project name
    read -p "Project name: " project_name
    jq ".github.project.name = \"$project_name\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    
    echo ""
    echo "To find your project ID and field IDs:"
    echo "1. First, let's list your projects..."
    echo ""
    
    # Try to list projects
    if gh auth status &>/dev/null; then
        echo "Available projects for $github_owner/$repo_name:"
        gh project list --owner "$github_owner" --format json | jq -r '.projects[] | "  - \(.title) (number: \(.number))"'
        
        echo ""
        read -p "Project number: " project_number
        jq ".github.project.number = $project_number" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        echo ""
        echo "To get the remaining IDs, you'll need to run this GraphQL query:"
        echo ""
        echo "gh api graphql -f query='{"
        echo "  organization(login: \"$github_owner\") {"
        echo "    projectV2(number: $project_number) {"
        echo "      id"
        echo "      fields(first: 20) {"
        echo "        nodes {"
        echo "          ... on ProjectV2Field {"
        echo "            id"
        echo "            name"
        echo "          }"
        echo "          ... on ProjectV2SingleSelectField {"
        echo "            id"
        echo "            name"
        echo "            options {"
        echo "              id"
        echo "              name"
        echo "            }"
        echo "          }"
        echo "        }"
        echo "      }"
        echo "    }"
        echo "  }"
        echo "}'"
        echo ""
        echo "Copy the output and update config.json with the appropriate IDs."
        echo "(You can do this later)"
    else
        echo -e "${YELLOW}Warning:${NC} Not authenticated with GitHub CLI."
        echo "Run 'gh auth login' to authenticate and get project information."
    fi
else
    # Clear project configuration
    jq '.github.project = {}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
fi

# PR Workflow configuration
echo ""
echo "PR Workflow Configuration"
echo "------------------------"

read -p "Default base branch [main]: " base_branch
base_branch=${base_branch:-main}
jq ".pr_workflow.default_base_branch = \"$base_branch\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo ""
echo "Validation modes:"
echo "  - full: Run all tests and validations"
echo "  - incremental: Only test changed files"
echo "  - quick: Minimal validation"
read -p "Default validation mode [full]: " validation_mode
validation_mode=${validation_mode:-full}
jq ".pr_workflow.validation.default_mode = \"$validation_mode\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

# Editor configuration
echo ""
read -p "Preferred editor [vim]: " editor
editor=${editor:-vim}
jq ".editor = \"$editor\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

# Make scripts executable
echo ""
echo -e "${BLUE}ℹ${NC} Making scripts executable..."
find "$SCRIPT_DIR/scripts" -name "*.sh" -type f -exec chmod +x {} \;

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Configuration saved to: $CONFIG_FILE"
echo ""
echo "Next steps:"
echo "1. Review and update $CONFIG_FILE if needed"
echo "2. If using GitHub Projects, update the project IDs in config.json"
echo "3. Run scripts from the scripts/ directory"
echo ""
echo "Example usage:"
echo "  ./scripts/github/manage_project_items.sh --help"
echo "  ./scripts/pr-workflow/create-pr.sh"
echo ""