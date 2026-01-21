import { DataSource } from 'typeorm';
import { Role } from '../src/modules/iam/entities/role.entity';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { UserRole } from '../src/modules/iam/entities/user-role.entity';

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

async function listRoles() {
  try {
    await dataSource.initialize();
    console.log('Connected to database\n');

    const roleRepo = dataSource.getRepository(Role);
    const companyRepo = dataSource.getRepository(Company);
    const userRoleRepo = dataSource.getRepository(UserRole);

    // Get all companies
    const companies = await companyRepo.find();
    console.log(`Found ${companies.length} company(ies)\n`);

    // List roles per company
    for (const company of companies) {
      console.log(`Company: ${company.name} (ID: ${company.id})`);
      console.log('='.repeat(60));

      const roles = await roleRepo.find({
        where: { companyId: company.id },
        order: { hierarchyLevel: 'DESC', name: 'ASC' },
      });

      if (roles.length === 0) {
        console.log('  No roles found\n');
        continue;
      }

      console.log(`\nTotal Roles: ${roles.length}\n`);

      for (const role of roles) {
        // Count users with this role
        const userCount = await userRoleRepo.count({
          where: { companyId: company.id, roleId: role.id },
        });

        console.log(`  Role: ${role.name}`);
        console.log(`    Description: ${role.description || 'N/A'}`);
        console.log(`    Hierarchy Level: ${role.hierarchyLevel}`);
        console.log(`    Users with this role: ${userCount}`);
        if (role.parentRoleId) {
          console.log(`    Parent Role ID: ${role.parentRoleId}`);
        }
        console.log('');
      }

      console.log('');
    }

    // Overall summary
    const allRoles = await roleRepo.find({
      order: { hierarchyLevel: 'DESC', name: 'ASC' },
    });

    const uniqueRoleNames = [...new Set(allRoles.map((r) => r.name))].sort();

    console.log('='.repeat(60));
    console.log('OVERALL SUMMARY:');
    console.log('='.repeat(60));
    console.log(`Total roles across all companies: ${allRoles.length}`);
    console.log(`Unique role names: ${uniqueRoleNames.length}`);
    console.log(`\nUnique role names:`);
    uniqueRoleNames.forEach((name) => {
      const count = allRoles.filter((r) => r.name === name).length;
      console.log(`  - ${name} (${count} instance${count > 1 ? 's' : ''})`);
    });
    console.log('='.repeat(60));

    await dataSource.destroy();
  } catch (error) {
    console.error('Error listing roles:', error);
    process.exit(1);
  }
}

listRoles();

