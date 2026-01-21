import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { TenantAwareRequest } from '../middleware/tenant-resolution.middleware';
import { SuperAdminService } from '../services/super-admin.service';
import { CurrentUserPayload } from '../decorators/current-user.decorator';

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private readonly superAdminService: SuperAdminService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<TenantAwareRequest>();
    const user = request.user;
    
    // Allow Super Admin to bypass site requirement for SYSTEM operations
    // Map middleware CurrentUserPayload to decorator CurrentUserPayload format (userId -> sub)
    if (user) {
      const userPayload: CurrentUserPayload = {
        sub: user.userId || '',
        email: user.email,
        companyId: user.companyId,
        siteId: user.siteId,
        siteCode: user.siteCode,
        roles: user.roles,
      };
      if (this.superAdminService.isSuperAdmin(userPayload)) {
        // Super Admin can work with headers for SYSTEM operations
        // Or use JWT token context for site-specific operations
        if (!request.companyId && user.companyId) {
          request.companyId = user.companyId;
        }
        if (!request.siteId && user.siteId) {
          request.siteId = user.siteId;
        }
        return true;
      }
    }
    
    // For normal users, extract from JWT token (set by JWT strategy)
    if (!request.companyId && request.user?.companyId) {
      request.companyId = request.user.companyId;
    }
    if (!request.siteId && request.user?.siteId) {
      request.siteId = request.user.siteId;
    }
    
    // Require both companyId and siteId for tenant scoping
    if (!request.companyId) {
      throw new ForbiddenException(
        'Missing tenant context. Ensure JWT token contains companyId.',
      );
    }
    if (!request.siteId) {
      throw new ForbiddenException(
        'Missing site context. Ensure JWT token contains siteId.',
      );
    }
    
    return true;
  }
}


