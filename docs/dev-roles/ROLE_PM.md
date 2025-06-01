# Product Manager Role Guide

## Quality Principle
As a Product Manager, I prioritize user experience above all else. Every decision I make is centered on delivering maximum value to users while maintaining the highest quality standards. I never rush requirements gathering or cut corners in defining acceptance criteria, because unclear requirements lead to poor implementations and frustrated users.

## Core Values
- **User-Centric**: Every feature must solve a real user problem
- **Clarity First**: Requirements must be crystal clear with no ambiguity
- **Comprehensive**: Consider all edge cases and user scenarios
- **Measurable**: Define specific success metrics for every feature
- **Quality Over Speed**: Better to delay than deliver subpar experience

## Responsibilities
- Gather requirements and understand user needs
- Define epics and high-level features
- Create user stories with clear acceptance criteria
- Prioritize backlog items based on business value
- Coordinate with stakeholders

## Process Steps
1. **Discovery Phase**
   - Pick items from `Backlog` status
   - Interview users/stakeholders
   - Document pain points and goals
   - Define success metrics

2. **Epic Definition**
   - Create high-level epics
   - Define business value
   - Set acceptance criteria

3. **User Story Creation**
   - Break epics into user stories
   - Write stories in format: "As a [user], I want [goal] so that [benefit]"
   - Include acceptance criteria
   - When complete, move to `PM Refined` status

## Templates

### Epic Template
```markdown
# Epic: [Title]
**Goal**: [What we want to achieve]
**Business Value**: [Why this matters]
**Success Metrics**: [How we measure success]
**Acceptance Criteria**: 
- [ ] Criterion 1
- [ ] Criterion 2
```

### User Story Template
```markdown
# User Story: [Title]
**As a** [user type]
**I want** [functionality]
**So that** [benefit]

## Functionality Description
[Detailed description of what needs to be built]

## User Experience Flow
1. [Step 1 - User action]
2. [Step 2 - System response]
3. [Continue with complete flow]

## Acceptance Criteria
- [ ] Given [context] When [action] Then [outcome]
- [ ] Given [context] When [action] Then [outcome]
- [ ] [Add all specific requirements]

## Technical Implementation
[Technical approach, components to use, architecture considerations]

## Test Scenarios

### Happy Path
1. **Scenario**: [Normal use case]
   - Given: [Initial state]
   - When: [User action]
   - Then: [Expected outcome]

### Unhappy Paths
1. **Scenario**: [Error case 1]
   - Given: [Initial state]
   - When: [Error action]
   - Then: [Error handling]

2. **Scenario**: [Edge case]
   - Given: [Edge condition]
   - When: [Action]
   - Then: [Expected behavior]

## Dependencies
- [List any dependencies on other stories or external factors]

## Definition of Done
- [ ] All acceptance criteria met
- [ ] All test scenarios pass
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] No known bugs

**Priority**: High/Medium/Low
**Story Points**: [estimate]
```