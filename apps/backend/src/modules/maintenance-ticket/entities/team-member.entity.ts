import {
  Column,
  Entity,
  Index,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { Team } from './team.entity';
import { User } from '../../iam/entities/user.entity';

@Entity({ name: 'team_members' })
@Unique(['companyId', 'teamId', 'userId'])
@Index(['companyId', 'teamId'])
@Index(['companyId', 'userId'])
export class TeamMember extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'team_id' })
  teamId!: string;

  @ManyToOne(() => Team, (team) => team.members, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'team_id' })
  team!: Team;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @Column({ type: 'boolean', default: false, name: 'is_lead' })
  isLead!: boolean;

  @Column({ type: 'timestamp with time zone', default: () => 'now()', name: 'joined_at' })
  joinedAt!: Date;
}

