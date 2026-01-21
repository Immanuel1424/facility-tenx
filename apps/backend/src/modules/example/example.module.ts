import { Module, forwardRef } from '@nestjs/common';
import { ProtectedController } from './controllers/protected.controller';
import { IamModule } from '../iam/iam.module';
import { TenantModule } from '../tenant/tenant.module';

@Module({
  imports: [
    IamModule,
    forwardRef(() => TenantModule),
  ],
  controllers: [ProtectedController],
})
export class ExampleModule {}
