# Next.js Module

This module contains specific guidance for projects using Next.js for web applications.

## Architecture Overview

For Next.js projects, our architecture includes:

- **Pages/App Directory**: Route-based components
- **Components**: Reusable UI components
- **API Routes**: Backend endpoints within Next.js
- **Services**: Business logic and external API integrations
- **Utils**: Helper functions and utilities

### Directory Structure
```
project/
├── src/
│   ├── app/                    # App router (Next.js 13+)
│   │   ├── (routes)/          # Route groups
│   │   ├── api/               # API routes
│   │   └── layout.tsx         # Root layout
│   ├── components/            # Reusable components
│   │   ├── ui/               # UI components
│   │   └── features/         # Feature-specific components
│   ├── lib/                   # Core libraries
│   │   ├── api/              # API client code
│   │   └── utils/            # Utility functions
│   ├── hooks/                 # Custom React hooks
│   └── types/                 # TypeScript types
├── public/                    # Static assets
├── tests/                     # Test files
│   ├── unit/                 # Unit tests
│   ├── integration/          # Integration tests
│   └── e2e/                  # End-to-end tests
└── cypress/                   # E2E test configs
```

## Development Setup

### Environment Configuration

Create `.env.local` for local development:
```bash
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_APP_URL=http://localhost:3000

# External Services
DATABASE_URL=postgresql://user:pass@localhost:5432/db
REDIS_URL=redis://localhost:6379

# Authentication
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key

# Feature Flags
NEXT_PUBLIC_ENABLE_ANALYTICS=false
```

### Development Scripts
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "e2e": "cypress run",
    "e2e:ui": "cypress open"
  }
}
```

## Testing Strategy

### Unit Testing Setup

Configure Jest for Next.js in `jest.config.js`:
```javascript
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  dir: './',
})

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  testPathIgnorePatterns: ['/node_modules/', '/.next/'],
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': ['babel-jest', { presets: ['next/babel'] }],
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
  ],
}

module.exports = createJestConfig(customJestConfig)
```

### Component Testing Example
```typescript
// components/ui/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('handles click events', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    
    fireEvent.click(screen.getByText('Click me'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### API Route Testing
```typescript
// app/api/users/route.test.ts
import { GET } from './route'
import { NextRequest } from 'next/server'

describe('/api/users', () => {
  it('returns users list', async () => {
    const request = new NextRequest('http://localhost:3000/api/users')
    const response = await GET(request)
    const data = await response.json()
    
    expect(response.status).toBe(200)
    expect(Array.isArray(data.users)).toBe(true)
  })
})
```

### E2E Testing with Cypress
```typescript
// cypress/e2e/home.cy.ts
describe('Home Page', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('displays welcome message', () => {
    cy.contains('h1', 'Welcome').should('be.visible')
  })

  it('navigates to about page', () => {
    cy.get('nav').contains('About').click()
    cy.url().should('include', '/about')
  })
})
```

## Architecture Best Practices

### 1. Server Components by Default
```typescript
// app/products/page.tsx - Server Component
async function ProductsPage() {
  const products = await fetchProducts() // Direct database call
  
  return (
    <div>
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  )
}
```

### 2. Client Components When Needed
```typescript
// components/InteractiveChart.tsx
'use client'

import { useState } from 'react'

export function InteractiveChart({ data }) {
  const [filter, setFilter] = useState('all')
  
  // Interactive client-side logic
  return <div>...</div>
}
```

### 3. API Route Pattern
```typescript
// app/api/products/[id]/route.ts
import { NextResponse } from 'next/server'

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  try {
    const product = await getProduct(params.id)
    return NextResponse.json(product)
  } catch (error) {
    return NextResponse.json(
      { error: 'Product not found' },
      { status: 404 }
    )
  }
}
```

### 4. Data Fetching Patterns
```typescript
// Parallel data fetching
async function Page() {
  const [users, posts] = await Promise.all([
    fetchUsers(),
    fetchPosts()
  ])
  
  return <div>...</div>
}

// Suspense for streaming
import { Suspense } from 'react'

function Page() {
  return (
    <Suspense fallback={<Loading />}>
      <SlowComponent />
    </Suspense>
  )
}
```

## Security Considerations

### Environment Variables
- Use `NEXT_PUBLIC_` prefix only for client-side variables
- Never expose sensitive keys to the client
- Validate all environment variables at build time

### API Security
```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // CSRF protection
  if (request.method !== 'GET') {
    const token = request.headers.get('x-csrf-token')
    if (!validateCSRFToken(token)) {
      return new NextResponse('Invalid CSRF token', { status: 403 })
    }
  }
  
  return NextResponse.next()
}

export const config = {
  matcher: '/api/:path*',
}
```

### Content Security Policy
```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: ContentSecurityPolicy.replace(/\s{2,}/g, ' ').trim()
  },
  {
    key: 'X-Frame-Options',
    value: 'DENY'
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff'
  }
]
```

## Performance Optimization

### 1. Image Optimization
```typescript
import Image from 'next/image'

export function ProductImage({ src, alt }) {
  return (
    <Image
      src={src}
      alt={alt}
      width={400}
      height={300}
      loading="lazy"
      placeholder="blur"
      blurDataURL={shimmerBase64}
    />
  )
}
```

### 2. Bundle Analysis
```bash
# Install bundle analyzer
npm install --save-dev @next/bundle-analyzer

# Run analysis
ANALYZE=true npm run build
```

### 3. Route Optimization
```typescript
// Preload critical routes
import { useRouter } from 'next/navigation'

function Navigation() {
  const router = useRouter()
  
  return (
    <nav onMouseEnter={() => router.prefetch('/products')}>
      <Link href="/products">Products</Link>
    </nav>
  )
}
```

## Deployment Considerations

### Build Configuration
```javascript
// next.config.js
module.exports = {
  output: 'standalone',
  images: {
    domains: ['cdn.example.com'],
  },
  experimental: {
    serverActions: true,
  },
}
```

### Docker Configuration
```dockerfile
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
```

## Common Patterns

### Custom Hook for Data Fetching
```typescript
// hooks/useApi.ts
import useSWR from 'swr'

export function useApi<T>(url: string) {
  const { data, error, isLoading } = useSWR<T>(url, fetcher)
  
  return {
    data,
    error,
    isLoading,
    isError: !!error,
  }
}
```

### Error Boundary
```typescript
// app/error.tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

### Loading States
```typescript
// app/loading.tsx
export default function Loading() {
  return <div className="loading-spinner">Loading...</div>
}
```

## Troubleshooting

### Common Issues

1. **Hydration Mismatch**
   - Ensure server and client render the same content
   - Use `useEffect` for client-only code
   - Check for date/time formatting differences

2. **Build Failures**
   ```bash
   # Clear cache and rebuild
   rm -rf .next
   npm run build
   ```

3. **API Route Not Found**
   - Check file naming conventions
   - Ensure proper export names (GET, POST, etc.)
   - Verify route parameters match

4. **Performance Issues**
   - Use React DevTools Profiler
   - Check for unnecessary re-renders
   - Implement proper memoization

## Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [SWR for Data Fetching](https://swr.vercel.app/)
- [Next.js Examples](https://github.com/vercel/next.js/tree/canary/examples)