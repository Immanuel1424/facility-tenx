import {
  Entity,
  Column,
  Index,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { RolePermission } from './role-permission.entity';
import { UserRole } from './user-role.entity';

@Entity('roles')
@Index(['companyId', 'name'], { unique: true })
export class Role extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'int', default: 0, name: 'hierarchy_level' })
  hierarchyLevel!: number;

  @Column({ type: 'uuid', nullable: true, name: 'parent_role_id' })
  parentRoleId?: string;

  @ManyToOne(() => Role, (role) => role.childRoles, { nullable: true })
  @JoinColumn({ name: 'parent_role_id' })
  parentRole?: Role;

  @OneToMany(() => Role, (role) => role.parentRole)
  childRoles!: Role[];

  @OneToMany(() => RolePermission, (rolePermission) => rolePermission.role, {
    cascade: true,
  })
  rolePermissions!: RolePermission[];

  @OneToMany(() => UserRole, (userRole) => userRole.role, { cascade: true })
  userRoles!: UserRole[];
}

