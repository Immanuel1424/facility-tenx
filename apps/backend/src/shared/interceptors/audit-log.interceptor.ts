import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { AuditService, AuditLogParams } from '../../modules/audit/audit.service';
import { AuditAction, AuditResourceType } from '../../modules/audit/entities/audit-log.entity';

/**
 * Audit Log Interceptor
 * Automatically logs API requests to the audit log
 * Can be applied at controller or method level
 */
@Injectable()
export class AuditLogInterceptor implements NestInterceptor {
  constructor(private readonly auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest();
    const startTime = Date.now();

    const { method, url, body, user } = request;
    const companyId = user?.companyId;
    const userId = user?.userId;
    const userEmail = user?.email;

    // Skip if no company context
    if (!companyId) {
      return next.handle();
    }

    // Determine action and resource type from request
    const action = this.getActionFromMethod(method);
    const resourceType = this.getResourceTypeFromUrl(url);

    return next.handle().pipe(
      tap((response) => {
        const duration = Date.now() - startTime;
        const responseStatus = context.switchToHttp().getResponse().statusCode;

        // Log successful request (async, don't await)
        this.auditService.log({
          companyId,
          userId,
          userEmail,
          action,
          resourceType,
          requestPath: url,
          requestMethod: method,
          responseStatus,
          durationMs: duration,
          isSuccess: true,
          ipAddress: request.ip,
          userAgent: request.headers['user-agent'],
        }).catch(() => {
          // Ignore audit log errors
        });
      }),
      catchError((error) => {
        const duration = Date.now() - startTime;

        // Log failed request (async, don't await)
        this.auditService.log({
          companyId,
          userId,
          userEmail,
          action,
          resourceType,
          requestPath: url,
          requestMethod: method,
          responseStatus: error.status || 500,
          durationMs: duration,
          isSuccess: false,
          errorMessage: error.message,
          ipAddress: request.ip,
          userAgent: request.headers['user-agent'],
        }).catch(() => {
          // Ignore audit log errors
        });

        throw error;
      }),
    );
  }

  private getActionFromMethod(method: string): AuditAction {
    switch (method.toUpperCase()) {
      case 'POST':
        return AuditAction.CREATE;
      case 'PUT':
      case 'PATCH':
        return AuditAction.UPDATE;
      case 'DELETE':
        return AuditAction.DELETE;
      case 'GET':
      default:
        return AuditAction.READ;
    }
  }

  private getResourceTypeFromUrl(url: string): AuditResourceType {
    const urlLower = url.toLowerCase();

    if (urlLower.includes('/maintenance-tickets') || urlLower.includes('/tickets')) {
      return AuditResourceType.TICKET;
    }
    if (urlLower.includes('/comments')) {
      return AuditResourceType.COMMENT;
    }
    if (urlLower.includes('/attachments')) {
      return AuditResourceType.ATTACHMENT;
    }
    if (urlLower.includes('/categories')) {
      return AuditResourceType.CATEGORY;
    }
    if (urlLower.includes('/departments')) {
      return AuditResourceType.DEPARTMENT;
    }
    if (urlLower.includes('/sla')) {
      return AuditResourceType.SLA_CONFIG;
    }
    if (urlLower.includes('/users')) {
      return AuditResourceType.USER;
    }
    if (urlLower.includes('/roles')) {
      return AuditResourceType.ROLE;
    }
    if (urlLower.includes('/permissions')) {
      return AuditResourceType.PERMISSION;
    }
    if (urlLower.includes('/auth') || urlLower.includes('/login') || urlLower.includes('/logout')) {
      return AuditResourceType.SESSION;
    }
    if (urlLower.includes('/notifications')) {
      return AuditResourceType.NOTIFICATION;
    }
    if (urlLower.includes('/companies') || urlLower.includes('/tenants')) {
      return AuditResourceType.COMPANY;
    }
    if (urlLower.includes('/villas')) {
      return AuditResourceType.VILLA;
    }

    return AuditResourceType.USER; // Default fallback
  }
}

