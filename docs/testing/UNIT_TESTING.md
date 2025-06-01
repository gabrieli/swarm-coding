# Unit Testing Guide

This guide covers unit testing practices for the Pulse project across all platforms (shared, iOS, and Android).

## Overview

Unit tests verify individual components in isolation. They should be:
- **Fast**: Run in milliseconds
- **Isolated**: No external dependencies
- **Repeatable**: Same result every time
- **Self-validating**: Clear pass/fail result

## Platform-Specific Setup

### Shared Module Tests

Located in `shared/src/commonTest/`, these tests run on all platforms.

```kotlin
// Example: shared/src/commonTest/kotlin/.../service/MenuImageProcessorServiceTest.kt
class MenuImageProcessorServiceTest {
    @Test
    fun `processMenuImage accepts Base64 string and returns flow of results`() = runTest {
        // Given
        val service = TestMenuImageProcessorServiceImpl()
        val base64Image = "dGVzdCBpbWFnZSBkYXRh"
        val mimeType = "image/jpeg"
        
        // When
        val results = service.processMenuImage(base64Image, mimeType).toList()
        
        // Then
        assertTrue(results.isNotEmpty())
        assertTrue(results.first() is MenuImageProcessorResult.Started)
    }
}
```

### Android Unit Tests

Located in `androidApp/src/test/` and `shared/src/androidUnitTest/`.

```kotlin
// Example: shared/src/androidUnitTest/kotlin/.../service/AndroidBase64ServiceTest.kt
class AndroidBase64ServiceTest {
    @Test
    fun `decodeBase64 correctly decodes valid base64 string`() {
        // Given
        val service = AndroidBase64Service()
        val base64String = "SGVsbG8gV29ybGQ=" // "Hello World"
        
        // When
        val result = service.decodeBase64(base64String)
        
        // Then
        assertEquals("Hello World", result.decodeToString())
    }
}
```

### iOS Unit Tests

Located in `iosApp/iosAppTests/` and `shared/src/iosTest/`.

```swift
// Example: iosApp/iosAppTests/ImageProcessingTests.swift
class ImageProcessingTests: XCTestCase {
    func testBase64Encoding_WithValidImage_ReturnsBase64String() {
        // Given
        let testImage = createTestImage()
        
        // When
        let base64String = testImage.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        
        // Then
        XCTAssertNotNil(base64String)
        XCTAssertFalse(base64String!.isEmpty)
    }
}
```

## Writing Effective Unit Tests

### 1. Test Structure (AAA Pattern)

Use the Arrange-Act-Assert pattern:

```kotlin
@Test
fun `calculateTotal - returns sum of all items when list is not empty`() {
    // Arrange
    val items = listOf(
        FoodItem(name = "Burger", price = 10.99),
        FoodItem(name = "Fries", price = 3.99)
    )
    val calculator = PriceCalculator()
    
    // Act
    val total = calculator.calculateTotal(items)
    
    // Assert
    assertEquals(14.98, total, 0.01)
}
```

### 2. Naming Conventions

#### Kotlin (Backtick Syntax)
```kotlin
@Test
fun `methodName - expected result when specific condition`() { }

// Examples:
@Test
fun `parseMenu - returns empty list when input is null`() { }

@Test
fun `validateEmail - throws exception when email format is invalid`() { }
```

#### Swift (Descriptive Method Names)
```swift
func testMethodName_WhenCondition_ExpectedResult() { }

// Examples:
func testParseMenu_WhenInputIsNil_ReturnsEmptyArray() { }

func testValidateEmail_WhenFormatIsInvalid_ThrowsError() { }
```

### 3. Test Data Builders

Create reusable test data builders:

```kotlin
// Kotlin Example
object TestDataBuilder {
    fun foodItem(
        name: String = "Test Food",
        price: Double = 9.99,
        description: String? = null,
        category: String = "Main"
    ) = FoodItem(
        name = name,
        price = price,
        description = description,
        category = category
    )
    
    fun menuResponse(
        items: List<FoodItem> = listOf(foodItem()),
        restaurantName: String = "Test Restaurant"
    ) = MenuResponse(
        items = items,
        restaurantName = restaurantName,
        timestamp = Clock.System.now()
    )
}

// Usage in tests
@Test
fun `processMenu - filters items by category`() {
    val menu = TestDataBuilder.menuResponse(
        items = listOf(
            TestDataBuilder.foodItem(category = "Appetizer"),
            TestDataBuilder.foodItem(category = "Main"),
            TestDataBuilder.foodItem(category = "Dessert")
        )
    )
    // ... rest of test
}
```

### 4. Mocking Strategies

#### Kotlin (Using Interfaces)
```kotlin
// Define interface
interface NetworkClient {
    suspend fun fetchMenu(url: String): Result<String>
}

// Test implementation
class MockNetworkClient : NetworkClient {
    var mockResponse: Result<String> = Result.success("{}")
    
    override suspend fun fetchMenu(url: String): Result<String> {
        return mockResponse
    }
}

// Usage in test
@Test
fun `MenuService - handles network errors gracefully`() = runTest {
    val mockClient = MockNetworkClient().apply {
        mockResponse = Result.failure(IOException("Network error"))
    }
    val service = MenuService(mockClient)
    
    val result = service.loadMenu("https://example.com")
    
    assertTrue(result.isFailure)
}
```

#### Swift (Using Protocols)
```swift
// Define protocol
protocol NetworkClientProtocol {
    func fetchMenu(from url: URL) async throws -> Data
}

// Mock implementation
class MockNetworkClient: NetworkClientProtocol {
    var mockData: Data?
    var mockError: Error?
    
    func fetchMenu(from url: URL) async throws -> Data {
        if let error = mockError {
            throw error
        }
        return mockData ?? Data()
    }
}

// Usage in test
func testMenuService_WhenNetworkFails_ReturnsError() async {
    // Given
    let mockClient = MockNetworkClient()
    mockClient.mockError = URLError(.notConnectedToInternet)
    let service = MenuService(networkClient: mockClient)
    
    // When/Then
    await XCTAssertThrowsError(try await service.loadMenu(from: testURL))
}
```

### 5. Testing Asynchronous Code

#### Kotlin Coroutines
```kotlin
@Test
fun `loadMenuAsync - completes successfully with valid data`() = runTest {
    // This test will wait for coroutines to complete
    val service = MenuService()
    
    val result = service.loadMenuAsync()
    
    assertNotNull(result)
    assertTrue(result.isSuccess)
}
```

#### Swift Async/Await
```swift
func testLoadMenuAsync_WithValidData_CompletesSuccessfully() async throws {
    // Given
    let service = MenuService()
    
    // When
    let menu = try await service.loadMenuAsync()
    
    // Then
    XCTAssertNotNil(menu)
    XCTAssertFalse(menu.items.isEmpty)
}
```

### 6. Testing Flows and Streams

#### Kotlin Flow
```kotlin
@Test
fun `menuUpdates - emits new values when menu changes`() = runTest {
    val repository = MenuRepository()
    val testMenu1 = TestDataBuilder.menuResponse(restaurantName = "Restaurant 1")
    val testMenu2 = TestDataBuilder.menuResponse(restaurantName = "Restaurant 2")
    
    val emissions = mutableListOf<MenuResponse>()
    val job = launch {
        repository.menuUpdates.toList(emissions)
    }
    
    repository.updateMenu(testMenu1)
    repository.updateMenu(testMenu2)
    
    delay(100) // Give time for emissions
    job.cancel()
    
    assertEquals(2, emissions.size)
    assertEquals("Restaurant 1", emissions[0].restaurantName)
    assertEquals("Restaurant 2", emissions[1].restaurantName)
}
```

## Test Organization

### 1. Package Structure
Mirror your source code structure in test directories:
```
src/main/kotlin/com/example/pulse/service/MenuService.kt
src/test/kotlin/com/example/pulse/service/MenuServiceTest.kt
```

### 2. Test Fixtures
Group related test data and utilities:
```kotlin
// shared/src/commonTest/kotlin/.../fixtures/MenuFixtures.kt
object MenuFixtures {
    val SIMPLE_MENU = """
        {
            "items": [
                {"name": "Burger", "price": 10.99},
                {"name": "Fries", "price": 3.99}
            ]
        }
    """.trimIndent()
    
    val EMPTY_MENU = """{"items": []}"""
    
    val INVALID_JSON = """{"items": [}"""
}
```

### 3. Base Test Classes
Create base classes for common test functionality:

```kotlin
// Android Example
abstract class ViewModelTest {
    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()
    
    protected val testDispatcher = StandardTestDispatcher()
    
    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }
    
    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }
}
```

## Running Tests

### Command Line

```bash
# Run all shared tests
./gradlew :shared:allTests

# Run specific test class
./gradlew :shared:allTests --tests "*.MenuServiceTest"

# Run with coverage
./gradlew :shared:koverReport

# Run Android unit tests
./gradlew :androidApp:testDebugUnitTest

# Run iOS tests
xcodebuild test -workspace iosApp.xcworkspace -scheme iosApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### IDE Integration

#### Android Studio / IntelliJ
- Right-click test class/method → Run
- Use gutter icons for quick test execution
- View coverage with "Run with Coverage"

#### Xcode
- ⌘+U to run all tests
- Click diamond icons in gutter to run specific tests
- Use Test Navigator (⌘+6) for test organization

## Best Practices

### 1. Keep Tests Fast
- Mock external dependencies
- Use in-memory databases
- Avoid file I/O when possible

### 2. Test One Thing
Each test should verify a single behavior:
```kotlin
// Good: Focused test
@Test
fun `parsePrice - returns null when price format is invalid`() {
    val result = parsePrice("abc")
    assertNull(result)
}

// Bad: Testing multiple things
@Test
fun `parsePrice - handles various inputs`() {
    assertEquals(10.99, parsePrice("$10.99"))
    assertNull(parsePrice("abc"))
    assertEquals(0.0, parsePrice("$0"))
    // Too many assertions!
}
```

### 3. Use Descriptive Assertions
```kotlin
// Good: Clear failure message
assertEquals(
    expected = 14.98,
    actual = total,
    absoluteTolerance = 0.01,
    message = "Total should be sum of burger ($10.99) and fries ($3.99)"
)

// Better: Custom assertions
fun assertPriceEquals(expected: Double, actual: Double) {
    assertEquals(expected, actual, 0.01, "Price mismatch")
}
```

### 4. Avoid Test Interdependence
```kotlin
// Bad: Tests depend on shared state
class BadTestExample {
    companion object {
        var sharedCounter = 0
    }
    
    @Test
    fun test1() {
        sharedCounter++
        assertEquals(1, sharedCounter) // Fails if test2 runs first!
    }
    
    @Test
    fun test2() {
        sharedCounter = 5
        assertEquals(5, sharedCounter)
    }
}

// Good: Independent tests
class GoodTestExample {
    private var counter = 0
    
    @Before
    fun setUp() {
        counter = 0
    }
    
    @Test
    fun test1() {
        counter++
        assertEquals(1, counter)
    }
}
```

## Common Patterns

### Testing ViewModels

```kotlin
class FoodMenuViewModelTest : ViewModelTest() {
    private lateinit var viewModel: FoodMenuViewModel
    private lateinit var mockRepository: MockFoodMenuRepository
    
    @Before
    override fun setUp() {
        super.setUp()
        mockRepository = MockFoodMenuRepository()
        viewModel = FoodMenuViewModel(mockRepository)
    }
    
    @Test
    fun `loadMenu - updates state to loading then success`() = runTest {
        // Given
        val expectedMenu = TestDataBuilder.menuResponse()
        mockRepository.mockMenu = expectedMenu
        
        // When
        viewModel.loadMenu()
        
        // Then - Loading state
        assertEquals(LoadingState.Loading, viewModel.state.value)
        
        // Advance coroutines
        advanceUntilIdle()
        
        // Then - Success state
        assertEquals(LoadingState.Success(expectedMenu), viewModel.state.value)
    }
}
```

### Testing Repository Pattern

```kotlin
class MenuRepositoryTest {
    @Test
    fun `getMenu - caches result after first call`() = runTest {
        // Given
        val mockService = MockMenuService()
        val repository = MenuRepository(mockService)
        var callCount = 0
        mockService.onFetch = { callCount++ }
        
        // When
        val result1 = repository.getMenu()
        val result2 = repository.getMenu()
        
        // Then
        assertEquals(1, callCount, "Service should only be called once")
        assertEquals(result1, result2, "Both calls should return same result")
    }
}
```

## Debugging Failed Tests

### 1. Add Logging
```kotlin
@Test
fun `complex calculation test`() {
    val input = createComplexInput()
    println("Input: $input") // Debug output
    
    val result = performCalculation(input)
    println("Result: $result") // Debug output
    
    assertEquals(expected, result)
}
```

### 2. Use Debugger Breakpoints
- Set breakpoints in test and production code
- Step through execution
- Inspect variable values

### 3. Isolate the Problem
```kotlin
@Test
fun `debug failing integration`() {
    // Break down complex test into smaller parts
    val step1Result = performStep1()
    assertNotNull(step1Result, "Step 1 failed")
    
    val step2Result = performStep2(step1Result)
    assertNotNull(step2Result, "Step 2 failed")
    
    // Continue breaking down...
}
```

## Next Steps

- Review [UI Testing Guide](./UI_TESTING.md) for testing user interfaces
- Check [Integration Testing](./INTEGRATION_TESTING.md) for external service tests
- See [Test Coverage](./TEST_COVERAGE.md) for coverage requirements