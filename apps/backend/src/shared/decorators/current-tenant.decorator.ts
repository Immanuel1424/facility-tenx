import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { TenantAwareRequest } from '../middleware/tenant-resolution.middleware';

export interface CurrentTenant {
  companyId?: string;
  siteId?: string;
}

export const CurrentTenant = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): CurrentTenant => {
    const request = ctx.switchToHttp().getRequest<TenantAwareRequest>();
    return {
      companyId: request.companyId,
      siteId: request.siteId,
    };
  },
);


