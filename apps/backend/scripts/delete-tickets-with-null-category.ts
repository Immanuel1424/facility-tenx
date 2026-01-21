import { DataSource, IsNull } from 'typeorm';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || '5432'),
  username: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'facility_erp',
  entities: [__dirname + '/../src/**/*.entity.{ts,js}'],
  synchronize: false,
});

async function deleteTicketsWithNullCategory() {
  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const ticketRepo = dataSource.getRepository(MaintenanceTicket);

    // First, count tickets that will be deleted
    const ticketsToDelete = await ticketRepo.count({
      where: { categoryId: IsNull() },
    });

    console.log(`📊 Found ${ticketsToDelete} tickets with NULL category_id\n`);

    if (ticketsToDelete === 0) {
      console.log('✅ No tickets to delete. Exiting...\n');
      await dataSource.destroy();
      process.exit(0);
    }

    // Handle child tickets: Set parent_ticket_id to NULL for child tickets whose parent will be deleted
    const ticketsWithNullCategory = await ticketRepo.find({
      where: { categoryId: IsNull() },
      select: ['id'],
    });

    const parentTicketIds = ticketsWithNullCategory.map((t) => t.id);

    if (parentTicketIds.length > 0) {
      // Use raw SQL to set NULL values (TypeORM query builder has issues with null in set())
      await dataSource.query(
        `UPDATE maintenance_tickets 
         SET parent_ticket_id = NULL 
         WHERE parent_ticket_id = ANY($1::uuid[])`,
        [parentTicketIds],
      );

      console.log(
        `🔄 Updated child tickets (removed parent reference)\n`,
      );
    }

    // Delete tickets where category_id is NULL
    // Note: Related records (status_history, comments, attachments) will be cascade deleted
    const deleteResult = await ticketRepo
      .createQueryBuilder()
      .delete()
      .from(MaintenanceTicket)
      .where('category_id IS NULL')
      .execute();

    console.log(`✅ Deleted ${deleteResult.affected || 0} tickets with NULL category_id\n`);

    // Verify deletion
    const remainingCount = await ticketRepo.count({
      where: { categoryId: IsNull() },
    });

    if (remainingCount === 0) {
      console.log('✅ Verification: No tickets with NULL category_id remain\n');
    } else {
      console.log(
        `⚠️  Warning: ${remainingCount} tickets with NULL category_id still exist\n`,
      );
    }

    await dataSource.destroy();
    console.log('✅ Script completed successfully!');
  } catch (error) {
    console.error('❌ Error:', error);
    if (dataSource.isInitialized) {
      await dataSource.destroy();
    }
    process.exit(1);
  }
}

deleteTicketsWithNullCategory();

