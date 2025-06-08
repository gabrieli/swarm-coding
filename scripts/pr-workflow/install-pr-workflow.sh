#!/bin/bash
# Installation script for Project PR Workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "🚀 Installing Project PR Workflow..."
echo ""

# 1. Create git alias for post-push hook
echo "Creating git aliases..."
git config alias.push-validate '!git push "$@" && $GIT_DIR/../scripts/pr-workflow/post-push-hook.sh'
git config alias.pr-create '!$GIT_DIR/../scripts/pr-workflow/create-pr.sh'

# 2. Create symlinks for easier access
echo "Creating command shortcuts..."
mkdir -p "$HOME/.local/bin"

# Create wrapper scripts
cat > "$HOME/.local/bin/pr-swarm" <<EOF
#!/bin/bash
exec "$PROJECT_ROOT/scripts/pr-workflow/create-pr.sh" "\$@"
EOF

chmod +x "$HOME/.local/bin/pr-swarm"

# 3. Set up environment variables
echo "Setting up environment..."
SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]]; then
    # Check if already configured
    if ! grep -q "PROJECT_PR_WORKFLOW" "$SHELL_RC"; then
        cat >> "$SHELL_RC" <<EOF

# Project PR Workflow Configuration
export PROJECT_PR_ASYNC=true              # Run post-push validation asynchronously
export PROJECT_PR_NOTIFY=desktop          # Notification method: desktop, terminal, none
export PROJECT_PR_VALIDATION_MODE=full    # Default validation mode: full, incremental, quick
EOF
        echo -e "${GREEN}✓${NC} Added configuration to $SHELL_RC"
    fi
fi

# 4. Create cache directory
mkdir -p "$HOME/.project-pr-cache"

# 5. Display instructions
echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "📝 Usage Instructions:"
echo ""
echo "1. Create PRs using the wrapper:"
echo "   ${YELLOW}pr-swarm${NC}                    # Interactive PR creation with full validation"
echo "   ${YELLOW}pr-swarm --mode quick${NC}       # Quick validation mode"
echo "   ${YELLOW}pr-swarm --draft${NC}            # Create draft PR"
echo ""
echo "2. Or use the git alias:"
echo "   ${YELLOW}git pr-create${NC}               # Same as pr-swarm"
echo ""
echo "3. Push with automatic validation:"
echo "   ${YELLOW}git push-validate${NC}           # Push and validate if PR exists"
echo ""
echo "4. Configure validation behavior:"
echo "   Edit ~/.project-pr-cache/config.yml or set environment variables:"
echo "   - PROJECT_PR_ASYNC (true/false)"
echo "   - PROJECT_PR_NOTIFY (desktop/terminal/none)"
echo "   - PROJECT_PR_VALIDATION_MODE (full/incremental/quick)"
echo ""
echo "⚠️  Important: Always use 'pr-swarm' or 'git pr-create' to create PRs!"
echo ""
echo "Need to add $HOME/.local/bin to your PATH? Add this to your shell config:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""