# Workflow State Management

## How to Track Progress

### 1. Project State File
The `PROJECT_STATE.md` file maintains:
- Current sprint information
- Active epic and its status
- Current role/phase in the workflow
- High-level progress tracking

### 2. Todo System
Use todos with this naming convention:
```
[ROLE][EPIC][STATUS] Task description
```

Example:
```
[PM][iOS-PARITY][IN_PROGRESS] Define user stories for camera feature
[ARCH][iOS-PARITY][PENDING] Design image processing architecture
[DEV][iOS-PARITY][COMPLETE] Implement camera permissions handler
```

### 3. State Transitions

#### Starting a New Epic
1. Update PROJECT_STATE.md with epic details
2. Set current phase to "Product Planning"
3. Create PM todos for requirements gathering

#### Moving Between Roles
1. Complete all todos for current role
2. Update PROJECT_STATE.md to next phase
3. Create todos for new role based on previous outputs

#### Tracking Individual Tasks
1. Create todo with proper naming convention
2. Update status as work progresses
3. Move completed items to "Completed" in PROJECT_STATE.md

### 4. Status Values
- **PENDING**: Not started
- **IN_PROGRESS**: Currently working
- **BLOCKED**: Waiting on dependency
- **REVIEW**: Under review
- **COMPLETE**: Finished

### 5. Role Prefixes
- **PM**: Product Manager
- **ARCH**: Technical Architect  
- **DEV**: Developer
- **LEAD**: Lead Developer
- **SEC**: Security Expert
- **QA**: QA Tester
- **SM**: Scrum Master

### 6. Epic/Sprint Tracking

#### Sprint File Template
Create `SPRINT_[NUMBER].md` for each sprint:
```markdown
# Sprint [Number]

## Sprint Goal
[What we aim to complete]

## Committed Stories
1. [Story ID] - [Description] - [Points]
2. [Story ID] - [Description] - [Points]

## Daily Progress
### Day 1 - [Date]
- Completed: [List]
- In Progress: [List]
- Blockers: [List]
```

#### Epic File Template
Create `EPIC_[NAME].md` for each epic:
```markdown
# Epic: [Name]

## Status: [Active/Complete/On Hold]

## User Stories
1. [x] Story 1 - Complete
2. [ ] Story 2 - In Progress
3. [ ] Story 3 - Pending

## Technical Tasks
1. [x] Task 1 - Complete
2. [ ] Task 2 - In Progress

## Current Phase
Role: [Current Role]
Status: [Status]
Next: [What's next]
```

### 7. Quick Status Check Process
1. Read PROJECT_STATE.md for high-level status
2. Check current epic file for detailed progress
3. Use TodoRead to see immediate tasks
4. Look for tasks with your current role prefix

### 8. Handoff Between Sessions
Before ending a session:
1. Update PROJECT_STATE.md with current status
2. Mark todos with appropriate status
3. Add "Up Next" items clearly
4. Document any blockers or decisions needed

### 9. Recovery Process
To understand where we left off:
1. Check PROJECT_STATE.md for current phase
2. Read current epic/sprint files
3. Use TodoRead to see active tasks
4. Look for IN_PROGRESS items first

### 10. Progress Reporting
Weekly summary should include:
- Stories completed
- Current phase/role
- Blockers resolved
- Next week's goals
- Velocity metrics