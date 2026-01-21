# NestJS Best Practices Audit Report

**Date:** 2025-01-14  
**Auditor:** Senior NestJS Architect  
**Scope:** Backend codebase compliance with NestJS/TypeScript best practices

---

## Executive Summary

The codebase demonstrates **good architectural foundations** with proper module structure, dependency injection, and global configuration. However, several violations of NestJS best practices were identified that need immediate attention.

**Overall Compliance Score: 75/100**

---

## ✅ Strengths

1. **Modular Architecture**: Well-organized feature-based modules
2. **Global Configuration**: Proper use of `@nestjs/config` with `ConfigModule.forRoot({ isGlobal: true })`
3. **Validation Pipeline**: Excellent validation setup with `whitelist: true` and `forbidNonWhitelisted: true`
4. **Swagger Documentation**: Good use of `@ApiProperty`, `@ApiOperation`, and `@ApiResponse`
5. **Dependency Injection**: Consistent use of constructor injection
6. **Exception Handling**: Global exception filter implemented
7. **DTOs with Validation**: DTOs use `class-validator` decorators properly

---

## ❌ Critical Issues

### 1. Business Logic in Controllers

**Location:** `apps/backend/src/modules/user/user.controller.ts`

**Violations:**
- Lines 74-81: Status enum parsing logic
- Lines 83-90: Metadata object construction
- Lines 185-212: Raw SQL query execution
- Lines 260-283: Complex villa assignment logic

**Impact:** Controllers should be thin and only handle HTTP concerns. Business logic belongs in Services.

**Recommendation:**
```typescript
// ❌ BAD - In Controller
async createUser(@Body() dto: CreateUserDto) {
  let userStatus: UserStatus | undefined;
  if (dto.status) {
    const statusUpper = dto.status.toUpperCase();
    if (Object.values(UserStatus).includes(statusUpper as UserStatus)) {
      userStatus = statusUpper as UserStatus;
    }
  }
  const metadata: Record<string, unknown> = {};
  if (dto.employeeId) metadata.employeeId = dto.employeeId;
  // ... more logic
}

// ✅ GOOD - Move to Service
async createUser(@Body() dto: CreateUserDto) {
  return this.userService.createUserFromDto(currentUser.companyId, dto);
}
```

---

### 2. Use of `any` Type (TypeScript Violation)

**Locations:**
- `apps/backend/src/modules/auth/services/email.service.ts` (Lines 66, 93, 120, 272, 299)
- `apps/backend/src/modules/notification/channels/email.channel.ts` (Lines 67, 97)
- `apps/backend/src/modules/maintenance-ticket/services/file-storage.service.ts` (Line 94)

**Impact:** Violates strict typing principles. Reduces type safety and IDE support.

**Recommendation:**
```typescript
// ❌ BAD
catch (error: any) {
  const errorMessage = error?.message || 'Unknown error';
}

// ✅ GOOD
catch (error: unknown) {
  const errorMessage = error instanceof Error ? error.message : 'Unknown error';
  this.logger.error('Operation failed', error);
}

// ❌ BAD
const requestBody: any = {
  api_key: this.apiKey,
  // ...
};

// ✅ GOOD
interface EmailRequestBody {
  api_key: string;
  to: string[];
  sender: string;
  subject: string;
  html_body: string;
  text_body: string;
}

const requestBody: EmailRequestBody = {
  api_key: this.apiKey,
  // ...
};
```

---

### 3. Direct Repository Injection in Controllers

**Location:** `apps/backend/src/modules/user/user.controller.ts` (Lines 42-43)

**Violation:**
```typescript
@InjectRepository(User)
private readonly userRepository: Repository<User>,
```

**Impact:** Controllers should not directly access repositories. This violates the layered architecture (Controller → Service → Repository).

**Recommendation:**
- Remove repository injection from controller
- Add method to `UserService` to handle multi-villa queries
- Controller should only call service methods

---

### 4. Raw SQL Queries in Controller

**Location:** `apps/backend/src/modules/user/user.controller.ts` (Lines 185-204)

**Violation:**
```typescript
const rawVillas: Array<{...}> = await this.userRepository.query(
  `SELECT DISTINCT v.id, ... FROM user_villas uv ...`,
  [currentUser.companyId, currentUser.userId],
);
```

**Impact:** 
- Business logic in controller
- Database queries should be in Repository/Service layer
- Hard to test and maintain

**Recommendation:**
- Move query to `UserService.getUserVillas(companyId: string, userId: string)`
- Use TypeORM QueryBuilder or Repository methods instead of raw SQL when possible

---

### 5. Missing Explicit Return Types

**Locations:**
- `apps/backend/src/modules/tenant/lookup.controller.ts` (Line 56)
- `apps/backend/src/modules/tenant/public-lookup.controller.ts` (Lines 33, 65)
- `apps/backend/src/modules/tenant/tenant.controller.ts` (Lines 61, 138, 335)
- `apps/backend/src/modules/auth/strategies/jwt.strategy.ts` (Line 23)

**Impact:** Reduces type safety and makes code harder to understand.

**Recommendation:**
```typescript
// ❌ BAD
async getVillas() {
  return this.tenantService.getVillas();
}

// ✅ GOOD
async getVillas(): Promise<VillaResponseDto[]> {
  return this.tenantService.getVillas();
}
```

---

### 6. Inline DTO Construction in Controller

**Location:** `apps/backend/src/modules/user/user.controller.ts` (Lines 214-228)

**Violation:**
```typescript
return {
  id: user.id,
  company_id: user.companyId,
  // ... manual mapping
} as unknown as UserResponseDto;
```

**Impact:** 
- Manual mapping is error-prone
- Should use `class-transformer` with `plainToInstance`
- Type assertion with `as unknown as` is a code smell

**Recommendation:**
```typescript
// ✅ GOOD
return plainToInstance(UserResponseDto, user, {
  excludeExtraneousValues: true,
});
```

---

## ⚠️ Medium Priority Issues

### 7. Missing API Response Decorators

Some controller methods lack `@ApiOkResponse` or `@ApiResponse` decorators for proper Swagger documentation.

**Recommendation:** Add `@ApiOkResponse` to all public endpoints.

---

### 8. Inconsistent Error Handling

Some services throw generic `Error` instead of NestJS exceptions (`BadRequestException`, `NotFoundException`).

**Recommendation:** Always use NestJS exception classes for consistent error responses.

---

### 9. Missing Input Validation on Query Parameters

Some endpoints accept query parameters without DTO validation.

**Example:** `user.controller.ts` line 57-58
```typescript
@Query('role') role?: string,
@Query('status') status?: string,
```

**Recommendation:**
```typescript
// Create QueryUserDto
class QueryUserDto {
  @IsOptional()
  @IsString()
  role?: string;

  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus;
}

// Use in controller
async getUsers(@Query() queryDto: QueryUserDto) {
  // ...
}
```

---

## 📋 Action Items

### Immediate (Critical)

- [ ] **Refactor `user.controller.ts`**: Move all business logic to `UserService`
- [ ] **Remove `any` types**: Replace with proper interfaces or `unknown`
- [ ] **Remove repository injection from controllers**: Move queries to services
- [ ] **Add explicit return types**: To all async methods without them
- [ ] **Move raw SQL queries**: From controllers to services/repositories

### High Priority

- [ ] **Create Query DTOs**: For all endpoints with query parameters
- [ ] **Use `plainToInstance`**: Replace manual DTO mapping
- [ ] **Add missing Swagger decorators**: Complete API documentation
- [ ] **Standardize error handling**: Use NestJS exceptions consistently

### Medium Priority

- [ ] **Add unit tests**: For refactored services
- [ ] **Review all controllers**: Ensure they follow thin controller pattern
- [ ] **Add JSDoc comments**: For complex business logic methods

---

## 📚 Code Examples

### Proper Controller Pattern

```typescript
@Controller('users')
export class UserController {
  constructor(
    private readonly userService: UserService, // ✅ Only services
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a user' })
  @ApiOkResponse({ type: UserResponseDto })
  async createUser(
    @CurrentUser() currentUser: CurrentUserData,
    @Body() dto: CreateUserDto,
  ): Promise<UserResponseDto> { // ✅ Explicit return type
    return this.userService.createUserFromDto(
      currentUser.companyId,
      dto,
    ); // ✅ All logic in service
  }
}
```

### Proper Service Pattern

```typescript
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly emailService: EmailService,
  ) {}

  async createUserFromDto(
    companyId: string,
    dto: CreateUserDto,
  ): Promise<User> { // ✅ Explicit return type
    // ✅ All business logic here
    const userStatus = this.parseUserStatus(dto.status);
    const metadata = this.buildUserMetadata(dto);
    
    const user = await this.createLocalUser(
      companyId,
      dto.email,
      dto.password,
      dto.firstName,
      dto.lastName,
      dto.villaNumber,
      dto.villaNumbers,
      userStatus,
      metadata,
    );

    if (dto.roleId) {
      await this.assignRole(companyId, user.id, dto.roleId);
    }

    if (dto.sendCredentialsViaEmail) {
      await this.emailService.sendUserCredentials(
        user.email,
        dto.password,
        user.firstName,
      );
    }

    return this.findById(companyId, user.id);
  }

  private parseUserStatus(status?: string): UserStatus | undefined {
    if (!status) return undefined;
    const statusUpper = status.toUpperCase();
    if (Object.values(UserStatus).includes(statusUpper as UserStatus)) {
      return statusUpper as UserStatus;
    }
    return undefined;
  }

  private buildUserMetadata(dto: CreateUserDto): Record<string, unknown> | undefined {
    const metadata: Record<string, unknown> = {};
    if (dto.employeeId) metadata.employeeId = dto.employeeId;
    if (dto.designation) metadata.designation = dto.designation;
    // ... more fields
    return Object.keys(metadata).length > 0 ? metadata : undefined;
  }
}
```

### Proper Error Handling

```typescript
// ❌ BAD
catch (error: any) {
  throw new Error(error.message);
}

// ✅ GOOD
catch (error: unknown) {
  if (error instanceof NotFoundException) {
    throw error; // Re-throw NestJS exceptions
  }
  this.logger.error('Operation failed', error);
  throw new InternalServerErrorException('An unexpected error occurred');
}
```

---

## 🎯 Compliance Checklist

### TypeScript Best Practices
- [x] Strict mode enabled
- [ ] No `any` types (8 violations found)
- [ ] Explicit return types on all methods (5+ missing)
- [x] Proper use of interfaces vs types

### NestJS Architecture
- [x] Modular design
- [x] Dependency injection
- [ ] Thin controllers (1 violation: `user.controller.ts`)
- [x] Rich services
- [ ] No direct repository access in controllers (1 violation)

### DTOs & Validation
- [x] DTOs for all inputs
- [x] `class-validator` decorators
- [x] Global validation pipe with `whitelist: true`
- [ ] Query parameter DTOs (missing in several endpoints)
- [ ] Proper use of `class-transformer` (manual mapping found)

### Error Handling
- [x] Global exception filter
- [ ] Consistent use of NestJS exceptions (some generic `Error` thrown)
- [x] Proper logging

### API Documentation
- [x] Swagger setup
- [x] `@ApiProperty` on DTOs
- [x] `@ApiOperation` on endpoints
- [ ] Complete `@ApiResponse` decorators (some missing)

---

## 📖 References

- [NestJS Documentation](https://docs.nestjs.com/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [class-validator Documentation](https://github.com/typestack/class-validator)
- [class-transformer Documentation](https://github.com/typestack/class-transformer)

---

**Next Steps:** Prioritize critical issues and create a refactoring plan. Start with `user.controller.ts` as it has the most violations.

