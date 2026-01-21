import {
  Entity,
  Column,
  Index,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { AnnouncementCategory } from '../enums/announcement-category.enum';
import { AnnouncementPriority } from '../enums/announcement-priority.enum';
import { AnnouncementTargetAudience } from '../enums/announcement-target-audience.enum';
import { AnnouncementRead } from './announcement-read.entity';
import { User } from '../../iam/entities/user.entity';

@Entity('announcements')
@Index(['companyId', 'isPublished', 'expiresAt'])
@Index(['companyId', 'scheduledAt'])
@Index(['companyId', 'category'])
@Index(['companyId', 'priority'])
export class Announcement extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'created_by_user_id' })
  createdByUserId!: string;

  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'created_by_user_id' })
  createdByUser!: User;

  @Column({ type: 'text' })
  title!: string;

  @Column({ type: 'text' })
  message!: string;

  @Column({
    type: 'enum',
    enum: AnnouncementCategory,
    default: AnnouncementCategory.GENERAL,
  })
  category!: AnnouncementCategory;

  @Column({
    type: 'enum',
    enum: AnnouncementPriority,
    default: AnnouncementPriority.MEDIUM,
  })
  priority!: AnnouncementPriority;

  @Column({
    type: 'enum',
    enum: AnnouncementTargetAudience,
    name: 'target_audience',
  })
  targetAudience!: AnnouncementTargetAudience;

  @Column({ type: 'jsonb', name: 'target_roles', nullable: true })
  targetRoles!: string[] | null;

  @Column({ type: 'timestamptz', name: 'scheduled_at', nullable: true })
  scheduledAt!: Date | null;

  @Column({ type: 'timestamptz', name: 'expires_at', nullable: true })
  expiresAt!: Date | null;

  @Column({ type: 'boolean', name: 'is_published', default: false })
  isPublished!: boolean;

  @Column({ type: 'timestamptz', name: 'published_at', nullable: true })
  publishedAt!: Date | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @Column({ type: 'timestamptz', name: 'deleted_at', nullable: true })
  deletedAt!: Date | null;

  @OneToMany(() => AnnouncementRead, (read) => read.announcement, {
    cascade: true,
  })
  reads!: AnnouncementRead[];
}

