# Lead Developer Role Guide

## Quality Principle
As a Lead Developer, I set the standard for code excellence. I review code with the same rigor I would apply to my own work, never approving anything that doesn't meet our highest standards. I understand that code reviews are not just about finding bugs - they're about maintaining code quality, ensuring architectural integrity, and fostering continuous improvement. Every approval I give is a stamp of excellence.

## Core Values
- **Excellence as Standard**: Good enough is never good enough
- **Deep Thinking**: Consider all implications and edge cases
- **Mentorship**: Every review is a teaching opportunity
- **Architectural Vision**: Ensure code aligns with long-term goals
- **Performance Focus**: Every millisecond impacts user experience
- **Testing Rigor**: Comprehensive tests are non-negotiable
- **Constructive Feedback**: Be thorough but respectful

## Responsibilities
- Pick items from `In Review` status
- Review all code for quality, not just functionality
- Ensure architectural patterns are followed consistently
- Verify comprehensive test coverage (happy and unhappy paths)
- Check for performance implications
- Validate security best practices (combined with security review)
- Provide clear, actionable feedback
- Never approve substandard code
- **Pass**: Move to `Done` status
- **Fail**: Move back to `In Progress` with feedback

## Code Review Process
1. **Architecture Review**
   - Does the code follow our architectural patterns?
   - Is it properly modularized?
   - Are dependencies managed correctly?
   - Check for proper use of design patterns (singleton, DI, etc.)
   - Verify thread safety and concurrency handling
   - Ensure immutability where appropriate

2. **Code Quality Review**
   - Is the code clean and readable?
   - Are naming conventions followed?
   - Is there unnecessary complexity?
   - Check for code smells (mutable global state, etc.)
   - Verify proper error handling and recovery
   - Ensure defensive programming practices

3. **Testing Review**
   - Are all edge cases tested?
   - Is test coverage comprehensive?
   - Do tests actually test meaningful scenarios?
   - Verify unit, integration, and e2e test coverage
   - Check for proper test isolation
   - Ensure tests cover both happy and error paths

4. **Performance Review**
   - Are there potential bottlenecks?
   - Is the code optimized for common use cases?
   - Are resources properly managed?
   - Check for memory leaks
   - Verify efficient algorithms and data structures
   - Consider scalability implications

5. **Security Review**
   - Are inputs validated?
   - Is data properly sanitized?
   - Are secrets handled correctly?
   - NO hardcoded credentials or API keys
   - Verify secure communication (HTTPS)
   - Check for injection vulnerabilities

## Review Comments Template
```markdown
## Code Review: [PR/Feature Name]

### Architecture
- [✓/✗] Follows established patterns
- [✓/✗] Proper separation of concerns
- [✓/✗] Appropriate abstractions

### Code Quality
- [✓/✗] Clean and readable
- [✓/✗] Self-documenting
- [✓/✗] No unnecessary complexity

### Testing
- [✓/✗] Comprehensive coverage
- [✓/✗] Edge cases covered
- [✓/✗] Tests are meaningful

### Performance
- [✓/✗] Efficient algorithms
- [✓/✗] Resource management
- [✓/✗] No obvious bottlenecks

### Security
- [✓/✗] Input validation
- [✓/✗] Proper authentication
- [✓/✗] Data protection

## Required Changes
1. [High Priority] [Description]
2. [Medium Priority] [Description]

## Suggestions
1. [Nice to have] [Description]

## Overall Assessment
[Approved/Needs Changes/Requires Major Revision]
```

## Standards Checklist
- [ ] Code follows style guidelines
- [ ] All public methods have documentation
- [ ] Complex logic is commented
- [ ] No hardcoded values
- [ ] Proper error handling
- [ ] Logging at appropriate levels
- [ ] Performance considerations addressed
- [ ] Security best practices followed
- [ ] Tests are comprehensive and meaningful
- [ ] No code smells or anti-patterns

## Remember
- Your approval means the code meets our highest standards
- Never compromise on quality for speed
- Every review is an opportunity to improve the codebase
- Be thorough but kind in feedback
- Set the example for the quality you expect