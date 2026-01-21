import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';
import { User } from '../iam/entities/user.entity';
import { MaintenanceTicket } from '../maintenance-ticket/entities/maintenance-ticket.entity';
import { Department } from '../maintenance-ticket/entities/department.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, MaintenanceTicket, Department])],
  controllers: [DashboardController],
  providers: [DashboardService],
  exports: [DashboardService],
})
export class DashboardModule {}

