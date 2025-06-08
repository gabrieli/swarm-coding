# UI Testing Guide

This guide covers UI testing practices for iOS and Android in your project. UI tests verify the application's user interface behaves correctly from the user's perspective.

## Overview

UI tests (also called instrumentation tests or UI automation tests) simulate real user interactions with your app. They:
- Test complete user flows
- Verify UI elements appear and function correctly
- Ensure proper navigation between screens
- Validate integration between components

## Platform-Specific Setup

### Android UI Testing with Compose

Android UI tests use Jetpack Compose Testing APIs and are located in `androidApp/src/androidTest/`.

#### Test Dependencies
```kotlin
// androidApp/build.gradle.kts
dependencies {
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
```

#### Base Test Setup
```kotlin
// androidApp/src/androidTest/.../utils/ComposeTestBase.kt
abstract class ComposeTestBase {
    @get:Rule
    val composeTestRule = createComposeRule()
    
    fun assertElementExists(tag: String) {
        composeTestRule.onNodeWithTag(tag).assertExists()
    }
    
    fun assertElementIsDisplayed(tag: String) {
        composeTestRule.onNodeWithTag(tag).assertIsDisplayed()
    }
    
    fun clickElement(tag: String) {
        composeTestRule.onNodeWithTag(tag).performClick()
    }
    
    fun waitUntilExists(tag: String, timeoutMillis: Long = 5000) {
        composeTestRule.waitUntil(timeoutMillis) {
            composeTestRule.onAllNodesWithTag(tag)
                .fetchSemanticsNodes().isNotEmpty()
        }
    }
}
```

#### Writing Android UI Tests
```kotlin
@RunWith(AndroidJUnit4::class)
class CameraScreenTest : ComposeTestBase() {
    
    @Test
    fun cameraScreen_displaysAllRequiredElements() {
        // Given: Camera screen is displayed
        composeTestRule.setContent {
            CameraScreen(
                onNavigateBack = {},
                onImageCaptured = {}
            )
        }
        
        // Then: Verify UI elements
        assertElementExists("camera_preview")
        assertElementExists("capture_button")
        assertElementExists("back_button")
        
        // Verify text content
        composeTestRule.onNodeWithText("Take Photo")
            .assertExists()
            .assertIsDisplayed()
    }
    
    @Test
    fun captureButton_triggersImageCapture() {
        var imageCaptured = false
        
        composeTestRule.setContent {
            CameraScreen(
                onNavigateBack = {},
                onImageCaptured = { imageCaptured = true }
            )
        }
        
        // When: User clicks capture button
        clickElement("capture_button")
        
        // Then: Image capture callback is triggered
        composeTestRule.waitUntil {
            imageCaptured
        }
        assert(imageCaptured)
    }
}
```

### iOS UI Testing with XCTest

iOS UI tests use XCUITest framework and are located in `iosApp/iosAppUITests/`.

#### Base Test Setup
```swift
// iosApp/iosAppUITests/Helpers/XCUITestBase.swift
class XCUITestBase: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        element.waitForExistence(timeout: timeout)
    }
    
    func takeScreenshot(name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
```

#### Writing iOS UI Tests
```swift
final class CameraScreenTests: XCUITestBase {
    
    func testCameraScreen_DisplaysAllRequiredElements() {
        // Given: Navigate to camera screen
        let cameraCard = app.otherElements["menuSourceCard_camera"]
        XCTAssertTrue(waitForElement(cameraCard))
        cameraCard.tap()
        
        // Then: Verify camera screen elements
        XCTAssertTrue(app.otherElements["camera_preview"].exists)
        XCTAssertTrue(app.buttons["capture_button"].exists)
        XCTAssertTrue(app.buttons["back_button"].exists)
        
        // Take screenshot for visual verification
        takeScreenshot(name: "camera_screen_loaded")
    }
    
    func testCaptureButton_TriggersImageCapture() {
        // Given: Navigate to camera screen
        let cameraCard = app.otherElements["menuSourceCard_camera"]
        cameraCard.tap()
        
        // When: Tap capture button
        let captureButton = app.buttons["capture_button"]
        XCTAssertTrue(waitForElement(captureButton))
        captureButton.tap()
        
        // Then: Verify capture process
        let processingIndicator = app.activityIndicators["processing_indicator"]
        XCTAssertTrue(waitForElement(processingIndicator))
    }
}
```

## UI Testing Best Practices

### 1. Use Accessibility Identifiers

#### Android (testTag)
```kotlin
@Composable
fun MenuCard(
    title: String,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .testTag("menuCard_$title") // Unique test tag
            .clickable { onClick() }
    ) {
        Text(
            text = title,
            modifier = Modifier.testTag("menuCard_title_$title")
        )
    }
}
```

#### iOS (accessibilityIdentifier)
```swift
struct MenuCard: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .accessibilityIdentifier("menuCard_title_\(title)")
            }
        }
        .accessibilityIdentifier("menuCard_\(title)")
    }
}
```

### 2. Page Object Pattern

Create page objects to encapsulate UI interactions:

#### Android Example
```kotlin
class CameraScreenRobot(private val composeRule: ComposeTestRule) {
    
    fun verifyCameraScreenDisplayed() = apply {
        composeRule.onNodeWithTag("camera_screen").assertIsDisplayed()
    }
    
    fun clickCaptureButton() = apply {
        composeRule.onNodeWithTag("capture_button").performClick()
    }
    
    fun verifyProcessingIndicatorShown() = apply {
        composeRule.onNodeWithTag("processing_indicator").assertIsDisplayed()
    }
    
    fun waitForProcessingComplete() = apply {
        composeRule.waitUntil(10000) {
            composeRule.onAllNodesWithTag("processing_indicator")
                .fetchSemanticsNodes().isEmpty()
        }
    }
}

// Usage in test
@Test
fun testCompletePhotoCapture() {
    val robot = CameraScreenRobot(composeTestRule)
    
    robot
        .verifyCameraScreenDisplayed()
        .clickCaptureButton()
        .verifyProcessingIndicatorShown()
        .waitForProcessingComplete()
}
```

#### iOS Example
```swift
class CameraScreenPage {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var cameraPreview: XCUIElement {
        app.otherElements["camera_preview"]
    }
    
    var captureButton: XCUIElement {
        app.buttons["capture_button"]
    }
    
    var processingIndicator: XCUIElement {
        app.activityIndicators["processing_indicator"]
    }
    
    func verifyCameraScreenDisplayed() {
        XCTAssertTrue(cameraPreview.exists)
        XCTAssertTrue(captureButton.exists)
    }
    
    func capturePhoto() {
        captureButton.tap()
    }
    
    func waitForProcessingComplete() {
        let notExists = NSPredicate(format: "exists == false")
        expectation(for: notExists, evaluatedWith: processingIndicator)
        waitForExpectations(timeout: 10)
    }
}

// Usage in test
func testCompletePhotoCapture() {
    let cameraPage = CameraScreenPage(app: app)
    
    cameraPage.verifyCameraScreenDisplayed()
    cameraPage.capturePhoto()
    cameraPage.waitForProcessingComplete()
}
```

### 3. Handling Asynchronous Operations

#### Android
```kotlin
@Test
fun testAsyncDataLoading() {
    composeTestRule.setContent {
        FoodMenuScreen()
    }
    
    // Wait for loading to complete
    composeTestRule.waitUntil(timeoutMillis = 10000) {
        composeTestRule.onAllNodesWithTag("loading_indicator")
            .fetchSemanticsNodes().isEmpty()
    }
    
    // Verify data is displayed
    composeTestRule.onNodeWithText("Burger").assertIsDisplayed()
    composeTestRule.onNodeWithText("$10.99").assertIsDisplayed()
}
```

#### iOS
```swift
func testAsyncDataLoading() {
    // Wait for loading indicator to disappear
    let loadingIndicator = app.activityIndicators["loading_indicator"]
    let notExists = NSPredicate(format: "exists == false")
    expectation(for: notExists, evaluatedWith: loadingIndicator)
    waitForExpectations(timeout: 10)
    
    // Verify data is displayed
    XCTAssertTrue(app.staticTexts["Burger"].exists)
    XCTAssertTrue(app.staticTexts["$10.99"].exists)
}
```

### 4. Testing Navigation Flows

#### Android
```kotlin
@Test
fun testCompleteMenuSelectionFlow() {
    // Start at menu selection
    composeTestRule.setContent {
        YourApp()
    }
    
    // Select camera option
    clickElement("menuSourceCard_camera")
    waitUntilExists("camera_screen")
    
    // Capture photo
    clickElement("capture_button")
    waitUntilExists("processing_screen")
    
    // Wait for menu to load
    waitUntilExists("food_menu_screen", timeoutMillis = 15000)
    
    // Verify we reached the menu
    assertElementExists("food_item_0")
    composeTestRule.onNodeWithText("Swipe to rate").assertIsDisplayed()
}
```

#### iOS
```swift
func testCompleteMenuSelectionFlow() {
    // Select camera option
    let cameraCard = app.otherElements["menuSourceCard_camera"]
    XCTAssertTrue(waitForElement(cameraCard))
    cameraCard.tap()
    
    // Capture photo
    let captureButton = app.buttons["capture_button"]
    XCTAssertTrue(waitForElement(captureButton))
    captureButton.tap()
    
    // Wait for processing
    let processingScreen = app.otherElements["processing_screen"]
    XCTAssertTrue(waitForElement(processingScreen))
    
    // Wait for menu to load
    let foodMenuItem = app.otherElements["food_item_0"]
    XCTAssertTrue(waitForElement(foodMenuItem, timeout: 15))
    
    // Verify we reached the menu
    XCTAssertTrue(app.staticTexts["Swipe to rate"].exists)
}
```

## Running UI Tests

### Android

```bash
# Run all UI tests
./androidApp/run_android_tests.sh

# Run specific test class
./gradlew :androidApp:connectedDebugAndroidTest --tests="*.CameraScreenTest"

# Run on specific device
./gradlew :androidApp:connectedDebugAndroidTest -Pandroid.testInstrumentationRunnerArguments.class=com.example.YOUR_PROJECT_NAME.YourScreenTest
```

### iOS

```bash
# Run all UI tests
xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:iosAppUITests

# Run specific test file
xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:iosAppUITests/CameraScreenTests

# Run specific test method
xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:iosAppUITests/CameraScreenTests/testCameraScreen_DisplaysAllRequiredElements
```

## UI Test Organization

### Test Structure
```
androidApp/src/androidTest/
├── java/com/example/YOUR_ORGANIZATION/YOUR_PROJECT_NAME/android/
│   ├── ui/                    # UI test files
│   │   ├── CameraScreenTest.kt
│   │   ├── FoodMenuScreenTest.kt
│   │   └── NavigationTest.kt
│   ├── utils/                  # Test utilities
│   │   └── ComposeTestBase.kt
│   └── robots/                 # Page objects
│       ├── CameraRobot.kt
│       └── MenuRobot.kt

iosApp/iosAppUITests/
├── Screens/                    # Screen-specific tests
│   ├── CameraScreenTests.swift
│   ├── FoodMenuScreenTests.swift
│   └── NavigationTests.swift
├── Helpers/                    # Test utilities
│   └── XCUITestBase.swift
└── Pages/                      # Page objects
    ├── CameraPage.swift
    └── MenuPage.swift
```

## Common UI Testing Patterns

### 1. Testing Swipe Gestures

#### Android
```kotlin
@Test
fun testSwipeGesture() {
    composeTestRule.onNodeWithTag("swipeable_card")
        .performTouchInput {
            swipeLeft()
        }
    
    // Verify swipe result
    composeTestRule.onNodeWithText("Next Item").assertIsDisplayed()
}
```

#### iOS
```swift
func testSwipeGesture() {
    let swipeableCard = app.otherElements["swipeable_card"]
    swipeableCard.swipeLeft()
    
    // Verify swipe result
    XCTAssertTrue(app.staticTexts["Next Item"].exists)
}
```

### 2. Testing Text Input

#### Android
```kotlin
@Test
fun testTextInput() {
    composeTestRule.onNodeWithTag("search_field")
        .performTextInput("Burger")
    
    // Verify filtered results
    composeTestRule.onNodeWithText("Burger").assertIsDisplayed()
    composeTestRule.onNodeWithText("Pizza").assertDoesNotExist()
}
```

#### iOS
```swift
func testTextInput() {
    let searchField = app.textFields["search_field"]
    searchField.tap()
    searchField.typeText("Burger")
    
    // Verify filtered results
    XCTAssertTrue(app.staticTexts["Burger"].exists)
    XCTAssertFalse(app.staticTexts["Pizza"].exists)
}
```

### 3. Screenshot Testing

#### Android
```kotlin
@Test
fun testScreenshotComparison() {
    composeTestRule.setContent {
        FoodItemCard(
            foodItem = FoodItem("Burger", 10.99, "Delicious beef burger"),
            onSwipe = {}
        )
    }
    
    // Capture screenshot for manual verification
    composeTestRule.onRoot().captureToImage()
}
```

#### iOS
```swift
func testScreenshotComparison() {
    // Navigate to screen
    navigateToFoodMenu()
    
    // Capture screenshots at different states
    takeScreenshot(name: "food_menu_initial")
    
    // Interact with UI
    app.buttons["filter_button"].tap()
    takeScreenshot(name: "food_menu_filtered")
}
```

## Debugging UI Tests

### 1. Add Wait Times for Debugging
```kotlin
// Android
composeTestRule.mainClock.autoAdvance = false
composeTestRule.mainClock.advanceTimeBy(1000) // Advance 1 second

// iOS
sleep(2) // Pause for 2 seconds to observe UI state
```

### 2. Print UI Hierarchy

#### Android
```kotlin
composeTestRule.onRoot().printToLog("UI_TREE")
```

#### iOS
```swift
print(app.debugDescription)
```

### 3. Use Breakpoints
- Set breakpoints in test code
- Use conditional breakpoints for specific scenarios
- Inspect element properties during execution

## Performance Considerations

### 1. Minimize Test Flakiness
- Always wait for UI elements before interacting
- Use explicit waits instead of sleep
- Handle animations and transitions properly

### 2. Optimize Test Execution
- Run tests in parallel when possible
- Use test sharding for large test suites
- Mock network calls to reduce execution time

### 3. Test Data Management
- Reset app state between tests
- Use test-specific data that won't conflict
- Clear preferences and databases in tearDown

## CI/CD Integration

### GitHub Actions Example
```yaml
name: UI Tests

on: [push, pull_request]

jobs:
  android-ui-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Android UI Tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 33
          script: ./gradlew connectedCheck
          
  ios-ui-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run iOS UI Tests
        run: |
          xcodebuild test \
            -workspace iosApp.xcworkspace \
            -scheme iosApp \
            -destination 'platform=iOS Simulator,name=iPhone 14'
```

## Next Steps

- Review [Integration Testing](./INTEGRATION_TESTING.md) for testing external services
- Check [Test Coverage](./TEST_COVERAGE.md) for UI test coverage requirements
- See [Troubleshooting](./TROUBLESHOOTING.md) for common UI test issues