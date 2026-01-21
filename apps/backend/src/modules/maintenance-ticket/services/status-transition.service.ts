import { Injectable, BadRequestException } from '@nestjs/common';
import { TicketStatus } from '../enums/ticket-status.enum';
import { UserRole } from '../enums/user-role.enum';

@Injectable()
export class StatusTransitionService {
  private readonly validTransitions: Map<TicketStatus, TicketStatus[]> = new Map([
    [TicketStatus.NEW, [TicketStatus.ACKNOWLEDGED, TicketStatus.CANCELLED]],
    [
      TicketStatus.ACKNOWLEDGED,
      [TicketStatus.ASSIGNED, TicketStatus.CANCELLED],
    ],
    [
      TicketStatus.ASSIGNED,
      [TicketStatus.IN_PROGRESS, TicketStatus.ON_HOLD, TicketStatus.CANCELLED],
    ],
    [
      TicketStatus.IN_PROGRESS,
      [TicketStatus.ON_HOLD, TicketStatus.COMPLETED, TicketStatus.CANCELLED],
    ],
    [
      TicketStatus.ON_HOLD,
      [TicketStatus.IN_PROGRESS, TicketStatus.ASSIGNED, TicketStatus.CANCELLED],
    ],
    [TicketStatus.COMPLETED, [TicketStatus.IN_PROGRESS]],
    [TicketStatus.CANCELLED, []],
  ]);

  private readonly rolePermissions: Map<
    TicketStatus,
    UserRole[]
  > = new Map([
    [TicketStatus.NEW, [UserRole.ADMIN, UserRole.SITE_COORDINATOR]],
    [
      TicketStatus.ACKNOWLEDGED,
      [UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR],
    ],
    [
      TicketStatus.ASSIGNED,
      [UserRole.ADMIN, UserRole.SITE_COORDINATOR, UserRole.SUPERVISOR],
    ],
    [
      TicketStatus.IN_PROGRESS,
      [
        UserRole.ADMIN,
        UserRole.SUPERVISOR,
        UserRole.TECHNICIAN,
      ],
    ],
    [
      TicketStatus.ON_HOLD,
      [
        UserRole.ADMIN,
        UserRole.SUPERVISOR,
        UserRole.TECHNICIAN,
      ],
    ],
    [
      TicketStatus.COMPLETED,
      [
        UserRole.ADMIN,
        UserRole.SUPERVISOR,
        UserRole.TECHNICIAN,
      ],
    ],
    [TicketStatus.CANCELLED, [UserRole.ADMIN, UserRole.TENANT]],
  ]);

  validateTransition(
    currentStatus: TicketStatus,
    newStatus: TicketStatus,
    userRole: UserRole,
  ): void {
    if (currentStatus === newStatus) {
      throw new BadRequestException(
        `Ticket is already in ${currentStatus} status`,
      );
    }

    const allowedTransitions = this.validTransitions.get(currentStatus);
    if (!allowedTransitions || !allowedTransitions.includes(newStatus)) {
      throw new BadRequestException(
        `Invalid status transition from ${currentStatus} to ${newStatus}`,
      );
    }

    const allowedRoles = this.rolePermissions.get(newStatus);
    if (!allowedRoles || !allowedRoles.includes(userRole)) {
      throw new BadRequestException(
        `Role ${userRole} is not authorized to set status to ${newStatus}`,
      );
    }
  }

  isValidTransition(
    currentStatus: TicketStatus,
    newStatus: TicketStatus,
  ): boolean {
    if (currentStatus === newStatus) {
      return false;
    }

    const allowedTransitions = this.validTransitions.get(currentStatus);
    return allowedTransitions?.includes(newStatus) ?? false;
  }

  canRoleChangeToStatus(userRole: UserRole, status: TicketStatus): boolean {
    const allowedRoles = this.rolePermissions.get(status);
    return allowedRoles?.includes(userRole) ?? false;
  }

  getNextValidStatuses(currentStatus: TicketStatus): TicketStatus[] {
    return this.validTransitions.get(currentStatus) ?? [];
  }
}

