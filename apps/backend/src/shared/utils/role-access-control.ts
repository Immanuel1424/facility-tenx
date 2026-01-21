import { Role } from '../decorators/roles.decorator';

export type RoleScope = 'GLOBAL' | 'COMPANY' | 'SITE';

export interface RoleAccessRule {
  scope: RoleScope;
  description: string;
}

/**
 * Central role → scope matrix.
 *
 * This does NOT grant permissions by itself; it documents and codifies
 * how each role is scoped in terms of multi-tenant isolation:
 * - GLOBAL   → can potentially span multiple companies/sites
 * - COMPANY  → strictly restricted to a single company
 * - SITE     → restricted to one or more sites within a single company
 */
export const ROLE_SCOPE_MATRIX: Record<Role, RoleAccessRule> = {
  SUPER_ADMIN: {
    scope: 'GLOBAL',
    description:
      'System-wide super admin. Can operate across all companies and sites.',
  },
  SYSTEM: {
    scope: 'GLOBAL',
    description:
      'Alias for system-level operator. Treated the same as SUPER_ADMIN.',
  },
  ADMIN: {
    scope: 'COMPANY',
    description:
      'Company admin. Can manage all resources within a single company, but never across companies.',
  },
  MANAGER: {
    scope: 'COMPANY',
    description:
      'Company manager. Visibility and actions are limited to a single company.',
  },
  USER: {
    scope: 'COMPANY',
    description:
      'Generic internal user. Reads and actions are limited to a single company.',
  },
  TENANT: {
    scope: 'SITE',
    description:
      'End-tenant. Restricted to their own villa(s) and associated site(s) within a single company.',
  },
  SITE_COORDINATOR: {
    scope: 'SITE',
    description:
      'Coordinator for one or more sites of a single company. Can see all tickets/users for assigned site(s) only.',
  },
  SUPERVISOR: {
    scope: 'SITE',
    description:
      'Supervisor for one or more sites of a single company. Can see and act on tickets for assigned site(s) only.',
  },
  TECHNICIAN: {
    scope: 'SITE',
    description:
      'Technician. Can see and update tickets assigned to them (or their team) within assigned site(s).',
  },
};

export function getRoleScope(role: Role): RoleAccessRule {
  return ROLE_SCOPE_MATRIX[role];
}

export function isGlobalRole(role: Role): boolean {
  return ROLE_SCOPE_MATRIX[role]?.scope === 'GLOBAL';
}

export function isCompanyScopedRole(role: Role): boolean {
  return ROLE_SCOPE_MATRIX[role]?.scope === 'COMPANY';
}

export function isSiteScopedRole(role: Role): boolean {
  return ROLE_SCOPE_MATRIX[role]?.scope === 'SITE';
}


