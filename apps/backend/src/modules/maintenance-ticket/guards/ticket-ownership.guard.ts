import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../iam/entities/user.entity';
import { UserRole } from '../enums/user-role.enum';
import { MaintenanceTicketService } from '../services/maintenance-ticket.service';

@Injectable()
export class TicketOwnershipGuard implements CanActivate {
  constructor(
    private readonly ticketService: MaintenanceTicketService,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const ticketId = request.params.id;

    if (!user || !ticketId) {
      throw new ForbiddenException('Invalid request');
    }

    try {
      const ticket = await this.ticketService.findOne(
        user.companyId,
        ticketId,
        user.userId,
      );

      const userRoles = user.roles || [];
      const isTenant = userRoles.includes(UserRole.TENANT);
      const isAdmin = userRoles.includes(UserRole.ADMIN);

      if (isAdmin) {
        return true;
      }

      // Access check is now handled within the service's findOne method
      // which supports multi-villa logic. We don't need to duplicate it here.
      // This guard now primarily ensures the ticket exists and catches NotFound.
      
      // if (isTenant) {
      //   const userEntity = await this.userRepository.findOne({
      //     where: { id: user.userId, companyId: user.companyId },
      //   });

      //   if (!userEntity) {
      //     throw new ForbiddenException('User not found');
      //   }

      //   // DEPRECATED CHECK: logic moved to MaintenanceTicketService.findOne
      //   // if (ticket.villaNumber !== userEntity.villaNumber) { ... }
      // }


      return true;
    } catch (error) {
      if (error instanceof ForbiddenException) {
        throw error;
      }
      throw new ForbiddenException('Access denied');
    }
  }
}

