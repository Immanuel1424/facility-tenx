# Testing Guide

## Overview

This directory contains test setup and utilities for the backend application.

## Running Tests

### Unit Tests
```bash
npm test
```

### Watch Mode
```bash
npm run test:watch
```

### Coverage Report
```bash
npm run test:cov
```

### Debug Tests
```bash
npm run test:debug
```

## Test Structure

- **Unit Tests**: Located alongside source files with `.spec.ts` extension
- **Integration Tests**: Located in `test/integration/` directory
- **E2E Tests**: Located in `test/e2e/` directory

## Writing Tests

### Example Unit Test

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { UserService } from './user.service';

describe('UserService', () => {
  let service: UserService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserService],
    }).compile();

    service = module.get<UserService>(UserService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
```

## Test Coverage

Aim for at least 80% code coverage for critical business logic:
- Services
- Controllers
- Guards
- Interceptors

## Best Practices

1. **Isolate Tests**: Each test should be independent
2. **Mock Dependencies**: Use Jest mocks for external dependencies
3. **Test Edge Cases**: Include error scenarios and boundary conditions
4. **Descriptive Names**: Use clear, descriptive test names
5. **Arrange-Act-Assert**: Follow the AAA pattern
