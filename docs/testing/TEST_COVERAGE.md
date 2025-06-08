# Test Coverage Guide

This guide outlines test coverage requirements, measurement tools, and best practices for maintaining high-quality test coverage in your project.

## Coverage Requirements

### Minimum Coverage Thresholds

| Component Type | Line Coverage | Branch Coverage | Function Coverage |
|----------------|---------------|-----------------|-------------------|
| Shared Module  | 80%           | 75%             | 85%               |
| ViewModels     | 85%           | 80%             | 90%               |
| Services       | 90%           | 85%             | 95%               |
| UI Components  | 70%           | 65%             | 75%               |
| Utilities      | 95%           | 90%             | 100%              |

### Platform-Specific Requirements

- **Android**: Minimum 80% overall coverage
- **iOS**: Minimum 80% overall coverage
- **Shared/Common**: Minimum 85% overall coverage

## Coverage Tools

### Kotlin/Android Coverage with Kover

#### Setup
```kotlin
// build.gradle.kts (project level)
plugins {
    id("org.jetbrains.kotlinx.kover") version "0.7.4"
}

// Configure Kover
koverMerged {
    enable()
    
    filters {
        classes {
            excludes += listOf(
                "*Activity",
                "*Fragment",
                "*.databinding.*",
                "*.BuildConfig"
            )
        }
    }
    
    verify {
        onCheck = true
        rule {
            isEnabled = true
            name = "Minimal line coverage"
            target = kotlinx.kover.api.VerificationTarget.ALL
            
            bound {
                minValue = 80
                counter = kotlinx.kover.api.CounterType.LINE
                valueType = kotlinx.kover.api.VerificationValueType.COVERED_PERCENTAGE
            }
        }
    }
}
```

#### Running Coverage Reports
```bash
# Generate coverage report for all modules
./gradlew koverMergedReport

# Generate HTML report
./gradlew koverMergedHtmlReport

# Verify coverage meets thresholds
./gradlew koverMergedVerify

# Module-specific coverage
./gradlew :shared:koverReport
./gradlew :androidApp:koverReport
```

### iOS Coverage with Xcode

#### Enable Coverage in Scheme
1. Edit scheme in Xcode
2. Test action → Options tab
3. Check "Code Coverage"
4. Check "Gather coverage for all targets"

#### Running Coverage
```bash
# Run tests with coverage
xcodebuild test \
  -workspace iosApp.xcworkspace \
  -scheme iosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Generate coverage report
xcrun xcresulttool get --path TestResults.xcresult --format json > coverage.json

# View coverage in Xcode
# Product → Show Build Folder → Products → Debug-iphonesimulator → Coverage
```

### Coverage Reporting Tools

#### 1. JaCoCo for Android
```kotlin
// androidApp/build.gradle.kts
android {
    buildTypes {
        debug {
            enableUnitTestCoverage = true
            enableAndroidTestCoverage = true
        }
    }
}

tasks.register<JacocoReport>("jacocoTestReport") {
    dependsOn("testDebugUnitTest")
    
    reports {
        xml.required.set(true)
        html.required.set(true)
    }
    
    sourceDirectories.setFrom(files("src/main/java"))
    classDirectories.setFrom(files("build/tmp/kotlin-classes/debug"))
    executionData.setFrom(files("build/jacoco/testDebugUnitTest.exec"))
}
```

#### 2. SwiftCov for iOS
```yaml
# .swiftcov.yml
minimum_coverage: 80
exclude:
  - "**/*Tests.swift"
  - "**/*Mock*.swift"
  - "**/Preview Content/**"
```

## Measuring Coverage

### Unit Test Coverage

```kotlin
// Example: Measuring ViewModel coverage
class FoodMenuViewModelTest {
    @Test
    fun `test all public methods for coverage`() {
        val viewModel = FoodMenuViewModel()
        
        // Test initialization
        assertNotNull(viewModel.state.value)
        
        // Test all public methods
        viewModel.loadMenu()
        viewModel.refreshMenu()
        viewModel.selectFoodItem(0)
        viewModel.clearSelection()
        
        // Test edge cases
        viewModel.selectFoodItem(-1) // Invalid index
        viewModel.selectFoodItem(Int.MAX_VALUE) // Out of bounds
    }
}
```

### Branch Coverage

```kotlin
// Ensure all conditional branches are tested
class PriceCalculator {
    fun calculateTotal(items: List<FoodItem>, includesTax: Boolean): Double {
        var total = items.sumOf { it.price }
        
        if (includesTax) {
            total *= 1.08 // 8% tax
        }
        
        return if (total > 100) {
            total * 0.9 // 10% discount
        } else {
            total
        }
    }
}

class PriceCalculatorTest {
    @Test
    fun `calculateTotal - covers all branches`() {
        val calculator = PriceCalculator()
        val items = listOf(FoodItem("Item", 50.0))
        
        // Branch 1: Without tax, under $100
        assertEquals(50.0, calculator.calculateTotal(items, false), 0.01)
        
        // Branch 2: With tax, under $100
        assertEquals(54.0, calculator.calculateTotal(items, true), 0.01)
        
        // Branch 3: Without tax, over $100
        val expensiveItems = listOf(FoodItem("Item", 150.0))
        assertEquals(135.0, calculator.calculateTotal(expensiveItems, false), 0.01)
        
        // Branch 4: With tax, over $100
        assertEquals(145.8, calculator.calculateTotal(expensiveItems, true), 0.01)
    }
}
```

## Coverage Analysis

### Identifying Uncovered Code

#### Using Coverage Reports
1. Generate HTML coverage report
2. Open report in browser
3. Navigate to uncovered classes
4. Look for red highlighting

#### Common Uncovered Areas
- Error handling paths
- Edge cases
- Platform-specific code
- Generated code (exclude from coverage)

### Improving Coverage

#### 1. Test Missing Branches
```kotlin
// Before: Missing error handling test
class NetworkService {
    suspend fun fetchData(): Result<String> {
        return try {
            val response = httpClient.get(url)
            Result.success(response.body())
        } catch (e: Exception) {
            Result.failure(e) // This branch not tested!
        }
    }
}

// After: Complete coverage
@Test
fun `fetchData - handles network errors`() = runTest {
    val service = NetworkService(mockHttpClient)
    mockHttpClient.throwError = IOException("Network error")
    
    val result = service.fetchData()
    
    assertTrue(result.isFailure)
    assertTrue(result.exceptionOrNull() is IOException)
}
```

#### 2. Test Edge Cases
```kotlin
@Test
fun `parsePrice - handles edge cases for full coverage`() {
    // Normal cases
    assertEquals(10.99, parsePrice("$10.99"))
    assertEquals(0.0, parsePrice("$0"))
    
    // Edge cases for coverage
    assertNull(parsePrice(null)) // Null input
    assertNull(parsePrice("")) // Empty string
    assertNull(parsePrice("abc")) // Invalid format
    assertEquals(999999.99, parsePrice("$999,999.99")) // Large number
    assertEquals(0.01, parsePrice("$0.01")) // Minimum value
}
```

## Excluding Code from Coverage

### Kotlin Exclusions

```kotlin
// Using annotations
@ExcludeFromCoverage
class GeneratedConstants {
    companion object {
        const val API_VERSION = "1.0"
    }
}

// Kover configuration
kover {
    filters {
        classes {
            excludes += listOf(
                "*.BuildConfig",
                "*.*\$\$serializer",
                "*.databinding.*",
                "*ComposableSingletons*"
            )
        }
        annotations {
            excludes += listOf(
                "ExcludeFromCoverage",
                "Generated"
            )
        }
    }
}
```

### iOS Exclusions

```swift
// Using comments
// swiftlint:disable:next force_cast
let viewController = storyboard.instantiateViewController(withIdentifier: "Main") as! MainViewController // excluded from coverage

// In .xcovignore file
# Exclude generated files
*.generated.swift
**/Generated/*

# Exclude UI previews
**/Preview Content/*

# Exclude test helpers
**/*Mock*.swift
**/*Stub*.swift
```

## Coverage in CI/CD

### GitHub Actions Integration

```yaml
name: Test Coverage

on: [push, pull_request]

jobs:
  coverage:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests with coverage
        run: ./gradlew koverMergedReport
      
      - name: Generate coverage report
        run: ./gradlew koverMergedHtmlReport
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./build/reports/kover/merged/xml/report.xml
          flags: unittests
          name: codecov-umbrella
      
      - name: Comment PR with coverage
        uses: actions/github-script@v6
        if: github.event_name == 'pull_request'
        with:
          script: |
            const coverage = require('./build/reports/coverage-summary.json');
            const comment = `## Coverage Report
            - Lines: ${coverage.total.lines.pct}%
            - Branches: ${coverage.total.branches.pct}%
            - Functions: ${coverage.total.functions.pct}%`;
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
      
      - name: Fail if below threshold
        run: ./gradlew koverMergedVerify
```

### Coverage Badges

```markdown
<!-- In README.md -->
![Coverage](https://codecov.io/gh/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME/branch/main/graph/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen.svg)
```

## Best Practices

### 1. Write Tests First (TDD)
- Ensures code is testable
- Guarantees coverage from the start
- Helps design better APIs

### 2. Focus on Meaningful Coverage
```kotlin
// Bad: Testing getters/setters for coverage
@Test
fun `test getters and setters`() {
    val item = FoodItem()
    item.name = "Test"
    assertEquals("Test", item.name) // Not meaningful
}

// Good: Testing business logic
@Test
fun `calculateNutritionScore - returns accurate score based on ingredients`() {
    val item = FoodItem(
        name = "Salad",
        calories = 150,
        protein = 10,
        fiber = 5
    )
    
    val score = item.calculateNutritionScore()
    
    assertEquals(8.5, score, 0.1) // Meaningful test
}
```

### 3. Regular Coverage Reviews
- Review coverage reports in PRs
- Set up coverage trend tracking
- Address coverage drops immediately

### 4. Balance Coverage and Quality
- 100% coverage doesn't mean bug-free
- Focus on critical paths first
- Don't write tests just for coverage

## Monitoring Coverage Trends

### Coverage History
```kotlin
// Track coverage over time
tasks.register("trackCoverage") {
    doLast {
        val coverageFile = file("coverage-history.csv")
        val coverage = calculateCurrentCoverage()
        val timestamp = LocalDateTime.now()
        
        coverageFile.appendText(
            "$timestamp,${coverage.line},${coverage.branch},${coverage.function}\n"
        )
    }
}
```

### Visualization
- Use tools like Codecov or Coveralls
- Create custom dashboards
- Monitor coverage trends in CI/CD

## Coverage for Different Test Types

### Unit Test Coverage
- Should cover majority of business logic
- Target: 85-95% coverage
- Fast and reliable

### Integration Test Coverage
- Covers interaction between components
- Target: 70-80% coverage
- Focuses on critical paths

### UI Test Coverage
- Covers user-facing functionality
- Target: 60-70% coverage
- Expensive but valuable

## Troubleshooting Low Coverage

### Common Issues

1. **Generated Code Counted**
   - Exclude generated files
   - Update filter configuration

2. **Unreachable Code**
   - Remove dead code
   - Add appropriate tests

3. **Platform-Specific Code**
   - Use expect/actual pattern
   - Test each platform separately

4. **Async Code Not Covered**
   - Use proper test coroutines
   - Ensure async operations complete

### Debugging Coverage

```kotlin
// Add logging to verify execution
fun complexMethod() {
    println("Method start") // Verify entry
    
    if (condition) {
        println("Branch 1") // Verify branch execution
        // ...
    } else {
        println("Branch 2")
        // ...
    }
    
    println("Method end") // Verify completion
}
```

## Next Steps

- Review [Troubleshooting Guide](./TROUBLESHOOTING.md) for coverage-related issues
- Set up coverage monitoring in your CI/CD pipeline
- Establish team coverage goals and review process