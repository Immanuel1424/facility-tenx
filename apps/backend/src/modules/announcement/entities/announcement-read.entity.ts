import {
  Entity,
  Column,
  Index,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { Announcement } from './announcement.entity';
import { User } from '../../iam/entities/user.entity';

@Entity('announcement_reads')
@Unique(['companyId', 'announcementId', 'userId'])
@Index(['companyId', 'userId'])
@Index(['announcementId'])
export class AnnouncementRead extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'announcement_id' })
  announcementId!: string;

  @ManyToOne(() => Announcement, (announcement) => announcement.reads, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'announcement_id' })
  announcement!: Announcement;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @Column({ type: 'timestamptz', name: 'read_at', default: () => 'now()' })
  readAt!: Date;
}

