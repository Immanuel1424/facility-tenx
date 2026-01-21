import { Entity, Column, Index, ManyToOne, JoinColumn } from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { User } from './user.entity';
import { Permission } from './permission.entity';

export enum AclEffect {
  ALLOW = 'allow',
  DENY = 'deny',
}

@Entity('acl_entries')
@Index(['companyId', 'resourceType', 'resourceId', 'userId'])
@Index(['companyId', 'resourceType', 'resourceId'])
export class AclEntry extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100, name: 'resource_type' })
  resourceType!: string;

  @Column({ type: 'uuid', nullable: true, name: 'resource_id' })
  resourceId?: string;

  @Column({ type: 'uuid', nullable: true, name: 'user_id' })
  userId?: string;

  @Column({ type: 'uuid', nullable: true, name: 'permission_id' })
  permissionId?: string;

  @Column({
    type: 'enum',
    enum: AclEffect,
    default: AclEffect.ALLOW,
  })
  effect!: AclEffect;

  @Column({ type: 'jsonb', nullable: true })
  conditions?: Record<string, unknown>;

  @ManyToOne(() => User, (user) => user.aclEntries, { nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: User;

  @ManyToOne(() => Permission, { nullable: true })
  @JoinColumn({ name: 'permission_id' })
  permission?: Permission;
}

