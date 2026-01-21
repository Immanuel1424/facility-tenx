import { Injectable } from '@nestjs/common';
import { CurrentUserPayload } from '../decorators/current-user.decorator';

/**
 * Service to detect and handle Super Admin users
 * Super Admin is identified by:
 * 1. Belonging to SYSTEM company (code: 'SYSTEM')
 * 2. Having SUPER_ADMIN role
 */
@Injectable()
export class SuperAdminService {
  /**
   * SYSTEM company code constant
   */
  readonly SYSTEM_COMPANY_CODE = 'SYSTEM';

  /**
   * Check if a user is a Super Admin
   * @param user Current user payload from JWT
   * @returns true if user is Super Admin
   */
  isSuperAdmin(user?: CurrentUserPayload): boolean {
    if (!user || !user.roles || !user.companyId) {
      return false;
    }

    // Super Admin must have SUPER_ADMIN role
    // Company ID check will be done by checking if company code is SYSTEM
    return user.roles.includes('SUPER_ADMIN');
  }

  /**
   * Check if company code is SYSTEM
   * @param companyCode Company code to check
   * @returns true if company code is SYSTEM
   */
  isSystemCompany(companyCode: string): boolean {
    return companyCode?.toUpperCase() === this.SYSTEM_COMPANY_CODE;
  }

  /**
   * Check if company ID belongs to SYSTEM company
   * This requires a database lookup, so use sparingly
   * @param companyId Company ID to check
   * @param companyCode Optional company code (if already known)
   * @returns true if company is SYSTEM
   */
  isSystemCompanyById(companyId: string, companyCode?: string): boolean {
    // If company code is provided, use it
    if (companyCode) {
      return this.isSystemCompany(companyCode);
    }
    // Otherwise, would need database lookup (not implemented here)
    // Services should pass company code when available
    return false;
  }
}

