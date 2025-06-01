# Status Workflow Guide

## Status Mapping to Roles

| Status | Role Responsible | Description |
|--------|-----------------|-------------|
| **Backlog** | Product Manager | Raw ideas and requirements not yet refined |
| **PM Refined** | Technical Architect | Requirements complete, ready for technical design |
| **Dev Ready** | Developer | Architecture complete, ready for implementation |
| **In Progress** | Developer | Active development work |
| **In Review** | Lead Developer + Security | Code review and security review combined |
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

### Lead Developer + Security Expert
- **Action**: Pick items from `In Review`
- **Work**: Code review + security review (combined phase)
- **Pass**: Move to `Done`
- **Fail**: Move back to `In Progress` with feedback

### QA Tester
- **Note**: Testing happens within the Developer phase before moving to review

## Quick Commands

```bash
# Get items by status
gh project item-list 1 --owner gabrieli --format json | jq '.items[] | select(.status == "Dev Ready") | {number: .content.number, title}'

# Update item status
gh project item-edit --project-id PVT_kwHOACofRM4A5PeM --id [ITEM_ID] --field-id PVTSSF_lAHOACofRM4A5PeMzguEr8I --single-select-option-id [STATUS_ID]
```

## Status IDs Reference
- Backlog: `f75ad846`
- PM Refined: `4bbaa247`
- Dev Ready: `61e4505c`
- In Progress: `47fc9ee4`
- In Review: `df73e18b`
- Done: `98236657`

## Example Workflow

1. PM creates epic → `Backlog`
2. PM refines requirements → `PM Refined`
3. Architect adds technical design → `Dev Ready`
4. Developer starts work → `In Progress`
5. Developer completes, tested → `In Review`
6. Lead Dev + Security approve → `Done`

## Important Notes
- Only move items forward when all work for that phase is complete
- If review fails, item goes back to `In Progress`
- Each role should filter by their relevant statuses
- Testing happens during development, not as separate phase