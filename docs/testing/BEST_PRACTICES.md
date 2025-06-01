# Testing Best Practices

This guide outlines testing patterns, anti-patterns, and best practices for maintaining high-quality tests in the Pulse project.

## Core Testing Principles

### 1. Test Pyramid

Follow the test pyramid approach for optimal test coverage and execution speed:

```
         /\
        /UI\        10% - UI Tests (Slow, Brittle, Expensive)
       /----\
      / Intg \      20% - Integration Tests (Medium Speed)
     /--------\
    /   Unit   \    70% - Unit Tests (Fast, Stable, Cheap)
   /____________\
```

### 2. F.I.R.S.T. Principles

Tests should be:
- **Fast**: Execute quickly to enable rapid feedback
- **Independent**: No dependencies between tests
- **Repeatable**: Same results every time
- **Self-validating**: Clear pass/fail result
- **Timely**: Written just before or with production code

### 3. AAA Pattern

Structure all tests with Arrange-Act-Assert:

```kotlin
@Test
fun `calculateTotal - applies discount when total exceeds threshold`() {
    // Arrange
    val calculator = PriceCalculator()
    val items = listOf(
        MenuItem("Expensive Item", 100.0),
        MenuItem("Another Item", 50.0)
    )
    
    // Act
    val total = calculator.calculateTotal(items)
    
    // Assert
    assertEquals(135.0, total) // 150 - 10% discount
}
```

## Writing Effective Tests

### Test Naming Conventions

#### Kotlin Tests
```kotlin
// Pattern: `methodName - expected behavior when condition`
@Test
fun `processPayment - returns success when valid card provided`() { }

@Test
fun `processPayment - throws exception when card is expired`() { }

@Test
fun `processPayment - returns decline when insufficient funds`() { }
```

#### Swift Tests
```swift
// Pattern: testMethodName_WhenCondition_ShouldExpectedBehavior
func testProcessPayment_WhenValidCard_ShouldReturnSuccess() { }

func testProcessPayment_WhenCardExpired_ShouldThrowError() { }

func testProcessPayment_WhenInsufficientFunds_ShouldReturnDecline() { }
```

### Single Responsibility

Each test should verify one behavior:

```kotlin
// ❌ Bad - Testing multiple behaviors
@Test
fun `menu service works correctly`() {
    val service = MenuService()
    val menu = service.fetchMenu()
    
    assertNotNull(menu)
    assertEquals(5, menu.items.size)
    assertTrue(menu.items.all { it.price > 0 })
    assertTrue(menu.items.all { it.name.isNotEmpty() })
    assertEquals("Special", menu.items.first().category)
}

// ✅ Good - Separate tests for each behavior
@Test
fun `fetchMenu - returns non-null menu`() {
    val service = MenuService()
    assertNotNull(service.fetchMenu())
}

@Test
fun `fetchMenu - returns menu with expected item count`() {
    val service = MenuService()
    assertEquals(5, service.fetchMenu().items.size)
}

@Test
fun `fetchMenu - all items have positive prices`() {
    val service = MenuService()
    val menu = service.fetchMenu()
    assertTrue(menu.items.all { it.price > 0 })
}
```

### Test Data Builders

Use builders for complex test data:

```kotlin
// Test data builder
class MenuItemBuilder {
    private var name = "Default Item"
    private var price = 9.99
    private var category = "Main"
    private var calories: Int? = null
    
    fun withName(name: String) = apply { this.name = name }
    fun withPrice(price: Double) = apply { this.price = price }
    fun withCategory(category: String) = apply { this.category = category }
    fun withCalories(calories: Int) = apply { this.calories = calories }
    
    fun build() = MenuItem(
        name = name,
        price = price,
        category = category,
        calories = calories
    )
}

// Usage in tests
@Test
fun `calculateHealthScore - gives bonus for low calorie items`() {
    // Arrange
    val healthyItem = MenuItemBuilder()
        .withName("Salad")
        .withCalories(250)
        .build()
    
    val unhealthyItem = MenuItemBuilder()
        .withName("Burger")
        .withCalories(850)
        .build()
    
    // Act & Assert
    assertTrue(calculateHealthScore(healthyItem) > calculateHealthScore(unhealthyItem))
}
```

### Parameterized Tests

Test multiple scenarios efficiently:

```kotlin
// Kotlin parameterized tests
@ParameterizedTest
@CsvSource(
    "5.00, 0.00, 5.00",
    "10.00, 0.50, 10.50",
    "100.00, 8.00, 108.00",
    "0.00, 0.00, 0.00"
)
fun `calculateTotal - correctly adds tax to base price`(
    basePrice: Double,
    tax: Double,
    expectedTotal: Double
) {
    val result = calculateTotal(basePrice, tax)
    assertEquals(expectedTotal, result, 0.01)
}

// Swift parameterized approach
func testCalculateTotal_VariousInputs() {
    let testCases: [(base: Double, tax: Double, expected: Double)] = [
        (5.00, 0.00, 5.00),
        (10.00, 0.50, 10.50),
        (100.00, 8.00, 108.00),
        (0.00, 0.00, 0.00)
    ]
    
    testCases.forEach { testCase in
        let result = calculateTotal(base: testCase.base, tax: testCase.tax)
        XCTAssertEqual(result, testCase.expected, accuracy: 0.01)
    }
}
```

## Test Doubles and Mocking

### When to Use Different Test Doubles

```kotlin
// Stub - Returns canned responses
class StubMenuService : MenuService {
    override suspend fun fetchMenu(): Menu {
        return Menu(
            items = listOf(
                MenuItem("Stub Item 1", 10.0),
                MenuItem("Stub Item 2", 15.0)
            )
        )
    }
}

// Mock - Verifies interactions
class MockMenuService : MenuService {
    var fetchMenuCalled = false
    var fetchMenuCallCount = 0
    
    override suspend fun fetchMenu(): Menu {
        fetchMenuCalled = true
        fetchMenuCallCount++
        return Menu(emptyList())
    }
}

// Fake - Working implementation for testing
class FakeMenuRepository : MenuRepository {
    private val items = mutableListOf<MenuItem>()
    
    override suspend fun save(item: MenuItem): MenuItem {
        items.add(item)
        return item
    }
    
    override suspend fun findAll(): List<MenuItem> = items.toList()
    
    override suspend fun delete(id: String) {
        items.removeAll { it.id == id }
    }
}
```

### Mocking Best Practices

```kotlin
// ❌ Bad - Over-mocking
@Test
fun `bad test with too much mocking`() {
    val mockMenuItem = mock<MenuItem>()
    val mockPrice = mock<Price>()
    val mockFormatter = mock<PriceFormatter>()
    
    whenever(mockMenuItem.price).thenReturn(mockPrice)
    whenever(mockPrice.value).thenReturn(10.0)
    whenever(mockFormatter.format(mockPrice)).thenReturn("$10.00")
    
    // This tests the mocks, not the actual behavior
}

// ✅ Good - Mock only external dependencies
@Test
fun `good test with appropriate mocking`() {
    val mockApiClient = mock<ApiClient>()
    val service = MenuService(mockApiClient)
    
    whenever(mockApiClient.get("/menu")).thenReturn(
        """{"items": [{"name": "Burger", "price": 10.0}]}"""
    )
    
    val menu = service.fetchMenu()
    
    assertEquals(1, menu.items.size)
    assertEquals("Burger", menu.items[0].name)
}
```

## Testing Async Code

### Coroutines Testing

```kotlin
// Use runTest for coroutine testing
class MenuViewModelTest {
    
    @Test
    fun `loadMenu - updates state correctly`() = runTest {
        // Arrange
        val mockService = MockMenuService()
        val viewModel = MenuViewModel(mockService)
        
        // Act
        viewModel.loadMenu()
        advanceUntilIdle() // Let coroutines complete
        
        // Assert
        assertFalse(viewModel.state.value.isLoading)
        assertTrue(viewModel.state.value.items.isNotEmpty())
    }
    
    @Test
    fun `concurrent operations - maintain consistency`() = runTest {
        val viewModel = MenuViewModel()
        
        // Launch multiple concurrent operations
        val job1 = launch { viewModel.refreshMenu() }
        val job2 = launch { viewModel.addToCart(item1) }
        val job3 = launch { viewModel.addToCart(item2) }
        
        // Wait for all to complete
        joinAll(job1, job2, job3)
        
        // Assert state is consistent
        assertEquals(2, viewModel.state.value.cartItems.size)
    }
}
```

### iOS Async Testing

```swift
// Modern async/await testing
func testLoadMenu_UpdatesStateCorrectly() async throws {
    // Arrange
    let mockService = MockMenuService()
    let viewModel = MenuViewModel(service: mockService)
    
    // Act
    await viewModel.loadMenu()
    
    // Assert
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertFalse(viewModel.items.isEmpty)
}

// Combine testing
func testMenuPublisher_EmitsUpdates() {
    let expectation = expectation(description: "Menu updates received")
    let viewModel = MenuViewModel()
    var receivedItems: [MenuItem] = []
    
    let cancellable = viewModel.$menuItems
        .dropFirst() // Skip initial value
        .sink { items in
            receivedItems = items
            expectation.fulfill()
        }
    
    viewModel.loadMenu()
    
    waitForExpectations(timeout: 5)
    XCTAssertFalse(receivedItems.isEmpty)
}
```

## UI Testing Best Practices

### Page Object Pattern

```kotlin
// Page object for better maintainability
class MenuPage(private val device: UiDevice) {
    
    private val menuList = By.res("menu_list")
    private val addToCartButton = By.res("add_to_cart")
    private val cartBadge = By.res("cart_badge")
    
    fun selectMenuItem(name: String): MenuPage {
        device.findObject(By.text(name)).click()
        return this
    }
    
    fun addToCart(): MenuPage {
        device.findObject(addToCartButton).click()
        return this
    }
    
    fun getCartItemCount(): Int {
        val badge = device.findObject(cartBadge)
        return badge.text.toIntOrNull() ?: 0
    }
}

// Clean test using page object
@Test
fun `add item to cart flow`() {
    val menuPage = MenuPage(device)
    
    menuPage
        .selectMenuItem("Burger")
        .addToCart()
    
    assertEquals(1, menuPage.getCartItemCount())
}
```

### UI Test Stability

```kotlin
// Wait for elements instead of fixed delays
@Test
fun `stable UI test with proper waiting`() {
    // ❌ Bad - Fixed delay
    onView(withId(R.id.load_button)).perform(click())
    Thread.sleep(2000) // Flaky!
    onView(withId(R.id.menu_list)).check(matches(isDisplayed()))
    
    // ✅ Good - Wait for condition
    onView(withId(R.id.load_button)).perform(click())
    
    // Wait for element with timeout
    onView(withId(R.id.menu_list))
        .perform(waitForElement(5000))
        .check(matches(isDisplayed()))
}

// Custom wait action
fun waitForElement(timeout: Long): ViewAction {
    return object : ViewAction {
        override fun perform(uiController: UiController, view: View) {
            val endTime = System.currentTimeMillis() + timeout
            while (System.currentTimeMillis() < endTime) {
                if (view.visibility == View.VISIBLE) return
                uiController.loopMainThreadForAtLeast(50)
            }
            throw PerformException.Builder()
                .withCause(TimeoutException())
                .build()
        }
    }
}
```

## Integration Testing Patterns

### Database Testing

```kotlin
// Use in-memory database for tests
class MenuRepositoryTest {
    
    private lateinit var database: TestDatabase
    private lateinit var repository: MenuRepository
    
    @BeforeTest
    fun setup() {
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            TestDatabase::class.java
        )
            .allowMainThreadQueries()
            .build()
        
        repository = MenuRepository(database.menuDao())
    }
    
    @AfterTest
    fun teardown() {
        database.close()
    }
    
    @Test
    fun `save and retrieve menu items`() = runTest {
        // Arrange
        val items = listOf(
            MenuItem("Item 1", 10.0),
            MenuItem("Item 2", 15.0)
        )
        
        // Act
        items.forEach { repository.save(it) }
        val retrieved = repository.findAll()
        
        // Assert
        assertEquals(items.size, retrieved.size)
        assertTrue(retrieved.containsAll(items))
    }
}
```

### API Testing

```kotlin
// Test API integration with mock server
class MenuApiTest {
    
    private val mockServer = MockWebServer()
    private lateinit var api: MenuApi
    
    @BeforeTest
    fun setup() {
        mockServer.start()
        api = MenuApi(baseUrl = mockServer.url("/").toString())
    }
    
    @AfterTest
    fun teardown() {
        mockServer.shutdown()
    }
    
    @Test
    fun `fetchMenu - parses response correctly`() = runTest {
        // Arrange
        val mockResponse = """
            {
                "items": [
                    {"name": "Burger", "price": 12.99},
                    {"name": "Fries", "price": 4.99}
                ]
            }
        """.trimIndent()
        
        mockServer.enqueue(
            MockResponse()
                .setBody(mockResponse)
                .setResponseCode(200)
        )
        
        // Act
        val menu = api.fetchMenu()
        
        // Assert
        assertEquals(2, menu.items.size)
        assertEquals("Burger", menu.items[0].name)
        assertEquals(12.99, menu.items[0].price)
    }
    
    @Test
    fun `fetchMenu - handles error responses`() = runTest {
        // Arrange
        mockServer.enqueue(
            MockResponse()
                .setResponseCode(500)
                .setBody("""{"error": "Internal Server Error"}""")
        )
        
        // Act & Assert
        assertFailsWith<ApiException> {
            api.fetchMenu()
        }
    }
}
```

## Performance Testing

### Measuring Test Performance

```kotlin
@Test
fun `performance - menu parsing completes within threshold`() {
    val largeMenu = generateLargeMenu(1000) // 1000 items
    
    val duration = measureTime {
        parseMenu(largeMenu)
    }
    
    assertTrue(
        duration < 100.milliseconds,
        "Menu parsing took ${duration.inWholeMilliseconds}ms, expected < 100ms"
    )
}

// Benchmark repeated operations
@Test
fun `performance - repeated operations maintain speed`() {
    val times = mutableListOf<Duration>()
    
    repeat(100) {
        times.add(measureTime {
            performOperation()
        })
    }
    
    val averageTime = times.map { it.inWholeMilliseconds }.average()
    val maxTime = times.maxOf { it.inWholeMilliseconds }
    
    assertTrue(averageTime < 50, "Average time: $averageTime ms")
    assertTrue(maxTime < 100, "Max time: $maxTime ms")
}
```

## Test Data Management

### Test Fixtures

```kotlin
// Centralized test data
object TestFixtures {
    val sampleMenu = Menu(
        id = "test-menu-1",
        items = listOf(
            MenuItem("Burger", 12.99, category = "Main"),
            MenuItem("Fries", 4.99, category = "Sides"),
            MenuItem("Coke", 2.99, category = "Drinks")
        )
    )
    
    val sampleUser = User(
        id = "test-user-1",
        name = "Test User",
        email = "test@example.com"
    )
    
    fun menuWithItems(count: Int) = Menu(
        items = (1..count).map { 
            MenuItem("Item $it", it * 5.0)
        }
    )
}

// Object Mother pattern
object MenuMother {
    fun simple() = MenuItem("Simple Item", 10.0)
    
    fun healthy() = MenuItem(
        name = "Salad",
        price = 8.99,
        calories = 250,
        tags = listOf("vegetarian", "gluten-free")
    )
    
    fun expensive() = MenuItem(
        name = "Lobster",
        price = 89.99,
        category = "Premium"
    )
}
```

### Test Data Cleanup

```kotlin
// Ensure clean state between tests
class MenuServiceTest {
    
    @BeforeEach
    fun setup() {
        clearTestData()
        insertBaselineData()
    }
    
    @AfterEach
    fun cleanup() {
        clearTestData()
    }
    
    private fun clearTestData() {
        database.clearAllTables()
        sharedPreferences.edit().clear().commit()
        networkCache.evictAll()
    }
}
```

## Testing Anti-Patterns to Avoid

### 1. Testing Implementation Details

```kotlin
// ❌ Bad - Tests internal implementation
@Test
fun `bad test of private method behavior`() {
    val service = MenuService()
    
    // Using reflection to test private method
    val method = service.javaClass.getDeclaredMethod("calculateInternalScore")
    method.isAccessible = true
    
    val result = method.invoke(service, testData)
    assertEquals(42, result)
}

// ✅ Good - Test public behavior
@Test
fun `good test of public interface`() {
    val service = MenuService()
    
    val menu = service.processMenu(testData)
    
    // Test the observable behavior, not internals
    assertTrue(menu.items.all { it.score > 0 })
}
```

### 2. Excessive Mocking

```kotlin
// ❌ Bad - Mocking value objects
@Test
fun `over mocked test`() {
    val mockString = mock<String>()
    whenever(mockString.length).thenReturn(5)
    
    val mockMenuItem = mock<MenuItem>()
    whenever(mockMenuItem.name).thenReturn(mockString)
    
    // This is testing mocks, not real behavior
}

// ✅ Good - Use real objects when possible
@Test
fun `properly isolated test`() {
    val menuItem = MenuItem(name = "Burger", price = 10.0)
    val formatter = MenuFormatter()
    
    val formatted = formatter.format(menuItem)
    
    assertEquals("Burger - $10.00", formatted)
}
```

### 3. Test Interdependence

```kotlin
// ❌ Bad - Tests depend on execution order
class BadTestSuite {
    companion object {
        var sharedState: Menu? = null
    }
    
    @Test
    @Order(1)
    fun `test 1 - create menu`() {
        sharedState = createMenu()
        assertNotNull(sharedState)
    }
    
    @Test
    @Order(2)
    fun `test 2 - use menu from test 1`() {
        // This fails if test 1 didn't run first!
        assertEquals(5, sharedState!!.items.size)
    }
}

// ✅ Good - Independent tests
class GoodTestSuite {
    @Test
    fun `create menu - returns valid menu`() {
        val menu = createMenu()
        assertNotNull(menu)
    }
    
    @Test
    fun `menu - contains expected items`() {
        val menu = createMenu() // Create fresh instance
        assertEquals(5, menu.items.size)
    }
}
```

## Testing Checklist

Before committing tests, verify:

- [ ] Tests follow naming conventions
- [ ] Each test verifies one behavior
- [ ] Tests are independent and repeatable
- [ ] No hardcoded delays or sleeps
- [ ] Appropriate use of test doubles
- [ ] Clear failure messages
- [ ] No commented-out tests
- [ ] Tests run quickly (< 1 second for unit tests)
- [ ] Test data is properly cleaned up
- [ ] No flaky tests

## Continuous Improvement

### Test Review Questions

During code review, ask:
1. Is the test name descriptive?
2. Is it clear what behavior is being tested?
3. Would the test catch real bugs?
4. Is the test maintainable?
5. Does it follow team conventions?

### Refactoring Tests

```kotlin
// Before refactoring
@Test
fun `test menu`() {
    val m = MenuService()
    val r = m.getMenu()
    assertTrue(r.items.size > 0)
}

// After refactoring
@Test
fun `getMenu - returns non-empty menu when service is available`() {
    // Arrange
    val menuService = MenuService(mockApiClient)
    mockApiClient.setupSuccessResponse()
    
    // Act
    val menu = menuService.getMenu()
    
    // Assert
    assertFalse(menu.items.isEmpty(), 
        "Expected menu to contain items but was empty")
}
```

## Next Steps

- Review [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
- Set up [TEST_COVERAGE.md](./TEST_COVERAGE.md) monitoring
- Practice TDD with new features