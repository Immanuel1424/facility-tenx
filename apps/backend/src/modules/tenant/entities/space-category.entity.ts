import { Column, Entity, Index } from 'typeorm';
import { BaseEntity } from '../../../shared/database/base.entity';

@Entity({ name: 'space_categories' })
@Index(['code'], { unique: true })
export class SpaceCategory extends BaseEntity {
  @Column({ type: 'varchar', length: 5, unique: true })
  code!: string;

  @Column({ type: 'varchar', length: 255 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'boolean', name: 'is_active', default: true })
  isActive!: boolean;
}

