# Node.js Microservice Module

This module contains specific guidance for building Node.js microservices following best practices.

## Architecture Overview

For Node.js microservices, our architecture follows Domain-Driven Design principles:

- **API Layer**: REST/GraphQL endpoints
- **Service Layer**: Business logic
- **Repository Layer**: Data access
- **Domain Layer**: Core business entities
- **Infrastructure**: External service integrations

### Directory Structure
```
service/
├── src/
│   ├── api/                   # API endpoints
│   │   ├── routes/           # Route definitions
│   │   ├── controllers/      # Request handlers
│   │   ├── middleware/       # Custom middleware
│   │   └── validators/       # Request validation
│   ├── services/             # Business logic
│   ├── repositories/         # Data access layer
│   ├── domain/               # Domain models
│   │   ├── entities/         # Business entities
│   │   └── value-objects/    # Value objects
│   ├── infrastructure/       # External services
│   │   ├── database/         # Database connections
│   │   ├── cache/            # Cache implementations
│   │   ├── messaging/        # Message queue clients
│   │   └── monitoring/       # Logging and metrics
│   ├── config/               # Configuration
│   └── utils/                # Utility functions
├── tests/
│   ├── unit/                 # Unit tests
│   ├── integration/          # Integration tests
│   └── contract/             # Contract tests
├── scripts/                  # Utility scripts
└── docs/                     # Service documentation
```

## Development Setup

### Environment Configuration

Create `.env` for local development:
```bash
# Service Configuration
NODE_ENV=development
PORT=3000
SERVICE_NAME=user-service

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/users
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10

# Redis Cache
REDIS_URL=redis://localhost:6379
CACHE_TTL=300

# Message Queue
RABBITMQ_URL=amqp://localhost:5672
QUEUE_NAME=user-events

# Authentication
JWT_SECRET=your-secret-key
JWT_EXPIRY=1h

# External Services
AUTH_SERVICE_URL=http://localhost:3001
NOTIFICATION_SERVICE_URL=http://localhost:3002

# Monitoring
LOG_LEVEL=debug
METRICS_PORT=9090
```

### Development Scripts
```json
{
  "scripts": {
    "dev": "nodemon --exec ts-node src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:contract": "jest --testPathPattern=contract",
    "lint": "eslint src --ext .ts",
    "format": "prettier --write 'src/**/*.ts'",
    "migrate": "knex migrate:latest",
    "seed": "knex seed:run"
  }
}
```

## API Design

### RESTful Endpoints
```typescript
// api/routes/users.ts
import { Router } from 'express'
import { UserController } from '../controllers/UserController'
import { validateRequest } from '../middleware/validation'
import { createUserSchema, updateUserSchema } from '../validators/user'

const router = Router()
const controller = new UserController()

router.get('/users', controller.list)
router.get('/users/:id', controller.get)
router.post('/users', validateRequest(createUserSchema), controller.create)
router.put('/users/:id', validateRequest(updateUserSchema), controller.update)
router.delete('/users/:id', controller.delete)

export default router
```

### Controller Pattern
```typescript
// api/controllers/UserController.ts
import { Request, Response, NextFunction } from 'express'
import { UserService } from '../../services/UserService'
import { ApiResponse } from '../utils/ApiResponse'

export class UserController {
  private userService: UserService

  constructor() {
    this.userService = new UserService()
  }

  list = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { page = 1, limit = 10 } = req.query
      const users = await this.userService.findAll({ page, limit })
      
      return ApiResponse.success(res, users)
    } catch (error) {
      next(error)
    }
  }

  get = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = await this.userService.findById(req.params.id)
      
      if (!user) {
        return ApiResponse.notFound(res, 'User not found')
      }
      
      return ApiResponse.success(res, user)
    } catch (error) {
      next(error)
    }
  }
}
```

## Service Layer

### Business Logic Implementation
```typescript
// services/UserService.ts
import { User } from '../domain/entities/User'
import { UserRepository } from '../repositories/UserRepository'
import { CacheService } from '../infrastructure/cache/CacheService'
import { EventPublisher } from '../infrastructure/messaging/EventPublisher'
import { Logger } from '../infrastructure/monitoring/Logger'

export class UserService {
  constructor(
    private userRepo = new UserRepository(),
    private cache = new CacheService(),
    private events = new EventPublisher(),
    private logger = new Logger('UserService')
  ) {}

  async findById(id: string): Promise<User | null> {
    // Check cache first
    const cached = await this.cache.get(`user:${id}`)
    if (cached) {
      this.logger.debug('Cache hit for user', { id })
      return cached
    }

    // Fetch from database
    const user = await this.userRepo.findById(id)
    
    if (user) {
      // Cache for future requests
      await this.cache.set(`user:${id}`, user, 300)
    }
    
    return user
  }

  async create(data: CreateUserDTO): Promise<User> {
    // Validate business rules
    const existingUser = await this.userRepo.findByEmail(data.email)
    if (existingUser) {
      throw new BusinessError('Email already registered')
    }

    // Create user
    const user = User.create(data)
    const savedUser = await this.userRepo.save(user)

    // Publish event
    await this.events.publish('user.created', {
      userId: savedUser.id,
      email: savedUser.email,
      timestamp: new Date()
    })

    this.logger.info('User created', { userId: savedUser.id })
    
    return savedUser
  }
}
```

## Testing Strategy

### Unit Testing
```typescript
// tests/unit/services/UserService.test.ts
import { UserService } from '../../../src/services/UserService'
import { UserRepository } from '../../../src/repositories/UserRepository'
import { CacheService } from '../../../src/infrastructure/cache/CacheService'

jest.mock('../../../src/repositories/UserRepository')
jest.mock('../../../src/infrastructure/cache/CacheService')

describe('UserService', () => {
  let userService: UserService
  let mockUserRepo: jest.Mocked<UserRepository>
  let mockCache: jest.Mocked<CacheService>

  beforeEach(() => {
    mockUserRepo = new UserRepository() as jest.Mocked<UserRepository>
    mockCache = new CacheService() as jest.Mocked<CacheService>
    userService = new UserService(mockUserRepo, mockCache)
  })

  describe('findById', () => {
    it('returns user from cache when available', async () => {
      const cachedUser = { id: '1', email: 'test@example.com' }
      mockCache.get.mockResolvedValue(cachedUser)

      const result = await userService.findById('1')

      expect(result).toEqual(cachedUser)
      expect(mockUserRepo.findById).not.toHaveBeenCalled()
    })

    it('fetches from database when not in cache', async () => {
      const dbUser = { id: '1', email: 'test@example.com' }
      mockCache.get.mockResolvedValue(null)
      mockUserRepo.findById.mockResolvedValue(dbUser)

      const result = await userService.findById('1')

      expect(result).toEqual(dbUser)
      expect(mockCache.set).toHaveBeenCalledWith('user:1', dbUser, 300)
    })
  })
})
```

### Integration Testing
```typescript
// tests/integration/api/users.test.ts
import request from 'supertest'
import { app } from '../../../src/app'
import { setupTestDatabase, teardownTestDatabase } from '../../helpers/database'

describe('Users API', () => {
  beforeAll(async () => {
    await setupTestDatabase()
  })

  afterAll(async () => {
    await teardownTestDatabase()
  })

  describe('GET /users/:id', () => {
    it('returns user when exists', async () => {
      const response = await request(app)
        .get('/api/users/123')
        .expect(200)

      expect(response.body).toMatchObject({
        status: 'success',
        data: {
          id: '123',
          email: expect.any(String)
        }
      })
    })

    it('returns 404 when user not found', async () => {
      const response = await request(app)
        .get('/api/users/nonexistent')
        .expect(404)

      expect(response.body.message).toBe('User not found')
    })
  })
})
```

### Contract Testing
```typescript
// tests/contract/user-service.pact.test.ts
import { Pact } from '@pact-foundation/pact'
import { UserServiceClient } from '../../../src/clients/UserServiceClient'

describe('User Service Contract', () => {
  const provider = new Pact({
    consumer: 'NotificationService',
    provider: 'UserService',
  })

  beforeAll(() => provider.setup())
  afterAll(() => provider.finalize())

  describe('get user', () => {
    it('returns user details', async () => {
      await provider.addInteraction({
        state: 'user 123 exists',
        uponReceiving: 'a request for user 123',
        withRequest: {
          method: 'GET',
          path: '/api/users/123',
        },
        willRespondWith: {
          status: 200,
          body: {
            id: '123',
            email: 'user@example.com',
            name: 'Test User'
          }
        }
      })

      const client = new UserServiceClient(provider.mockService.baseUrl)
      const user = await client.getUser('123')

      expect(user.email).toBe('user@example.com')
    })
  })
})
```

## Error Handling

### Custom Error Classes
```typescript
// domain/errors/BusinessError.ts
export class BusinessError extends Error {
  constructor(
    message: string,
    public code: string = 'BUSINESS_ERROR',
    public statusCode: number = 400
  ) {
    super(message)
    this.name = 'BusinessError'
  }
}

// domain/errors/ValidationError.ts
export class ValidationError extends BusinessError {
  constructor(
    message: string,
    public fields: Record<string, string[]>
  ) {
    super(message, 'VALIDATION_ERROR', 422)
    this.name = 'ValidationError'
  }
}
```

### Global Error Handler
```typescript
// api/middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express'
import { BusinessError } from '../../domain/errors/BusinessError'
import { Logger } from '../../infrastructure/monitoring/Logger'

const logger = new Logger('ErrorHandler')

export function errorHandler(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  logger.error('Request failed', {
    error: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
  })

  if (error instanceof BusinessError) {
    return res.status(error.statusCode).json({
      status: 'error',
      code: error.code,
      message: error.message,
    })
  }

  // Default error response
  res.status(500).json({
    status: 'error',
    code: 'INTERNAL_ERROR',
    message: 'An unexpected error occurred',
  })
}
```

## Database Layer

### Repository Pattern
```typescript
// repositories/UserRepository.ts
import { Knex } from 'knex'
import { db } from '../infrastructure/database/connection'
import { User } from '../domain/entities/User'

export class UserRepository {
  private table = 'users'

  async findById(id: string): Promise<User | null> {
    const data = await db(this.table)
      .where({ id })
      .first()
    
    return data ? User.fromDatabase(data) : null
  }

  async findByEmail(email: string): Promise<User | null> {
    const data = await db(this.table)
      .where({ email })
      .first()
    
    return data ? User.fromDatabase(data) : null
  }

  async save(user: User): Promise<User> {
    const data = user.toDatabaseObject()
    
    if (user.isNew()) {
      const [id] = await db(this.table).insert(data).returning('id')
      return User.fromDatabase({ ...data, id })
    } else {
      await db(this.table).where({ id: user.id }).update(data)
      return user
    }
  }

  async delete(id: string): Promise<void> {
    await db(this.table).where({ id }).delete()
  }
}
```

### Database Migrations
```typescript
// migrations/20240101_create_users_table.ts
import { Knex } from 'knex'

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('users', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'))
    table.string('email').notNullable().unique()
    table.string('name').notNullable()
    table.string('password_hash').notNullable()
    table.boolean('is_active').defaultTo(true)
    table.timestamps(true, true)
    
    table.index(['email'])
    table.index(['created_at'])
  })
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTable('users')
}
```

## Messaging & Events

### Event Publisher
```typescript
// infrastructure/messaging/EventPublisher.ts
import amqp from 'amqplib'
import { config } from '../../config'
import { Logger } from '../monitoring/Logger'

export class EventPublisher {
  private connection: amqp.Connection | null = null
  private channel: amqp.Channel | null = null
  private logger = new Logger('EventPublisher')

  async connect(): Promise<void> {
    this.connection = await amqp.connect(config.rabbitmq.url)
    this.channel = await this.connection.createChannel()
    
    // Declare exchange
    await this.channel.assertExchange('events', 'topic', { durable: true })
  }

  async publish(eventType: string, data: any): Promise<void> {
    if (!this.channel) {
      throw new Error('Not connected to message broker')
    }

    const message = {
      type: eventType,
      data,
      timestamp: new Date().toISOString(),
      service: config.service.name,
    }

    await this.channel.publish(
      'events',
      eventType,
      Buffer.from(JSON.stringify(message)),
      { persistent: true }
    )

    this.logger.info('Event published', { eventType, data })
  }
}
```

### Event Consumer
```typescript
// infrastructure/messaging/EventConsumer.ts
export class EventConsumer {
  async consume(queue: string, handler: (message: any) => Promise<void>) {
    if (!this.channel) {
      throw new Error('Not connected to message broker')
    }

    await this.channel.assertQueue(queue, { durable: true })
    await this.channel.bindQueue(queue, 'events', '#')

    await this.channel.consume(queue, async (msg) => {
      if (!msg) return

      try {
        const content = JSON.parse(msg.content.toString())
        await handler(content)
        
        this.channel!.ack(msg)
      } catch (error) {
        this.logger.error('Failed to process message', { error })
        
        // Requeue on failure
        this.channel!.nack(msg, false, true)
      }
    })
  }
}
```

## Monitoring & Observability

### Structured Logging
```typescript
// infrastructure/monitoring/Logger.ts
import winston from 'winston'
import { config } from '../../config'

export class Logger {
  private winston: winston.Logger

  constructor(private context: string) {
    this.winston = winston.createLogger({
      level: config.log.level,
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
      ),
      defaultMeta: {
        service: config.service.name,
        context: this.context,
      },
      transports: [
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
          ),
        }),
      ],
    })
  }

  info(message: string, meta?: any) {
    this.winston.info(message, meta)
  }

  error(message: string, meta?: any) {
    this.winston.error(message, meta)
  }

  debug(message: string, meta?: any) {
    this.winston.debug(message, meta)
  }
}
```

### Metrics Collection
```typescript
// infrastructure/monitoring/Metrics.ts
import { Registry, Counter, Histogram } from 'prom-client'

export class Metrics {
  private registry = new Registry()
  
  public httpRequestDuration = new Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'status'],
    registers: [this.registry],
  })

  public httpRequestTotal = new Counter({
    name: 'http_request_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status'],
    registers: [this.registry],
  })

  public businessErrors = new Counter({
    name: 'business_errors_total',
    help: 'Total number of business errors',
    labelNames: ['type'],
    registers: [this.registry],
  })

  getMetrics(): string {
    return this.registry.metrics()
  }
}
```

### Health Checks
```typescript
// api/routes/health.ts
import { Router } from 'express'
import { HealthChecker } from '../../infrastructure/monitoring/HealthChecker'

const router = Router()
const healthChecker = new HealthChecker()

router.get('/health', async (req, res) => {
  const health = await healthChecker.check()
  
  const status = health.status === 'healthy' ? 200 : 503
  res.status(status).json(health)
})

router.get('/health/live', (req, res) => {
  res.status(200).json({ status: 'alive' })
})

router.get('/health/ready', async (req, res) => {
  const isReady = await healthChecker.checkReadiness()
  const status = isReady ? 200 : 503
  
  res.status(status).json({ ready: isReady })
})
```

## Security Best Practices

### Authentication Middleware
```typescript
// api/middleware/auth.ts
import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { config } from '../../config'

export interface AuthRequest extends Request {
  user?: {
    id: string
    email: string
    roles: string[]
  }
}

export function authenticate(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  const token = req.headers.authorization?.replace('Bearer ', '')
  
  if (!token) {
    return res.status(401).json({
      status: 'error',
      message: 'Authentication required',
    })
  }

  try {
    const decoded = jwt.verify(token, config.auth.jwtSecret) as any
    req.user = {
      id: decoded.sub,
      email: decoded.email,
      roles: decoded.roles || [],
    }
    next()
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid token',
    })
  }
}
```

### Rate Limiting
```typescript
// api/middleware/rateLimiter.ts
import rateLimit from 'express-rate-limit'
import RedisStore from 'rate-limit-redis'
import { redis } from '../../infrastructure/cache/redis'

export const apiLimiter = rateLimit({
  store: new RedisStore({
    client: redis,
    prefix: 'rl:',
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false,
})

export const strictLimiter = rateLimit({
  store: new RedisStore({
    client: redis,
    prefix: 'rl:strict:',
  }),
  windowMs: 15 * 60 * 1000,
  max: 10, // Stricter limit for sensitive endpoints
})
```

## Deployment

### Dockerfile
```dockerfile
FROM node:18-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Build application
FROM base AS builder
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production image
FROM base AS runner
ENV NODE_ENV production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 service

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./

# Set ownership
RUN chown -R service:nodejs /app

USER service

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

CMD ["node", "dist/index.js"]
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: user-service:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: production
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: user-service-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

## Best Practices Summary

1. **Use Dependency Injection** - Makes testing easier and code more maintainable
2. **Implement Circuit Breakers** - For external service calls
3. **Use Correlation IDs** - For tracing requests across services
4. **Implement Graceful Shutdown** - Handle SIGTERM properly
5. **Version Your APIs** - Use URL versioning or headers
6. **Document Your APIs** - Use OpenAPI/Swagger
7. **Monitor Everything** - Logs, metrics, and traces
8. **Test at Multiple Levels** - Unit, integration, and contract tests
9. **Handle Errors Consistently** - Use error classes and global handlers
10. **Keep Services Small** - Single responsibility principle