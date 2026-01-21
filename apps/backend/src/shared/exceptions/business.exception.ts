import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Base Business Exception
 * All custom business exceptions should extend this class
 */
export abstract class BusinessException extends HttpException {
  constructor(
    public readonly errorCode: string,
    message: string,
    status: HttpStatus,
    public readonly details?: Record<string, unknown>,
  ) {
    super(
      {
        success: false,
        errorCode,
        message,
        details,
        timestamp: new Date().toISOString(),
      },
      status,
    );
  }
}

/**
 * Tenant Not Found Exception
 */
export class TenantNotFoundException extends BusinessException {
  constructor(companyId: string) {
    super(
      'TENANT_NOT_FOUND',
      `Tenant with ID ${companyId} not found`,
      HttpStatus.NOT_FOUND,
      { company_id: companyId },
    );
  }
}

/**
 * Resource Not Found Exception
 */
export class ResourceNotFoundException extends BusinessException {
  constructor(resource: string, id: string) {
    super(
      'RESOURCE_NOT_FOUND',
      `${resource} with ID ${id} not found`,
      HttpStatus.NOT_FOUND,
      { resource, id },
    );
  }
}

/**
 * Ticket Not Found Exception
 */
export class TicketNotFoundException extends BusinessException {
  constructor(ticketId: string) {
    super(
      'TICKET_NOT_FOUND',
      `Ticket with ID ${ticketId} not found`,
      HttpStatus.NOT_FOUND,
      { ticket_id: ticketId },
    );
  }
}

/**
 * Invalid Status Transition Exception
 */
export class InvalidStatusTransitionException extends BusinessException {
  constructor(currentStatus: string, targetStatus: string) {
    super(
      'INVALID_STATUS_TRANSITION',
      `Cannot transition from ${currentStatus} to ${targetStatus}`,
      HttpStatus.BAD_REQUEST,
      { current_status: currentStatus, target_status: targetStatus },
    );
  }
}

/**
 * Unauthorized Role Exception
 */
export class UnauthorizedRoleException extends BusinessException {
  constructor(requiredRoles: string[], userRoles: string[]) {
    super(
      'UNAUTHORIZED_ROLE',
      `Access denied. Required roles: ${requiredRoles.join(', ')}`,
      HttpStatus.FORBIDDEN,
      { required_roles: requiredRoles, user_roles: userRoles },
    );
  }
}

/**
 * Tenant Access Violation Exception
 */
export class TenantAccessViolationException extends BusinessException {
  constructor(message = 'You do not have access to this resource') {
    super(
      'TENANT_ACCESS_VIOLATION',
      message,
      HttpStatus.FORBIDDEN,
    );
  }
}

/**
 * Villa Mismatch Exception
 */
export class VillaMismatchException extends BusinessException {
  constructor(userVilla?: string | number, ticketVilla?: string | number) {
    super(
      'VILLA_MISMATCH',
      'You can only access tickets for your own villa',
      HttpStatus.FORBIDDEN,
      { user_villa: userVilla ?? null, ticket_villa: ticketVilla ?? null },
    );
  }
}

/**
 * Ticket Already Assigned Exception
 */
export class TicketAlreadyAssignedException extends BusinessException {
  constructor(ticketId: string, assigneeId: string) {
    super(
      'TICKET_ALREADY_ASSIGNED',
      'This ticket is already assigned to another technician',
      HttpStatus.CONFLICT,
      { ticket_id: ticketId, current_assignee_id: assigneeId },
    );
  }
}

/**
 * Invalid Technician Exception
 */
export class InvalidTechnicianException extends BusinessException {
  constructor(userId: string) {
    super(
      'INVALID_TECHNICIAN',
      'The specified user is not a valid technician',
      HttpStatus.BAD_REQUEST,
      { user_id: userId },
    );
  }
}

/**
 * SLA Violation Exception
 */
export class SlaViolationException extends BusinessException {
  constructor(ticketId: string, slaType: string) {
    super(
      'SLA_VIOLATION',
      `SLA ${slaType} has been violated for this ticket`,
      HttpStatus.UNPROCESSABLE_ENTITY,
      { ticket_id: ticketId, sla_type: slaType },
    );
  }
}

/**
 * Attachment Limit Exceeded Exception
 */
export class AttachmentLimitExceededException extends BusinessException {
  constructor(limit: number) {
    super(
      'ATTACHMENT_LIMIT_EXCEEDED',
      `Maximum attachment limit of ${limit} exceeded`,
      HttpStatus.BAD_REQUEST,
      { limit },
    );
  }
}

/**
 * Ticket Closed Exception
 */
export class TicketClosedException extends BusinessException {
  constructor(ticketId: string) {
    super(
      'TICKET_CLOSED',
      'Cannot perform operation on a closed ticket',
      HttpStatus.BAD_REQUEST,
      { ticket_id: ticketId },
    );
  }
}

/**
 * Company Scope Violation Exception
 */
export class CompanyScopeViolationException extends BusinessException {
  constructor() {
    super(
      'COMPANY_SCOPE_VIOLATION',
      'Cross-company access is not allowed',
      HttpStatus.FORBIDDEN,
    );
  }
}

/**
 * Duplicate Resource Exception
 */
export class DuplicateResourceException extends BusinessException {
  constructor(resource: string, field: string, value: string) {
    super(
      'DUPLICATE_RESOURCE',
      `${resource} with ${field} '${value}' already exists`,
      HttpStatus.CONFLICT,
      { resource, field, value },
    );
  }
}

