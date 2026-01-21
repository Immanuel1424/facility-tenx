import {
  Column,
  Entity,
  Index,
  ManyToOne,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { Site } from './site.entity';
import { SpaceCategory } from './space-category.entity';

@Entity({ name: 'spaces' })
@Index(['companyId', 'code'])
@Index(['companyId', 'siteId'])
export class Space extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  code!: string;

  @Column({ type: 'varchar', length: 255 })
  name!: string;

  @Column({ type: 'uuid', nullable: true, name: 'site_id' })
  siteId?: string;

  @ManyToOne(() => Site, { nullable: true })
  site?: Site;

  @Column({ type: 'uuid', nullable: true, name: 'space_category_id' })
  spaceCategoryId?: string;

  @ManyToOne(() => SpaceCategory, { nullable: true })
  spaceCategory?: SpaceCategory;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;
}

