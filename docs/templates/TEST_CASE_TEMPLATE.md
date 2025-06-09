# Test Case Template

## 📋 Test Case Information

**Test Case ID**: TC-[Number]
**Test Case Name**: [Descriptive name]
**Feature/Component**: [What is being tested]
**Priority**: 🔴 High / 🟡 Medium / 🟢 Low
**Type**: Unit / Integration / E2E / Performance / Security
**Automated**: Yes / No / Planned

## 📝 Test Description

### Objective
[Clear statement of what this test is verifying]

### Background
[Any context or setup information needed to understand the test]

### Dependencies
- **Test Data**: [Required test data]
- **Environment**: [Specific environment needs]
- **Other Tests**: [Tests that must run before this one]

## 🔧 Test Setup

### Preconditions
1. [Condition that must be true before test starts]
2. [Another precondition]
3. [Continue as needed]

### Test Data
```
// Example test data structure
{
  "user": {
    "id": "test-user-123",
    "email": "test@example.com",
    "role": "admin"
  },
  "testData": {
    // Additional test data
  }
}
```

### Environment Configuration
- **URL**: [Test environment URL]
- **Credentials**: [How to obtain test credentials]
- **Feature Flags**: [Any required feature flags]

## 📋 Test Steps

### Manual Test Steps
1. **Action**: [First action to perform]
   - **Expected**: [What should happen]
   - **Actual**: [Fill during execution]
   - **Pass/Fail**: [ ]

2. **Action**: [Second action to perform]
   - **Expected**: [What should happen]
   - **Actual**: [Fill during execution]
   - **Pass/Fail**: [ ]

3. **Action**: [Continue with all steps]
   - **Expected**: [What should happen]
   - **Actual**: [Fill during execution]
   - **Pass/Fail**: [ ]

### Automated Test Code
```typescript
describe('[Feature Name]', () => {
  beforeEach(() => {
    // Setup code
  });

  it('[test case name]', async () => {
    // Arrange
    const testData = createTestData();
    
    // Act
    const result = await performAction(testData);
    
    // Assert
    expect(result).toBe(expectedValue);
  });

  afterEach(() => {
    // Cleanup code
  });
});
```

## ✅ Expected Results

### Success Criteria
- [ ] [Specific measurable outcome]
- [ ] [Another expected outcome]
- [ ] [Performance requirement if applicable]

### Validation Points
1. **UI Validation**: [What should be visible/hidden]
2. **Data Validation**: [What data should be present]
3. **State Validation**: [What state changes should occur]
4. **Integration Validation**: [External system interactions]

## 🔍 Actual Results

### Test Execution Details
- **Executed By**: [Tester name]
- **Execution Date**: [Date]
- **Environment**: [Where test was run]
- **Build/Version**: [Version tested]

### Results
- **Status**: ✅ Pass / ❌ Fail / ⏭️ Skipped / 🔄 Blocked
- **Duration**: [How long test took]
- **Screenshots**: [Attach if applicable]

### Failure Details (if applicable)
- **Failure Step**: [Which step failed]
- **Error Message**: [Exact error message]
- **Stack Trace**: [If available]
- **Screenshots/Videos**: [Evidence of failure]

## 🐛 Defects

### Related Defects
| Defect ID | Description | Status |
|-----------|-------------|--------|
| [BUG-123] | [Description] | Open |

### New Defects Found
| Step | Description | Severity |
|------|-------------|----------|
| [Step #] | [What went wrong] | High/Medium/Low |

## 📊 Test Coverage

### Requirements Covered
- [ ] [Requirement ID]: [Description]
- [ ] [Requirement ID]: [Description]
- [ ] [User Story ID]: [Description]

### Edge Cases
- [ ] [Edge case 1]
- [ ] [Edge case 2]
- [ ] [Boundary condition]

### Negative Tests
- [ ] [Invalid input test]
- [ ] [Error handling test]
- [ ] [Security test]

## 🔄 Test Variations

### Data Variations
| Variation | Data Set | Expected Result | Status |
|-----------|----------|-----------------|--------|
| Valid User | Standard | Success | ✅ |
| Invalid Email | Bad email | Error message | ✅ |
| Empty Fields | Null values | Validation error | ❌ |

### Platform Variations
| Platform | Version | Status | Notes |
|----------|---------|--------|-------|
| Chrome | Latest | ✅ Pass | |
| Safari | Latest | ✅ Pass | |
| Mobile Web | iOS 16 | ❌ Fail | Layout issue |

## 📝 Notes & Observations

### Performance Notes
- [Loading time observations]
- [Resource usage notes]
- [Scalability concerns]

### Usability Notes
- [User experience observations]
- [Confusion points]
- [Improvement suggestions]

### Technical Notes
- [Implementation details noticed]
- [Potential issues spotted]
- [Optimization opportunities]

## 🔗 References

### Documentation
- **Feature Spec**: [Link to specification]
- **API Docs**: [Link to API documentation]
- **User Guide**: [Link to user documentation]

### Related Tests
- **Prerequisite**: [TC-101 - Test that must run first]
- **Related**: [TC-102 - Similar test case]
- **Regression**: [TC-103 - Part of regression suite]

## ✏️ Maintenance

### Last Updated
- **Date**: [Date]
- **By**: [Name]
- **Changes**: [What was updated]

### Review Schedule
- **Next Review**: [Date]
- **Reviewer**: [Name]
- **Reason**: [Why review is needed]

---
*Test case template - Ensure all sections are completed before test execution*