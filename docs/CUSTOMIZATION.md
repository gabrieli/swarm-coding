# Customization Guide for Swarm Coding

This guide helps you customize the Swarm Coding methodology for your specific project needs.

## Overview

Swarm Coding is a flexible methodology that can be adapted to various technology stacks, team sizes, and project types. This guide walks through the key areas you'll need to customize.

## 1. Placeholder Replacement

Throughout the documentation, you'll find placeholders in angle brackets that need to be replaced with your project-specific values:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `<github-username>` | Your GitHub username | `johndoe` |
| `<repo-name>` | Your repository name | `my-awesome-app` |
| `<project-name>` | Your project name | `My Awesome App` |
| `<org-name>` | Your GitHub organization | `acme-corp` |
| `<project-number>` | GitHub Project board number | `42` |
| `<status-field-id>` | Project field ID for status | `PVTF_123...` |
| `<work-item-type-field-id>` | Project field ID for work item type | `PVTF_456...` |

### Finding GitHub Project Field IDs

Use the GraphQL queries in `scripts/github/` to find your project field IDs:
```bash
gh api graphql -f query=@scripts/github/get_project_fields.graphql
```

## 2. Workflow Status Configuration

The default workflow uses these statuses, but you can customize them:

### Default Statuses
1. **Backlog** - Unrefined ideas
2. **PM Refined** - Requirements defined
3. **Dev Ready** - Technical design complete
4. **In Progress** - Active development
5. **In Review** - Under review
6. **Done** - Complete

### Customizing Statuses

1. Update your GitHub Project board with your preferred statuses
2. Update the status references in:
   - `docs/instructions/STATUS_WORKFLOW.md`
   - `scripts/github/project_config.sh`
   - Role documentation as needed

3. Map your statuses to roles:
```markdown
| Your Status | Role Responsible | Description |
|-------------|-----------------|-------------|
| Planning | Product Manager | Initial planning |
| Design | Architect | Technical design |
| Development | Developer | Implementation |
| Review | Review Team | Quality checks |
| Complete | All | Finished |
```

## 3. Technology Stack Modules

### Using Technology Modules

For specific technology stacks, check the `docs/modules/` directory:
- `kotlin-multiplatform.md` - For Kotlin Multiplatform projects
- Add your own modules as needed

### Creating a New Module

Create `docs/modules/your-technology.md`:
```markdown
# [Technology] Module

## Overview
Specific guidance for [Technology] projects.

## Architecture
[Technology-specific architecture patterns]

## Testing Setup
[Technology-specific test configuration]

## Known Issues
[Common issues and workarounds]
```

## 4. Platform Customization

### Supported Platforms

The documentation uses generic platform references. Map these to your platforms:

| Generic Term | Your Platform |
|--------------|---------------|
| Platform A | iOS / Web / Desktop |
| Platform B | Android / Mobile Web |
| Core/Shared | Backend / Shared Library |

### Platform-Specific Sections

When you see sections for "Mobile Platforms" or "Web Platforms", adapt them to your specific platforms:
- Mobile → iOS, Android, React Native
- Web → React, Angular, Vue
- Desktop → Electron, Native

## 5. Tool Configuration

### Development Tools

Replace generic tool references with your specific tools:

| Generic Reference | Your Tools |
|-------------------|------------|
| Build system | Gradle, Maven, npm, etc. |
| Test framework | JUnit, Jest, XCTest, etc. |
| CI/CD system | GitHub Actions, Jenkins, etc. |
| Package manager | npm, pip, CocoaPods, etc. |

### External Services

Configure external services mentioned in documentation:
1. Replace generic service references with your services
2. Update environment variable names
3. Document service-specific setup in your README

## 6. Review Process Customization

### Review Types

The default review types can be customized based on your needs:
- Architecture Review - Always recommended
- Security Review - Essential for user data handling
- Testing Review - Critical for quality
- Documentation Review - Important for maintenance
- DevOps Review - For deployment concerns
- UX Review - For user-facing changes

### Enabling/Disabling Reviews

In your pre-commit hooks or CI configuration:
```bash
# Enable only the reviews you need
ENABLE_ARCHITECTURE_REVIEW=true
ENABLE_SECURITY_REVIEW=true
ENABLE_TESTING_REVIEW=true
ENABLE_DOCUMENTATION_REVIEW=false  # Optional
ENABLE_DEVOPS_REVIEW=false         # Optional
ENABLE_UX_REVIEW=false              # Optional
```

## 7. Scripts and Automation

### Customizing Scripts

The `scripts/` directory contains automation tools:

1. **PR Workflow Scripts**: Update paths and commands in:
   - `scripts/pr-workflow/create-pr.sh`
   - `scripts/lib/config-loader.sh`

2. **GitHub Integration**: Configure in:
   - `scripts/github/project_config.sh`
   - Update GraphQL queries for your schema

3. **Review Aggregation**: Modify review weights in:
   - `scripts/aggregate-reviews.py`

## 8. Testing Configuration

### Test Categories

Customize test categories for your project:
```bash
# In your test runner configuration
TEST_CATEGORIES="unit integration e2e performance"
```

### Coverage Requirements

Set your coverage thresholds:
```yaml
# Example configuration
coverage:
  unit: 80%
  integration: 70%
  overall: 75%
```

## 9. Creating Your Configuration File

Use the **[Project Configuration Template](templates/PROJECT_CONFIG_TEMPLATE.json)** as a starting point for your project configuration.

Copy the template to your project root as `config.json` or `swarm-config.json` and customize it with your specific values.

The template includes all available configuration options with detailed structure for:
- Project metadata
- GitHub integration
- Workflow customization
- Testing setup
- Tool specifications
- Environment definitions
- Team information

## 10. Quick Start Checklist

- [ ] Replace all placeholders with your values
- [ ] Configure GitHub Project board with your statuses
- [ ] Set up project field IDs in scripts
- [ ] Choose applicable technology modules
- [ ] Map generic platform references to your platforms
- [ ] Configure review types for your needs
- [ ] Update tool references
- [ ] Create `swarm-config.json`
- [ ] Test automation scripts
- [ ] Update team documentation

## Getting Help

- Review example configurations in released projects
- Check technology-specific modules in `docs/modules/`
- Contribute your customizations back to help others