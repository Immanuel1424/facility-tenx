import { Entity, Column, Index, OneToMany } from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { MaintenanceTicket } from './maintenance-ticket.entity';

@Entity('departments')
@Index(['companyId', 'name'], { unique: true })
export class Department extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  @OneToMany(() => MaintenanceTicket, (ticket) => ticket.department)
  tickets!: MaintenanceTicket[];
}

