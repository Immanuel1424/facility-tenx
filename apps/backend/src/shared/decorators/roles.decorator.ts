import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';

/**
 * High-level application roles used for route protection.
 *
 * Notes:
 * - `SUPER_ADMIN` is the existing system-wide admin role and is treated as the
 *   SYSTEM role in the helpdesk/tenant-maintenance design.
 * - Domain-specific roles (TENANT, SITE_COORDINATOR, SUPERVISOR, TECHNICIAN)
 *   are included so they can be used directly with @Roles().
 */
export type Role =
  | 'SUPER_ADMIN'
  | 'SYSTEM'
  | 'ADMIN'
  | 'MANAGER'
  | 'USER'
  | 'TENANT'
  | 'SITE_COORDINATOR'
  | 'SUPERVISOR'
  | 'TECHNICIAN';

export const Roles = (...roles: Role[]): ReturnType<typeof SetMetadata> =>
  SetMetadata(ROLES_KEY, roles);


