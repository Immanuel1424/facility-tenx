import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface CurrentUserPayload {
  sub: string;
  email?: string;
  /**
   * High-level application roles (see shared/decorators/roles.decorator.ts).
   */
  roles?: string[];
  /**
   * Tenant/company scope for the current request.
   */
  companyId?: string;
  /**
   * Optional site scope for site-scoped users (coordinators, supervisors,
   * technicians, tenants linked to a specific site).
   */
  siteId?: string;
  siteCode?: string;
}

export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): CurrentUserPayload | undefined => {
    const request = ctx
      .switchToHttp()
      .getRequest<{ user?: CurrentUserPayload }>();
    return request.user;
  },
);


