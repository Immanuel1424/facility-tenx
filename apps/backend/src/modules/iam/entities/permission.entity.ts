import { Entity, Column, Index, OneToMany } from 'typeorm';
import { BaseEntity } from '../../../shared/database/base.entity';
import { RolePermission } from './role-permission.entity';

/**
 * Permissions are GLOBAL (not tenant-scoped).
 * Each permission represents an action on a resource (e.g., tickets:create, users:read).
 * The same permission definitions are shared across all companies.
 * Only role_permissions (the junction table) is tenant-scoped.
 */
@Entity('permissions')
@Index(['resource', 'action'], { unique: true })
export class Permission extends BaseEntity {
  @Column({ type: 'varchar', length: 100 })
  resource!: string;

  @Column({ type: 'varchar', length: 50 })
  action!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  /**
   * Category for grouping in UI (e.g., 'Tickets', 'Users', 'Reports')
   */
  @Column({ type: 'varchar', length: 50, nullable: true })
  category?: string;

  /**
   * Display order within category
   */
  @Column({ type: 'int', default: 0, name: 'display_order' })
  displayOrder!: number;

  @OneToMany(
    () => RolePermission,
    (rolePermission) => rolePermission.permission,
    { cascade: true },
  )
  rolePermissions!: RolePermission[];
}

