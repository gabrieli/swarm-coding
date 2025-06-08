# Status Workflow Guide

## Status Mapping to Roles

| Status | Role Responsible | Description |
|--------|-----------------|-------------|
| **Backlog** | Product Manager | Raw ideas and requirements not yet refined |
| **PM Refined** | Technical Architect | Requirements complete, ready for technical design |
| **Dev Ready** | Developer | Architecture complete, ready for implementation |
| **In Progress** | Developer | Active development work |
| **In Review** | All Review Roles | Architecture, Security, Testing, Documentation, DevOps, and UX reviews |
| **Done** | All | Complete and deployed |

## Status Transitions by Role

### Product Manager
- **Action**: Pick items from `Backlog`
- **Work**: Define requirements, user stories, acceptance criteria
- **Complete**: Move to `PM Refined`

### Technical Architect 
- **Action**: Pick items from `PM Refined`
- **Work**: Technical design, architecture decisions, update user stories with technical details
- **Complete**: Move to `Dev Ready`

### Developer
- **Action**: Pick items from `Dev Ready` 
- **Work**: Implement feature following TDD
- **In Progress**: Move to `In Progress` when starting work
- **Complete**: Move to `In Review`

### Review Roles (Architecture, Security, Testing, Documentation, DevOps, UX)
- **Action**: Pick items from `In Review`
- **Work**: Combined review phase covering all aspects:
  - Architecture: Design patterns and standards
  - Security: Vulnerabilities and best practices
  - Testing: Coverage and quality
  - Documentation: Clarity and completeness
  - DevOps: CI/CD and deployment
  - UX: User experience and accessibility
- **Pass**: Move to `Done` (all applicable reviews must pass)
- **Fail**: Move back to `In Progress` with feedback

### QA Tester
- **Note**: Testing happens within the Developer phase before moving to review

## Quick Commands

```bash
# Get items by status
gh project item-list 1 --owner YOUR_GITHUB_USERNAME --format json | jq '.items[] | select(.status == "Dev Ready") | {number: .content.number, title}'

# Update item status
gh project item-edit --project-id YOUR_PROJECT_ID --id [ITEM_ID] --field-id YOUR_STATUS_FIELD_ID --single-select-option-id [STATUS_ID]
```

## Status IDs Reference
- Backlog: `YOUR_BACKLOG_STATUS_ID`
- PM Refined: `YOUR_PM_REFINED_STATUS_ID`
- Dev Ready: `YOUR_DEV_READY_STATUS_ID`
- In Progress: `YOUR_IN_PROGRESS_STATUS_ID`
- In Review: `YOUR_IN_REVIEW_STATUS_ID`
- Done: `YOUR_DONE_STATUS_ID`

## Example Workflow

1. PM creates epic → `Backlog`
2. PM refines requirements → `PM Refined`
3. Architect adds technical design → `Dev Ready`
4. Developer starts work → `In Progress`
5. Developer completes, tested → `In Review`
6. All review roles approve → `Done`

## Important Notes
- Only move items forward when all work for that phase is complete
- If review fails, item goes back to `In Progress`
- Each role should filter by their relevant statuses
- Testing happens during development, not as separate phase