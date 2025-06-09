# Unit Test Template

## Test Structure Guidelines

### Basic Test Structure

```typescript
// TypeScript/JavaScript Example
describe('[Component/Module Name]', () => {
  // Setup that runs before all tests
  beforeAll(() => {
    // One-time setup
  });

  // Setup that runs before each test
  beforeEach(() => {
    // Reset state
    // Create fresh instances
  });

  // Cleanup after each test
  afterEach(() => {
    // Clean up resources
    // Reset mocks
  });

  // Cleanup after all tests
  afterAll(() => {
    // Final cleanup
  });

  describe('[Feature/Method Name]', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      const input = createTestInput();
      const expected = createExpectedOutput();
      
      // Act
      const result = functionUnderTest(input);
      
      // Assert
      expect(result).toEqual(expected);
    });

    it('should handle [edge case]', () => {
      // Test edge cases
    });

    it('should throw error when [invalid condition]', () => {
      // Test error scenarios
      expect(() => functionUnderTest(invalidInput))
        .toThrow(ExpectedError);
    });
  });
});
```

### Language-Specific Examples

#### Java/Kotlin
```kotlin
import kotlin.test.*

class ComponentTest {
    private lateinit var component: Component
    
    @BeforeTest
    fun setup() {
        component = Component()
    }
    
    @Test
    fun `should return expected value when input is valid`() {
        // Given
        val input = "test"
        val expected = "TEST"
        
        // When
        val result = component.process(input)
        
        // Then
        assertEquals(expected, result)
    }
    
    @Test
    fun `should throw exception when input is null`() {
        assertFailsWith<IllegalArgumentException> {
            component.process(null)
        }
    }
}
```

#### Python
```python
import unittest
from unittest.mock import Mock, patch

class TestComponent(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures."""
        self.component = Component()
        
    def tearDown(self):
        """Clean up after tests."""
        self.component = None
    
    def test_process_valid_input(self):
        """Test processing with valid input."""
        # Arrange
        input_data = "test"
        expected = "TEST"
        
        # Act
        result = self.component.process(input_data)
        
        # Assert
        self.assertEqual(result, expected)
    
    def test_process_invalid_input_raises_error(self):
        """Test that invalid input raises appropriate error."""
        with self.assertRaises(ValueError):
            self.component.process(None)
```

#### Swift
```swift
import XCTest
@testable import YourModule

class ComponentTests: XCTestCase {
    var component: Component!
    
    override func setUp() {
        super.setUp()
        component = Component()
    }
    
    override func tearDown() {
        component = nil
        super.tearDown()
    }
    
    func testProcessValidInput() {
        // Given
        let input = "test"
        let expected = "TEST"
        
        // When
        let result = component.process(input)
        
        // Then
        XCTAssertEqual(result, expected)
    }
    
    func testProcessNilInputThrowsError() {
        // Then
        XCTAssertThrowsError(try component.process(nil)) { error in
            XCTAssertTrue(error is ComponentError)
        }
    }
}
```

## Test Naming Conventions

### Descriptive Names
- `should_[expectedBehavior]_when_[condition]`
- `[methodName]_[scenario]_[expectedResult]`
- `given_[context]_when_[action]_then_[outcome]`

### Examples
```
// Good test names
test_calculateTotal_withValidItems_returnsCorrectSum()
should_throw_exception_when_input_is_null()
given_empty_cart_when_adding_item_then_cart_has_one_item()

// Poor test names
test1()
testCalculate()
testError()
```

## Test Organization

### Arrange-Act-Assert Pattern
```typescript
it('should calculate discount correctly', () => {
  // Arrange - Set up test data
  const originalPrice = 100;
  const discountPercentage = 20;
  const expectedPrice = 80;
  
  // Act - Execute the function
  const result = calculateDiscount(originalPrice, discountPercentage);
  
  // Assert - Verify the result
  expect(result).toBe(expectedPrice);
});
```

### Given-When-Then Pattern
```typescript
describe('ShoppingCart', () => {
  it('should apply discount code', () => {
    // Given - Initial context
    const cart = new ShoppingCart();
    cart.addItem({ id: '1', price: 100 });
    
    // When - Action is performed
    cart.applyDiscountCode('SAVE20');
    
    // Then - Expected outcome
    expect(cart.getTotal()).toBe(80);
    expect(cart.hasDiscount()).toBe(true);
  });
});
```

## Test Data Builders

### Builder Pattern for Test Data
```typescript
class UserBuilder {
  private user: User = {
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    role: 'user'
  };
  
  withId(id: string): UserBuilder {
    this.user.id = id;
    return this;
  }
  
  withName(name: string): UserBuilder {
    this.user.name = name;
    return this;
  }
  
  withRole(role: string): UserBuilder {
    this.user.role = role;
    return this;
  }
  
  build(): User {
    return { ...this.user };
  }
}

// Usage in tests
const adminUser = new UserBuilder()
  .withRole('admin')
  .withName('Admin User')
  .build();
```

## Mocking Best Practices

### Mock Only External Dependencies
```typescript
// Good - Mocking external service
const mockApiClient = {
  fetchUser: jest.fn().mockResolvedValue({ id: '1', name: 'Test' })
};

const service = new UserService(mockApiClient);

// Bad - Mocking internal implementation
const service = new UserService();
service.validateUser = jest.fn(); // Don't mock your own methods
```

### Clear Mock Setup
```typescript
describe('NotificationService', () => {
  let mockEmailClient: jest.Mocked<EmailClient>;
  let service: NotificationService;
  
  beforeEach(() => {
    mockEmailClient = {
      send: jest.fn().mockResolvedValue({ success: true })
    };
    service = new NotificationService(mockEmailClient);
  });
  
  it('should send email notification', async () => {
    // Test using the mock
    await service.notify('user@example.com', 'Hello');
    
    expect(mockEmailClient.send).toHaveBeenCalledWith({
      to: 'user@example.com',
      subject: 'Notification',
      body: 'Hello'
    });
  });
});
```

## Testing Async Code

### Promises
```typescript
// Using async/await
it('should fetch user data', async () => {
  const userData = await userService.getUser('123');
  expect(userData.name).toBe('John Doe');
});

// Using return
it('should fetch user data', () => {
  return userService.getUser('123').then(userData => {
    expect(userData.name).toBe('John Doe');
  });
});
```

### Callbacks
```typescript
it('should execute callback with result', (done) => {
  processData(input, (error, result) => {
    expect(error).toBeNull();
    expect(result).toBe('processed');
    done();
  });
});
```

## Edge Cases to Test

### Common Edge Cases
- Null/undefined/empty inputs
- Zero and negative numbers
- Empty arrays/collections
- Boundary values (min/max)
- Special characters in strings
- Concurrent operations
- Network failures
- Timeout scenarios

### Example Edge Case Tests
```typescript
describe('parsePrice', () => {
  it('should handle null input', () => {
    expect(parsePrice(null)).toBe(0);
  });
  
  it('should handle negative values', () => {
    expect(parsePrice(-10)).toBe(0);
  });
  
  it('should handle maximum safe integer', () => {
    expect(parsePrice(Number.MAX_SAFE_INTEGER)).toBe(Number.MAX_SAFE_INTEGER);
  });
  
  it('should handle non-numeric strings', () => {
    expect(parsePrice('abc')).toBe(0);
  });
});
```

## Test Coverage Guidelines

### What to Test
- ✅ Public API/interfaces
- ✅ Business logic
- ✅ Edge cases and error conditions
- ✅ Integration points
- ✅ Complex algorithms

### What Not to Test
- ❌ Third-party libraries
- ❌ Framework code
- ❌ Simple getters/setters
- ❌ Configuration constants
- ❌ Private implementation details

## Performance Testing in Unit Tests

```typescript
describe('Performance', () => {
  it('should process large dataset within time limit', () => {
    const largeArray = Array(10000).fill(0).map((_, i) => i);
    
    const startTime = performance.now();
    const result = processArray(largeArray);
    const endTime = performance.now();
    
    expect(endTime - startTime).toBeLessThan(100); // 100ms limit
    expect(result).toHaveLength(10000);
  });
});
```

## Test Documentation

### Document Complex Test Scenarios
```typescript
describe('Order Processing', () => {
  it('should handle partial refund with tax recalculation', () => {
    /**
     * This test verifies that when a partial refund is issued:
     * 1. The refunded amount is subtracted from the total
     * 2. Tax is recalculated based on the new subtotal
     * 3. The order status is updated to 'partially_refunded'
     * 4. A refund record is created with proper audit trail
     */
    
    // Test implementation...
  });
});
```

## Continuous Improvement

### Test Refactoring Checklist
- [ ] Remove duplicate test setup
- [ ] Extract common assertions
- [ ] Improve test names for clarity
- [ ] Remove obsolete tests
- [ ] Combine related tests
- [ ] Update tests for new requirements
- [ ] Improve test performance
- [ ] Add missing edge cases