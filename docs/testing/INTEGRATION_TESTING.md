# Integration Testing Guide

This guide covers integration testing practices for your project, focusing on testing interactions with external services like backend APIs, AI services, and network APIs.

## Overview

Integration tests verify that different components of the system work correctly together. They:
- Test real interactions with external services
- Validate API contracts and responses
- Ensure proper error handling across system boundaries
- Verify data flow through multiple layers

## Types of Integration Tests

### 1. API Integration Tests
Test interactions with REST APIs and external services.

### 2. Database Integration Tests
Verify data persistence and retrieval operations.

### 3. Service Integration Tests
Test communication between different microservices or modules.

### 4. End-to-End Integration Tests
Test complete user scenarios across multiple systems.

## Platform-Specific Implementation

### Kotlin/KMM Integration Tests

#### Supabase Integration Test Example
```kotlin
// shared/src/commonTest/kotlin/.../service/SupabaseIntegrationTest.kt
class SupabaseIntegrationTest {
    private lateinit var supabaseClient: SupabaseClient
    
    @BeforeTest
    fun setup() {
        supabaseClient = createTestSupabaseClient()
    }
    
    @Test
    fun `uploadMenuImage - successfully uploads and retrieves image`() = runTest {
        // Given
        val testImage = TestDataBuilder.createTestImageData()
        val fileName = "test-menu-${System.currentTimeMillis()}.jpg"
        
        // When - Upload image
        val uploadResult = supabaseClient.storage
            .from("menu-images")
            .upload(fileName, testImage)
        
        // Then - Verify upload
        assertTrue(uploadResult.isSuccess)
        
        // When - Retrieve image
        val downloadResult = supabaseClient.storage
            .from("menu-images")
            .download(fileName)
        
        // Then - Verify retrieval
        assertTrue(downloadResult.isSuccess)
        assertContentEquals(testImage, downloadResult.getOrNull())
        
        // Cleanup
        supabaseClient.storage
            .from("menu-images")
            .delete(listOf(fileName))
    }
    
    @Test
    fun `menuParser function - processes image and returns food items`() = runTest {
        // Given
        val testImageBase64 = TestDataBuilder.createBase64MenuImage()
        
        // When
        val response = supabaseClient.functions.invoke(
            function = "menu-parser",
            body = MenuParserRequest(
                image = testImageBase64,
                mimeType = "image/jpeg"
            )
        )
        
        // Then
        assertTrue(response.isSuccess)
        val menuResponse = response.getOrNull()?.decodeAs<MenuParserResponse>()
        assertNotNull(menuResponse)
        assertTrue(menuResponse.items.isNotEmpty())
        
        // Verify response structure
        menuResponse.items.forEach { item ->
            assertNotNull(item.name)
            assertTrue(item.price > 0)
        }
    }
}
```

#### Network Service Integration Test
```kotlin
// shared/src/commonTest/kotlin/.../service/NetworkIntegrationTest.kt
class NetworkIntegrationTest {
    private lateinit var networkService: NetworkService
    
    @BeforeTest
    fun setup() {
        networkService = NetworkService(
            httpClient = createTestHttpClient()
        )
    }
    
    @Test
    fun `fetchRestaurantMenu - handles various response codes correctly`() = runTest {
        // Test successful response
        val successUrl = "https://api.example.com/menu/valid"
        val successResult = networkService.fetchRestaurantMenu(successUrl)
        assertTrue(successResult.isSuccess)
        
        // Test 404 response
        val notFoundUrl = "https://api.example.com/menu/notfound"
        val notFoundResult = networkService.fetchRestaurantMenu(notFoundUrl)
        assertTrue(notFoundResult.isFailure)
        assertTrue(notFoundResult.exceptionOrNull() is NotFoundException)
        
        // Test network timeout
        val timeoutUrl = "https://api.example.com/menu/timeout"
        val timeoutResult = networkService.fetchRestaurantMenu(timeoutUrl)
        assertTrue(timeoutResult.isFailure)
        assertTrue(timeoutResult.exceptionOrNull() is NetworkTimeoutException)
    }
    
    @Test
    fun `retryWithBackoff - retries failed requests appropriately`() = runTest {
        // Given
        var attemptCount = 0
        val flakeyOperation = suspend {
            attemptCount++
            if (attemptCount < 3) {
                throw NetworkException("Temporary failure")
            }
            "Success"
        }
        
        // When
        val result = networkService.retryWithBackoff(
            operation = flakeyOperation,
            maxAttempts = 3
        )
        
        // Then
        assertEquals("Success", result)
        assertEquals(3, attemptCount)
    }
}
```

### iOS Integration Tests

#### Supabase Integration Test
```swift
// iosApp/iosAppTests/SupabaseIntegrationTests.swift
import XCTest
import Supabase
@testable import iosApp

class SupabaseIntegrationTests: XCTestCase {
    var supabaseClient: SupabaseClient!
    
    override func setUp() async throws {
        supabaseClient = try await createTestSupabaseClient()
    }
    
    func testUploadMenuImage_SuccessfullyUploadsAndRetrievesImage() async throws {
        // Given
        let testImage = createTestMenuImage()
        let imageData = testImage.jpegData(compressionQuality: 0.8)!
        let fileName = "test-menu-\(Date().timeIntervalSince1970).jpg"
        
        // When - Upload image
        let uploadPath = try await supabaseClient.storage
            .from("menu-images")
            .upload(
                path: fileName,
                data: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        // Then - Verify upload
        XCTAssertFalse(uploadPath.isEmpty)
        
        // When - Download image
        let downloadedData = try await supabaseClient.storage
            .from("menu-images")
            .download(path: fileName)
        
        // Then - Verify download
        XCTAssertEqual(imageData.count, downloadedData.count)
        
        // Cleanup
        try await supabaseClient.storage
            .from("menu-images")
            .remove(paths: [fileName])
    }
    
    func testMenuParserFunction_ProcessesImageAndReturnsFoodItems() async throws {
        // Given
        let testImageBase64 = createBase64MenuImage()
        
        // When
        let response = try await supabaseClient.functions.invoke(
            functionName: "menu-parser",
            invokeOptions: FunctionInvokeOptions(
                body: [
                    "image": testImageBase64,
                    "mimeType": "image/jpeg"
                ]
            )
        )
        
        // Then
        let menuResponse = try JSONDecoder().decode(
            MenuParserResponse.self,
            from: response.data
        )
        XCTAssertFalse(menuResponse.items.isEmpty)
        
        // Verify response structure
        for item in menuResponse.items {
            XCTAssertFalse(item.name.isEmpty)
            XCTAssertGreaterThan(item.price, 0)
        }
    }
}
```

#### Network Integration Test
```swift
// iosApp/iosAppTests/NetworkIntegrationTests.swift
class NetworkIntegrationTests: XCTestCase {
    var networkService: NetworkService!
    
    override func setUp() {
        networkService = NetworkService(
            urlSession: createTestURLSession()
        )
    }
    
    func testFetchRestaurantMenu_HandlesVariousResponseCodes() async throws {
        // Test successful response
        let successURL = URL(string: "https://api.example.com/menu/valid")!
        let successResult = try await networkService.fetchRestaurantMenu(from: successURL)
        XCTAssertNotNil(successResult)
        
        // Test 404 response
        let notFoundURL = URL(string: "https://api.example.com/menu/notfound")!
        do {
            _ = try await networkService.fetchRestaurantMenu(from: notFoundURL)
            XCTFail("Should throw NotFoundError")
        } catch {
            XCTAssertTrue(error is NotFoundError)
        }
        
        // Test network timeout
        let timeoutURL = URL(string: "https://api.example.com/menu/timeout")!
        do {
            _ = try await networkService.fetchRestaurantMenu(from: timeoutURL)
            XCTFail("Should throw TimeoutError")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .timedOut)
        }
    }
}
```

### Android Integration Tests

```kotlin
// androidApp/src/androidTest/.../integration/CameraIntegrationTest.kt
@RunWith(AndroidJUnit4::class)
class CameraIntegrationTest {
    @get:Rule
    val permissionRule = GrantPermissionRule.grant(
        android.Manifest.permission.CAMERA
    )
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun testCompleteImageCaptureFlow() {
        // Given: Camera permission is granted
        composeTestRule.setContent {
            CameraScreen(
                onImageCaptured = { base64Image ->
                    // Verify image is properly encoded
                    assertTrue(base64Image.isNotEmpty())
                    assertTrue(base64Image.startsWith("/9j/")) // JPEG marker
                }
            )
        }
        
        // When: Wait for camera to initialize
        composeTestRule.waitUntil(5000) {
            composeTestRule.onAllNodesWithTag("camera_preview")
                .fetchSemanticsNodes().isNotEmpty()
        }
        
        // Then: Capture image
        composeTestRule.onNodeWithTag("capture_button").performClick()
        
        // Verify capture completes
        composeTestRule.waitUntil(10000) {
            composeTestRule.onAllNodesWithTag("processing_indicator")
                .fetchSemanticsNodes().isEmpty()
        }
    }
}
```

## Testing Strategies

### 1. Test Environment Setup

#### Local Test Environment
```kotlin
// shared/src/commonTest/kotlin/.../TestEnvironment.kt
object TestEnvironment {
    val SUPABASE_URL = System.getenv("TEST_SUPABASE_URL") 
        ?: "http://localhost:54321"
    val SUPABASE_ANON_KEY = System.getenv("TEST_SUPABASE_ANON_KEY")
        ?: "test-anon-key"
    
    fun createTestSupabaseClient(): SupabaseClient {
        return createSupabaseClient(
            supabaseUrl = SUPABASE_URL,
            supabaseKey = SUPABASE_ANON_KEY
        ) {
            // Test-specific configuration
            install(GoTrue) {
                autoRefreshSession = false
            }
            install(Storage) {
                // Use test bucket
            }
        }
    }
}
```

### 2. Mock Services for Integration Tests

```kotlin
// Create controllable mock services
class MockMenuParserService : MenuParserService {
    var mockResponse: MenuParserResponse? = null
    var shouldFail: Boolean = false
    var delayMillis: Long = 0
    
    override suspend fun parseMenu(image: String): MenuParserResponse {
        delay(delayMillis) // Simulate network delay
        
        if (shouldFail) {
            throw MenuParserException("Mock failure")
        }
        
        return mockResponse ?: MenuParserResponse(
            items = listOf(
                FoodItem("Test Burger", 9.99),
                FoodItem("Test Fries", 3.99)
            )
        )
    }
}
```

### 3. Database Integration Testing

```kotlin
class DatabaseIntegrationTest {
    private lateinit var database: AppDatabase
    
    @BeforeTest
    fun setup() {
        // Use in-memory database for tests
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            AppDatabase::class.java
        ).build()
    }
    
    @AfterTest
    fun tearDown() {
        database.close()
    }
    
    @Test
    fun `foodItemDao - insert and retrieve operations work correctly`() = runTest {
        // Given
        val foodItems = listOf(
            FoodItemEntity(name = "Burger", price = 10.99),
            FoodItemEntity(name = "Pizza", price = 12.99)
        )
        
        // When - Insert items
        database.foodItemDao().insertAll(foodItems)
        
        // Then - Retrieve and verify
        val retrieved = database.foodItemDao().getAllFoodItems().first()
        assertEquals(2, retrieved.size)
        assertEquals("Burger", retrieved[0].name)
        assertEquals(10.99, retrieved[0].price, 0.01)
    }
}
```

### 4. API Contract Testing

```kotlin
@Test
fun `menuParser API - response matches expected contract`() = runTest {
    // Given
    val request = MenuParserRequest(
        image = TestDataBuilder.createBase64MenuImage(),
        mimeType = "image/jpeg"
    )
    
    // When
    val response = supabaseClient.functions.invoke(
        function = "menu-parser",
        body = request
    )
    
    // Then - Verify response structure
    val json = response.data.decodeToString()
    val jsonObject = Json.parseToJsonElement(json).jsonObject
    
    // Verify required fields exist
    assertTrue(jsonObject.containsKey("items"))
    assertTrue(jsonObject.containsKey("timestamp"))
    assertTrue(jsonObject.containsKey("confidence"))
    
    // Verify items structure
    val items = jsonObject["items"]?.jsonArray
    assertNotNull(items)
    items?.forEach { item ->
        val itemObject = item.jsonObject
        assertTrue(itemObject.containsKey("name"))
        assertTrue(itemObject.containsKey("price"))
        assertTrue(itemObject.containsKey("id"))
    }
}
```

## Testing External Services

### 1. Testing with Real Services

```kotlin
@OptIn(ExperimentalTestApi::class)
@IntegrationTest // Custom annotation to mark integration tests
class RealServiceIntegrationTest {
    
    @Test
    fun `real Supabase service - handles rate limiting gracefully`() = runTest {
        val client = createRealSupabaseClient()
        
        // Make multiple rapid requests
        val requests = (1..20).map { index ->
            async {
                client.functions.invoke(
                    function = "menu-parser",
                    body = mapOf("test" to index)
                )
            }
        }
        
        // Collect results
        val results = requests.awaitAll()
        
        // Verify rate limiting handling
        val successCount = results.count { it.isSuccess }
        val rateLimitedCount = results.count { 
            it.isFailure && it.exceptionOrNull() is RateLimitException 
        }
        
        assertTrue(successCount > 0)
        println("Success: $successCount, Rate Limited: $rateLimitedCount")
    }
}
```

### 2. Testing with Test Doubles

```kotlin
class TestDoubleIntegrationTest {
    @Test
    fun `service integration - handles cascade failures correctly`() = runTest {
        // Setup test doubles
        val mockImageProcessor = MockImageProcessor().apply {
            processResult = Result.success(ProcessedImage(data = byteArrayOf()))
        }
        
        val mockMenuParser = MockMenuParser().apply {
            shouldFail = true
            errorType = NetworkException("Service unavailable")
        }
        
        val menuService = MenuService(
            imageProcessor = mockImageProcessor,
            menuParser = mockMenuParser
        )
        
        // Test cascade failure handling
        val result = menuService.processMenuImage("test-image")
        
        assertTrue(result.isFailure)
        assertTrue(result.exceptionOrNull() is ServiceUnavailableException)
    }
}
```

## Performance Testing

### Load Testing Integration Points

```kotlin
@Test
fun `menuParser function - handles concurrent requests`() = runTest {
    val concurrentRequests = 10
    val client = createTestSupabaseClient()
    
    val startTime = System.currentTimeMillis()
    
    val results = (1..concurrentRequests).map {
        async {
            client.functions.invoke(
                function = "menu-parser",
                body = MenuParserRequest(
                    image = TestDataBuilder.createBase64MenuImage(),
                    mimeType = "image/jpeg"
                )
            )
        }
    }.awaitAll()
    
    val endTime = System.currentTimeMillis()
    val totalTime = endTime - startTime
    
    // Verify all requests completed
    assertEquals(concurrentRequests, results.size)
    assertTrue(results.all { it.isSuccess })
    
    // Verify performance
    val avgTimePerRequest = totalTime / concurrentRequests
    assertTrue(avgTimePerRequest < 2000) // Less than 2 seconds per request
    
    println("Processed $concurrentRequests requests in ${totalTime}ms")
    println("Average time per request: ${avgTimePerRequest}ms")
}
```

## Test Data Management

### 1. Test Data Fixtures

```kotlin
object IntegrationTestFixtures {
    val SAMPLE_MENU_IMAGES = mapOf(
        "simple_menu" to loadResource("test-data/simple-menu.jpg"),
        "complex_menu" to loadResource("test-data/complex-menu.jpg"),
        "handwritten_menu" to loadResource("test-data/handwritten-menu.jpg")
    )
    
    val EXPECTED_MENU_ITEMS = mapOf(
        "simple_menu" to listOf(
            FoodItem("Burger", 10.99),
            FoodItem("Fries", 3.99),
            FoodItem("Soda", 2.99)
        )
    )
    
    fun createTestUser(): TestUser {
        return TestUser(
            email = "test-${UUID.randomUUID()}@example.com",
            password = "testpass123"
        )
    }
}
```

### 2. Database Seeding

```kotlin
class DatabaseSeeder {
    suspend fun seedTestData(database: AppDatabase) {
        // Clear existing data
        database.clearAllTables()
        
        // Insert test restaurants
        val restaurants = listOf(
            RestaurantEntity(id = 1, name = "Test Burger Place"),
            RestaurantEntity(id = 2, name = "Test Pizza Shop")
        )
        database.restaurantDao().insertAll(restaurants)
        
        // Insert test menu items
        val menuItems = listOf(
            MenuItemEntity(restaurantId = 1, name = "Burger", price = 10.99),
            MenuItemEntity(restaurantId = 1, name = "Fries", price = 3.99),
            MenuItemEntity(restaurantId = 2, name = "Pizza", price = 12.99)
        )
        database.menuItemDao().insertAll(menuItems)
    }
}
```

## Error Handling and Recovery

### Testing Error Scenarios

```kotlin
@Test
fun `integration - recovers from transient failures`() = runTest {
    val service = ResilientMenuService(
        retryPolicy = RetryPolicy(
            maxAttempts = 3,
            backoffMillis = 100
        )
    )
    
    // Simulate transient failure then success
    var attemptCount = 0
    service.onMenuParse = {
        attemptCount++
        if (attemptCount < 3) {
            throw NetworkException("Transient failure")
        }
        MenuParserResponse(items = listOf(FoodItem("Success", 1.0)))
    }
    
    val result = service.parseMenuWithRetry("test-image")
    
    assertTrue(result.isSuccess)
    assertEquals(3, attemptCount)
    assertEquals("Success", result.getOrNull()?.items?.first()?.name)
}
```

## CI/CD Integration

### GitHub Actions Configuration

```yaml
name: Integration Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *' # Run nightly at 2 AM

jobs:
  integration-tests:
    runs-on: ubuntu-latest
    
    services:
      supabase:
        image: supabase/postgres:15.1.0.55
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Test Environment
        run: |
          echo "TEST_SUPABASE_URL=${{ secrets.TEST_SUPABASE_URL }}" >> $GITHUB_ENV
          echo "TEST_SUPABASE_ANON_KEY=${{ secrets.TEST_SUPABASE_ANON_KEY }}" >> $GITHUB_ENV
      
      - name: Run Integration Tests
        run: |
          ./gradlew :shared:integrationTest
          ./gradlew :androidApp:connectedCheck
      
      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-results
          path: |
            **/build/reports/tests/
            **/build/test-results/
```

## Best Practices

### 1. Test Isolation
- Each test should be independent
- Clean up test data after each test
- Use unique identifiers for test data

### 2. Timeouts and Retries
- Set appropriate timeouts for network operations
- Implement retry logic for flaky operations
- Use exponential backoff for retries

### 3. Environment Management
- Use separate test environments
- Never run integration tests against production
- Use environment variables for configuration

### 4. Test Categories
- Tag tests appropriately (unit, integration, e2e)
- Run different test suites at different stages
- Balance test coverage with execution time

## Troubleshooting Integration Tests

### Common Issues

1. **Network Timeouts**
   - Increase timeout values for slow operations
   - Check network connectivity
   - Verify service endpoints are correct

2. **Authentication Failures**
   - Verify test credentials are valid
   - Check token expiration
   - Ensure proper environment configuration

3. **Data Conflicts**
   - Use unique identifiers for test data
   - Clean up data between tests
   - Implement proper transaction isolation

4. **Service Unavailability**
   - Implement circuit breakers
   - Add retry logic with backoff
   - Have fallback mechanisms

## Next Steps

- Review [Test Coverage](./TEST_COVERAGE.md) for integration test coverage requirements
- See [Troubleshooting](./TROUBLESHOOTING.md) for debugging integration test issues
- Check [UI Testing](./UI_TESTING.md) for end-to-end test scenarios