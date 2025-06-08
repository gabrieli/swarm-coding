# 🐝 Swarm Coding

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Issues](https://img.shields.io/github/issues/yourusername/swarm-coding)](https://github.com/yourusername/swarm-coding/issues)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/yourusername/swarm-coding/pulls)

A comprehensive development workflow framework that leverages AI-powered role simulation to ensure high-quality software delivery through structured planning, implementation, and review processes.

## 🎯 Overview

Swarm Coding transforms the solo development experience by simulating a full development team through AI personas. Each role follows industry best practices and maintains specific quality principles, creating a robust feedback loop that catches issues early and ensures code quality.

### Why Swarm Coding?

- **Structured Workflow**: Move from chaotic development to organized, predictable delivery
- **Quality First**: Every role has built-in quality gates and review processes
- **Best Practices**: Incorporates TDD, SOLID principles, and security-first thinking
- **Comprehensive Documentation**: Every decision and implementation is well-documented
- **GitHub Integration**: Seamless workflow with issues, projects, and pull requests

## ✨ Key Features

- 🎭 **5 Specialized Development Roles**: PM, Architect, Developer, Security Expert, and QA Tester
- 🔍 **6 Comprehensive Review Roles**: Architecture, Security, Testing, Documentation, DevOps, and UX
- 📋 **Structured Workflow Pipeline**: Clear progression from ideation to deployment
- 🔒 **Security-First Approach**: Built-in security reviews and vulnerability scanning
- 🧪 **Test-Driven Development**: Comprehensive testing at every stage
- 📊 **GitHub Project Integration**: Full kanban board workflow with automated status updates
- 🤖 **AI-Powered Code Reviews**: Intelligent analysis of architecture, security, and code quality
- 🚀 **Automated PR Workflow**: Smart validation and review before pull request creation

## 🚀 Quick Start

### Prerequisites

- Git
- GitHub CLI (`gh`) authenticated
- Bash shell (macOS/Linux)
- AI assistant with access to the role instructions and CLAUDE.md

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/swarm-coding.git
cd swarm-coding
```

2. Install the PR workflow (optional):
```bash
./scripts/pr-workflow/install-pr-workflow.sh
```

3. Configure GitHub project settings:
```bash
# Edit project configuration
vim scripts/github/project_config.sh

# Get your project field IDs
./scripts/github/manage_project_items.sh get-fields
```

### Basic Workflow

1. **Start with Product Management**:
```bash
# Create an epic
gh issue create --title "Epic: New Feature" --label "epic"

# AI uses PM role to refine requirements
# Reference: docs/dev-roles/ROLE_PM.md
```

2. **Technical Architecture**:
```bash
# AI uses Architect role to design solution
# Updates issues to "Dev Ready" status
./scripts/github/manage_project_items.sh set-dev-ready [issue-number]
```

3. **Implementation**:
```bash
# Developer picks up "Dev Ready" issues
# Implements with TDD approach
# Creates PR when complete
./scripts/pr-workflow/create-pr.sh
```

## 📚 Available Roles

### Development Roles

#### 🎯 Product Manager (`ROLE_PM.md`)
- Gathers requirements and defines user stories
- Creates epics with clear business value
- Prioritizes backlog based on user needs
- **Quality Principle**: User-centric, clarity first

#### 🏗️ Technical Architect (`ROLE_ARCHITECT.md`)
- Converts user stories into technical designs
- Ensures scalability and maintainability
- Reviews code for architectural compliance
- **Quality Principle**: No shortcuts, long-term thinking

#### 💻 Developer (`ROLE_DEVELOPER.md`)
- Implements features using TDD
- Writes clean, functional code
- Creates comprehensive tests
- **Quality Principle**: Craft code with pride

#### 🔒 Security Expert (`ROLE_SECURITY.md`)
- Reviews code for vulnerabilities
- Implements security best practices
- Validates authentication and authorization
- **Quality Principle**: Security is non-negotiable

#### 🧪 QA Tester (`ROLE_TESTER.md`)
- Creates comprehensive test plans
- Executes manual and automated tests
- Validates acceptance criteria
- **Quality Principle**: Quality through verification

### Review Roles

- **Architect Review**: Focus on design patterns and architectural compliance
- **Security Review**: Identify vulnerabilities and security issues
- **Testing Review**: Ensure comprehensive test coverage
- **Documentation Review**: Ensure clarity, completeness, and accuracy of documentation
- **DevOps Review**: Validate CI/CD, infrastructure, and deployment practices
- **UX Review**: Assess user experience, accessibility, and interface design

## 🛠️ Scripts Documentation

### GitHub Project Management

#### `manage_project_items.sh`
Comprehensive tool for managing GitHub project board items.

```bash
# Set up an epic with sub-issues
./scripts/github/manage_project_items.sh setup-epic 17 18 19 20

# Set work item types and statuses
./scripts/github/manage_project_items.sh set-dev-ready 18
./scripts/github/manage_project_items.sh set-epic 17

# View project fields
./scripts/github/manage_project_items.sh get-fields
```

### PR Workflow

#### `create-pr.sh`
Intelligent PR creation with built-in validation.

```bash
# Standard PR with full validation
./scripts/pr-workflow/create-pr.sh

# Quick validation against develop branch
./scripts/pr-workflow/create-pr.sh --base develop --mode quick

# Create draft PR
./scripts/pr-workflow/create-pr.sh --draft
```

Features:
- Runs relevant tests based on changed files
- Performs AI code review on PR scope
- Generates detailed PR descriptions
- Adds appropriate labels

#### `install-pr-workflow.sh`
Sets up the PR workflow in your development environment.

```bash
./scripts/pr-workflow/install-pr-workflow.sh
```

### Utility Scripts

#### `create_dev_ready_issue.sh`
Creates a GitHub issue and immediately sets it to "Dev Ready" status.

```bash
./scripts/create_dev_ready_issue.sh "Issue Title" issue-body.md
```

#### `aggregate-reviews.py`
Aggregates multiple review results into a summary (used by PR workflow).

## ⚙️ Configuration

### Project Configuration

Edit `scripts/github/project_config.sh`:

```bash
# GitHub repository settings
REPO_OWNER="your-org"
REPO_NAME="your-repo"

# Project board settings
PROJECT_NUMBER="1"
PROJECT_NAME="Your Project"
PROJECT_ID="PVT_xxxxxxxxxxxx"

# Field IDs (get these from manage_project_items.sh get-fields)
STATUS_FIELD_ID="PVTF_xxxxxxxxxxxx"
WORK_ITEM_TYPE_FIELD_ID="PVTF_xxxxxxxxxxxx"
```

### PR Workflow Configuration

Edit `scripts/pr-workflow/.pr-workflow-config`:

```bash
# Validation settings
DEFAULT_VALIDATION_MODE="full"
DEFAULT_BASE_BRANCH="main"

# Label configuration
VALIDATED_LABEL="validation-passed"
VALIDATION_FAILED_LABEL="validation-failed"
MODULE_LABEL_PREFIX="module:"
```

## 📁 Project Structure

```
swarm-coding/
├── docs/
│   ├── dev-roles/          # Development role instructions
│   ├── review-roles/       # Review role specifications
│   ├── instructions/       # Workflow and process guides
│   └── testing/           # Testing documentation
├── scripts/
│   ├── github/            # GitHub integration scripts
│   ├── pr-workflow/       # PR creation and validation
│   └── *.py/*.sh         # Utility scripts
└── LICENSE               # MIT License
```

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Use the Swarm Coding workflow**: All contributions should follow our role-based process
2. **Start with an issue**: Create an issue describing your proposed change
3. **Follow the roles**: Use the appropriate role instructions for each phase
4. **Create quality PRs**: Use our PR workflow script for validation
5. **Be patient**: Reviews follow our comprehensive process

### Development Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Follow the Swarm Coding workflow (PM → Architect → Developer)
4. Run tests and validation: `./scripts/pr-workflow/create-pr.sh`
5. Submit PR with detailed description

### Code Standards

- Follow language-specific best practices
- Write comprehensive tests (TDD preferred)
- Document all public APIs
- Ensure security compliance
- Maintain backward compatibility

## 📖 Documentation

- **[Development Workflow](docs/instructions/DEVELOPMENT_WORKFLOW.md)**: Complete guide to the development process
- **[GitHub Workflow](docs/instructions/GITHUB_WORKFLOW.md)**: How we use GitHub for project management
- **[Testing Guide](docs/testing/README.md)**: Comprehensive testing documentation
- **[Role Guides](docs/dev-roles/)**: Detailed instructions for each role

## 🏆 Best Practices

1. **Always start with PM role** for new features
2. **Never skip the Architect phase** for complex changes
3. **Use TDD** - write tests first
4. **Review thoroughly** - use all applicable review roles
5. **Document decisions** in issues and PRs
6. **Keep PRs small** and focused
7. **Update status regularly** on the project board

## 🐛 Troubleshooting

### Common Issues

**Script permissions**:
```bash
chmod +x scripts/**/*.sh
```

**GitHub CLI authentication**:
```bash
gh auth login
```

**Project field IDs not found**:
```bash
# Get current field IDs
./scripts/github/manage_project_items.sh get-fields
# Update project_config.sh with new IDs
```

## 📊 Metrics and Success

Track your team's performance:
- **Cycle Time**: Time from backlog to done
- **Defect Rate**: Bugs found post-review
- **Test Coverage**: Percentage of code tested
- **Review Turnaround**: Time to complete reviews

## 🙏 Acknowledgments

- Inspired by agile methodologies and XP practices
- Built for developers who value quality
- Powered by AI assistance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
Made with ❤️ by developers, for developers
</p>

<p align="center">
<strong>Remember: Quality is not an act, it's a habit.</strong>
</p>