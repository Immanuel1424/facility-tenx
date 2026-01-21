import * as ExcelJS from 'exceljs';
import * as fs from 'fs';
import * as path from 'path';

interface ColumnInfo {
  columnName: string;
  dataType: string;
  constraints: string;
  defaultValue: string;
  indexes: string;
  relationships: string;
}

interface TableInfo {
  tableName: string;
  module: string;
  columns: ColumnInfo[];
  notes: string;
}

const tables: TableInfo[] = [
  // IAM Module
  {
    tableName: 'users',
    module: 'IAM',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'email', dataType: 'VARCHAR(255)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Unique (company_id, email)', relationships: '' },
      { columnName: 'password_hash', dataType: 'VARCHAR(255)', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'first_name', dataType: 'VARCHAR(100)', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'last_name', dataType: 'VARCHAR(100)', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'status', dataType: "ENUM('active', 'inactive', 'suspended')", constraints: 'NOT NULL', defaultValue: "'active'", indexes: '', relationships: '' },
      { columnName: 'auth_provider', dataType: "ENUM('local', 'azure_ad', 'okta', 'auth0', 'keycloak')", constraints: 'NOT NULL', defaultValue: "'local'", indexes: '', relationships: '' },
      { columnName: 'external_id', dataType: 'VARCHAR(255)', constraints: 'NULLABLE', defaultValue: '', indexes: 'Unique (company_id, external_id) WHERE external_id IS NOT NULL', relationships: '' },
      { columnName: 'provider_metadata', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'last_login_at', dataType: 'TIMESTAMP', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'One-to-Many → refresh_tokens, user_roles, acl_entries'
  },
  {
    tableName: 'roles',
    module: 'IAM',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'name', dataType: 'VARCHAR(100)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Unique (company_id, name)', relationships: '' },
      { columnName: 'description', dataType: 'TEXT', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'hierarchy_level', dataType: 'INT', constraints: 'NOT NULL', defaultValue: '0', indexes: '', relationships: '' },
      { columnName: 'parent_role_id', dataType: 'UUID', constraints: 'NULLABLE, FK → roles.id', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Many-to-One → parent_role (self), One-to-Many → child_roles, role_permissions, user_roles'
  },
  {
    tableName: 'permissions',
    module: 'IAM',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'resource', dataType: 'VARCHAR(100)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Unique (company_id, resource, action)', relationships: '' },
      { columnName: 'action', dataType: 'VARCHAR(50)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Unique (company_id, resource, action)', relationships: '' },
      { columnName: 'description', dataType: 'TEXT', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'One-to-Many → role_permissions'
  },
  {
    tableName: 'user_roles',
    module: 'IAM',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'user_id', dataType: 'UUID', constraints: 'NOT NULL, FK → users.id', defaultValue: '', indexes: 'Index (company_id, user_id)', relationships: '' },
      { columnName: 'role_id', dataType: 'UUID', constraints: 'NOT NULL, FK → roles.id', defaultValue: '', indexes: 'Index (company_id, role_id)', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Unique: (company_id, user_id, role_id). Many-to-One → user, role'
  },
  {
    tableName: 'role_permissions',
    module: 'IAM',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'role_id', dataType: 'UUID', constraints: 'NOT NULL, FK → roles.id', defaultValue: '', indexes: 'Index (company_id, role_id)', relationships: '' },
      { columnName: 'permission_id', dataType: 'UUID', constraints: 'NOT NULL, FK → permissions.id', defaultValue: '', indexes: 'Index (company_id, permission_id)', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Unique: (company_id, role_id, permission_id). Many-to-One → role, permission'
  },
  {
    tableName: 'acl_entries',
    module: 'IAM',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'resource_type', dataType: 'VARCHAR(100)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Index (company_id, resource_type, resource_id, user_id)', relationships: '' },
      { columnName: 'resource_id', dataType: 'UUID', constraints: 'NULLABLE', defaultValue: '', indexes: 'Index (company_id, resource_type, resource_id)', relationships: '' },
      { columnName: 'user_id', dataType: 'UUID', constraints: 'NULLABLE, FK → users.id', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'permission_id', dataType: 'UUID', constraints: 'NULLABLE, FK → permissions.id', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'effect', dataType: "ENUM('allow', 'deny')", constraints: 'NOT NULL', defaultValue: "'allow'", indexes: '', relationships: '' },
      { columnName: 'conditions', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Many-to-One → user (optional), permission (optional)'
  },
  {
    tableName: 'refresh_tokens',
    module: 'IAM',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'user_id', dataType: 'UUID', constraints: 'NOT NULL, FK → users.id', defaultValue: '', indexes: 'Index (company_id, user_id), Unique (company_id, token)', relationships: '' },
      { columnName: 'token', dataType: 'TEXT', constraints: 'NOT NULL', defaultValue: '', indexes: 'Unique (company_id, token)', relationships: '' },
      { columnName: 'expires_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'ip_address', dataType: 'VARCHAR(255)', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'user_agent', dataType: 'TEXT', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'revoked_at', dataType: 'TIMESTAMP', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Many-to-One → user (CASCADE delete)'
  },
  // Tenant Module
  {
    tableName: 'companies',
    module: 'Tenant',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'code', dataType: 'VARCHAR(100)', constraints: 'NOT NULL, UNIQUE', defaultValue: '', indexes: 'Unique (code)', relationships: '' },
      { columnName: 'name', dataType: 'VARCHAR(255)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'One-to-Many → sites'
  },
  {
    tableName: 'sites',
    module: 'Tenant',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'code', dataType: 'VARCHAR(100)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'name', dataType: 'VARCHAR(255)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'is_parent', dataType: 'BOOLEAN', constraints: 'NOT NULL', defaultValue: 'true', indexes: '', relationships: '' },
      { columnName: 'parent_site_id', dataType: 'UUID', constraints: 'NULLABLE, FK → sites.id', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Self-referential Many-to-One → parent site (nullable, when is_parent = false)'
  },
  {
    tableName: 'space_categories',
    module: 'Tenant',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'code', dataType: 'VARCHAR(5)', constraints: 'NOT NULL, UNIQUE', defaultValue: 'auto-generated from name', indexes: 'Index (code)', relationships: '' },
      { columnName: 'name', dataType: 'VARCHAR(255)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'description', dataType: 'TEXT', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'is_active', dataType: 'BOOLEAN', constraints: 'NOT NULL', defaultValue: 'true', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Reference data for categorizing spaces. Code is auto-generated from name (3-5 uppercase letters) if not provided, following same rules as site codes.'
  },
  // Hierarchy Module
  {
    tableName: 'hierarchy_nodes',
    module: 'Hierarchy',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'type', dataType: 'VARCHAR(100)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Index (company_id, type)', relationships: '' },
      { columnName: 'name', dataType: 'VARCHAR(255)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'external_id', dataType: 'VARCHAR(255)', constraints: 'NULLABLE', defaultValue: '', indexes: 'Index (company_id, external_id)', relationships: '' },
      { columnName: 'parent_id', dataType: 'UUID', constraints: 'NULLABLE, FK → hierarchy_nodes.id', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'metadata', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Many-to-One → parent (self, CASCADE delete), One-to-Many → children (self)'
  },
  // Service Request Module
  {
    tableName: 'service_requests',
    module: 'Service Request',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'request_number', dataType: 'VARCHAR(64)', constraints: 'NOT NULL, UNIQUE', defaultValue: '', indexes: 'Index, Unique', relationships: '' },
      { columnName: 'site_id', dataType: 'UUID', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'parent_request_id', dataType: 'UUID', constraints: 'NULLABLE, FK → service_requests.id', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'title', dataType: 'VARCHAR(255)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'description', dataType: 'TEXT', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'category', dataType: 'VARCHAR(64)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'status', dataType: 'VARCHAR(64)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Index', relationships: '' },
      { columnName: 'priority', dataType: 'VARCHAR(64)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'assigned_team_id', dataType: 'UUID', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'assigned_technician_id', dataType: 'UUID', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'sla_due_at', dataType: 'TIMESTAMP WITH TIME ZONE', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'is_escalated', dataType: 'BOOLEAN', constraints: 'NOT NULL', defaultValue: 'false', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Many-to-One → parent (self), One-to-Many → children (self), transitions'
  },
  {
    tableName: 'service_request_workflows',
    module: 'Service Request',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'name', dataType: 'VARCHAR(64)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'category', dataType: 'VARCHAR(64)', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'statuses', dataType: 'JSONB', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'transitions', dataType: 'JSONB', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'sla_rules', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Does not extend TenantBaseEntity'
  },
  {
    tableName: 'service_request_status_transitions',
    module: 'Service Request',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'service_request', dataType: 'Relationship', constraints: 'FK → service_requests.id, CASCADE delete', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'from_status', dataType: 'VARCHAR(64)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'to_status', dataType: 'VARCHAR(64)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'changed_by_user_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'changed_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'reason', dataType: 'TEXT', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
    ],
    notes: 'Does not extend TenantBaseEntity (no company_id)'
  },
  // Notification Module
  {
    tableName: 'notifications',
    module: 'Notification',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'recipient_user_id', dataType: 'UUID', constraints: 'NULLABLE', defaultValue: '', indexes: 'Index (company_id, recipient_user_id, created_at)', relationships: '' },
      { columnName: 'type', dataType: 'VARCHAR(128)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'severity', dataType: 'ENUM', constraints: 'NOT NULL', defaultValue: "'info'", indexes: '', relationships: '' },
      { columnName: 'title', dataType: 'VARCHAR(255)', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'message', dataType: 'TEXT', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'payload', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'is_read', dataType: 'BOOLEAN', constraints: 'NOT NULL', defaultValue: 'false', indexes: '', relationships: '' },
      { columnName: 'read_at', dataType: 'TIMESTAMP', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'channels', dataType: 'ENUM Array', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'One-to-Many → deliveries'
  },
  {
    tableName: 'notification_templates',
    module: 'Notification',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'code', dataType: 'VARCHAR(128)', constraints: 'NOT NULL', defaultValue: '', indexes: 'Unique (company_id, code, channel)', relationships: '' },
      { columnName: 'channel', dataType: 'ENUM', constraints: 'NOT NULL', defaultValue: '', indexes: 'Unique (company_id, code, channel)', relationships: '' },
      { columnName: 'subject', dataType: 'VARCHAR(255)', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'body', dataType: 'TEXT', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'default_variables', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: ''
  },
  {
    tableName: 'notification_deliveries',
    module: 'Notification',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'notification_id', dataType: 'UUID', constraints: 'NOT NULL, FK → notifications.id', defaultValue: '', indexes: 'Index (company_id, notification_id, channel)', relationships: '' },
      { columnName: 'channel', dataType: 'ENUM', constraints: 'NOT NULL', defaultValue: '', indexes: 'Index (company_id, notification_id, channel)', relationships: '' },
      { columnName: 'status', dataType: "ENUM('pending', 'success', 'failed', 'retrying')", constraints: 'NOT NULL', defaultValue: "'pending'", indexes: '', relationships: '' },
      { columnName: 'attempt_count', dataType: 'INT', constraints: 'NOT NULL', defaultValue: '0', indexes: '', relationships: '' },
      { columnName: 'last_error', dataType: 'TEXT', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: 'Many-to-One → notification (CASCADE delete)'
  },
  {
    tableName: 'notification_audit_logs',
    module: 'Notification',
    columns: [
      { columnName: 'id', dataType: 'UUID', constraints: 'PRIMARY KEY, NOT NULL', defaultValue: 'auto-generated', indexes: '', relationships: '' },
      { columnName: 'company_id', dataType: 'UUID', constraints: 'NOT NULL', defaultValue: '', indexes: 'Index (company_id, created_at)', relationships: '' },
      { columnName: 'event_type', dataType: 'VARCHAR(128)', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'severity', dataType: 'ENUM', constraints: 'NOT NULL', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'recipient_user_id', dataType: 'UUID', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'event_payload', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'metadata', dataType: 'JSONB', constraints: 'NULLABLE', defaultValue: '', indexes: '', relationships: '' },
      { columnName: 'created_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-generated', indexes: 'Index (company_id, created_at)', relationships: '' },
      { columnName: 'updated_at', dataType: 'TIMESTAMP', constraints: 'NOT NULL', defaultValue: 'auto-updated', indexes: '', relationships: '' },
    ],
    notes: ''
  },
];

async function exportToExcel() {
  const workbook = new ExcelJS.Workbook();
  
  // Create summary sheet
  const summarySheet = workbook.addWorksheet('Summary');
  summarySheet.columns = [
    { header: 'Table Name', key: 'tableName', width: 30 },
    { header: 'Module', key: 'module', width: 20 },
    { header: 'Column Count', key: 'columnCount', width: 15 },
    { header: 'Notes', key: 'notes', width: 50 },
  ];
  
  summarySheet.getRow(1).font = { bold: true };
  summarySheet.getRow(1).fill = {
    type: 'pattern',
    pattern: 'solid',
    fgColor: { argb: 'FF4472C4' },
  };
  summarySheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
  
  tables.forEach((table) => {
    summarySheet.addRow({
      tableName: table.tableName,
      module: table.module,
      columnCount: table.columns.length,
      notes: table.notes,
    });
  });
  
  // Create a sheet for each table
  tables.forEach((table) => {
    const sheet = workbook.addWorksheet(`${table.module} - ${table.tableName}`);
    
    // Add table info header
    sheet.addRow(['Table Name:', table.tableName]);
    sheet.addRow(['Module:', table.module]);
    sheet.addRow(['Notes:', table.notes]);
    sheet.addRow([]);
    
    // Add column headers
    sheet.addRow(['Column Name', 'Data Type', 'Constraints', 'Default Value', 'Indexes', 'Relationships']);
    const headerRow = sheet.getRow(sheet.rowCount);
    headerRow.font = { bold: true };
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF4472C4' },
    };
    headerRow.font = { bold: true, color: { argb: 'FFFFFFFF' } };
    
    // Add columns
    table.columns.forEach((column) => {
      sheet.addRow([
        column.columnName,
        column.dataType,
        column.constraints,
        column.defaultValue,
        column.indexes,
        column.relationships,
      ]);
    });
    
    // Auto-fit columns
    sheet.columns.forEach((column) => {
      column.width = 25;
    });
    
    // Freeze header row
    sheet.views = [{ state: 'frozen', ySplit: 5 }];
  });
  
  // Save the file
  const outputPath = path.join(__dirname, '../database-schema.xlsx');
  await workbook.xlsx.writeFile(outputPath);
  console.log(`✅ Database schema exported to: ${outputPath}`);
}

// Run the export
exportToExcel().catch(console.error);

