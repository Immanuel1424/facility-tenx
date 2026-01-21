import { DataSource } from 'typeorm';
import { Role } from '../src/modules/iam/entities/role.entity';
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

async function migrateTechnicianRoles() {
  try {
    await dataSource.initialize();
    console.log('Connected to database');

    const roleRepo = dataSource.getRepository(Role);
    const userRoleRepo = dataSource.getRepository(UserRole);

    // Get all companies
    const companies = await dataSource.query('SELECT DISTINCT company_id FROM roles');
    console.log(`\nFound ${companies.length} company(ies)\n`);

    for (const company of companies) {
      const companyId = company.company_id;
      console.log(`Processing company: ${companyId}`);

      // Find TECHNICIAN_1 and TECHNICIAN_2 roles
      const technician1Role = await roleRepo.findOne({
        where: { companyId, name: 'TECHNICIAN_1' },
      });
      const technician2Role = await roleRepo.findOne({
        where: { companyId, name: 'TECHNICIAN_2' },
      });

      // Find or create TECHNICIAN role
      let technicianRole = await roleRepo.findOne({
        where: { companyId, name: 'TECHNICIAN' },
      });

      if (!technicianRole) {
        // Create TECHNICIAN role if it doesn't exist
        technicianRole = roleRepo.create({
          companyId,
          name: 'TECHNICIAN',
          description: 'Technician - Update assigned tickets, add work notes',
          hierarchyLevel: 30,
        });
        technicianRole = await roleRepo.save(technicianRole);
        console.log(`  ✅ Created TECHNICIAN role`);
      } else {
        console.log(`  ✅ TECHNICIAN role already exists`);
      }

      // Migrate user roles from TECHNICIAN_1 to TECHNICIAN
      if (technician1Role) {
        const userRoles1 = await userRoleRepo.find({
          where: { companyId, roleId: technician1Role.id },
        });
        console.log(`  Found ${userRoles1.length} users with TECHNICIAN_1 role`);

        for (const userRole of userRoles1) {
          // Check if user already has TECHNICIAN role
          const existing = await userRoleRepo.findOne({
            where: {
              companyId,
              userId: userRole.userId,
              roleId: technicianRole!.id,
            },
          });

          if (!existing) {
            // Create new user role with TECHNICIAN
            const newUserRole = userRoleRepo.create({
              companyId,
              userId: userRole.userId,
              roleId: technicianRole!.id,
            });
            await userRoleRepo.save(newUserRole);
            console.log(`    ✅ Migrated user ${userRole.userId} from TECHNICIAN_1 to TECHNICIAN`);
          } else {
            console.log(`    ⚠️  User ${userRole.userId} already has TECHNICIAN role`);
          }

          // Delete old TECHNICIAN_1 user role
          await userRoleRepo.remove(userRole);
        }

        // Delete TECHNICIAN_1 role
        await roleRepo.remove(technician1Role);
        console.log(`  ✅ Deleted TECHNICIAN_1 role`);
      }

      // Migrate user roles from TECHNICIAN_2 to TECHNICIAN
      if (technician2Role) {
        const userRoles2 = await userRoleRepo.find({
          where: { companyId, roleId: technician2Role.id },
        });
        console.log(`  Found ${userRoles2.length} users with TECHNICIAN_2 role`);

        for (const userRole of userRoles2) {
          // Check if user already has TECHNICIAN role
          const existing = await userRoleRepo.findOne({
            where: {
              companyId,
              userId: userRole.userId,
              roleId: technicianRole!.id,
            },
          });

          if (!existing) {
            // Create new user role with TECHNICIAN
            const newUserRole = userRoleRepo.create({
              companyId,
              userId: userRole.userId,
              roleId: technicianRole!.id,
            });
            await userRoleRepo.save(newUserRole);
            console.log(`    ✅ Migrated user ${userRole.userId} from TECHNICIAN_2 to TECHNICIAN`);
          } else {
            console.log(`    ⚠️  User ${userRole.userId} already has TECHNICIAN role`);
          }

          // Delete old TECHNICIAN_2 user role
          await userRoleRepo.remove(userRole);
        }

        // Delete TECHNICIAN_2 role
        await roleRepo.remove(technician2Role);
        console.log(`  ✅ Deleted TECHNICIAN_2 role`);
      }

      if (!technician1Role && !technician2Role) {
        console.log(`  ℹ️  No TECHNICIAN_1 or TECHNICIAN_2 roles found for this company`);
      }

      console.log('');
    }

    console.log('='.repeat(50));
    console.log('✅ Migration completed successfully!');
    console.log('='.repeat(50));

    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Migration failed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

migrateTechnicianRoles();

