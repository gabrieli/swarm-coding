# Development Workflow Pipeline

## Overview
This document outlines our structured development process using simulated team roles to ensure thorough planning, implementation, and quality assurance.

## Workflow Stages & Status Transitions

### 1. Product Planning (PM Role) - Status: Backlog → PM Refined
- Pick items from `Backlog` status
- Gather requirements
- Define epics and user stories
- Set acceptance criteria
- Move to `PM Refined` when complete

### 2. Technical Design (Architect Role) - Status: PM Refined → Dev Ready
- Pick items from `PM Refined` status
- Create technical discovery based on epics
- Update user stories with:
  - Clear functionality description
  - Expected user experience details
  - Technical implementation guidance
  - Test cases for happy and unhappy paths
- Ensure stories are independent and valuable
- Identify dependencies and risks
- Move to `Dev Ready` when complete

### 3. Implementation (Developer Role) - Status: Dev Ready → In Progress → In Review
- Pick stories from `Dev Ready` status
- Move to `In Progress` when starting
- Write tests first (TDD)
- Implement the functionality needed
- Ensure platform compliance
- Test thoroughly (QA testing happens here)
- Document code
- Move to `In Review` when complete

### 4. Combined Review (Lead Developer + Security) - Status: In Review → Done/In Progress
- Pick items from `In Review` status
- Ensure architecture and security standards are met
- Assess engineering best practices
- Verify test coverage for all paths
- Check security vulnerabilities
- **Pass**: Move to `Done`
- **Fail**: Move back to `In Progress` with feedback

### 5. Code fixes (Developer role) - Status: In Progress → In Review
- Address review feedback
- Fix identified issues
- Re-test thoroughly
- **CRITICAL**: Always commit changes before requesting re-review
- Move back to `In Review` for re-review
- Lead Developer and Security Expert must re-review immediately

## Example: iOS Feature Parity Epic

### PM Phase
```markdown
Epic: iOS Feature Parity
Goal: Achieve feature parity between iOS and Android apps
Business Value: Consistent user experience across platforms

User Stories:
1. As an iOS user, I want to capture menu images
2. As an iOS user, I want to process menu images
3. As an iOS user, I want to view food recommendations
```

### Architect Phase
```markdown
Technical Breakdown:
1. Camera Integration Task
   - Platform: iOS specific
   - Components: CameraView, PermissionHandler
   
2. Image Processing Task
   - Platform: Shared with iOS specific
   - Components: ImageProcessor, ImageConverter
   
3. Supabase Integration Task
   - Platform: Shared
   - Components: APIClient, DataModels
```

### Implementation Flow
1. Start with smallest, independent task
2. Follow TDD approach
3. Test on platform
4. Move to next task
5. Integrate components
6. Full feature testing

## Benefits
- Clear role responsibilities
- Structured approach
- Better tracking
- Quality assurance
- Reduced bugs
- Faster delivery

## Getting Started
1. Identify the epic/feature
2. Start with PM role to gather requirements
3. Progress through each role sequentially
4. Document decisions and progress
5. Use todo lists to track tasks
6. Follow platform-specific guidelines