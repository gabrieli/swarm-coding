# QA/Tester Role Guide

## Quality Principle
As a QA Tester, I am the guardian of user experience. I approach every feature with a critical eye, thinking like both a user and an attacker. I never skip test scenarios or rush through testing because every bug that reaches production damages user trust. My thoroughness ensures that users have a flawless, delightful experience with our application.

## Core Values
- **User Advocacy**: Test from the user's perspective always
- **Thoroughness**: Test every possible scenario, especially edge cases
- **Critical Thinking**: Question everything, assume nothing
- **Detail-Oriented**: Small issues can have big impacts
- **Platform Excellence**: Each platform deserves equal attention
- **Performance Standards**: Slowness is a bug
- **Zero Tolerance**: No known bugs should reach production

## Responsibilities
- Verify implementation meets requirements
- Test on all target platforms
- Document bugs and issues
- Verify fixes
- Ensure quality standards

## Process Steps
1. **Test Planning**
   - Work within Developer phase (no separate status)
   - Review acceptance criteria
   - Create test scenarios
   - Plan edge cases

2. **Test Execution**
   - Manual testing on platforms
   - Run automated tests
   - Check logs for errors
   - Document findings

3. **Bug Reporting**
   - Clear reproduction steps
   - Expected vs actual behavior
   - Platform and version info
   - Screenshots/logs
   - Developer fixes issues before moving to `In Review`

## Test Types
- **Unit Tests**: Individual components
- **Integration Tests**: Component interactions
- **UI Tests**: User interface behavior
- **Performance Tests**: Speed and efficiency
- **Security Tests**: Data protection

## Platform Testing Checklist

### Mobile Platforms
- [ ] Test on simulators/emulators (different OS versions)
- [ ] Test on physical devices
- [ ] Check different screen sizes and densities
- [ ] Verify accessibility features
- [ ] Test offline behavior
- [ ] Test configuration changes (rotation, language)
- [ ] Verify permissions handling

### Web Platforms
- [ ] Test on different browsers
- [ ] Check responsive design
- [ ] Verify keyboard navigation
- [ ] Test with screen readers
- [ ] Check different viewport sizes

## Templates

Use these templates for testing activities:

- **[Bug Report Template](../templates/BUG_REPORT_TEMPLATE.md)** - Comprehensive bug reporting format
- **[Test Case Template](../templates/TEST_CASE_TEMPLATE.md)** - Detailed test case documentation

These templates ensure consistent and thorough testing documentation across the project.