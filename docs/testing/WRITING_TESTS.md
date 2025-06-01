# Writing Tests Guide

This comprehensive guide covers how to write different types of tests for the Pulse project, including unit tests, UI tests, and integration tests across all platforms.

## Test Structure and Organization

### Test File Naming Conventions

```
Feature.kt           → FeatureTest.kt              # Kotlin unit tests
Feature.swift        → FeatureTests.swift          # Swift unit tests
FeatureScreen.kt     → FeatureScreenTest.kt        # Android UI tests
FeatureView.swift    → FeatureViewUITests.swift    # iOS UI tests
```

### Test Method Naming

#### Kotlin Test Naming
```kotlin
@Test
fun `methodName - expected result when specific condition`() {
    // Arrange
    // Act
    // Assert
}

// Examples:
@Test
fun `parseMenuImage - returns menu items when valid base64 image provided`() { }

@Test
fun `calculatePrice - throws exception when negative price provided`() { }
```

#### Swift Test Naming
```swift
func testMethodName_WhenCondition_ShouldExpectedResult() {
    // Arrange
    // Act
    // Assert
}

// Examples:
func testParseMenuImage_WhenValidBase64_ShouldReturnMenuItems() { }

func testCalculatePrice_WhenNegativePrice_ShouldThrowError() { }
```

## Unit Testing

### Kotlin/Shared Module Tests

#### Basic Unit Test
```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/MenuParserTest.kt
class MenuParserTest {
    
    private lateinit var parser: MenuParser
    
    @BeforeTest
    fun setup() {
        parser = MenuParser()
    }
    
    @Test
    fun `parseMenu - returns empty list when input is null`() {
        // Arrange
        val input: String? = null
        
        // Act
        val result = parser.parseMenu(input)
        
        // Assert
        assertTrue(result.isEmpty())
    }
    
    @Test
    fun `parseMenu - extracts all menu items from valid JSON`() {
        // Arrange
        val json = """
            {
                "items": [
                    {"name": "Burger", "price": 12.99},
                    {"name": "Fries", "price": 4.99}
                ]
            }
        """.trimIndent()
        
        // Act
        val result = parser.parseMenu(json)
        
        // Assert
        assertEquals(2, result.size)
        assertEquals("Burger", result[0].name)
        assertEquals(12.99, result[0].price)
    }
}
```

#### Testing Coroutines
```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/MenuServiceTest.kt
class MenuServiceTest {
    
    @Test
    fun `fetchMenu - returns menu data from API`() = runTest {
        // Arrange
        val mockClient = MockHttpClient()
        val service = MenuService(mockClient)
        val expectedMenu = Menu(items = listOf(MenuItem("Pizza", 15.99)))
        mockClient.mockResponse = expectedMenu.toJson()
        
        // Act
        val result = service.fetchMenu()
        
        // Assert
        assertEquals(expectedMenu, result)
        assertTrue(mockClient.wasGetCalled)
    }
    
    @Test
    fun `fetchMenu - handles network errors gracefully`() = runTest {
        // Arrange
        val mockClient = MockHttpClient()
        mockClient.shouldThrowError = true
        val service = MenuService(mockClient)
        
        // Act & Assert
        assertFailsWith<NetworkException> {
            service.fetchMenu()
        }
    }
}
```

#### Testing ViewModels
```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/MenuViewModelTest.kt
class MenuViewModelTest {
    
    @Test
    fun `loadMenu - updates state with loaded menu items`() = runTest {
        // Arrange
        val mockService = MockMenuService()
        val viewModel = MenuViewModel(mockService)
        val testItems = listOf(
            MenuItem("Salad", 9.99),
            MenuItem("Soup", 7.99)
        )
        mockService.menuToReturn = Menu(testItems)
        
        // Act
        viewModel.loadMenu()
        advanceUntilIdle() // Wait for coroutines
        
        // Assert
        val state = viewModel.state.value
        assertFalse(state.isLoading)
        assertEquals(testItems, state.menuItems)
        assertNull(state.error)
    }
    
    @Test
    fun `selectItem - marks item as selected in state`() {
        // Arrange
        val viewModel = MenuViewModel(MockMenuService())
        val items = listOf(MenuItem("Test", 5.99))
        viewModel.updateState { copy(menuItems = items) }
        
        // Act
        viewModel.selectItem(0)
        
        // Assert
        assertTrue(viewModel.state.value.selectedItems.contains(0))
    }
}
```

### Android-Specific Unit Tests

```kotlin
// androidApp/src/test/java/com/example/pulse/AndroidMenuFormatterTest.kt
class AndroidMenuFormatterTest {
    
    @Test
    fun `formatPrice - formats with currency symbol for locale`() {
        // Arrange
        val formatter = AndroidMenuFormatter(Locale.US)
        
        // Act
        val result = formatter.formatPrice(9.99)
        
        // Assert
        assertEquals("$9.99", result)
    }
    
    @Test
    fun `formatPrice - handles different locales correctly`() {
        // Arrange
        val formatterEU = AndroidMenuFormatter(Locale.GERMANY)
        
        // Act
        val result = formatterEU.formatPrice(9.99)
        
        // Assert
        assertEquals("9,99 €", result)
    }
}
```

### iOS-Specific Unit Tests

```swift
// iosApp/iosAppTests/MenuFormatterTests.swift
import XCTest
@testable import iosApp

class MenuFormatterTests: XCTestCase {
    
    var formatter: MenuFormatter!
    
    override func setUp() {
        super.setUp()
        formatter = MenuFormatter()
    }
    
    func testFormatPrice_WhenValidPrice_ShouldFormatWithCurrency() {
        // Arrange
        let price = 9.99
        
        // Act
        let result = formatter.formatPrice(price)
        
        // Assert
        XCTAssertEqual(result, "$9.99")
    }
    
    func testFormatPrice_WhenZeroPrice_ShouldShowFree() {
        // Arrange
        let price = 0.0
        
        // Act
        let result = formatter.formatPrice(price)
        
        // Assert
        XCTAssertEqual(result, "Free")
    }
}
```

## UI Testing

### Android UI Tests with Compose

```kotlin
// androidApp/src/androidTest/java/com/example/pulse/MenuScreenTest.kt
class MenuScreenTest {
    
    @get:Rule
    val composeTestRule = createAndroidComposeRule<MainActivity>()
    
    @Test
    fun menuScreen_displaysMenuItems() {
        // Arrange
        val testItems = listOf(
            MenuItem("Burger", 12.99),
            MenuItem("Fries", 4.99)
        )
        
        // Act
        composeTestRule.setContent {
            MenuScreen(menuItems = testItems)
        }
        
        // Assert
        composeTestRule
            .onNodeWithText("Burger")
            .assertIsDisplayed()
        
        composeTestRule
            .onNodeWithText("$12.99")
            .assertIsDisplayed()
        
        composeTestRule
            .onNodeWithText("Fries")
            .assertIsDisplayed()
    }
    
    @Test
    fun menuScreen_clickItem_showsDetails() {
        // Arrange
        composeTestRule.setContent {
            MenuScreen(menuItems = testMenuItems)
        }
        
        // Act
        composeTestRule
            .onNodeWithText("Burger")
            .performClick()
        
        // Assert
        composeTestRule
            .onNodeWithText("Calories: 650")
            .assertIsDisplayed()
    }
}
```

### iOS UI Tests with XCUITest

```swift
// iosApp/iosAppUITests/MenuScreenUITests.swift
import XCTest

class MenuScreenUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    func testMenuScreen_DisplaysMenuItems() {
        // Assert
        XCTAssertTrue(app.staticTexts["Burger"].exists)
        XCTAssertTrue(app.staticTexts["$12.99"].exists)
        XCTAssertTrue(app.staticTexts["Fries"].exists)
        XCTAssertTrue(app.staticTexts["$4.99"].exists)
    }
    
    func testMenuScreen_TapItem_ShowsDetails() {
        // Act
        app.staticTexts["Burger"].tap()
        
        // Assert
        let caloriesLabel = app.staticTexts["Calories: 650"]
        XCTAssertTrue(caloriesLabel.waitForExistence(timeout: 3))
    }
    
    func testCameraCapture_ProcessesMenuImage() {
        // Act
        app.buttons["Camera"].tap()
        
        // Handle camera permission if needed
        if app.alerts.element.exists {
            app.alerts.buttons["OK"].tap()
        }
        
        // Simulate capture (using mock in UI test mode)
        app.buttons["Capture"].tap()
        
        // Assert
        let processingIndicator = app.activityIndicators["ProcessingIndicator"]
        XCTAssertTrue(processingIndicator.exists)
        
        // Wait for processing
        let menuItem = app.staticTexts["Detected Menu Items"]
        XCTAssertTrue(menuItem.waitForExistence(timeout: 10))
    }
}
```

### Page Object Pattern for UI Tests

#### Android Page Objects
```kotlin
// androidApp/src/androidTest/java/com/example/pulse/pages/MenuPage.kt
class MenuPage(private val composeRule: ComposeContentTestRule) {
    
    fun assertMenuItemDisplayed(name: String): MenuPage {
        composeRule
            .onNodeWithText(name)
            .assertIsDisplayed()
        return this
    }
    
    fun clickMenuItem(name: String): MenuPage {
        composeRule
            .onNodeWithText(name)
            .performClick()
        return this
    }
    
    fun assertPriceDisplayed(price: String): MenuPage {
        composeRule
            .onNodeWithText(price)
            .assertIsDisplayed()
        return this
    }
}

// Usage in test
@Test
fun menuFlow_completeUserJourney() {
    val menuPage = MenuPage(composeTestRule)
    
    menuPage
        .assertMenuItemDisplayed("Burger")
        .assertPriceDisplayed("$12.99")
        .clickMenuItem("Burger")
        .assertMenuItemDisplayed("Calories: 650")
}
```

#### iOS Page Objects
```swift
// iosApp/iosAppUITests/Pages/MenuPage.swift
class MenuPage {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    func assertMenuItemExists(_ name: String) -> Self {
        XCTAssertTrue(app.staticTexts[name].exists)
        return self
    }
    
    func tapMenuItem(_ name: String) -> Self {
        app.staticTexts[name].tap()
        return self
    }
    
    func assertPriceExists(_ price: String) -> Self {
        XCTAssertTrue(app.staticTexts[price].exists)
        return self
    }
}

// Usage in test
func testMenuFlow_CompleteUserJourney() {
    let menuPage = MenuPage(app: app)
    
    menuPage
        .assertMenuItemExists("Burger")
        .assertPriceExists("$12.99")
        .tapMenuItem("Burger")
        .assertMenuItemExists("Calories: 650")
}
```

## Integration Testing

### Testing with Supabase

```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/SupabaseIntegrationTest.kt
class SupabaseIntegrationTest {
    
    private lateinit var supabaseClient: SupabaseClient
    
    @BeforeTest
    fun setup() {
        supabaseClient = createSupabaseClient(
            supabaseUrl = "http://localhost:54321",
            supabaseKey = "test-anon-key"
        ) {
            install(Auth)
            install(Postgrest)
        }
    }
    
    @Test
    fun `saveMenuItem - persists item to database`() = runTest {
        // Arrange
        val menuItem = MenuItem(
            name = "Test Burger",
            price = 9.99,
            calories = 500
        )
        
        // Act
        val result = supabaseClient
            .from("menu_items")
            .insert(menuItem)
            .decodeSingle<MenuItem>()
        
        // Assert
        assertNotNull(result.id)
        assertEquals(menuItem.name, result.name)
        assertEquals(menuItem.price, result.price)
        
        // Cleanup
        supabaseClient
            .from("menu_items")
            .delete()
            .eq("id", result.id)
    }
    
    @Test
    fun `fetchMenuItems - retrieves items from database`() = runTest {
        // Arrange - Insert test data
        val testItems = listOf(
            MenuItem("Burger", 12.99),
            MenuItem("Fries", 4.99)
        )
        
        testItems.forEach { item ->
            supabaseClient
                .from("menu_items")
                .insert(item)
        }
        
        // Act
        val results = supabaseClient
            .from("menu_items")
            .select()
            .decodeList<MenuItem>()
        
        // Assert
        assertTrue(results.size >= 2)
        assertTrue(results.any { it.name == "Burger" })
        assertTrue(results.any { it.name == "Fries" })
    }
}
```

### Testing Image Processing

```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/ImageProcessingTest.kt
class ImageProcessingTest {
    
    @Test
    fun `processMenuImage - extracts text from base64 image`() = runTest {
        // Arrange
        val testImageBase64 = TestData.SAMPLE_MENU_IMAGE
        val processor = ImageProcessor()
        
        // Act
        val result = processor.processMenuImage(testImageBase64)
        
        // Assert
        assertTrue(result.isSuccess)
        val menuItems = result.getOrNull()!!
        assertTrue(menuItems.isNotEmpty())
        assertTrue(menuItems.any { it.name.contains("Burger", ignoreCase = true) })
    }
    
    @Test
    fun `processMenuImage - handles invalid base64 gracefully`() = runTest {
        // Arrange
        val invalidBase64 = "not-a-valid-base64-string"
        val processor = ImageProcessor()
        
        // Act
        val result = processor.processMenuImage(invalidBase64)
        
        // Assert
        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull() is InvalidImageException)
    }
}
```

## Test Data Management

### Test Data Builders

```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/builders/TestDataBuilders.kt
class MenuItemBuilder {
    private var name: String = "Test Item"
    private var price: Double = 9.99
    private var calories: Int = 500
    private var description: String? = null
    
    fun withName(name: String) = apply { this.name = name }
    fun withPrice(price: Double) = apply { this.price = price }
    fun withCalories(calories: Int) = apply { this.calories = calories }
    fun withDescription(desc: String) = apply { this.description = desc }
    
    fun build() = MenuItem(
        name = name,
        price = price,
        calories = calories,
        description = description
    )
}

// Usage
@Test
fun `calculateTotal - sums prices correctly`() {
    // Arrange
    val items = listOf(
        MenuItemBuilder().withPrice(10.00).build(),
        MenuItemBuilder().withPrice(5.50).build(),
        MenuItemBuilder().withPrice(3.25).build()
    )
    
    // Act
    val total = calculateTotal(items)
    
    // Assert
    assertEquals(18.75, total)
}
```

### Test Fixtures

```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/fixtures/TestFixtures.kt
object TestFixtures {
    val sampleMenu = Menu(
        items = listOf(
            MenuItem("Burger", 12.99, 650),
            MenuItem("Fries", 4.99, 320),
            MenuItem("Salad", 8.99, 250),
            MenuItem("Soda", 2.99, 140)
        )
    )
    
    val sampleBase64Image = """
        iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==
    """.trimIndent()
    
    val mockApiResponse = """
        {
            "success": true,
            "data": {
                "items": [
                    {"name": "Test Item", "price": 9.99}
                ]
            }
        }
    """.trimIndent()
}
```

## Mocking and Test Doubles

### Creating Mock Objects

```kotlin
// shared/src/commonTest/kotlin/com/example/pulse/mocks/MockServices.kt
class MockMenuService : MenuService {
    var menuToReturn: Menu = Menu(emptyList())
    var shouldThrowError = false
    var fetchMenuCallCount = 0
    
    override suspend fun fetchMenu(): Menu {
        fetchMenuCallCount++
        
        if (shouldThrowError) {
            throw NetworkException("Mock network error")
        }
        
        return menuToReturn
    }
}

class MockImageProcessor : ImageProcessor {
    var processResult: Result<List<MenuItem>> = Result.success(emptyList())
    var processCallCount = 0
    
    override suspend fun processImage(base64: String): Result<List<MenuItem>> {
        processCallCount++
        return processResult
    }
}
```

### Using Fakes vs Mocks

```kotlin
// Fake implementation (stateful, more realistic)
class FakeMenuRepository : MenuRepository {
    private val items = mutableListOf<MenuItem>()
    
    override suspend fun save(item: MenuItem): MenuItem {
        val saved = item.copy(id = UUID.randomUUID().toString())
        items.add(saved)
        return saved
    }
    
    override suspend fun findAll(): List<MenuItem> {
        return items.toList()
    }
    
    override suspend fun delete(id: String) {
        items.removeAll { it.id == id }
    }
}

// Mock implementation (behavior verification)
class MockMenuRepository : MenuRepository {
    val savedItems = mutableListOf<MenuItem>()
    var findAllCalled = false
    var deletedIds = mutableListOf<String>()
    
    override suspend fun save(item: MenuItem): MenuItem {
        savedItems.add(item)
        return item.copy(id = "mock-id")
    }
    
    override suspend fun findAll(): List<MenuItem> {
        findAllCalled = true
        return emptyList()
    }
    
    override suspend fun delete(id: String) {
        deletedIds.add(id)
    }
}
```

## Testing Best Practices

### 1. Follow AAA Pattern
```kotlin
@Test
fun `example test following AAA pattern`() {
    // Arrange - Set up test data and dependencies
    val calculator = PriceCalculator()
    val items = listOf(
        MenuItem("Item1", 10.00),
        MenuItem("Item2", 15.00)
    )
    val taxRate = 0.08
    
    // Act - Execute the code under test
    val total = calculator.calculateTotal(items, taxRate)
    
    // Assert - Verify the results
    assertEquals(27.00, total) // 25 + 2 tax
}
```

### 2. Test One Thing at a Time
```kotlin
// Bad - Testing multiple behaviors
@Test
fun `menuService does everything correctly`() {
    val service = MenuService()
    val menu = service.fetchMenu()
    assertNotNull(menu)
    assertTrue(menu.items.isNotEmpty())
    assertEquals(5, menu.items.size)
    assertTrue(menu.items.all { it.price > 0 })
}

// Good - Separate tests for each behavior
@Test
fun `fetchMenu - returns non-null menu`() {
    val service = MenuService()
    val menu = service.fetchMenu()
    assertNotNull(menu)
}

@Test
fun `fetchMenu - returns menu with items`() {
    val service = MenuService()
    val menu = service.fetchMenu()
    assertTrue(menu.items.isNotEmpty())
}

@Test
fun `fetchMenu - all items have positive prices`() {
    val service = MenuService()
    val menu = service.fetchMenu()
    assertTrue(menu.items.all { it.price > 0 })
}
```

### 3. Use Descriptive Assertions
```kotlin
// Use specific assertions with meaningful messages
@Test
fun `parsePrice - handles currency formats`() {
    val result = parsePrice("$12.99")
    
    // Bad
    assertTrue(result == 12.99)
    
    // Good
    assertEquals(12.99, result, "Price should be parsed without currency symbol")
    
    // Better with custom assertions
    assertThat(result)
        .isEqualTo(12.99)
        .withFailMessage("Expected price to be 12.99 but was $result")
}
```

### 4. Isolate External Dependencies
```kotlin
@Test
fun `menuViewModel - loads menu without network`() = runTest {
    // Use mock service instead of real network
    val mockService = MockMenuService().apply {
        menuToReturn = TestFixtures.sampleMenu
    }
    
    val viewModel = MenuViewModel(mockService)
    viewModel.loadMenu()
    
    assertEquals(TestFixtures.sampleMenu, viewModel.state.value.menu)
}
```

### 5. Keep Tests Fast
```kotlin
// Bad - Slow test with real delays
@Test
fun `animation completes after delay`() {
    val animator = MenuAnimator()
    animator.startAnimation()
    
    Thread.sleep(2000) // Bad! Slows down test suite
    
    assertTrue(animator.isComplete)
}

// Good - Use test schedulers
@Test
fun `animation completes after delay`() = runTest {
    val animator = MenuAnimator(testScheduler)
    animator.startAnimation()
    
    testScheduler.advanceTimeBy(2000)
    
    assertTrue(animator.isComplete)
}
```

## Platform-Specific Testing Tips

### Android Testing Tips

1. **Use Test Orchestrator for Isolation**
```kotlin
android {
    defaultConfig {
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }
    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }
}
```

2. **Mock Android Dependencies**
```kotlin
@Test
fun `formats price using Android resources`() {
    val mockContext = mockk<Context>()
    val mockResources = mockk<Resources>()
    
    every { mockContext.resources } returns mockResources
    every { mockResources.getString(R.string.price_format, any()) } returns "$9.99"
    
    val formatter = AndroidPriceFormatter(mockContext)
    val result = formatter.format(9.99)
    
    assertEquals("$9.99", result)
}
```

### iOS Testing Tips

1. **Use XCTAssertions Effectively**
```swift
// Custom assertions for better error messages
func assertMenuItem(_ item: MenuItem, hasName name: String, price: Double) {
    XCTAssertEqual(item.name, name, "Expected item name to be '\(name)' but was '\(item.name)'")
    XCTAssertEqual(item.price, price, accuracy: 0.01, "Expected price to be \(price) but was \(item.price)")
}
```

2. **Handle Async Operations**
```swift
func testFetchMenu_WhenSuccess_ReturnsMenuItems() {
    let expectation = expectation(description: "Menu fetched")
    var receivedMenu: Menu?
    
    menuService.fetchMenu { result in
        if case .success(let menu) = result {
            receivedMenu = menu
        }
        expectation.fulfill()
    }
    
    waitForExpectations(timeout: 5)
    
    XCTAssertNotNil(receivedMenu)
    XCTAssertFalse(receivedMenu!.items.isEmpty)
}
```

## Next Steps

- Review [RUNNING_TESTS.md](./RUNNING_TESTS.md) for test execution
- Check [BEST_PRACTICES.md](./BEST_PRACTICES.md) for advanced patterns
- See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues