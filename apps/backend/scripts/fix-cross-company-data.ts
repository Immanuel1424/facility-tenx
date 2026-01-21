import { DataSource } from 'typeorm';
import { config } from 'dotenv';

config();

/**
 * Script to fix cross-company data violations
 * 
 * This script:
 * 1. Identifies records with mismatched company_id in foreign key relationships
 * 2. Fixes or removes invalid cross-company references
 * 3. Adds database constraints to prevent future violations
 */

async function fixCrossCompanyData() {
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || '5432'),
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'facility_erp',
    synchronize: false,
    logging: true,
  });

  try {
    await dataSource.initialize();
    console.log('✅ Database connection established');

    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();

    console.log('\n🔍 Checking for cross-company data violations...\n');

    // 1. Fix maintenance_tickets with invalid created_by users
    console.log('1. Fixing maintenance_tickets with invalid created_by users...');
    const invalidCreatorTickets = await queryRunner.query(`
      SELECT t.id, t.company_id, t.created_by, u.company_id as user_company_id
      FROM maintenance_tickets t
      LEFT JOIN users u ON t.created_by = u.id
      WHERE u.company_id IS NULL OR u.company_id != t.company_id
    `);
    console.log(`   Found ${invalidCreatorTickets.length} tickets with invalid creators`);
    if (invalidCreatorTickets.length > 0) {
      // Find valid users for each company
      for (const ticket of invalidCreatorTickets) {
        const validUser = await queryRunner.query(`
          SELECT id FROM users 
          WHERE company_id = $1 
          ORDER BY created_at ASC 
          LIMIT 1
        `, [ticket.company_id]);
        
        if (validUser.length > 0) {
          await queryRunner.query(`
            UPDATE maintenance_tickets 
            SET created_by = $1 
            WHERE id = $2
          `, [validUser[0].id, ticket.id]);
          console.log(`   ✅ Fixed ticket ${ticket.id} - assigned to user ${validUser[0].id}`);
        } else {
          console.log(`   ⚠️  No valid user found for ticket ${ticket.id}, marking for deletion`);
          // Delete ticket if no valid user exists
          await queryRunner.query(`DELETE FROM maintenance_tickets WHERE id = $1`, [ticket.id]);
        }
      }
    }

    // 2. Fix maintenance_tickets with invalid department_id
    console.log('\n2. Fixing maintenance_tickets with invalid department_id...');
    const invalidDeptTickets = await queryRunner.query(`
      SELECT t.id, t.company_id, t.department_id, d.company_id as dept_company_id
      FROM maintenance_tickets t
      LEFT JOIN departments d ON t.department_id = d.id
      WHERE t.department_id IS NOT NULL 
        AND (d.company_id IS NULL OR d.company_id != t.company_id)
    `);
    console.log(`   Found ${invalidDeptTickets.length} tickets with invalid departments`);
    if (invalidDeptTickets.length > 0) {
      for (const ticket of invalidDeptTickets) {
        await queryRunner.query(`
          UPDATE maintenance_tickets 
          SET department_id = NULL 
          WHERE id = $1
        `, [ticket.id]);
        console.log(`   ✅ Removed invalid department from ticket ${ticket.id}`);
      }
    }

    // 3. Fix maintenance_tickets with invalid category_id
    console.log('\n3. Fixing maintenance_tickets with invalid category_id...');
    const invalidCategoryTickets = await queryRunner.query(`
      SELECT t.id, t.company_id, t.category_id, c.company_id as cat_company_id
      FROM maintenance_tickets t
      LEFT JOIN ticket_categories c ON t.category_id = c.id
      WHERE t.category_id IS NOT NULL 
        AND (c.company_id IS NULL OR c.company_id != t.company_id)
    `);
    console.log(`   Found ${invalidCategoryTickets.length} tickets with invalid categories`);
    if (invalidCategoryTickets.length > 0) {
      for (const ticket of invalidCategoryTickets) {
        await queryRunner.query(`
          UPDATE maintenance_tickets 
          SET category_id = NULL 
          WHERE id = $1
        `, [ticket.id]);
        console.log(`   ✅ Removed invalid category from ticket ${ticket.id}`);
      }
    }

    // 4. Fix maintenance_tickets with invalid assigned users
    console.log('\n4. Fixing maintenance_tickets with invalid assigned users...');
    const invalidAssignedTickets = await queryRunner.query(`
      SELECT t.id, t.company_id, 
             t.assigned_technician_id, 
             t.assigned_supervisor_id,
             t.assigned_by,
             t.acknowledged_by,
             u1.company_id as tech_company_id,
             u2.company_id as supervisor_company_id,
             u3.company_id as assigner_company_id,
             u4.company_id as acknowledger_company_id
      FROM maintenance_tickets t
      LEFT JOIN users u1 ON t.assigned_technician_id = u1.id
      LEFT JOIN users u2 ON t.assigned_supervisor_id = u2.id
      LEFT JOIN users u3 ON t.assigned_by = u3.id
      LEFT JOIN users u4 ON t.acknowledged_by = u4.id
      WHERE (
        (t.assigned_technician_id IS NOT NULL AND (u1.company_id IS NULL OR u1.company_id != t.company_id)) OR
        (t.assigned_supervisor_id IS NOT NULL AND (u2.company_id IS NULL OR u2.company_id != t.company_id)) OR
        (t.assigned_by IS NOT NULL AND (u3.company_id IS NULL OR u3.company_id != t.company_id)) OR
        (t.acknowledged_by IS NOT NULL AND (u4.company_id IS NULL OR u4.company_id != t.company_id))
      )
    `);
    console.log(`   Found ${invalidAssignedTickets.length} tickets with invalid assigned users`);
    if (invalidAssignedTickets.length > 0) {
      for (const ticket of invalidAssignedTickets) {
        const updates: string[] = [];
        const params: any[] = [];
        let paramIndex = 1;

        if (ticket.tech_company_id !== ticket.company_id) {
          updates.push(`assigned_technician_id = NULL`);
        }
        if (ticket.supervisor_company_id !== ticket.company_id) {
          updates.push(`assigned_supervisor_id = NULL`);
        }
        if (ticket.assigner_company_id !== ticket.company_id) {
          updates.push(`assigned_by = NULL`);
        }
        if (ticket.acknowledger_company_id !== ticket.company_id) {
          updates.push(`acknowledged_by = NULL`);
        }

        if (updates.length > 0) {
          await queryRunner.query(`
            UPDATE maintenance_tickets 
            SET ${updates.join(', ')} 
            WHERE id = $${paramIndex}
          `, [ticket.id]);
          console.log(`   ✅ Fixed ticket ${ticket.id} - cleared invalid assignments`);
        }
      }
    }

    // 5. Fix ticket_comments with invalid users or tickets
    console.log('\n5. Fixing ticket_comments with invalid users or tickets...');
    const invalidComments = await queryRunner.query(`
      SELECT c.id, c.company_id, c.ticket_id, c.created_by_id,
             t.company_id as ticket_company_id,
             u.company_id as user_company_id
      FROM ticket_comments c
      LEFT JOIN maintenance_tickets t ON c.ticket_id = t.id
      LEFT JOIN users u ON c.created_by_id = u.id
      WHERE t.company_id IS NULL OR t.company_id != c.company_id 
         OR u.company_id IS NULL OR u.company_id != c.company_id
    `);
    console.log(`   Found ${invalidComments.length} comments with invalid references`);
    if (invalidComments.length > 0) {
      for (const comment of invalidComments) {
        await queryRunner.query(`DELETE FROM ticket_comments WHERE id = $1`, [comment.id]);
        console.log(`   ✅ Deleted invalid comment ${comment.id}`);
      }
    }

    // 6. Fix ticket_attachments with invalid users or tickets
    console.log('\n6. Fixing ticket_attachments with invalid users or tickets...');
    const invalidAttachments = await queryRunner.query(`
      SELECT a.id, a.company_id, a.ticket_id, a.uploaded_by_id,
             t.company_id as ticket_company_id,
             u.company_id as user_company_id
      FROM ticket_attachments a
      LEFT JOIN maintenance_tickets t ON a.ticket_id = t.id
      LEFT JOIN users u ON a.uploaded_by_id = u.id
      WHERE t.company_id IS NULL OR t.company_id != a.company_id 
         OR u.company_id IS NULL OR u.company_id != a.company_id
    `);
    console.log(`   Found ${invalidAttachments.length} attachments with invalid references`);
    if (invalidAttachments.length > 0) {
      for (const attachment of invalidAttachments) {
        await queryRunner.query(`DELETE FROM ticket_attachments WHERE id = $1`, [attachment.id]);
        console.log(`   ✅ Deleted invalid attachment ${attachment.id}`);
      }
    }

    // 7. Fix ticket_status_history with invalid users or tickets
    console.log('\n7. Fixing ticket_status_history with invalid users or tickets...');
    const invalidHistory = await queryRunner.query(`
      SELECT h.id, h.company_id, h.ticket_id, h.changed_by,
             t.company_id as ticket_company_id,
             u.company_id as user_company_id
      FROM ticket_status_history h
      LEFT JOIN maintenance_tickets t ON h.ticket_id = t.id
      LEFT JOIN users u ON h.changed_by = u.id
      WHERE t.company_id IS NULL OR t.company_id != h.company_id 
         OR u.company_id IS NULL OR u.company_id != h.company_id
    `);
    console.log(`   Found ${invalidHistory.length} status history records with invalid references`);
    if (invalidHistory.length > 0) {
      for (const history of invalidHistory) {
        await queryRunner.query(`DELETE FROM ticket_status_history WHERE id = $1`, [history.id]);
        console.log(`   ✅ Deleted invalid status history ${history.id}`);
      }
    }

    console.log('\n✅ Cross-company data fix completed!\n');

    // 8. Add database constraints to prevent future violations
    console.log('8. Adding database constraints to prevent future violations...\n');
    
    try {
      // Constraint: Ensure ticket.created_by user belongs to same company
      await queryRunner.query(`
        ALTER TABLE maintenance_tickets
        ADD CONSTRAINT fk_ticket_creator_company_check
        CHECK (
          created_by IS NULL OR 
          EXISTS (
            SELECT 1 FROM users u 
            WHERE u.id = maintenance_tickets.created_by 
            AND u.company_id = maintenance_tickets.company_id
          )
        )
      `);
      console.log('   ✅ Added constraint: ticket.created_by company check');
    } catch (error: any) {
      if (error.message.includes('already exists')) {
        console.log('   ⚠️  Constraint fk_ticket_creator_company_check already exists');
      } else {
        console.log(`   ⚠️  Could not add constraint: ${error.message}`);
      }
    }

    try {
      // Constraint: Ensure ticket.department belongs to same company
      await queryRunner.query(`
        ALTER TABLE maintenance_tickets
        ADD CONSTRAINT fk_ticket_department_company_check
        CHECK (
          department_id IS NULL OR 
          EXISTS (
            SELECT 1 FROM departments d 
            WHERE d.id = maintenance_tickets.department_id 
            AND d.company_id = maintenance_tickets.company_id
          )
        )
      `);
      console.log('   ✅ Added constraint: ticket.department company check');
    } catch (error: any) {
      if (error.message.includes('already exists')) {
        console.log('   ⚠️  Constraint fk_ticket_department_company_check already exists');
      } else {
        console.log(`   ⚠️  Could not add constraint: ${error.message}`);
      }
    }

    try {
      // Constraint: Ensure ticket.category belongs to same company
      await queryRunner.query(`
        ALTER TABLE maintenance_tickets
        ADD CONSTRAINT fk_ticket_category_company_check
        CHECK (
          category_id IS NULL OR 
          EXISTS (
            SELECT 1 FROM ticket_categories c 
            WHERE c.id = maintenance_tickets.category_id 
            AND c.company_id = maintenance_tickets.company_id
          )
        )
      `);
      console.log('   ✅ Added constraint: ticket.category company check');
    } catch (error: any) {
      if (error.message.includes('already exists')) {
        console.log('   ⚠️  Constraint fk_ticket_category_company_check already exists');
      } else {
        console.log(`   ⚠️  Could not add constraint: ${error.message}`);
      }
    }

    await queryRunner.release();
    await dataSource.destroy();
    console.log('\n✅ Script completed successfully!\n');
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

fixCrossCompanyData();

