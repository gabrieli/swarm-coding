# Development Guidelines for Claude

## Code Style
- Use consistent indentation (spaces or tabs as per project convention)
- Follow naming conventions appropriate to the language
- Add trailing commas in multi-line lists where supported
- Keep line length reasonable (80-120 characters)
- Maintain consistency with existing codebase style

## Development Approach
- Follow light functional programming style:
  - Self-contained functions with clear input/output
  - Minimize side effects
  - Pure functions where possible
  - Compose small functions into larger ones
- Top-down development:
  - Start with the end goal
  - Work backwards to determine required inputs
  - Build components to transform data step by step
- Small iterations:
  - Break features into tiny, testable units
  - Complete one small piece at a time
  - Each iteration should be independently valuable

## Testing (Red-Green-Refactor)
- Strict Test-Driven Development (TDD):
  1. Write the smallest possible failing test
  2. Write minimal code to make it pass
  3. Refactor while keeping tests green
  4. Repeat for next small increment
- Test hierarchy:
  - Unit tests for pure functions (input → output)
  - Integration tests for side effects
  - End-to-end tests for complete flows
- Test what matters:
  - Focus on behavior, not implementation
  - Test public interfaces, not private details
  - Each test should test ONE thing
- Avoid mocks except for external services

## Build and Test Workflow

### When analyzing problems:
1. Start by identifying the exact API/function that needs to be called
2. Work backwards to understand what inputs are required
3. Create small, focused tests for each transformation
4. Build the solution incrementally, one test at a time

### When doing changes:
1. Write a failing test first for the smallest piece of functionality
2. Implement just enough code to make the test pass
3. Verify the test passes before moving to the next piece
4. **CRITICAL**: Always run tests BEFORE declaring work complete
5. **CRITICAL**: Always build and verify BEFORE declaring work complete
6. **CRITICAL**: Always commit your changes after fixing issues
7. **CRITICAL**: WAIT for pre-commit validation to complete (if configured)
8. **CRITICAL**: PROVIDE a summary of pre-commit feedback after PR creation (if applicable)
9. **CRITICAL**: After committing, request re-review as needed
10. **CRITICAL**: Always provide a brief summary (2-3 sentences) of what was done when finishing a task
11. Once testing starts, proactively check logs and fix any issues found
12. Always check that tests are actually testing production scenarios, not mocked behavior
13. **CRITICAL**: When implementing features, verify ALL requirements are met:
    - Parse user request into specific checkable items
    - Test each requirement individually
    - Show actual output/results in your response
    - Never claim completion without verification
    - Be honest about partial implementations

### GitHub Workflow Requirements:
1. **Keep Issues Updated**: Always update the GitHub issue as you progress
   - Move from `Ready` → `In Progress` when starting
   - Add progress comments on the issue
   - Move to `In Review` when PR is created
2. **Iterative Development**:
   - Implement → Commit → Wait for reviews
   - Address ALL feedback → Commit fixes
   - Repeat until approved by all reviewers
3. **Pull Request Management**:
   - Create PR with detailed description
   - Link to issue with "Closes #XX"
   - Move issue to `In Review` immediately after PR creation
   - Monitor and respond to all review comments
   - Keep PR updated until merged

## Documentation
- Add appropriate comments for all public APIs
- Include parameter descriptions and return values
- Document non-obvious behavior
- Keep documentation close to the code

## Testing Documentation
For comprehensive testing guidance, see the testing documentation in the docs/testing/ directory:
- Testing Overview - Complete testing strategy and quick start
- Setup Guide - Environment setup for testing
- Writing Tests - How to write different test types
- Running Tests - Test execution guide
- Best Practices - Testing patterns and anti-patterns
- Test Coverage - Coverage requirements and tools
- Troubleshooting - Common issues and solutions

## Build Verification
- Run appropriate build/test commands before submitting code
- Verify all tests pass
- Check for linting/formatting issues

## Git Workflow
- Create atomic commits with clear messages
- Prefix commit messages with relevant feature/component
- **IMPORTANT**: Do NOT include any automated signatures or co-authorship mentions in commits
- Do NOT add "Generated with Claude Code" or "Co-Authored-By: Claude" to commits
- Keep commit messages clean and professional

## PR Creation and Validation Requirements

### Use Project-Specific PR Workflow
If the project has a custom PR creation workflow, always use it instead of direct commands.
Check for scripts like `pr-create`, `pr-swarm`, or similar in the project's scripts directory.

### Pre-commit Validation
- **CRITICAL**: NEVER use `--no-verify` to bypass pre-commit hooks
- **CRITICAL**: If pre-commit validation fails, FIX THE ISSUES before committing
- **CRITICAL**: Broken builds should NEVER be committed to any branch

### Pre-commit Feedback Summary
After creating a PR with validation, provide a comprehensive summary of all validation feedback:

#### Required Summary Format:
```markdown
## Pre-commit Validation Summary

### Build Results
- ✅/❌ Build status: [status/errors]
- ✅/❌ Test results: [status/failures]
- ✅/❌ Linting: [status/issues]

### Code Review Results (if applicable)
- Architectural Review: [✅ Approved / ❌ Issues found]
- Security Review: [✅ Approved / ❌ Issues found]
- Testing Review: [✅ Approved / ❌ Issues found]
- Documentation Review: [✅ Approved / ❌ Issues found]
- DevOps Review: [✅ Approved / ❌ Issues found]
- UX Review: [✅ Approved / ❌ Issues found]

### Overall Status
- **Total Validation Time**: [X minutes]
- **Issues Found**: [Number and brief description]
- **Actions Taken**: [How issues were addressed]
```

## Security Guidelines
- **NEVER hardcode API keys or secrets in source code**
- All API keys must come from environment files or secure storage
- Use platform-specific secure storage when available
- Create example configuration files with placeholder values
- Never commit files containing real keys to version control

## Implementation Accuracy
- **READ REQUIREMENTS CAREFULLY**: When a user asks for multiple specific things, implement ALL of them
- **VERIFY IMPLEMENTATION**: After implementing changes, verify the output matches what was requested
- **PARTIAL WORK**: If you can't complete all requirements, explicitly state what's done and what's pending

## Development Workflow
We follow a structured process with simulated team roles:
1. **Product Manager** - Requirements gathering and story creation
2. **Technical Architect** - Technical design and task breakdown
3. **Developer** - Implementation following TDD
4. **Security Expert** - Security review and compliance
5. **QA Tester** - Testing and bug reporting

### Using the Workflow
1. Start with PM role to define the epic/feature
2. Progress through each role sequentially
3. Use todo lists to track tasks within each role
4. Document decisions and create appropriate artifacts
5. Follow platform-specific guidelines when applicable

### State Tracking System
Use GitHub Issues and Projects for workflow management:
- Tree structure: Epics → User Stories → Technical Tasks
- Kanban board: Backlog → Ready → In Progress → Review → Testing → Done
- Appropriate labels for roles, status, and types

## Development Guidelines and Principles

* Always read entire files. Otherwise, you don't know what you don't know, and will end up making mistakes, duplicating code that already exists, or misunderstanding the architecture.
* Commit early and often. When working on large tasks, your task could be broken down into multiple logical milestones. After a certain milestone is completed and confirmed to be ok by the user, you should commit it.
* Your internal knowledgebase of libraries might not be up to date. When working with any external library, verify the latest syntax and usage via documentation or web search.
* Do not say things like: "x library isn't working so I will skip it". Generally, it isn't working because you are using the incorrect syntax or patterns.
* Always run linting after making major changes. Otherwise, you won't know if you've corrupted a file or made syntax errors.
* Please organize code into separate files wherever appropriate, and follow general coding best practices about variable naming, modularity, function complexity, file sizes, commenting, etc.
* Code is read more often than it is written, make sure your code is always optimized for readability.
* Unless explicitly asked otherwise, the user never wants you to do a "dummy" implementation of any given task. Just implement the thing.
* Whenever you are starting a new task, it is of utmost importance that you have clarity about the task. You should ask the user follow up questions if you do not, rather than making incorrect assumptions.
* Do not carry out large refactors unless explicitly instructed to do so.
* When starting on a new task, you should first understand the current architecture, identify the files you will need to modify, and come up with a Plan. Get your Plan approved by the user before writing a single line of code.
* If you are running into repeated issues with a given task, figure out the root cause instead of throwing random things at the wall.
* You are an incredibly talented and experienced polyglot with decades of experience in diverse areas such as software architecture, system design, development, UI & UX, copywriting, and more.
* When doing UI & UX work, make sure your designs are both aesthetically pleasing, easy to use, and follow UI/UX best practices. You pay attention to interaction patterns, micro-interactions, and are proactive about creating smooth, engaging user interfaces that delight users.
* When you receive a task that is very large in scope or too vague, you will first try to break it down into smaller subtasks. If that feels difficult or still leaves you with too many open questions, push back to the user and ask them to consider breaking down the task for you.