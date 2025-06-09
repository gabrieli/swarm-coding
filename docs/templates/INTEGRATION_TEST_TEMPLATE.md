# Integration Test Template

## Overview
Integration tests verify that different parts of the system work together correctly. They test the interactions between components, external services, and databases.

## Test Structure

### Basic Integration Test
```typescript
// Example: API Integration Test
describe('User API Integration', () => {
  let app: Application;
  let database: Database;
  
  beforeAll(async () => {
    // Set up test environment
    database = await createTestDatabase();
    app = await createTestApp(database);
  });
  
  afterAll(async () => {
    // Clean up
    await database.close();
    await app.close();
  });
  
  beforeEach(async () => {
    // Reset database state
    await database.truncate(['users', 'sessions']);
    await seedTestData(database);
  });
  
  describe('POST /api/users', () => {
    it('should create user and send welcome email', async () => {
      // Arrange
      const newUser = {
        email: 'test@example.com',
        name: 'Test User',
        password: 'SecurePass123!'
      };
      
      // Act
      const response = await request(app)
        .post('/api/users')
        .send(newUser)
        .expect(201);
      
      // Assert - API Response
      expect(response.body).toMatchObject({
        id: expect.any(String),
        email: newUser.email,
        name: newUser.name
      });
      
      // Assert - Database State
      const savedUser = await database.users.findByEmail(newUser.email);
      expect(savedUser).toBeTruthy();
      expect(savedUser.passwordHash).not.toBe(newUser.password);
      
      // Assert - Email Service
      const sentEmails = await getTestEmailsSent();
      expect(sentEmails).toHaveLength(1);
      expect(sentEmails[0]).toMatchObject({
        to: newUser.email,
        subject: 'Welcome to Our App'
      });
    });
  });
});
```

## Database Integration Tests

### Test Database Setup
```typescript
// test-helpers/database.ts
export async function createTestDatabase(): Promise<TestDatabase> {
  const dbName = `test_${process.env.JEST_WORKER_ID}_${Date.now()}`;
  
  // Create isolated test database
  await exec(`createdb ${dbName}`);
  
  // Run migrations
  const db = new Database({ database: dbName });
  await db.migrate.latest();
  
  return {
    ...db,
    truncate: async (tables: string[]) => {
      for (const table of tables) {
        await db.raw(`TRUNCATE TABLE ${table} CASCADE`);
      }
    },
    close: async () => {
      await db.destroy();
      await exec(`dropdb ${dbName}`);
    }
  };
}
```

### Repository Integration Test
```typescript
describe('UserRepository Integration', () => {
  let db: TestDatabase;
  let userRepo: UserRepository;
  
  beforeAll(async () => {
    db = await createTestDatabase();
    userRepo = new UserRepository(db);
  });
  
  afterAll(async () => {
    await db.close();
  });
  
  describe('complex queries', () => {
    it('should find users with active subscriptions', async () => {
      // Seed test data
      await db.seed.run({ specific: 'users-with-subscriptions' });
      
      // Execute complex query
      const activeUsers = await userRepo.findActiveSubscribers({
        plan: 'premium',
        expiresAfter: new Date()
      });
      
      // Verify results
      expect(activeUsers).toHaveLength(3);
      expect(activeUsers[0]).toMatchObject({
        subscription: {
          plan: 'premium',
          active: true
        }
      });
    });
  });
});
```

## External Service Integration

### HTTP Service Integration
```typescript
describe('PaymentService Integration', () => {
  let paymentService: PaymentService;
  let mockServer: MockServer;
  
  beforeAll(async () => {
    // Set up mock external service
    mockServer = await createMockServer();
    mockServer
      .post('/payments')
      .reply(200, { id: 'pay_123', status: 'success' });
    
    paymentService = new PaymentService({
      apiUrl: mockServer.url,
      apiKey: 'test_key'
    });
  });
  
  afterAll(async () => {
    await mockServer.close();
  });
  
  it('should process payment successfully', async () => {
    // Arrange
    const payment = {
      amount: 9999,
      currency: 'USD',
      source: 'tok_visa'
    };
    
    // Act
    const result = await paymentService.charge(payment);
    
    // Assert
    expect(result).toMatchObject({
      id: 'pay_123',
      status: 'success',
      amount: 9999
    });
    
    // Verify request was made correctly
    const requests = mockServer.getRequests();
    expect(requests[0]).toMatchObject({
      method: 'POST',
      path: '/payments',
      headers: {
        authorization: 'Bearer test_key'
      },
      body: payment
    });
  });
});
```

### Message Queue Integration
```typescript
describe('Order Processing Queue Integration', () => {
  let queue: TestQueue;
  let orderProcessor: OrderProcessor;
  
  beforeAll(async () => {
    queue = await createTestQueue('orders');
    orderProcessor = new OrderProcessor(queue);
  });
  
  afterAll(async () => {
    await queue.close();
  });
  
  beforeEach(async () => {
    await queue.purge();
  });
  
  it('should process order through queue', async () => {
    // Arrange
    const order = {
      id: '123',
      items: [{ sku: 'WIDGET-1', quantity: 2 }],
      total: 5999
    };
    
    // Act - Send message
    await queue.send('process.order', order);
    
    // Wait for processing
    await waitForExpect(async () => {
      const processed = await getProcessedOrders();
      expect(processed).toContainEqual(
        expect.objectContaining({ id: '123' })
      );
    });
    
    // Assert - Verify side effects
    const inventory = await getInventory('WIDGET-1');
    expect(inventory.available).toBe(98); // 100 - 2
    
    const notification = await getNotifications();
    expect(notification).toContainEqual({
      type: 'order.confirmed',
      orderId: '123'
    });
  });
});
```

## End-to-End Integration Tests

### Full User Journey Test
```typescript
describe('User Registration Journey', () => {
  let browser: Browser;
  let page: Page;
  let testUser: TestUser;
  
  beforeAll(async () => {
    browser = await chromium.launch();
    testUser = generateTestUser();
  });
  
  afterAll(async () => {
    await browser.close();
    await cleanupTestUser(testUser);
  });
  
  beforeEach(async () => {
    page = await browser.newPage();
  });
  
  afterEach(async () => {
    await page.close();
  });
  
  it('should complete full registration flow', async () => {
    // 1. Navigate to registration
    await page.goto(`${BASE_URL}/register`);
    
    // 2. Fill registration form
    await page.fill('[name="email"]', testUser.email);
    await page.fill('[name="password"]', testUser.password);
    await page.fill('[name="name"]', testUser.name);
    await page.click('[type="submit"]');
    
    // 3. Verify email sent
    await page.waitForSelector('.success-message');
    const emailLink = await getVerificationLink(testUser.email);
    expect(emailLink).toBeTruthy();
    
    // 4. Click verification link
    await page.goto(emailLink);
    await page.waitForSelector('.email-verified');
    
    // 5. Complete profile
    await page.fill('[name="phone"]', testUser.phone);
    await page.selectOption('[name="timezone"]', 'America/New_York');
    await page.click('[type="submit"]');
    
    // 6. Verify dashboard access
    await page.waitForURL(`${BASE_URL}/dashboard`);
    const welcomeText = await page.textContent('h1');
    expect(welcomeText).toContain(`Welcome, ${testUser.name}`);
    
    // 7. Verify database state
    const dbUser = await getUserByEmail(testUser.email);
    expect(dbUser).toMatchObject({
      email: testUser.email,
      emailVerified: true,
      profileComplete: true
    });
  });
});
```

## Test Data Management

### Test Data Builders
```typescript
class TestDataBuilder {
  private database: Database;
  
  constructor(database: Database) {
    this.database = database;
  }
  
  async createUserWithOrders(overrides = {}) {
    const user = await this.database.users.insert({
      email: `test-${Date.now()}@example.com`,
      name: 'Test User',
      ...overrides.user
    });
    
    const orders = await Promise.all(
      Array(3).fill(0).map((_, i) => 
        this.database.orders.insert({
          userId: user.id,
          total: 1000 + i * 100,
          status: 'completed',
          ...overrides.orders?.[i]
        })
      )
    );
    
    return { user, orders };
  }
  
  async createCompleteTestScenario() {
    const { user } = await this.createUserWithOrders();
    const subscription = await this.createSubscription(user.id);
    const invoices = await this.createInvoices(subscription.id);
    
    return { user, subscription, invoices };
  }
}
```

### Database Seeding
```typescript
// seeds/integration-tests.ts
export async function seed(knex: Knex): Promise<void> {
  // Clear existing data
  await knex('users').del();
  await knex('products').del();
  await knex('orders').del();
  
  // Insert test users
  const users = await knex('users').insert([
    { email: 'admin@test.com', role: 'admin', name: 'Admin User' },
    { email: 'user1@test.com', role: 'user', name: 'Regular User' },
    { email: 'user2@test.com', role: 'user', name: 'Another User' }
  ]).returning('*');
  
  // Insert test products
  const products = await knex('products').insert([
    { sku: 'WIDGET-1', name: 'Widget', price: 2999, stock: 100 },
    { sku: 'GADGET-1', name: 'Gadget', price: 4999, stock: 50 }
  ]).returning('*');
  
  // Create orders
  await knex('orders').insert([
    {
      userId: users[1].id,
      total: 2999,
      items: JSON.stringify([
        { productId: products[0].id, quantity: 1 }
      ])
    }
  ]);
}
```

## Environment Configuration

### Test Environment Setup
```typescript
// test-setup.ts
import { config } from 'dotenv';

// Load test environment variables
config({ path: '.env.test' });

// Override with test-specific values
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = process.env.TEST_DATABASE_URL;
process.env.REDIS_URL = process.env.TEST_REDIS_URL;
process.env.SMTP_HOST = 'localhost';
process.env.SMTP_PORT = '1025'; // Test SMTP server

// Set up global test utilities
global.testHelpers = {
  waitForExpect,
  createTestUser,
  cleanupTestData
};
```

### Docker Compose for Tests
```yaml
# docker-compose.test.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
    ports:
      - "5433:5432"
  
  redis:
    image: redis:7
    ports:
      - "6380:6379"
  
  mailhog:
    image: mailhog/mailhog
    ports:
      - "1025:1025" # SMTP
      - "8025:8025" # Web UI
  
  localstack:
    image: localstack/localstack
    environment:
      SERVICES: s3,sqs
      AWS_ACCESS_KEY_ID: test
      AWS_SECRET_ACCESS_KEY: test
    ports:
      - "4566:4566"
```

## Assertion Helpers

### Custom Matchers
```typescript
// test-helpers/matchers.ts
expect.extend({
  toBeWithinRange(received: number, floor: number, ceiling: number) {
    const pass = received >= floor && received <= ceiling;
    return {
      pass,
      message: () =>
        `expected ${received} to be within range ${floor} - ${ceiling}`
    };
  },
  
  toContainUser(received: User[], expected: Partial<User>) {
    const user = received.find(u => 
      Object.entries(expected).every(([key, value]) => 
        u[key] === value
      )
    );
    return {
      pass: !!user,
      message: () =>
        `expected array to contain user matching ${JSON.stringify(expected)}`
    };
  }
});
```

## Performance Testing

### Load Testing Integration
```typescript
describe('API Performance', () => {
  it('should handle concurrent requests', async () => {
    const concurrentRequests = 100;
    const requests = Array(concurrentRequests)
      .fill(0)
      .map((_, i) => 
        request(app)
          .get(`/api/users/${i % 10}`)
          .expect(200)
      );
    
    const startTime = Date.now();
    const responses = await Promise.all(requests);
    const duration = Date.now() - startTime;
    
    // All requests should succeed
    expect(responses).toHaveLength(concurrentRequests);
    
    // Should complete within reasonable time
    expect(duration).toBeLessThan(5000); // 5 seconds
    
    // Check response times
    const responseTimes = responses.map(r => 
      parseInt(r.headers['x-response-time'])
    );
    const avgResponseTime = responseTimes.reduce((a, b) => a + b) / responseTimes.length;
    
    expect(avgResponseTime).toBeLessThan(100); // 100ms average
  });
});
```

## Error Scenarios

### Testing Error Conditions
```typescript
describe('Error Handling Integration', () => {
  it('should handle database connection failure gracefully', async () => {
    // Simulate database failure
    await database.close();
    
    const response = await request(app)
      .get('/api/users')
      .expect(503);
    
    expect(response.body).toMatchObject({
      error: 'Service temporarily unavailable',
      retryAfter: expect.any(Number)
    });
    
    // Verify circuit breaker activated
    const healthCheck = await request(app)
      .get('/health')
      .expect(503);
    
    expect(healthCheck.body.database).toBe('unhealthy');
  });
  
  it('should handle external service timeout', async () => {
    // Configure mock to delay response
    mockServer
      .get('/external-api/data')
      .delay(6000) // Longer than timeout
      .reply(200, {});
    
    const response = await request(app)
      .get('/api/external-data')
      .expect(504);
    
    expect(response.body.error).toContain('Gateway timeout');
    
    // Verify fallback data was used
    expect(response.body.data).toEqual({
      source: 'cache',
      cached: true
    });
  });
});
```

## Best Practices

### Test Isolation
- Each test should be independent
- Use unique test data (timestamps, UUIDs)
- Clean up after tests
- Don't rely on test execution order

### Realistic Test Data
- Use production-like data volumes
- Test with various data types
- Include edge cases in test data
- Test with different locales/timezones

### Test Organization
```
tests/
├── integration/
│   ├── api/
│   │   ├── users.test.ts
│   │   └── orders.test.ts
│   ├── database/
│   │   ├── repositories.test.ts
│   │   └── migrations.test.ts
│   ├── external/
│   │   ├── payment.test.ts
│   │   └── email.test.ts
│   └── workflows/
│       ├── registration.test.ts
│       └── checkout.test.ts
├── fixtures/
│   ├── users.json
│   └── products.json
└── helpers/
    ├── database.ts
    ├── server.ts
    └── assertions.ts
```