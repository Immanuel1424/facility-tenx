import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

export interface CurrentUserPayload {
  userId?: string;
  email?: string;
  companyId?: string;
  siteId?: string;
  siteCode?: string;
  roles?: string[];
  permissions?: string[];
}

export interface TenantAwareRequest extends Request {
  companyId?: string;
  siteId?: string;
  user?: CurrentUserPayload;
}

@Injectable()
export class TenantResolutionMiddleware implements NestMiddleware {
  use(req: TenantAwareRequest, _res: Response, next: NextFunction): void {
    // For SYSTEM/SUPER_ADMIN operations, allow x-company-id and x-site-id headers
    // For normal users, extract from JWT token (set by JWT strategy)
    const headerCompanyId = req.header('x-company-id');
    const headerSiteId = req.header('x-site-id');

    // Prefer JWT user context (siteId, companyId from token) for authenticated requests
    // Fallback to headers only for SYSTEM operations or unauthenticated requests
    if (req.user?.companyId && req.user?.siteId) {
      req.companyId = req.user.companyId;
      req.siteId = req.user.siteId;
    } else {
      req.companyId = headerCompanyId ?? req.user?.companyId ?? undefined;
      req.siteId = headerSiteId ?? req.user?.siteId ?? undefined;
    }

    next();
  }

  static create(): (req: Request, res: Response, next: NextFunction) => void {
    const instance = new TenantResolutionMiddleware();
    return instance.use.bind(instance) as (
      req: Request,
      res: Response,
      next: NextFunction,
    ) => void;
  }
}


