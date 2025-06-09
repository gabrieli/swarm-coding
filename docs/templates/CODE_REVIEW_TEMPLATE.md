# Code Review Template

## 📊 Summary Review

### Overall Assessment
[Brief overview of the PR's quality and readiness - 2-3 sentences covering the main strengths and areas for improvement]

**Review Status**: ✅ Approved / 🔄 Needs Changes / ❌ Rejected
**Review Date**: [Date]
**Reviewer**: [Name]

### Review Statistics
- **Files Changed**: [Number]
- **Lines Added**: [Number]
- **Lines Removed**: [Number]
- **Test Coverage**: [Percentage]

## 🚨 Critical Issues
[Issues that MUST be fixed before merging]

1. **[Issue Type]**: [Description and impact]
   - **Severity**: 🔴 Critical
   - **File**: `path/to/file.ext`
   - **Line**: [Line numbers]
   - **Fix**: [Suggested solution]

2. **[Issue Type]**: [Description and impact]
   - **Severity**: 🔴 Critical
   - **File**: `path/to/file.ext`
   - **Line**: [Line numbers]
   - **Fix**: [Suggested solution]

## ⚠️ Major Concerns
[Important issues that should be addressed]

### Architecture Concerns
- [ ] [Concern about design patterns or structure]
- [ ] [Concern about scalability or maintainability]
- [ ] [Concern about dependencies or coupling]

### Performance Concerns
- [ ] [Potential bottleneck or inefficiency]
- [ ] [Memory usage concern]
- [ ] [Algorithm complexity issue]

### Security Vulnerabilities
- [ ] [Security issue description]
- [ ] [Data exposure risk]
- [ ] [Authentication/authorization concern]

## 📝 Code Quality Issues
[Non-critical but important for maintainability]

### Readability & Style
- [ ] [Naming convention issue]
- [ ] [Code organization problem]
- [ ] [Missing or unclear comments]

### Best Practices
- [ ] [Deviation from established patterns]
- [ ] [Missing error handling]
- [ ] [Inadequate logging]

### Testing Gaps
- [ ] [Missing test cases]
- [ ] [Insufficient test coverage]
- [ ] [Test quality issues]

## 💡 Suggestions for Improvement
[Optional improvements that would enhance the code]

1. **Enhancement**: [Description]
   - **Benefit**: [Why this would help]
   - **Example**: [Code snippet if applicable]

2. **Refactoring Opportunity**: [Description]
   - **Current**: [Current approach]
   - **Suggested**: [Better approach]

## ✅ Positive Feedback
[Highlight what was done well]

- 👍 [Good practice or implementation]
- 👍 [Well-structured code section]
- 👍 [Excellent test coverage in specific area]

## 📋 Inline Comments to Add

### File: `path/to/file1.ext`
- **Line 42**: [Specific issue and suggested fix]
  ```diff
  - current code
  + suggested code
  ```
- **Line 156**: [Specific issue and suggested fix]
- **Line 203-210**: [Block-level comment about larger issue]

### File: `path/to/file2.ext`
- **Line 23**: [Specific issue and suggested fix]
- **Line 89**: [Specific issue and suggested fix]

## 🔍 Verification Checklist

### Functionality
- [ ] Feature works as described in PR
- [ ] Edge cases handled properly
- [ ] Backward compatibility maintained
- [ ] No regressions introduced

### Code Quality
- [ ] Code follows project style guide
- [ ] No code duplication
- [ ] Clear variable/function names
- [ ] Appropriate comments/documentation

### Testing
- [ ] Adequate test coverage
- [ ] Tests actually test the functionality
- [ ] Tests pass locally
- [ ] No flaky tests introduced

### Performance
- [ ] No obvious performance issues
- [ ] Resource usage is reasonable
- [ ] Scales appropriately

### Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No security vulnerabilities
- [ ] Follows security best practices

### Documentation
- [ ] API documentation updated
- [ ] README updated if needed
- [ ] Inline documentation adequate
- [ ] Change log updated

## 🎯 Action Items

### Must Fix Before Merge
1. [ ] [Critical issue that blocks merge]
2. [ ] [Another blocking issue]

### Should Fix Soon
1. [ ] [Important but non-blocking issue]
2. [ ] [Technical debt to address]

### Consider for Future
1. [ ] [Long-term improvement]
2. [ ] [Refactoring opportunity]

## 📊 Review Summary

**Decision**: 
- [ ] ✅ **Approved** - Ready to merge
- [ ] ✅ **Approved with comments** - Minor issues but can merge
- [ ] 🔄 **Request changes** - Needs fixes before merge
- [ ] ❌ **Rejected** - Major issues or wrong approach

**Next Steps**:
[Clear description of what the author needs to do next]

## 💬 Additional Comments
[Any other feedback, context, or discussion points]

---
*Review conducted according to: [Link to review guidelines or checklist]*