import {
  Column,
  Entity,
  Index,
  Unique,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';

@Entity({ name: 'holidays' })
@Unique(['companyId', 'holidayDate'])
@Index(['companyId', 'holidayDate'])
export class Holiday extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'date', name: 'holiday_date' })
  holidayDate!: Date;

  @Column({ type: 'text', nullable: true })
  description?: string;

  /**
   * If true, this holiday recurs every year on the same date.
   * Useful for fixed holidays like Christmas, New Year, etc.
   */
  @Column({ type: 'boolean', default: false, name: 'is_recurring' })
  isRecurring!: boolean;

  /**
   * If true, this holiday applies to all sites.
   * If false, use site_ids to specify which sites observe this holiday.
   */
  @Column({ type: 'boolean', default: true, name: 'applies_to_all_sites' })
  appliesToAllSites!: boolean;

  /**
   * Array of site IDs this holiday applies to (when applies_to_all_sites is false)
   */
  @Column({ type: 'uuid', array: true, nullable: true, name: 'site_ids' })
  siteIds?: string[];

  /**
   * Holiday type for categorization (e.g., 'NATIONAL', 'RELIGIOUS', 'COMPANY')
   */
  @Column({ type: 'varchar', length: 50, nullable: true, name: 'holiday_type' })
  holidayType?: string;
}

