/**
 * Ticket Permissions Constants
 * Defines all permissions for the maintenance ticket module
 */
export const TICKET_PERMISSIONS = {
  // Ticket CRUD
  CREATE: 'ticket:create',
  READ: 'ticket:read',
  READ_ALL: 'ticket:read_all',
  READ_OWN: 'ticket:read_own',
  READ_ASSIGNED: 'ticket:read_assigned',
  UPDATE: 'ticket:update',
  DELETE: 'ticket:delete',

  // Ticket Actions
  ACKNOWLEDGE: 'ticket:acknowledge',
  ASSIGN_SUPERVISOR: 'ticket:assign_supervisor',
  ASSIGN_TECHNICIAN: 'ticket:assign_technician',
  CHANGE_STATUS: 'ticket:change_status',
  CHANGE_PRIORITY: 'ticket:change_priority',
  CANCEL: 'ticket:cancel',
  CLOSE: 'ticket:close',
  CONFIRM_COMPLETION: 'ticket:confirm_completion',
  RATE: 'ticket:rate',

  // Notes
  ADD_PUBLIC_COMMENT: 'ticket:add_public_comment',
  ADD_INTERNAL_NOTE: 'ticket:add_internal_note',
  ADD_WORK_NOTE: 'ticket:add_work_note',
  VIEW_INTERNAL_NOTES: 'ticket:view_internal_notes',

  // Attachments
  ADD_ATTACHMENT: 'ticket:add_attachment',
  DELETE_ATTACHMENT: 'ticket:delete_attachment',

  // Reports
  VIEW_REPORTS: 'ticket:view_reports',
  EXPORT_DATA: 'ticket:export_data',
} as const;

/**
 * Category Permissions
 */
export const CATEGORY_PERMISSIONS = {
  CREATE: 'category:create',
  READ: 'category:read',
  UPDATE: 'category:update',
  DELETE: 'category:delete',
} as const;

/**
 * Department Permissions
 */
export const DEPARTMENT_PERMISSIONS = {
  CREATE: 'department:create',
  READ: 'department:read',
  UPDATE: 'department:update',
  DELETE: 'department:delete',
} as const;

/**
 * SLA Permissions
 */
export const SLA_PERMISSIONS = {
  CREATE: 'sla:create',
  READ: 'sla:read',
  UPDATE: 'sla:update',
  DELETE: 'sla:delete',
  VIEW_METRICS: 'sla:view_metrics',
} as const;

/**
 * Audit Permissions
 */
export const AUDIT_PERMISSIONS = {
  VIEW: 'audit:view',
  EXPORT: 'audit:export',
} as const;

/**
 * User Permissions
 */
export const USER_PERMISSIONS = {
  CREATE: 'user:create',
  READ: 'user:read',
  UPDATE: 'user:update',
  DELETE: 'user:delete',
  RESET_PASSWORD: 'user:reset_password',
  CHANGE_ROLE: 'user:change_role',
} as const;

/**
 * Role-based permission matrix
 * Defines which permissions each role has
 */
export const ROLE_PERMISSIONS = {
  TENANT: [
    TICKET_PERMISSIONS.CREATE,
    TICKET_PERMISSIONS.READ_OWN,
    TICKET_PERMISSIONS.ADD_PUBLIC_COMMENT,
    TICKET_PERMISSIONS.ADD_ATTACHMENT,
    TICKET_PERMISSIONS.CANCEL,
    TICKET_PERMISSIONS.CONFIRM_COMPLETION,
    TICKET_PERMISSIONS.RATE,
    CATEGORY_PERMISSIONS.READ,
    DEPARTMENT_PERMISSIONS.READ,
  ],

  TECHNICIAN: [
    TICKET_PERMISSIONS.READ_ASSIGNED,
    TICKET_PERMISSIONS.UPDATE,
    TICKET_PERMISSIONS.CHANGE_STATUS,
    TICKET_PERMISSIONS.ADD_WORK_NOTE,
    TICKET_PERMISSIONS.ADD_ATTACHMENT,
    TICKET_PERMISSIONS.VIEW_INTERNAL_NOTES,
    CATEGORY_PERMISSIONS.READ,
    DEPARTMENT_PERMISSIONS.READ,
  ],

  SUPERVISOR: [
    TICKET_PERMISSIONS.READ_ALL,
    TICKET_PERMISSIONS.UPDATE,
    TICKET_PERMISSIONS.ASSIGN_TECHNICIAN,
    TICKET_PERMISSIONS.CHANGE_STATUS,
    TICKET_PERMISSIONS.CHANGE_PRIORITY,
    TICKET_PERMISSIONS.ADD_INTERNAL_NOTE,
    TICKET_PERMISSIONS.ADD_WORK_NOTE,
    TICKET_PERMISSIONS.VIEW_INTERNAL_NOTES,
    TICKET_PERMISSIONS.ADD_ATTACHMENT,
    TICKET_PERMISSIONS.VIEW_REPORTS,
    CATEGORY_PERMISSIONS.READ,
    DEPARTMENT_PERMISSIONS.READ,
    SLA_PERMISSIONS.READ,
    SLA_PERMISSIONS.VIEW_METRICS,
  ],

  SITE_COORDINATOR: [
    TICKET_PERMISSIONS.READ_ALL,
    TICKET_PERMISSIONS.UPDATE,
    TICKET_PERMISSIONS.ACKNOWLEDGE,
    TICKET_PERMISSIONS.ASSIGN_SUPERVISOR,
    TICKET_PERMISSIONS.ASSIGN_TECHNICIAN,
    TICKET_PERMISSIONS.CHANGE_STATUS,
    TICKET_PERMISSIONS.CHANGE_PRIORITY,
    TICKET_PERMISSIONS.ADD_INTERNAL_NOTE,
    TICKET_PERMISSIONS.VIEW_INTERNAL_NOTES,
    TICKET_PERMISSIONS.ADD_ATTACHMENT,
    TICKET_PERMISSIONS.VIEW_REPORTS,
    TICKET_PERMISSIONS.EXPORT_DATA,
    CATEGORY_PERMISSIONS.READ,
    DEPARTMENT_PERMISSIONS.READ,
    SLA_PERMISSIONS.READ,
    SLA_PERMISSIONS.VIEW_METRICS,
  ],

  ADMIN: [
    // Full access to everything
    ...Object.values(TICKET_PERMISSIONS),
    ...Object.values(CATEGORY_PERMISSIONS),
    ...Object.values(DEPARTMENT_PERMISSIONS),
    ...Object.values(SLA_PERMISSIONS),
    ...Object.values(AUDIT_PERMISSIONS),
    ...Object.values(USER_PERMISSIONS),
  ],
} as const;

