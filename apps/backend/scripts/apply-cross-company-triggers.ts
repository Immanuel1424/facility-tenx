import { DataSource } from 'typeorm';
import { typeOrmConfig } from '../src/shared/config/typeorm.config';

/**
 * Apply Cross-Company Data Integrity Triggers
 * 
 * PostgreSQL doesn't allow subqueries in CHECK constraints,
 * so we use BEFORE INSERT/UPDATE triggers to enforce cross-company integrity.
 */
async function main(): Promise<void> {
  const config = typeOrmConfig();
  const dataSource = new DataSource({
    ...config,
    type: 'postgres',
  } as any);

  try {
    await dataSource.initialize();
    console.log('✅ Database connection established\n');

    console.log('🔧 Creating cross-company integrity triggers...\n');

    // Drop existing triggers and functions
    await dropExistingTriggers(dataSource);

    // Create triggers for each table
    await createMaintenanceTicketTrigger(dataSource);
    await createTicketCommentTrigger(dataSource);
    await createTicketAttachmentTrigger(dataSource);
    await createTicketStatusHistoryTrigger(dataSource);
    await createTicketSlaTrigger(dataSource);

    // Verify triggers
    await verifyTriggers(dataSource);

    console.log('\n✅ All cross-company integrity triggers created successfully!');
    console.log('\n📝 These triggers will prevent:');
    console.log('   - Assigning users from different companies to tickets');
    console.log('   - Using departments/categories from different companies');
    console.log('   - Creating comments/attachments for tickets in different companies');
    console.log('   - Any other cross-company data violations at the database level\n');

  } catch (error) {
    console.error('❌ Error applying triggers:', error);
    process.exit(1);
  } finally {
    await dataSource.destroy();
  }
}

async function dropExistingTriggers(dataSource: DataSource): Promise<void> {
  console.log('1. Dropping existing triggers and functions...');

  const dropStatements = [
    'DROP TRIGGER IF EXISTS trg_maintenance_ticket_company_check ON maintenance_tickets',
    'DROP TRIGGER IF EXISTS trg_ticket_comment_company_check ON ticket_comments',
    'DROP TRIGGER IF EXISTS trg_ticket_attachment_company_check ON ticket_attachments',
    'DROP TRIGGER IF EXISTS trg_ticket_status_history_company_check ON ticket_status_history',
    'DROP TRIGGER IF EXISTS trg_ticket_sla_company_check ON ticket_sla',
    'DROP FUNCTION IF EXISTS fn_check_ticket_company_integrity() CASCADE',
    'DROP FUNCTION IF EXISTS fn_check_comment_company_integrity() CASCADE',
    'DROP FUNCTION IF EXISTS fn_check_attachment_company_integrity() CASCADE',
    'DROP FUNCTION IF EXISTS fn_check_status_history_company_integrity() CASCADE',
    'DROP FUNCTION IF EXISTS fn_check_ticket_sla_company_integrity() CASCADE',
  ];

  for (const sql of dropStatements) {
    try {
      await dataSource.query(sql);
    } catch (error) {
      // Ignore errors for non-existent objects
    }
  }

  console.log('   ✓ Existing triggers dropped\n');
}

async function tableExists(dataSource: DataSource, tableName: string): Promise<boolean> {
  const result = await dataSource.query(`
    SELECT EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = $1
    )
  `, [tableName]);
  return result[0]?.exists === true;
}

async function createMaintenanceTicketTrigger(dataSource: DataSource): Promise<void> {
  console.log('2. Creating maintenance_tickets trigger...');

  if (!await tableExists(dataSource, 'maintenance_tickets')) {
    console.log('   ⚠️ maintenance_tickets table does not exist yet (run migrations first)\n');
    return;
  }

  await dataSource.query(`
    CREATE OR REPLACE FUNCTION fn_check_ticket_company_integrity()
    RETURNS TRIGGER AS $$
    DECLARE
      v_user_company_id UUID;
      v_dept_company_id UUID;
      v_cat_company_id UUID;
    BEGIN
      -- Check created_by user belongs to same company
      IF NEW.created_by IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.created_by;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: created_by user (%) does not belong to ticket company (%)', 
            NEW.created_by, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      -- Check department belongs to same company
      IF NEW.department_id IS NOT NULL THEN
        SELECT company_id INTO v_dept_company_id FROM departments WHERE id = NEW.department_id;
        IF v_dept_company_id IS NULL OR v_dept_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: department (%) does not belong to ticket company (%)',
            NEW.department_id, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      -- Check category belongs to same company
      IF NEW.category_id IS NOT NULL THEN
        SELECT company_id INTO v_cat_company_id FROM ticket_categories WHERE id = NEW.category_id;
        IF v_cat_company_id IS NULL OR v_cat_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: category (%) does not belong to ticket company (%)',
            NEW.category_id, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      -- Check assigned_technician belongs to same company
      IF NEW.assigned_technician_id IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.assigned_technician_id;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: assigned_technician (%) does not belong to ticket company (%)',
            NEW.assigned_technician_id, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      -- Check assigned_supervisor belongs to same company
      IF NEW.assigned_supervisor_id IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.assigned_supervisor_id;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: assigned_supervisor (%) does not belong to ticket company (%)',
            NEW.assigned_supervisor_id, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      -- Check assigned_by belongs to same company
      IF NEW.assigned_by IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.assigned_by;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: assigned_by user (%) does not belong to ticket company (%)',
            NEW.assigned_by, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      -- Check acknowledged_by belongs to same company
      IF NEW.acknowledged_by IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.acknowledged_by;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: acknowledged_by user (%) does not belong to ticket company (%)',
            NEW.acknowledged_by, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
  `);

  await dataSource.query(`
    CREATE TRIGGER trg_maintenance_ticket_company_check
      BEFORE INSERT OR UPDATE ON maintenance_tickets
      FOR EACH ROW
      EXECUTE FUNCTION fn_check_ticket_company_integrity()
  `);

  console.log('   ✓ maintenance_tickets trigger created\n');
}

async function createTicketCommentTrigger(dataSource: DataSource): Promise<void> {
  console.log('3. Creating ticket_comments trigger...');

  if (!await tableExists(dataSource, 'ticket_comments')) {
    console.log('   ⚠️ ticket_comments table does not exist yet (run migrations first)\n');
    return;
  }

  await dataSource.query(`
    CREATE OR REPLACE FUNCTION fn_check_comment_company_integrity()
    RETURNS TRIGGER AS $$
    DECLARE
      v_ticket_company_id UUID;
      v_user_company_id UUID;
    BEGIN
      -- Check ticket belongs to same company
      SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
      IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
        RAISE EXCEPTION 'Cross-company violation: ticket (%) does not belong to comment company (%)',
          NEW.ticket_id, NEW.company_id
          USING ERRCODE = '23503';
      END IF;

      -- Check created_by user belongs to same company (if not null)
      IF NEW.created_by_id IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.created_by_id;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: comment creator (%) does not belong to comment company (%)',
            NEW.created_by_id, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
  `);

  await dataSource.query(`
    CREATE TRIGGER trg_ticket_comment_company_check
      BEFORE INSERT OR UPDATE ON ticket_comments
      FOR EACH ROW
      EXECUTE FUNCTION fn_check_comment_company_integrity()
  `);

  console.log('   ✓ ticket_comments trigger created\n');
}

async function createTicketAttachmentTrigger(dataSource: DataSource): Promise<void> {
  console.log('4. Creating ticket_attachments trigger...');

  if (!await tableExists(dataSource, 'ticket_attachments')) {
    console.log('   ⚠️ ticket_attachments table does not exist yet (run migrations first)\n');
    return;
  }

  await dataSource.query(`
    CREATE OR REPLACE FUNCTION fn_check_attachment_company_integrity()
    RETURNS TRIGGER AS $$
    DECLARE
      v_ticket_company_id UUID;
      v_user_company_id UUID;
    BEGIN
      -- Check ticket belongs to same company
      SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
      IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
        RAISE EXCEPTION 'Cross-company violation: ticket (%) does not belong to attachment company (%)',
          NEW.ticket_id, NEW.company_id
          USING ERRCODE = '23503';
      END IF;

      -- Check uploaded_by user belongs to same company
      IF NEW.uploaded_by_id IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.uploaded_by_id;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: attachment uploader (%) does not belong to attachment company (%)',
            NEW.uploaded_by_id, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
  `);

  await dataSource.query(`
    CREATE TRIGGER trg_ticket_attachment_company_check
      BEFORE INSERT OR UPDATE ON ticket_attachments
      FOR EACH ROW
      EXECUTE FUNCTION fn_check_attachment_company_integrity()
  `);

  console.log('   ✓ ticket_attachments trigger created\n');
}

async function createTicketStatusHistoryTrigger(dataSource: DataSource): Promise<void> {
  console.log('5. Creating ticket_status_history trigger...');

  if (!await tableExists(dataSource, 'ticket_status_history')) {
    console.log('   ⚠️ ticket_status_history table does not exist yet (run migrations first)\n');
    return;
  }

  await dataSource.query(`
    CREATE OR REPLACE FUNCTION fn_check_status_history_company_integrity()
    RETURNS TRIGGER AS $$
    DECLARE
      v_ticket_company_id UUID;
      v_user_company_id UUID;
    BEGIN
      -- Check ticket belongs to same company
      SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
      IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
        RAISE EXCEPTION 'Cross-company violation: ticket (%) does not belong to status history company (%)',
          NEW.ticket_id, NEW.company_id
          USING ERRCODE = '23503';
      END IF;

      -- Check changed_by user belongs to same company
      IF NEW.changed_by IS NOT NULL THEN
        SELECT company_id INTO v_user_company_id FROM users WHERE id = NEW.changed_by;
        IF v_user_company_id IS NULL OR v_user_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: status changer (%) does not belong to history company (%)',
            NEW.changed_by, NEW.company_id
            USING ERRCODE = '23503';
        END IF;
      END IF;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
  `);

  await dataSource.query(`
    CREATE TRIGGER trg_ticket_status_history_company_check
      BEFORE INSERT OR UPDATE ON ticket_status_history
      FOR EACH ROW
      EXECUTE FUNCTION fn_check_status_history_company_integrity()
  `);

  console.log('   ✓ ticket_status_history trigger created\n');
}

async function createTicketSlaTrigger(dataSource: DataSource): Promise<void> {
  console.log('6. Creating ticket_sla trigger...');

  if (!await tableExists(dataSource, 'ticket_sla')) {
    console.log('   ⚠️ ticket_sla table does not exist yet (run migrations first)\n');
    return;
  }

  try {
    await dataSource.query(`
      CREATE OR REPLACE FUNCTION fn_check_ticket_sla_company_integrity()
      RETURNS TRIGGER AS $$
      DECLARE
        v_ticket_company_id UUID;
        v_sla_config_company_id UUID;
      BEGIN
        -- Check ticket belongs to same company
        SELECT company_id INTO v_ticket_company_id FROM maintenance_tickets WHERE id = NEW.ticket_id;
        IF v_ticket_company_id IS NULL OR v_ticket_company_id != NEW.company_id THEN
          RAISE EXCEPTION 'Cross-company violation: ticket (%) does not belong to SLA company (%)',
            NEW.ticket_id, NEW.company_id
            USING ERRCODE = '23503';
        END IF;

        -- Check SLA configuration belongs to same company
        IF NEW.sla_configuration_id IS NOT NULL THEN
          SELECT company_id INTO v_sla_config_company_id FROM sla_configurations WHERE id = NEW.sla_configuration_id;
          IF v_sla_config_company_id IS NULL OR v_sla_config_company_id != NEW.company_id THEN
            RAISE EXCEPTION 'Cross-company violation: SLA configuration (%) does not belong to SLA company (%)',
              NEW.sla_configuration_id, NEW.company_id
              USING ERRCODE = '23503';
          END IF;
        END IF;

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql
    `);

    await dataSource.query(`
      CREATE TRIGGER trg_ticket_sla_company_check
        BEFORE INSERT OR UPDATE ON ticket_sla
        FOR EACH ROW
        EXECUTE FUNCTION fn_check_ticket_sla_company_integrity()
    `);

    console.log('   ✓ ticket_sla trigger created\n');
  } catch (error: any) {
    if (error.message?.includes('does not exist')) {
      console.log('   ⚠️ ticket_sla table does not exist yet (will be created by migration)\n');
    } else {
      throw error;
    }
  }
}

async function verifyTriggers(dataSource: DataSource): Promise<void> {
  console.log('7. Verifying triggers...\n');

  const result = await dataSource.query(`
    SELECT 
      tgname as trigger_name,
      tgrelid::regclass as table_name,
      CASE tgenabled 
        WHEN 'O' THEN 'enabled'
        WHEN 'D' THEN 'disabled'
        WHEN 'R' THEN 'replica'
        WHEN 'A' THEN 'always'
        ELSE 'unknown'
      END as status
    FROM pg_trigger 
    WHERE tgname LIKE 'trg_%company_check'
    ORDER BY tgrelid::regclass::text
  `);

  if (result.length === 0) {
    console.log('   ⚠️ No triggers found');
  } else {
    console.log('   Triggers created:');
    for (const row of result) {
      console.log(`   ✓ ${row.trigger_name} on ${row.table_name} [${row.status}]`);
    }
  }
}

main();

