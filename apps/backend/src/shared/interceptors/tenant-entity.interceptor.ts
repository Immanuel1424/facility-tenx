import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { TenantAwareRequest } from '../middleware/tenant-resolution.middleware';

@Injectable()
export class TenantEntityInterceptor implements NestInterceptor {
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<unknown> {
    const request = context.switchToHttp().getRequest<TenantAwareRequest>();
    const companyId = request.companyId;

    return next.handle().pipe(
      map((data) => {
        if (!companyId) {
          return data;
        }

        if (Array.isArray(data)) {
          return data.filter(
            (item) => item && (item as { companyId?: string }).companyId === companyId,
          );
        }

        if (
          data &&
          (data as { companyId?: string }).companyId &&
          (data as { companyId?: string }).companyId !== companyId
        ) {
          return undefined;
        }

        return data;
      }),
    );
  }
}


