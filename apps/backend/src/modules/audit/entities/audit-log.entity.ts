import {
  Entity,
  Column,
  Index,
  CreateDateColumn,
  PrimaryGeneratedColumn,
} from 'typeorm';

export enum AuditAction {
  CREATE = 'CREATE',
  READ = 'READ',
  UPDATE = 'UPDATE',
  DELETE = 'DELETE',
  LOGIN = 'LOGIN',
  LOGOUT = 'LOGOUT',
  LOGIN_FAILED = 'LOGIN_FAILED',
  ASSIGN = 'ASSIGN',
  STATUS_CHANGE = 'STATUS_CHANGE',
  EXPORT = 'EXPORT',
  IMPORT = 'IMPORT',
  PASSWORD_RESET = 'PASSWORD_RESET',
  PERMISSION_CHANGE = 'PERMISSION_CHANGE',
  ROLE_CHANGE = 'ROLE_CHANGE',
}

export enum AuditResourceType {
  USER = 'USER',
  ROLE = 'ROLE',
  PERMISSION = 'PERMISSION',
  TICKET = 'TICKET',
  COMMENT = 'COMMENT',
  ATTACHMENT = 'ATTACHMENT',
  CATEGORY = 'CATEGORY',
  DEPARTMENT = 'DEPARTMENT',
  SLA_CONFIG = 'SLA_CONFIG',
  VILLA = 'VILLA',
  COMPANY = 'COMPANY',
  SESSION = 'SESSION',
  NOTIFICATION = 'NOTIFICATION',
}

@Entity('audit_logs')
@Index(['companyId', 'createdAt'])
@Index(['companyId', 'userId'])
@Index(['companyId', 'resourceType'])
@Index(['companyId', 'action'])
@Index(['companyId', 'resourceId'])
export class AuditLog {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'company_id' })
  companyId!: string;

  @Column({ type: 'uuid', nullable: true, name: 'user_id' })
  userId?: string;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'user_email' })
  userEmail?: string;

  @Column({
    type: 'enum',
    enum: AuditAction,
  })
  action!: AuditAction;

  @Column({
    type: 'enum',
    enum: AuditResourceType,
    name: 'resource_type',
  })
  resourceType!: AuditResourceType;

  @Column({ type: 'uuid', nullable: true, name: 'resource_id' })
  resourceId?: string;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'resource_name' })
  resourceName?: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'jsonb', nullable: true, name: 'old_values' })
  oldValues?: Record<string, unknown>;

  @Column({ type: 'jsonb', nullable: true, name: 'new_values' })
  newValues?: Record<string, unknown>;

  @Column({ type: 'jsonb', nullable: true, name: 'changed_fields' })
  changedFields?: string[];

  @Column({ type: 'varchar', length: 45, nullable: true, name: 'ip_address' })
  ipAddress?: string;

  @Column({ type: 'text', nullable: true, name: 'user_agent' })
  userAgent?: string;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'request_path' })
  requestPath?: string;

  @Column({ type: 'varchar', length: 10, nullable: true, name: 'request_method' })
  requestMethod?: string;

  @Column({ type: 'int', nullable: true, name: 'response_status' })
  responseStatus?: number;

  @Column({ type: 'int', nullable: true, name: 'duration_ms' })
  durationMs?: number;

  @Column({ type: 'boolean', default: false, name: 'is_success' })
  isSuccess!: boolean;

  @Column({ type: 'text', nullable: true, name: 'error_message' })
  errorMessage?: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}

