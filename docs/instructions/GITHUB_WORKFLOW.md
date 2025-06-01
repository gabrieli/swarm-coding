# GitHub-Based Kanban Workflow

## Overview
We use GitHub Issues and Projects to track our work in a Kanban style, maintaining tree-like relationships between epics, user stories, and tasks.

## Structure Hierarchy

### 1. Epic (GitHub Issue with `epic` label)
```markdown
# Epic: iOS Feature Parity

## Overview
[Business value and goals]

## User Stories
- [ ] #2 Camera Menu Capture
- [ ] #3 Image Processing
- [ ] #4 AI Recommendations Display

## Success Metrics
- [ ] Metric 1
- [ ] Metric 2
```

### 2. User Story (GitHub Issue with `user-story` label)
```markdown
# User Story: Camera Menu Capture

**Parent Epic**: #1
**As an** iOS user  
**I want** to capture menu images  
**So that** I can get recommendations

## Functionality Description
[Detailed technical and functional description]

## User Experience Flow
1. User taps "Take Photo" button
2. Camera permission requested (first time)
3. Camera interface opens
4. User captures photo
5. Photo preview shown
6. User confirms or retakes

## Acceptance Criteria
- [ ] Camera permissions handled properly
- [ ] Photo capture implemented with native UI
- [ ] Preview functionality works correctly
- [ ] Error states handled gracefully

## Technical Implementation
- Use UIImagePickerController for camera
- Implement permission flow with AVCaptureDevice
- Handle delegate callbacks for image processing
- Compress images for optimal processing

## Test Scenarios

### Happy Path
1. **First time camera use**
   - Given: App freshly installed
   - When: User taps "Take Photo"
   - Then: Permission request shown → Camera opens → Photo captured

### Unhappy Paths
1. **Camera permission denied**
   - Given: User previously denied camera
   - When: User taps "Take Photo"
   - Then: Alert shown with settings link

2. **Camera unavailable**
   - Given: Running on simulator
   - When: User taps "Take Photo"
   - Then: Appropriate error message shown

## Definition of Done
- [ ] All test scenarios pass
- [ ] Code reviewed and approved
- [ ] Works on real device
- [ ] No memory leaks
```

## GitHub Labels for Workflow States

### Role Labels
- `role:pm` - Product Manager work
- `role:architect` - Architecture design
- `role:dev` - Development work
- `role:lead-dev` - Code review
- `role:security` - Security review
- `role:qa` - Testing

### Status Labels
- `status:backlog` - Not started
- `status:in-progress` - Currently working
- `status:review` - Under review
- `status:blocked` - Waiting on dependency
- `status:done` - Completed

### Type Labels
- `epic` - High-level feature
- `user-story` - User-facing functionality
- `task` - Technical implementation
- `bug` - Defect to fix

## GitHub Project Board Columns

1. **Backlog** - All work not started
2. **Ready** - Work ready to begin
3. **In Progress** - Active work (WIP limit: 2)
4. **Review** - Code/security review
5. **Testing** - QA verification
6. **Done** - Completed work

## Workflow Process

### 1. Creating Work Items
```bash
# Create epic
gh issue create --title "Epic: iOS Feature Parity" \
  --label "epic,role:pm" \
  --body "Epic description..."

# Create user story
gh issue create --title "Story: Camera Menu Capture" \
  --label "user-story,role:architect,status:backlog" \
  --body "Story description with link to #1"

# Create task
gh issue create --title "Task: Implement camera permissions" \
  --label "task,role:dev,status:backlog" \
  --body "Task description with link to #2"
```

### 2. Moving Through Workflow
```bash
# Start work
gh issue edit [number] --add-label "status:in-progress" \
  --remove-label "status:backlog"

# Move to review
gh issue edit [number] --add-label "status:review,role:lead-dev" \
  --remove-label "status:in-progress,role:dev"
```

### 3. Tracking Progress
```bash
# View current work
gh issue list --label "status:in-progress"

# View work by role
gh issue list --label "role:dev,status:backlog"

# View epic progress
gh issue view [epic-number]
```

## Benefits Over File-Based Tracking

1. **Visual Kanban board** via GitHub Projects
2. **Automatic linking** between issues
3. **Progress tracking** with checkboxes
4. **History and comments** on each item
5. **Notifications** for updates
6. **Search and filtering** capabilities

## Integration with Our Roles

### Product Manager Flow
1. Create epic with user stories
2. Define acceptance criteria
3. Link stories to epic using checkboxes
4. Transition to architect when ready

### Architect Flow
1. Review user stories
2. Create technical tasks
3. Link tasks to stories
4. Add technical details
5. Transition to developer

### Developer Flow
1. Pick task from ready column
2. Move to in-progress
3. Implement with TDD
4. Create PR linked to issue
5. Move to review

### Review Flow
1. Review code in PR
2. Check against standards
3. Add review comments
4. Move to testing or back to dev

## WIP Limits
- **In Progress**: Max 2 items
- **Review**: Max 3 items
- **Testing**: Max 2 items

## Daily Workflow
1. Check GitHub Project board
2. Look at "Ready" column
3. Move item to "In Progress"
4. Work on item
5. Update status labels
6. Move through workflow

## Metrics to Track
- Cycle time (backlog to done)
- Throughput (items completed/week)
- WIP adherence
- Blocked items count