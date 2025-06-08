# Testing Troubleshooting Guide

This guide helps you diagnose and fix common testing issues in your project across all platforms.

## Quick Diagnostics

### Test Failure Checklist
1. ✓ Is the test environment properly configured?
2. ✓ Are all dependencies up to date?
3. ✓ Is the test database/service running?
4. ✓ Are there any hardcoded values or timeouts?
5. ✓ Is the test isolated from other tests?
6. ✓ Are you using the correct test configuration?

### Common Symptoms and Solutions

| Symptom | Likely Cause | Quick Fix |
|---------|--------------|-----------|
| All tests fail | Environment issue | Check setup, clean build |
| Random failures | Flaky tests | Add proper waits, remove delays |
| Tests pass locally, fail in CI | Environment differences | Check CI configuration |
| Slow test execution | No parallelization | Enable parallel execution |
| Out of memory | Large test data | Increase heap size |

## Platform-Specific Issues

### Android/Kotlin Issues

#### Gradle Build Failures

**Problem**: `Could not resolve dependencies`
```
FAILURE: Build failed with an exception.
* What went wrong:
Could not resolve all dependencies for configuration ':androidApp:debugUnitTestRuntimeClasspath'.
```

**Solution**:
```bash
# Clear Gradle cache
./gradlew clean
rm -rf ~/.gradle/caches

# Refresh dependencies
./gradlew build --refresh-dependencies

# If still failing, check proxy settings
# In gradle.properties:
systemProp.http.proxyHost=your-proxy
systemProp.http.proxyPort=8080
```

#### Test Compilation Errors

**Problem**: `Unresolved reference: test`
```kotlin
import kotlin.test.* // Error: Unresolved reference
```

**Solution**:
```kotlin
// In build.gradle.kts
dependencies {
    testImplementation(kotlin("test"))
    testImplementation(kotlin("test-junit"))
}

// For Android tests
androidTestImplementation(kotlin("test"))
androidTestImplementation("androidx.test:runner:1.5.2")
```

#### Instrumented Test Failures

**Problem**: `No connected devices`
```
> Task :androidApp:connectedDebugAndroidTest FAILED
com.android.builder.testing.api.DeviceException: No connected devices!
```

**Solution**:
```bash
# Start emulator
emulator -list-avds
emulator -avd Pixel_7_API_34

# Or use Gradle managed devices
android {
    testOptions {
        managedDevices {
            devices {
                maybeCreate<ManagedVirtualDevice>("pixel7api34").apply {
                    device = "Pixel 7"
                    apiLevel = 34
                    systemImageSource = "google"
                }
            }
        }
    }
}

# Run with managed device
./gradlew pixel7api34DebugAndroidTest
```

### iOS/Swift Issues

#### Pod Installation Failures

**Problem**: `Unable to find a specification for 'XCTest'`
```
[!] Unable to find a specification for `XCTest`
```

**Solution**:
```bash
cd iosApp

# Clean pods
pod deintegrate
rm -rf Pods Podfile.lock

# Clear cache
pod cache clean --all

# Reinstall
pod install --repo-update
```

#### Simulator Issues

**Problem**: `Failed to boot simulator`
```
xcodebuild: error: Failed to build workspace iosApp.xcworkspace with scheme iosApp.
Reason: The simulator failed to boot.
```

**Solution**:
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all

# Create new simulator
xcrun simctl create "iPhone 15 Test" "iPhone 15" iOS17.2

# Boot simulator manually
xcrun simctl boot "iPhone 15 Test"

# List available runtimes
xcrun simctl list runtimes
```

#### Code Signing Issues

**Problem**: `Code signing is required for product type 'Unit Test Bundle'`

**Solution**:
```bash
# In test target Build Settings:
# Code Signing Identity = "Sign to Run Locally"
# Code Signing Style = Automatic
# Development Team = None

# Or in command line:
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

### Shared Module Issues

#### Platform-Specific Test Failures

**Problem**: `expect/actual declarations don't match`
```
e: Expected function 'getCurrentTimeMillis' has no actual declaration in module
```

**Solution**:
```kotlin
// In commonMain
expect fun getCurrentTimeMillis(): Long

// In androidMain
actual fun getCurrentTimeMillis(): Long = System.currentTimeMillis()

// In iosMain
actual fun getCurrentTimeMillis(): Long = 
    NSDate().timeIntervalSince1970.toLong() * 1000
```

#### Coroutine Test Failures

**Problem**: `Module with the Main dispatcher had failed to initialize`

**Solution**:
```kotlin
// In test
class MyTest {
    @BeforeTest
    fun setup() {
        Dispatchers.setMain(StandardTestDispatcher())
    }
    
    @AfterTest
    fun teardown() {
        Dispatchers.resetMain()
    }
    
    @Test
    fun `test with coroutines`() = runTest {
        // Test code
    }
}
```

## Test Execution Issues

### Flaky Tests

#### Timing Issues

**Problem**: Tests randomly fail with timing-related errors

**Solution**:
```kotlin
// ❌ Bad - Fixed delays
@Test
fun `flaky test with sleep`() {
    viewModel.loadData()
    Thread.sleep(1000) // Unreliable!
    assertEquals(5, viewModel.items.size)
}

// ✅ Good - Proper synchronization
@Test
fun `stable test with proper waiting`() = runTest {
    viewModel.loadData()
    
    // Wait for state change
    viewModel.state.test {
        val loaded = awaitItem()
        assertEquals(5, loaded.items.size)
    }
}

// For UI tests
composeTestRule.waitUntil(timeoutMillis = 5000) {
    composeTestRule
        .onAllNodesWithTag("menu_item")
        .fetchSemanticsNodes()
        .isNotEmpty()
}
```

#### Race Conditions

**Problem**: Tests fail when run in parallel but pass individually

**Solution**:
```kotlin
// Ensure test isolation
class PotentiallyFlaky Test {
    // Don't use shared state
    companion object {
        @JvmStatic
        var sharedState = mutableListOf<String>() // ❌ Bad!
    }
    
    // Use instance state instead
    private val testState = mutableListOf<String>() // ✅ Good
    
    @BeforeEach
    fun setup() {
        testState.clear()
    }
}

// Or disable parallel execution for specific tests
@Execution(ExecutionMode.SAME_THREAD)
class SequentialTestSuite {
    // Tests run sequentially
}
```

### Memory Issues

#### Out of Memory Errors

**Problem**: `java.lang.OutOfMemoryError: Java heap space`

**Solution**:
```gradle
// In gradle.properties
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m

// For specific test tasks
tasks.withType<Test> {
    maxHeapSize = "2g"
    jvmArgs = listOf(
        "-XX:MaxMetaspaceSize=512m",
        "-XX:+HeapDumpOnOutOfMemoryError"
    )
}

// For Android instrumented tests
android {
    defaultConfig {
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }
}
```

#### Memory Leaks in Tests

**Problem**: Tests gradually slow down and consume more memory

**Solution**:
```kotlin
class MemoryLeakTest {
    private var largeObject: LargeObject? = null
    
    @AfterEach
    fun cleanup() {
        // Clean up references
        largeObject?.dispose()
        largeObject = null
        
        // Force garbage collection (use sparingly)
        System.gc()
    }
}

// For Android views
@After
fun tearDown() {
    scenario?.close()
    IdlingRegistry.getInstance().unregister(idlingResource)
}
```

## Integration Test Issues

### Supabase Connection Issues

**Problem**: `Connection refused` when running integration tests

**Solution**:
```bash
# 1. Check if Supabase is running
docker ps | grep supabase

# 2. Start Supabase if not running
cd supabase
supabase start

# 3. Check service URLs
supabase status

# 4. Verify in test
@Test
fun `verify supabase connection`() = runTest {
    val client = createSupabaseClient(
        supabaseUrl = "http://localhost:54321",
        supabaseKey = System.getenv("SUPABASE_ANON_KEY") 
            ?: "your-anon-key"
    )
    
    // Test connection
    val response = client.from("test_table").select().execute()
    assertNotNull(response)
}
```

### Mock Server Issues

**Problem**: `SocketTimeoutException` in API tests

**Solution**:
```kotlin
class ApiTest {
    private val mockServer = MockWebServer()
    
    @BeforeTest
    fun setup() {
        mockServer.start()
        // Configure client with longer timeout
        apiClient = ApiClient(
            baseUrl = mockServer.url("/").toString(),
            connectTimeout = 30.seconds,
            readTimeout = 30.seconds
        )
    }
    
    @Test
    fun `handle slow responses`() = runTest {
        mockServer.enqueue(
            MockResponse()
                .setBody("""{"status": "ok"}""")
                .setBodyDelay(2, TimeUnit.SECONDS) // Simulate slow response
        )
        
        val response = apiClient.getStatus()
        assertEquals("ok", response.status)
    }
}
```

## CI/CD Test Issues

### Environment Differences

**Problem**: Tests pass locally but fail in CI

**Solution**:
```yaml
# GitHub Actions - Match local environment
jobs:
  test:
    runs-on: macos-latest # Match your local OS
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17' # Match local Java version
      
      - name: Setup Android SDK
        uses: android-actions/setup-android@v2
        
      - name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
            ~/.konan
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
```

### Timeout Issues

**Problem**: CI tests timeout after 6 hours

**Solution**:
```yaml
# Split tests into smaller jobs
jobs:
  unit-tests:
    timeout-minutes: 30
    steps:
      - run: ./gradlew :shared:test :androidApp:test
  
  ui-tests:
    timeout-minutes: 45
    steps:
      - run: ./gradlew :androidApp:connectedAndroidTest
  
  ios-tests:
    timeout-minutes: 45
    steps:
      - run: xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp
```

## Debugging Techniques

### Enable Verbose Logging

```kotlin
// Kotlin tests
@Test
fun `debug failing test`() {
    // Add logging
    println("DEBUG: Starting test with state: $initialState")
    
    try {
        val result = performOperation()
        println("DEBUG: Operation result: $result")
    } catch (e: Exception) {
        println("DEBUG: Exception caught: ${e.message}")
        e.printStackTrace()
        throw e
    }
}

// Gradle verbose output
./gradlew test --info --stacktrace
```

### Capture Test Artifacts

```kotlin
// Screenshot on failure (Android)
@Rule
@JvmField
val screenshotRule = ScreenshotRule()

@Test
fun `capture screenshot on failure`() {
    onView(withId(R.id.button)).perform(click())
    // Screenshot automatically captured if test fails
}

// iOS screenshot
override func tearDown() {
    if testRun?.failureCount ?? 0 > 0 {
        add(XCTAttachment(screenshot: XCUIScreen.main.screenshot()))
    }
}
```

### Test Report Analysis

```bash
# Find test reports
find . -name "TEST-*.xml" -o -name "*.html" | grep -E "(test-results|reports)"

# Common locations:
# build/reports/tests/test/index.html
# build/test-results/test/TEST-*.xml
# androidApp/build/reports/androidTests/connected/index.html
# iosApp/build/reports/tests/index.html
```

## Performance Optimization

### Slow Test Suite

**Problem**: Test suite takes too long to run

**Solution**:
```kotlin
// 1. Enable parallel execution
tasks.withType<Test> {
    maxParallelForks = (Runtime.getRuntime().availableProcessors() / 2)
        .coerceAtLeast(1)
}

// 2. Use test sharding
@LargeTest
@RunWith(AndroidJUnit4::class)
@ShardTest(shardIndex = 0, numShards = 4)
class MenuScreenTest {
    // Tests will be distributed across 4 shards
}

// 3. Skip slow tests in development
./gradlew test -DexcludeSlowTests=true
```

### Database Test Performance

```kotlin
// Use in-memory database
@get:Rule
val databaseRule = DatabaseRule.inMemory()

// Batch operations
@Test
fun `batch insert performance`() = runTest {
    val items = List(1000) { createMenuItem(it) }
    
    // Slow: Individual inserts
    // items.forEach { dao.insert(it) }
    
    // Fast: Batch insert
    dao.insertAll(items)
}
```

## Common Error Messages

### Error Reference Table

| Error Message | Cause | Solution |
|--------------|-------|----------|
| `Test instrumentation process crashed` | Memory/timeout issue | Increase heap size, reduce test scope |
| `Mockito cannot mock/spy because: - final class` | Mocking final class | Open class or use mockk |
| `No tests found for given includes` | Wrong test filter | Check test naming pattern |
| `Unable to create test AVD` | Missing system image | Install via SDK Manager |
| `Test framework quit unexpectedly` | Configuration issue | Check test runner setup |

## Recovery Procedures

### Complete Test Environment Reset

```bash
#!/bin/bash
# reset-test-env.sh

echo "🧹 Cleaning test environment..."

# Stop all services
docker stop $(docker ps -q)
supabase stop

# Clean Gradle
./gradlew clean
rm -rf ~/.gradle/caches/transforms-*
rm -rf ~/.gradle/caches/build-cache-*

# Clean iOS
cd iosApp
xcodebuild clean
rm -rf ~/Library/Developer/Xcode/DerivedData
pod deintegrate && pod install
cd ..

# Clean Android
rm -rf ~/.android/avd/*.avd/*.lock
rm -rf ~/.android/cache

# Restart services
supabase start
emulator -avd Pixel_7_API_34 &

echo "✅ Test environment reset complete"
```

## Getting Help

### Diagnostic Information to Collect

When asking for help, provide:

1. **Environment Info**
   ```bash
   # System info
   uname -a
   java -version
   gradle --version
   xcodebuild -version
   
   # Project info
   git rev-parse HEAD
   git status
   ```

2. **Full Error Output**
   ```bash
   # Run with maximum verbosity
   ./gradlew test --debug --stacktrace > test-output.log 2>&1
   ```

3. **Test Configuration**
   - build.gradle.kts files
   - Test class that's failing
   - CI configuration if applicable

### Where to Get Help

1. Check this troubleshooting guide
2. Search existing issues on GitHub
3. Ask in team chat with diagnostic info
4. Create detailed bug report with reproduction steps