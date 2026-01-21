import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PolicyEvaluationService } from '../services/policy-evaluation.service';
import { PermissionCheck, PERMISSION_KEY } from '../decorators/require-permission.decorator';
import { CurrentUserData } from '../decorators/current-user.decorator';
import { UserSiteService } from '../../tenant/services/user-site.service';

@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private policyService: PolicyEvaluationService,
    private userSiteService: UserSiteService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const permission = this.reflector.getAllAndOverride<PermissionCheck>(
      PERMISSION_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!permission) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user as CurrentUserData | undefined;

    if (!user) {
      return false;
    }

    const roles = (user.roles ?? []).map((role) =>
      role.toUpperCase().trim(),
    );

    // SUPER_ADMIN: Full system-wide access (bypass all checks)
    if (roles.includes('SUPER_ADMIN')) {
      return true;
    }

    // ADMIN: Site-scoped full access
    // Admin users have all privileges but only for their assigned site(s)
    if (roles.includes('ADMIN')) {
      // Get siteId from request (set by TenantResolutionMiddleware from JWT token or headers)
      const siteId = (request as any).siteId || user.siteId;

      if (!siteId) {
        // If no site context, allow access (for company-wide operations)
        // This handles cases where operations don't require site context
        // However, most operations should have site context from JWT token
        return true;
      }

      // Verify ADMIN is assigned to this site
      const isAssigned = await this.userSiteService.isUserAssignedToSite(
        user.companyId,
        user.userId,
        siteId,
      );

      if (!isAssigned) {
        throw new ForbiddenException(
          `Admin access denied: User is not assigned to site ${siteId}`,
        );
      }

      // ADMIN has full access to this site - bypass permission check
      return true;
    }

    // Other roles: Check specific permissions
    const resourceContext = request.resourceContext;

    await this.policyService.requirePermission(
      user.companyId,
      user.userId,
      permission,
      resourceContext,
    );

    return true;
  }
}

