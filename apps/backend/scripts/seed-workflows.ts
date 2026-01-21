import { DataSource, IsNull } from 'typeorm';
import { ServiceRequestWorkflow } from '../src/modules/service-request/entities/service-request-workflow.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';

/**
 * Seeds default service request workflows for all companies.
 * This is required before service requests can be created.
 */
async function seedWorkflows() {
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || '5432'),
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'facility_erp',
    entities: [ServiceRequestWorkflow, Company],
    synchronize: false,
  });

  try {
    await dataSource.initialize();
    console.log('✅ Database connected\n');

    const companyRepo = dataSource.getRepository(Company);
    const workflowRepo = dataSource.getRepository(ServiceRequestWorkflow);

    // Fetch all companies
    const companies = await companyRepo.find();
    console.log(`📋 Found ${companies.length} companies\n`);

    if (companies.length === 0) {
      console.log('⚠️  No companies found. Please seed companies first.');
      return;
    }

    let createdCount = 0;
    let skippedCount = 0;

    for (const company of companies) {
      const companyId = company.companyId;
      console.log(`🏢 Processing company: ${company.name} (${companyId})`);

      // Check if a global workflow already exists for this company
      const existingWorkflow = await workflowRepo.findOne({
        where: { companyId, category: IsNull() },
      });

      if (existingWorkflow) {
        console.log(`   ⏭️  Default workflow already exists, skipping.`);
        skippedCount++;
        continue;
      }

      // Create a default global workflow for service requests
      const defaultWorkflow = workflowRepo.create({
        companyId,
        name: 'Default Workflow',
        category: null, // Global workflow for all categories
        statuses: [
          { code: 'open', label: 'Open', color: '#4caf50' },
          { code: 'in_progress', label: 'In Progress', color: '#2196f3' },
          { code: 'on_hold', label: 'On Hold', color: '#ff9800' },
          { code: 'completed', label: 'Completed', color: '#8bc34a' },
          { code: 'cancelled', label: 'Cancelled', color: '#f44336' },
        ],
        transitions: [
          { from: 'open', to: 'in_progress' },
          { from: 'open', to: 'on_hold' },
          { from: 'open', to: 'cancelled' },
          { from: 'in_progress', to: 'on_hold' },
          { from: 'in_progress', to: 'completed' },
          { from: 'in_progress', to: 'cancelled' },
          { from: 'on_hold', to: 'in_progress' },
          { from: 'on_hold', to: 'cancelled' },
        ],
        slaRules: [
          { matcher: 'priority=low', slaHours: 72, warnBeforeHours: 24 },
          { matcher: 'priority=medium', slaHours: 48, warnBeforeHours: 12 },
          { matcher: 'priority=high', slaHours: 24, warnBeforeHours: 6 },
          { matcher: 'priority=urgent', slaHours: 4, warnBeforeHours: 1 },
        ],
      });

      await workflowRepo.save(defaultWorkflow);
      console.log(`   ✅ Created default workflow for ${company.name}`);
      createdCount++;
    }

    console.log('\n' + '='.repeat(50));
    console.log(`📊 Summary:`);
    console.log(`   Created: ${createdCount}`);
    console.log(`   Skipped: ${skippedCount}`);
    console.log('='.repeat(50));
    console.log('\n✅ Workflow seeding completed!');
    console.log('You can now create service requests for these companies.\n');

  } catch (error) {
    console.error('❌ Error seeding workflows:', error);
    throw error;
  } finally {
    await dataSource.destroy();
  }
}

seedWorkflows()
  .then(() => process.exit(0))
  .catch(() => process.exit(1));

