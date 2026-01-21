import {
  Entity,
  Column,
  Index,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';

@Entity('ticket_categories')
@Index(['companyId', 'code'], { unique: true })
@Index(['companyId', 'name'])
@Index(['companyId', 'parentCategoryId'])
export class TicketCategory extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 50 })
  code!: string;

  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'uuid', nullable: true, name: 'parent_category_id' })
  parentCategoryId?: string;

  @ManyToOne(() => TicketCategory, (category) => category.subCategories, {
    nullable: true,
  })
  @JoinColumn({ name: 'parent_category_id' })
  parentCategory?: TicketCategory;

  @OneToMany(() => TicketCategory, (category) => category.parentCategory)
  subCategories!: TicketCategory[];

  @Column({ type: 'int', default: 0, name: 'display_order' })
  displayOrder!: number;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  @Column({ type: 'varchar', length: 50, nullable: true })
  icon?: string;

  @Column({ type: 'varchar', length: 7, nullable: true, name: 'color_code' })
  colorCode?: string;

  @Column({ type: 'int', nullable: true, name: 'default_sla_hours' })
  defaultSlaHours?: number;

  @Column({ type: 'uuid', nullable: true, name: 'default_department_id' })
  defaultDepartmentId?: string;

  @Column({ type: 'uuid', nullable: true, name: 'created_by_id' })
  createdById?: string;
}

