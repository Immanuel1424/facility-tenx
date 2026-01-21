import { TicketStatus } from '../enums/ticket-status.enum';
import { UserRole } from '../enums/user-role.enum';

/**
 * Status Workflow Configuration
 * Defines valid status transitions and who can perform them
 */
export interface StatusTransition {
  from: TicketStatus;
  to: TicketStatus;
  allowed_roles: UserRole[];
  requires_assignment?: boolean;
  auto_actions?: string[];
}

/**
 * Valid Status Transitions
 * Follows the ticket lifecycle:
 * NEW → ACKNOWLEDGED → ASSIGNED → IN_PROGRESS → ON_HOLD → COMPLETED → CANCELLED
 */
export const STATUS_TRANSITIONS: StatusTransition[] = [
  // From NEW
  {
    from: TicketStatus.NEW,
    to: TicketStatus.ACKNOWLEDGED,
    allowed_roles: [UserRole.ADMIN, UserRole.SITE_COORDINATOR],
  },
  {
    from: TicketStatus.NEW,
    to: TicketStatus.CANCELLED,
    allowed_roles: [UserRole.ADMIN, UserRole.TENANT],
  },

  // From ACKNOWLEDGED
  {
    from: TicketStatus.ACKNOWLEDGED,
    to: TicketStatus.ASSIGNED,
    allowed_roles: [UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR],
    requires_assignment: true,
  },
  {
    from: TicketStatus.ACKNOWLEDGED,
    to: TicketStatus.CANCELLED,
    allowed_roles: [UserRole.ADMIN, UserRole.SITE_COORDINATOR],
  },

  // From ASSIGNED
  {
    from: TicketStatus.ASSIGNED,
    to: TicketStatus.IN_PROGRESS,
        allowed_roles: [UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.TECHNICIAN],
  },
  {
    from: TicketStatus.ASSIGNED,
    to: TicketStatus.ON_HOLD,
        allowed_roles: [UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.TECHNICIAN],
  },
  {
    from: TicketStatus.ASSIGNED,
    to: TicketStatus.CANCELLED,
    allowed_roles: [UserRole.ADMIN, UserRole.SITE_COORDINATOR],
  },

  // From IN_PROGRESS
  {
    from: TicketStatus.IN_PROGRESS,
    to: TicketStatus.ON_HOLD,
        allowed_roles: [UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.TECHNICIAN],
  },
  {
    from: TicketStatus.IN_PROGRESS,
    to: TicketStatus.COMPLETED,
        allowed_roles: [UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.TECHNICIAN],
    auto_actions: ['set_completed_at', 'set_auto_close_timer'],
  },
  {
    from: TicketStatus.IN_PROGRESS,
    to: TicketStatus.CANCELLED,
    allowed_roles: [UserRole.ADMIN, UserRole.SITE_COORDINATOR],
  },

  // From ON_HOLD
  {
    from: TicketStatus.ON_HOLD,
    to: TicketStatus.IN_PROGRESS,
        allowed_roles: [UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.TECHNICIAN],
  },
  {
    from: TicketStatus.ON_HOLD,
    to: TicketStatus.ASSIGNED,
    allowed_roles: [UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR],
  },
  {
    from: TicketStatus.ON_HOLD,
    to: TicketStatus.CANCELLED,
    allowed_roles: [UserRole.ADMIN, UserRole.SITE_COORDINATOR],
  },

  // From COMPLETED
  {
    from: TicketStatus.COMPLETED,
    to: TicketStatus.IN_PROGRESS,
    allowed_roles: [UserRole.ADMIN, UserRole.SUPERVISOR],
    // Reopen if tenant disputes completion
  },

  // COMPLETED and CANCELLED are terminal states (no transitions allowed)
];

/**
 * Status Display Configuration
 */
export const STATUS_CONFIG = {
  [TicketStatus.NEW]: {
    label: 'New',
    color: '#3B82F6', // Blue
    icon: 'fiber_new',
    description: 'Ticket created, awaiting acknowledgement',
  },
  [TicketStatus.ACKNOWLEDGED]: {
    label: 'Acknowledged',
    color: '#8B5CF6', // Purple
    icon: 'visibility',
    description: 'Ticket acknowledged, awaiting assignment',
  },
  [TicketStatus.ASSIGNED]: {
    label: 'Assigned',
    color: '#F59E0B', // Amber
    icon: 'person',
    description: 'Assigned to technician, awaiting work start',
  },
  [TicketStatus.IN_PROGRESS]: {
    label: 'In Progress',
    color: '#10B981', // Green
    icon: 'engineering',
    description: 'Work in progress',
  },
  [TicketStatus.ON_HOLD]: {
    label: 'On Hold',
    color: '#6B7280', // Gray
    icon: 'pause_circle',
    description: 'Work paused temporarily',
  },
  [TicketStatus.COMPLETED]: {
    label: 'Completed',
    color: '#059669', // Emerald
    icon: 'task_alt',
    description: 'Work completed',
  },
  [TicketStatus.CANCELLED]: {
    label: 'Cancelled',
    color: '#EF4444', // Red
    icon: 'cancel',
    description: 'Ticket cancelled',
  },
} as const;

/**
 * Get next valid statuses for a given status and role
 */
export function getNextValidStatuses(
  currentStatus: TicketStatus,
  userRole: UserRole,
): TicketStatus[] {
  return STATUS_TRANSITIONS
    .filter((t) => t.from === currentStatus && t.allowed_roles.includes(userRole))
    .map((t) => t.to);
}

/**
 * Check if a status transition is valid for a given role
 */
export function isValidTransition(
  from: TicketStatus,
  to: TicketStatus,
  userRole: UserRole,
): boolean {
  const transition = STATUS_TRANSITIONS.find(
    (t) => t.from === from && t.to === to,
  );

  if (!transition) {
    return false;
  }

  return transition.allowed_roles.includes(userRole);
}

