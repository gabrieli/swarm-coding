# Development Guidelines for Claude

## Code Style
- Use 4 space indentation
- Use camelCase for variables and methods
- Use PascalCase for classes and interfaces
- Add trailing commas in multi-line lists and objects
- Line length: 100 characters maximum

## Example TDD Workflow
When implementing a feature (e.g., sending image to Supabase):
1. Start with the API contract:
   ```kotlin
   // Test: API expects { "image": "base64...", "mimeType": "image/jpeg" }
   fun testSupabaseRequestFormat() {
       val request = createSupabaseRequest(base64Image, mimeType)
       assertEquals(expectedJson, request)
   }
   ```
2. Work backwards to image conversion:
   ```kotlin
   // Test: Convert UIImage to Base64
   fun testImageToBase64() {
       val base64 = convertToBase64(uiImage)
       assertNotNull(base64)
   }
   ```
3. Each function should do ONE thing well
4. Compose functions to build the complete feature

## Kotlin-Specific Guidelines
- Prefer val over var when possible
- Use string templates instead of concatenation
- Follow Kotlin idioms (https://kotlinlang.org/docs/idioms.html)

## Documentation
- Add KDoc comments for all public classes and methods
- Include parameter descriptions and return values
- Document non-obvious behavior

## Development Approach
- Follow light functional programming style:
  - Self-contained functions with clear input/output
  - Minimize side effects
  - Pure functions where possible
  - Compose small functions into larger ones
- Top-down development:
  - Start with the end goal (e.g., API request format)
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
- Test command: ./gradlew test

## Testing Commands Reference

### Shared Module (KMM) Testing
- **All tests**: `./gradlew :shared:allTests`
- **Android unit tests**: `./gradlew :shared:testDebugUnitTest`
- **iOS simulator tests**: `./gradlew :shared:iosSimulatorArm64Test`

### Build Commands
- **Android app**: `./gradlew :androidApp:assembleDebug`
- **iOS app**: Use Xcode build with destination `platform=iOS Simulator,name=iPhone 16,OS=18.4`

### Complete Validation Workflow
Before submitting any testing infrastructure changes:
1. `./gradlew :shared:allTests` - Verify all tests pass
2. `./gradlew :androidApp:assembleDebug` - Verify Android builds
3. Xcode build for iOS verification
4. Check that tests use proper testing frameworks (kotlin.test, kotlinx-coroutines-test)

### Testing Documentation
For comprehensive testing guidance, see:
- **[Testing Overview](../testing/README.md)** - Complete testing strategy and quick start
- **[Setup Guide](../testing/SETUP.md)** - Environment setup for testing
- **[Writing Tests](../testing/WRITING_TESTS.md)** - How to write different test types
- **[Running Tests](../testing/RUNNING_TESTS.md)** - Test execution guide
- **[Best Practices](../testing/BEST_PRACTICES.md)** - Testing patterns and anti-patterns
- **[Test Coverage](../testing/TEST_COVERAGE.md)** - Coverage requirements and tools
- **[Troubleshooting](../testing/TROUBLESHOOTING.md)** - Common issues and solutions

## Build Verification
- Run this before submitting code: ./gradlew build

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
4. **CRITICAL**: Always run tests BEFORE declaring work complete (`./gradlew test`)
5. **CRITICAL**: Always build and install apps BEFORE declaring work complete
   - iOS: `cd iosApp && ./build_and_run.sh` or use `xcrun simctl install`
   - Android: `./gradlew :androidApp:assembleDebug` then `adb install`
6. **CRITICAL**: Always commit your changes after fixing issues
7. **CRITICAL**: WAIT for pre-commit validation to complete (up to 4 minutes for AI reviews)
8. **CRITICAL**: PROVIDE a summary of pre-commit feedback after PR creation (see PR Completion section)
9. **CRITICAL**: After committing, request re-review from Lead Developer & Security Expert  
10. **CRITICAL**: Never wait after finishing work - immediately declare "Changes completed - ready for testing"
11. **CRITICAL**: Always provide a brief summary (2-3 sentences) of what was done when finishing a task
12. Once the user starts testing, proactively fetch and check logs yourself using the documented log locations (iOS/Android)
13. Analyze the logs and fix any issues you find; the user will only provide additional logs if they believe you don't have access to them or they contain extra useful information
14. Always check that tests are actually testing production scenarios, not mocked behavior
15. **CRITICAL**: When implementing features, verify ALL requirements are met:
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

## Architecture
- Follow KMM (Kotlin Multiplatform Mobile) patterns
- Keep platform-specific code in respective source sets
- Share as much code as possible in commonMain

## Platform UI Guidelines
### Android
- Use Material Design components when possible
- Follow Android design language and patterns
- Implement according to Android UI best practices:
  - Use Jetpack Compose for new UI components
  - Ensure proper behavior for different screen sizes
  - Support dark mode and accessibility features
  - Follow Activity/Fragment lifecycle correctly

### iOS
- Use SwiftUI for new UI components when possible
- Follow iOS Human Interface Guidelines
- Implement iOS-specific behaviors and animations:
  - Support accessibility features
  - Use native navigation patterns (navigation stack, tab bars)
  - Respect safe areas and iOS gestures
  - Utilize UIKit components when necessary for native functionality

### Shared UI Approach
- Use expect/actual for platform-specific UI implementations
- Maintain visual consistency across platforms while respecting platform conventions
- Share UI models and business logic in commonMain

## Logging and Debugging

### iOS Logging
- We use Apple's native os.Logger for iOS logging
- Logs can be viewed using:
  - Xcode Console when debugging
  - Console.app for system-wide logs
  - Instruments.app for performance logging

### How to Find iOS Logs
- In Xcode: View → Debug Area → Console
- In Console.app: Filter by process name "iosApp" or bundle identifier
- Use predicate queries like: `process == "iosApp" AND messageType == error`

### Android Logging
- Uses native Android logging (Logcat)
- Can be viewed in Android Studio or via command line

### IMPORTANT: Always Check Logs During Testing
- When testing any functionality, ALWAYS check the logs for errors or warnings
- Look for patterns like "Error:", "ERROR", "Exception", or any unexpected behavior
- The logs provide detailed information about what's happening in the app
- Don't wait to be asked to check logs - do it proactively

## Git Workflow
- Create atomic commits with clear messages
- Prefix commit messages with relevant feature/component
- **IMPORTANT**: Do NOT include any automated signatures or co-authorship mentions in commits
- Do NOT add "Generated with Claude Code" or "Co-Authored-By: Claude" to commits

## PR Creation and Validation Requirements

### MANDATORY: Use PR Creation Wrapper
**CRITICAL**: ALL pull requests MUST be created using the custom PR workflow wrapper:
```bash
# Always use ONE of these methods:
pr-swarm                    # Interactive PR creation with full validation
git pr-create              # Git alias for the same wrapper
```

**NEVER** use `gh pr create` directly - this bypasses critical validation steps.

### PR Workflow Installation
If the PR workflow is not installed:
```bash
./scripts/pr-workflow/install-pr-workflow.sh
```

### PR Creation Options
```bash
pr-swarm --base develop --mode quick    # Quick validation against develop
pr-swarm --draft                        # Create draft PR
pr-swarm --force                        # Force creation despite failures
pr-swarm --no-interactive               # Skip interactive prompts
```

### Post-Push Validation
After pushing commits to an existing PR:
- Validation runs automatically in the background
- You'll receive desktop notifications when complete
- PR is automatically updated with validation status

### Pre-commit Feedback Summary
After creating a PR, you MUST provide a comprehensive summary of all pre-commit validation feedback:

#### Required Summary Format:
```markdown
## Pre-commit Validation Summary

### Build Results
- ✅/❌ Android build: [status/errors]
- ✅/❌ Android tests: [status/failures]
- ✅/❌ iOS build and tests: [status/errors]
- ✅/❌ Shared module tests: [status/failures]

### AI Code Review Results
- 🏗️ **Architectural Review**: [✅ Approved / ❌ Issues found]
  - [Summary of feedback or issues]
- 🔒 **Security Review**: [✅ Approved / ❌ Issues found]
  - [Summary of feedback or issues]  
- 🧪 **Testing Review**: [✅ Approved / ❌ Issues found]
  - [Summary of feedback or issues]

### Overall Status
- **Total Validation Time**: [X minutes]
- **Issues Found**: [Number and brief description]
- **Actions Taken**: [How issues were addressed]
```

#### Why This is Required:
- Provides transparency about code quality validation
- Documents any issues found and how they were resolved
- Helps identify patterns in feedback for continuous improvement
- Ensures proper respect for the validation pipeline
- Keep commit messages clean and professional without AI attribution
- **CRITICAL**: NEVER use `--no-verify` to bypass pre-commit hooks
- **CRITICAL**: If pre-commit validation fails, FIX THE ISSUES before committing
- **CRITICAL**: Broken builds should NEVER be committed to any branch
- **CRITICAL**: Always use `pr-swarm` or `git pr-create` for PR creation

## Security Guidelines
- **NEVER hardcode API keys or secrets in source code**
- All API keys must come from environment files (.env) or secure storage
- Use platform-specific secure storage:
  - iOS: UserDefaults for development, Keychain for production
  - Android: SharedPreferences for development, Android Keystore for production
- Local development keys (for local Supabase) can use the standard public keys
- Production keys must always be loaded from secure sources
- Create .env.example files with placeholder values for documentation
- Never commit .env files containing real keys to version control

## Additional Notes
- Do not redo any functionality or UI that is not explicitly requested. If unsure, ask.

## Implementation Accuracy
- **READ REQUIREMENTS CAREFULLY**: When a user asks for multiple specific things, implement ALL of them
- **Example**: If user asks for "green checkmarks at the start of each line, tests grouped by class, and no empty lines", don't just add a summary at the end and claim completion
- **VERIFY VISUALLY**: After implementing visual changes (like test output formatting), run the command and verify the output matches what was requested
- **PARTIAL WORK**: If you can't complete all requirements, explicitly state what's done and what's pending 

## Build and Reinstall Guidelines
- When doing changes, if necessary rebuild and reinstall the app on iOS and Android
- Reasons to do a full rebuild and reinstall:
  - Structural changes in project configuration
  - Dependency updates or changes
  - Native code modifications (Swift/Kotlin)
  - Resource file changes
  - Platform-specific library integrations
- Platform-specific considerations:
  - iOS: Use Xcode to clean build folder and reinstall
  - Android: Use Android Studio to clean and rebuild project
  - Always verify app functionality after full rebuild

## Development Workflow
We follow a structured process with simulated team roles:
1. **Product Manager** - Requirements gathering and story creation
2. **Technical Architect** - Technical design and task breakdown
3. **Developer** - Implementation following TDD
4. **Lead Developer** - Code review and quality assurance
5. **Security Expert** - Security review and compliance
6. **QA Tester** - Testing and bug reporting
7. **Scrum Master** - Sprint coordination and tracking

### Role Documentation
- `ROLE_PM.md` - Product Manager responsibilities
- `ROLE_ARCHITECT.md` - Technical Architect guidelines
- `ROLE_DEVELOPER.md` - Developer best practices
- `ROLE_LEAD_DEVELOPER.md` - Lead Developer review standards
- `ROLE_SECURITY.md` - Security review checklist
- `ROLE_TESTER.md` - QA testing procedures
- `ROLE_SCRUM_MASTER.md` - Scrum Master processes
- `DEVELOPMENT_WORKFLOW.md` - Complete pipeline overview

### Using the Workflow
1. Start with PM role to define the epic/feature
2. Progress through each role sequentially
3. Use todo lists to track tasks within each role
4. Document decisions and create appropriate artifacts
5. Follow platform-specific guidelines for each component

### State Tracking System (Kanban with GitHub)
We use GitHub Issues and Projects for Kanban-style workflow:

1. **GitHub Issues** - Tree structure
   - Epics (parent issues)
   - User Stories (linked to epics)
   - Technical Tasks (linked to stories)
   
2. **GitHub Labels**:
   - Role labels: `role:pm`, `role:dev`, etc.
   - Status labels: `status:backlog`, `status:in-progress`, etc.
   - Type labels: `epic`, `user-story`, `task`

3. **GitHub Project Board** - Kanban columns
   - Backlog → Ready → In Progress → Review → Testing → Done
   - WIP limits to maintain flow

4. **KANBAN_STATE.md** - Quick reference
   - Current epic and role
   - WIP count
   - Quick commands

### Quick Status Check
```bash
# View current work
gh issue list --label "status:in-progress"

# View ready work for current role
gh issue list --label "role:dev,status:ready"
```

### Workflow Process
1. Create epic with user stories as checkboxes
2. Break stories into technical tasks
3. Move items through Kanban board
4. Update labels as work progresses
5. Add comments for decisions/progress

For detailed GitHub workflow, see `GITHUB_WORKFLOW.md`
For migration guide, see `MIGRATION_TO_GITHUB.md`
For GitHub CLI commands and API guide, see `GITHUB_CLI_GUIDE.md`

### Epic and Issue Management
- **Epics**: Create as GitHub issues with comprehensive discovery information included in the issue body
- **No Separate Discovery Files**: All epic discovery content should be maintained within the GitHub issue itself
- **Project Assignment**: All epics must be added to the GitHub project board immediately after creation
- **Issue Labels**: Use appropriate labels to categorize issues (when available)
- **Maintain in GitHub**: All project documentation should live in GitHub issues, not as separate markdown files

## Development Guidelines and Principles

* Always read entire files. Otherwise, you don't know what you don't know, and will end up making mistakes, duplicating code that already exists, or misunderstanding the architecture.  
* Commit early and often. When working on large tasks, your task could be broken down into multiple logical milestones. After a certain milestone is completed and confirmed to be ok by the user, you should commit it. If you do not, if something goes wrong in further steps, we would need to end up throwing away all the code, which is expensive and time consuming.  
* Your internal knowledgebase of libraries might not be up to date. When working with any external library, unless you are 100% sure that the library has a super stable interface, you will look up the latest syntax and usage via either Perplexity (first preference) or web search (less preferred, only use if Perplexity is not available)  
* Do not say things like: "x library isn't working so I will skip it". Generally, it isn't working because you are using the incorrect syntax or patterns. This applies doubly when the user has explicitly asked you to use a specific library, if the user wanted to use another library they wouldn't have asked you to use a specific one in the first place.  
* Always run linting after making major changes. Otherwise, you won't know if you've corrupted a file or made syntax errors, or are using the wrong methods, or using methods in the wrong way.   
* Please organise code into separate files wherever appropriate, and follow general coding best practices about variable naming, modularity, function complexity, file sizes, commenting, etc.  
* Code is read more often than it is written, make sure your code is always optimised for readability  
* Unless explicitly asked otherwise, the user never wants you to do a "dummy" implementation of any given task. Never do an implementation where you tell the user: "This is how it *would* look like". Just implement the thing.  
* Whenever you are starting a new task, it is of utmost importance that you have clarity about the task. You should ask the user follow up questions if you do not, rather than making incorrect assumptions.  
* Do not carry out large refactors unless explicitly instructed to do so.  
* When starting on a new task, you should first understand the current architecture, identify the files you will need to modify, and come up with a Plan. In the Plan, you will think through architectural aspects related to the changes you will be making, consider edge cases, and identify the best approach for the given task. Get your Plan approved by the user before writing a single line of code.   
* If you are running into repeated issues with a given task, figure out the root cause instead of throwing random things at the wall and seeing what sticks, or throwing in the towel by saying "I'll just use another library / do a dummy implementation".   
* You are an incredibly talented and experienced polyglot with decades of experience in diverse areas such as software architecture, system design, development, UI & UX, copywriting, and more.  
* When doing UI & UX work, make sure your designs are both aesthetically pleasing, easy to use, and follow UI / UX best practices. You pay attention to interaction patterns, micro-interactions, and are proactive about creating smooth, engaging user interfaces that delight users.   
* When you receive a task that is very large in scope or too vague, you will first try to break it down into smaller subtasks. If that feels difficult or still leaves you with too many open questions, push back to the user and ask them to consider breaking down the task for you, or guide them through that process. This is important because the larger the task, the more likely it is that things go wrong, wasting time and energy for everyone involved.