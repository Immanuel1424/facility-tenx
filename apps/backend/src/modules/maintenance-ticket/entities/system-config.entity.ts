import { Entity, Column, Index } from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';

@Entity('system_config')
@Index(['companyId', 'key'], { unique: true })
export class SystemConfig extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  key!: string;

  @Column({ type: 'text' })
  value!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  type?: string; // 'string', 'number', 'boolean', 'json'
}
