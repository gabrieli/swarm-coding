# Running Tests Guide

This guide provides comprehensive instructions for executing tests in the Pulse project across all platforms and environments.

## Quick Command Reference

```bash
# Run all tests
./gradlew test

# Run Android tests
./gradlew :androidApp:test
./androidApp/run_android_tests.sh

# Run iOS tests
cd iosApp && xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Run shared module tests
./gradlew :shared:allTests

# Run with coverage
./gradlew koverMergedReport
```

## Running Tests by Platform

### Shared Module Tests

#### Run All Shared Tests
```bash
# Run tests for all platforms
./gradlew :shared:allTests

# Run only common tests
./gradlew :shared:commonTest

# Run Android-specific shared tests
./gradlew :shared:androidUnitTest

# Run iOS-specific shared tests
./gradlew :shared:iosTest
```

#### Run Specific Test Classes
```bash
# Run a specific test class
./gradlew :shared:commonTest --tests "MenuParserTest"

# Run tests matching a pattern
./gradlew :shared:commonTest --tests "*Parser*"

# Run a specific test method
./gradlew :shared:commonTest --tests "MenuParserTest.parseMenu - returns empty list when input is null"
```

### Android Tests

#### Unit Tests
```bash
# Run all unit tests
./gradlew :androidApp:test

# Run debug variant tests
./gradlew :androidApp:testDebugUnitTest

# Run release variant tests
./gradlew :androidApp:testReleaseUnitTest

# Run with detailed output
./gradlew :androidApp:test --info

# Run with test logging
./gradlew :androidApp:test --debug-jvm
```

#### UI Tests (Instrumented)
```bash
# Using the convenience script
./androidApp/run_android_tests.sh

# Or manually with Gradle
./gradlew :androidApp:connectedAndroidTest

# Run on specific device
./gradlew :androidApp:connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.device=emulator-5554

# Run specific UI test class
./gradlew :androidApp:connectedAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.pulse.MenuScreenTest
```

#### Running Tests from Android Studio
1. **Unit Tests**: Right-click on test file/class → Run
2. **UI Tests**: Ensure device/emulator is running → Right-click → Run
3. **With Coverage**: Right-click → Run with Coverage

### iOS Tests

#### Unit Tests
```bash
# Run all unit tests
cd iosApp
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iosAppTests

# Run specific test class
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iosAppTests/MenuParserTests

# Run specific test method
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iosAppTests/MenuParserTests/testParseMenu_WhenValidInput_ReturnsMenuItems
```

#### UI Tests
```bash
# Run all UI tests
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iosAppUITests

# Run with specific iOS version
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'

# Run on physical device
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS,name=My iPhone'
```

#### Running Tests from Xcode
1. **All Tests**: Product → Test (⌘U)
2. **Specific Test**: Click diamond next to test method
3. **With Coverage**: Hold ⌥ while selecting Product → Test

### Integration Tests with Supabase

#### Start Local Supabase
```bash
# Navigate to supabase directory
cd supabase

# Start Supabase services
supabase start

# Verify services are running
supabase status
```

#### Run Integration Tests
```bash
# Set environment variables
export SUPABASE_URL=http://localhost:54321
export SUPABASE_ANON_KEY=your-local-anon-key

# Run integration tests
./gradlew :shared:commonTest --tests "*IntegrationTest"

# Run with specific configuration
./gradlew :shared:commonTest \
  -Dsupabase.url=http://localhost:54321 \
  -Dsupabase.key=your-key \
  --tests "SupabaseIntegrationTest"
```

## Test Filtering and Selection

### Gradle Test Filtering

```bash
# Run tests by name pattern
./gradlew test --tests "*Menu*"

# Exclude tests
./gradlew test --exclude "*Slow*"

# Run tests by package
./gradlew test --tests "com.example.pulse.services.*"

# Combine filters
./gradlew test --tests "*Menu*" --exclude "*Integration*"
```

### Using Test Tags/Categories

#### Kotlin Test Categories
```kotlin
// Define categories
interface SlowTests
interface IntegrationTests
interface UITests

// Tag tests
@Category(SlowTests::class, IntegrationTests::class)
class MenuIntegrationTest {
    // ...
}

// Run by category
./gradlew test -Dgroups=SlowTests
./gradlew test -DexcludedGroups=IntegrationTests
```

#### iOS Test Plans
Create `.xctestplan` file:
```json
{
  "configurations": [
    {
      "name": "Unit Tests",
      "options": {
        "targetForVariableExpansion": {
          "containerPath": "container:iosApp.xcodeproj",
          "identifier": "iosApp",
          "name": "iosApp"
        }
      },
      "testTargets": [
        {
          "skippedTests": [
            "iosAppUITests"
          ],
          "target": {
            "containerPath": "container:iosApp.xcodeproj",
            "identifier": "iosAppTests",
            "name": "iosAppTests"
          }
        }
      ]
    }
  ],
  "defaultOptions": {
    "codeCoverage": true
  },
  "version": 1
}
```

## Running Tests with Coverage

### Generate Coverage Reports

#### Kotlin/Android Coverage
```bash
# Generate unified coverage report
./gradlew koverMergedReport

# Generate HTML report
./gradlew koverMergedHtmlReport

# Open report
open build/reports/kover/merged/html/index.html

# Module-specific coverage
./gradlew :shared:koverReport
./gradlew :androidApp:koverReport

# Verify coverage thresholds
./gradlew koverMergedVerify
```

#### iOS Coverage
```bash
# Run with coverage enabled
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Generate coverage report
xcrun xccov view --report --json Result.xcresult > coverage.json

# View in Xcode
open Result.xcresult
```

## Parallel Test Execution

### Android Parallel Testing
```gradle
// In androidApp/build.gradle.kts
android {
    testOptions {
        unitTests.all {
            maxParallelForks = Runtime.getRuntime().availableProcessors()
        }
    }
}
```

### Gradle Parallel Execution
```bash
# Run tests in parallel
./gradlew test --parallel --max-workers=4

# Configure in gradle.properties
org.gradle.parallel=true
org.gradle.workers.max=4
```

### iOS Parallel Testing
```bash
# Run UI tests in parallel
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  -parallel-testing-enabled YES \
  -maximum-concurrent-test-simulator-destinations 2
```

## Continuous Integration Testing

### GitHub Actions Example
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test-shared:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Run shared tests
        run: ./gradlew :shared:allTests
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results-shared
          path: shared/build/test-results/

  test-android:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Run Android tests
        run: ./gradlew :androidApp:test
      
      - name: Run Android UI tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          script: ./gradlew :androidApp:connectedAndroidTest

  test-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install pods
        run: cd iosApp && pod install
      
      - name: Run iOS tests
        run: |
          cd iosApp
          xcodebuild test \
            -workspace iosApp.xcworkspace \
            -scheme iosApp \
            -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Output and Reporting

### Console Output Configuration

#### Gradle Test Output
```gradle
// In build.gradle.kts
tasks.withType<Test> {
    testLogging {
        events("passed", "skipped", "failed", "standardOut", "standardError")
        
        showExceptions = true
        showCauses = true
        showStackTraces = true
        
        // Show test progress
        exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
    }
}
```

#### Verbose Output
```bash
# Show all test output
./gradlew test --info

# Show detailed failure information
./gradlew test --stacktrace

# Debug test execution
./gradlew test --debug
```

### Test Reports

#### HTML Reports Location
```
# Gradle test reports
build/reports/tests/test/index.html
androidApp/build/reports/tests/testDebugUnitTest/index.html
shared/build/reports/tests/allTests/index.html

# Coverage reports
build/reports/kover/merged/html/index.html
androidApp/build/reports/coverage/test/debug/index.html

# iOS reports
DerivedData/iosApp/Logs/Test/*.xcresult
```

#### JUnit XML Reports
```bash
# Configure XML output
tasks.withType<Test> {
    reports {
        junitXml.required.set(true)
        html.required.set(true)
    }
}

# Find XML reports
find . -name "TEST-*.xml"
```

## Debugging Failed Tests

### Android/Kotlin Debugging

#### Run Single Test with Debugging
```bash
# Enable debugging
./gradlew :androidApp:test --debug-jvm --tests "MenuParserTest.parseMenu - returns empty list when input is null"

# In IDE: Set breakpoints and use Debug instead of Run
```

#### Inspect Test Failures
```kotlin
// Add detailed logging
@Test
fun `complex test with debugging`() {
    println("Starting test with state: $currentState")
    
    try {
        // Test code
    } catch (e: Exception) {
        println("Test failed at step X")
        println("Current values: $debugInfo")
        throw e
    }
}
```

### iOS Debugging

#### Xcode Test Debugging
1. Set breakpoints in test code
2. Right-click test → Debug Test
3. Use LLDB commands in console

#### Test Failure Screenshots
```swift
// Automatically capture screenshots on failure
override func tearDown() {
    if let failureCount = testRun?.failureCount, failureCount > 0 {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Failure Screenshot"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    super.tearDown()
}
```

## Performance Optimization

### Speed Up Test Execution

#### Disable Animations
```kotlin
// Android: In test
@get:Rule
val disableAnimationsRule = DisableAnimationsRule()

// iOS: In scheme
Arguments Passed On Launch: -UIAnimationDragCoefficient 10
```

#### Use Test Doubles
```kotlin
// Replace slow operations
class FastMockImageProcessor : ImageProcessor {
    override suspend fun process(image: ByteArray): Result {
        // Return immediately instead of actual processing
        return Result.Success(TestData.mockProcessedImage)
    }
}
```

#### Parallel Execution
```bash
# Maximum parallelization
./gradlew test \
  --parallel \
  --max-workers=8 \
  --configure-on-demand \
  --build-cache
```

### Test Sharding

#### Android Test Sharding
```bash
# Split tests across multiple devices
./gradlew connectedAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.numShards=4 \
  -Pandroid.testInstrumentationRunnerArguments.shardIndex=0
```

#### iOS Test Distribution
```bash
# Use xcodebuild's test-without-building
xcodebuild build-for-testing -workspace iosApp.xcworkspace -scheme iosApp

# Run on multiple simulators
for i in {0..3}; do
  xcodebuild test-without-building \
    -workspace iosApp.xcworkspace \
    -scheme iosApp \
    -destination "platform=iOS Simulator,name=iPhone 15 Clone $i" &
done
wait
```

## Test Environment Configuration

### Environment Variables
```bash
# Set for single test run
SUPABASE_URL=http://localhost:54321 ./gradlew test

# Set in gradle.properties
systemProp.supabase.url=http://localhost:54321
systemProp.supabase.key=test-key

# Access in tests
val supabaseUrl = System.getProperty("supabase.url")
```

### Test Configurations
```kotlin
// Create test configurations
interface TestConfig {
    val apiUrl: String
    val timeout: Long
}

object LocalTestConfig : TestConfig {
    override val apiUrl = "http://localhost:8080"
    override val timeout = 5000L
}

object CITestConfig : TestConfig {
    override val apiUrl = "http://test-api:8080"
    override val timeout = 30000L
}

// Use in tests
val config = if (System.getenv("CI") != null) CITestConfig else LocalTestConfig
```

## Common Test Running Issues

### Out of Memory Errors
```gradle
// Increase test JVM memory
tasks.withType<Test> {
    maxHeapSize = "2g"
    jvmArgs = listOf("-XX:MaxPermSize=512m")
}
```

### Flaky Tests
```kotlin
// Retry flaky tests
@RetryingTest(3)
fun `potentially flaky test`() {
    // Test code
}

// Or in Gradle
tasks.withType<Test> {
    retry {
        maxRetries = 3
        maxFailures = 5
    }
}
```

### Test Timeouts
```kotlin
// Set test timeout
@Test(timeout = 5000) // 5 seconds
fun `test with timeout`() {
    // Test code
}

// Gradle configuration
tasks.withType<Test> {
    timeout.set(Duration.ofMinutes(10))
}
```

## Next Steps

- Review [BEST_PRACTICES.md](./BEST_PRACTICES.md) for testing patterns
- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
- Set up [TEST_COVERAGE.md](./TEST_COVERAGE.md) monitoring