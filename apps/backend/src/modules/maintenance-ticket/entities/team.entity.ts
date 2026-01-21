import {
  Column,
  Entity,
  Index,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { Department } from './department.entity';
import { User } from '../../iam/entities/user.entity';
import { TeamMember } from './team-member.entity';

@Entity({ name: 'teams' })
@Index(['companyId', 'name'], { unique: true })
@Index(['companyId', 'departmentId'])
@Index(['companyId', 'isActive'])
export class Team extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'uuid', nullable: true, name: 'department_id' })
  departmentId?: string;

  @ManyToOne(() => Department, { nullable: true })
  @JoinColumn({ name: 'department_id' })
  department?: Department;

  @Column({ type: 'uuid', nullable: true, name: 'lead_user_id' })
  leadUserId?: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'lead_user_id' })
  leadUser?: User;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  @Column({ type: 'varchar', length: 7, nullable: true, name: 'color_code' })
  colorCode?: string;

  @OneToMany(() => TeamMember, (member) => member.team, { cascade: true })
  members!: TeamMember[];
}

