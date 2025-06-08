# Project Testing Documentation

Welcome to the project testing documentation. This guide provides comprehensive information about testing practices, conventions, and guidelines for your multi-platform project.

## Overview

Your project uses a multi-platform architecture with Kotlin Multiplatform Mobile (KMM) for shared code and platform-specific implementations for iOS and Android. Our testing strategy reflects this architecture with:

- **Shared Tests**: Common business logic tests that run on all platforms
- **Platform-Specific Tests**: iOS and Android specific implementations
- **UI Tests**: Platform-specific UI automation tests
- **Integration Tests**: End-to-end testing with external services

## Documentation Structure

### Core Testing Guides

- [Unit Testing](./UNIT_TESTING.md) - Writing and running unit tests across platforms
- [UI Testing](./UI_TESTING.md) - Automated UI testing for iOS and Android
- [Integration Testing](./INTEGRATION_TESTING.md) - Testing external service integrations
- [Test Coverage](./TEST_COVERAGE.md) - Coverage requirements and measurement
- [Troubleshooting](./TROUBLESHOOTING.md) - Common issues and solutions

## Quick Start

### Running Tests Locally

#### Android Tests
```bash
# Run all Android unit tests
./gradlew :androidApp:test

# Run Android UI tests
./androidApp/run_android_tests.sh

# Run specific test class
./gradlew :androidApp:testDebugUnitTest --tests "*.CameraScreenTest"
```

#### iOS Tests
```bash
# Run all iOS tests
cd iosApp && xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test file
xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:iosAppTests/CameraIntegrationTests
```

#### Shared Tests
```bash
# Run all shared tests
./gradlew :shared:allTests

# Run common tests only
./gradlew :shared:commonTest
```

## Test Organization

### Directory Structure
```
your-project/
├── shared/
│   ├── src/
│   │   ├── commonTest/        # Shared test code
│   │   ├── androidUnitTest/   # Android-specific unit tests
│   │   └── iosTest/           # iOS-specific unit tests
├── androidApp/
│   ├── src/
│   │   ├── test/              # Android unit tests
│   │   └── androidTest/       # Android UI tests
└── iosApp/
    ├── iosAppTests/           # iOS unit tests
    └── iosAppUITests/         # iOS UI tests
```

## Testing Principles

### 1. Test Pyramid
We follow the test pyramid approach:
- **Unit Tests** (70%): Fast, isolated tests for individual components
- **Integration Tests** (20%): Tests for component interactions
- **UI Tests** (10%): End-to-end user flow tests

### 2. Platform Parity
Ensure equivalent test coverage across platforms:
- Shared business logic tested in common tests
- Platform-specific implementations tested separately
- UI behaviors tested on both iOS and Android

### 3. Test Naming Conventions

#### Kotlin Tests
```kotlin
@Test
fun `function name - expected behavior when condition`() {
    // Test implementation
}

// Example:
@Test
fun `processMenuImage - returns error when base64 string is empty`() {
    // ...
}
```

#### Swift Tests
```swift
func testFunctionName_WhenCondition_ExpectedBehavior() {
    // Test implementation
}

// Example:
func testProcessImage_WhenImageIsValid_ReturnsProcessedData() {
    // ...
}
```

### 4. Test Independence
- Each test should be independent and not rely on other tests
- Use proper setup and teardown methods
- Avoid shared mutable state between tests

## Continuous Integration

Our CI/CD pipeline runs tests automatically:

1. **Pull Request Checks**
   - All unit tests must pass
   - Code coverage must meet minimum thresholds
   - UI tests run on key user flows

2. **Main Branch Protection**
   - No direct commits to main
   - All tests must pass before merge
   - Coverage reports generated automatically

## Getting Help

- Check the [Troubleshooting Guide](./TROUBLESHOOTING.md) for common issues
- Review platform-specific guides for detailed instructions
- Consult the example tests in the codebase

## Contributing

When adding new features:
1. Write tests first (TDD approach encouraged)
2. Ensure tests pass on all platforms
3. Update documentation if testing approach changes
4. Include tests in your pull request

## Next Steps

- [Unit Testing Guide](./UNIT_TESTING.md) - Start here for writing your first tests
- [UI Testing Guide](./UI_TESTING.md) - Learn about automated UI testing
- [Test Coverage](./TEST_COVERAGE.md) - Understanding our coverage requirements