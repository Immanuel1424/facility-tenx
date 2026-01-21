import {
  CanActivate,
  ExecutionContext,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { CompanyScopeViolationException } from '../exceptions/business.exception';
import { IS_PUBLIC_KEY } from '../../modules/auth/decorators/public.decorator';
import { SuperAdminService } from '../services/super-admin.service';

/**
 * User object structure returned by JWT strategy's validate() method
 * This matches what Passport sets on request.user
 */
interface JwtStrategyUser {
  userId: string;
  email: string;
  companyId: string;
  siteId: string;
  siteCode: string;
  roles: string[];
  permissions: string[];
}

/**
 * Company Scope Guard
 * 
 * Industry Best Practices:
 * 1. Single Responsibility: Validates company scope, doesn't decode tokens
 * 2. Security: Relies on JWT strategy to set user object (verified token)
 * 3. Type Safety: Uses TypeScript interfaces for type checking
 * 4. Fail Fast: Throws clear exceptions for violations
 * 5. SUPER_ADMIN Bypass: Allows system admins to access any company
 * 
 * Flow:
 * 1. JWT Guard runs first (validates token, sets request.user)
 * 2. This guard validates company scope from request.user.companyId
 * 3. Prevents cross-company data access
 */
@Injectable()
export class CompanyScopeGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private superAdminService: SuperAdminService,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    // Skip company scope check for public routes (like login)
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user as JwtStrategyUser | undefined;

    // JWT guard should have set request.user
    // If user is missing, JWT guard should have thrown UnauthorizedException
    if (!user) {
      console.error(
        '[CompanyScopeGuard] User not set. JWT guard should have run first.',
      );
      throw new CompanyScopeViolationException();
    }

    // Allow SUPER_ADMIN to bypass company scope restrictions
    // SUPER_ADMIN can access any company by providing companyId in query/body/header
    // Map JwtStrategyUser to CurrentUserPayload format (userId -> sub)
    const userPayload = {
      sub: user.userId,
      email: user.email,
      companyId: user.companyId,
      siteId: user.siteId,
      siteCode: user.siteCode,
      roles: user.roles,
    };
    if (this.superAdminService.isSuperAdmin(userPayload)) {
      const queryCompanyId =
        request.query?.companyId || request.query?.company_id;
      const bodyCompanyId = request.body?.companyId || request.body?.company_id;
      const headerCompanyId = request.headers['x-company-id'];
      const tokenCompanyId = user.companyId;

      // SUPER_ADMIN can use any provided companyId, or fall back to token companyId
      const targetCompanyId =
        queryCompanyId || bodyCompanyId || headerCompanyId || tokenCompanyId;

      if (targetCompanyId) {
        request.companyId = targetCompanyId;
      } else if (tokenCompanyId) {
        request.companyId = tokenCompanyId;
      }

      return true;
    }

    // For normal users, enforce strict company scope matching
    // Extract company ID from JWT token (set by JWT strategy)
    const tokenCompanyId = user.companyId;

    // Validate that company ID is present in JWT token
    // This should always be present if JWT strategy is working correctly
    if (!tokenCompanyId) {
      console.error(
        '[CompanyScopeGuard] JWT token missing companyId.',
        `User object: ${JSON.stringify(user, null, 2)}`,
      );
      throw new CompanyScopeViolationException();
    }

    // Extract company ID from header (if provided)
    const headerCompanyId = request.headers['x-company-id'];

    // Extract company ID from query params (if provided)
    const queryCompanyId = request.query?.companyId || request.query?.company_id;

    // Extract company ID from body (if provided)
    const bodyCompanyId = request.body?.companyId || request.body?.company_id;

    // Security: If header/query/body company ID is provided, it must match token
    // This prevents users from accessing other companies' data
    if (headerCompanyId && headerCompanyId !== tokenCompanyId) {
      console.error(
        `[CompanyScopeGuard] Header companyId mismatch: Token=${tokenCompanyId}, Header=${headerCompanyId}`,
      );
      throw new CompanyScopeViolationException();
    }

    if (queryCompanyId && queryCompanyId !== tokenCompanyId) {
      console.error(
        `[CompanyScopeGuard] Query companyId mismatch: Token=${tokenCompanyId}, Query=${queryCompanyId}`,
      );
      throw new CompanyScopeViolationException();
    }

    if (bodyCompanyId && bodyCompanyId !== tokenCompanyId) {
      console.error(
        `[CompanyScopeGuard] Body companyId mismatch: Token=${tokenCompanyId}, Body=${bodyCompanyId}`,
      );
      throw new CompanyScopeViolationException();
    }

    // Set company ID on request for downstream use (services, repositories)
    request.companyId = tokenCompanyId;

    return true;
  }
}
