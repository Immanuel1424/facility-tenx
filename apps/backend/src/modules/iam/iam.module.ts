import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Role } from './entities/role.entity';
import { Permission } from './entities/permission.entity';
import { UserRole } from './entities/user-role.entity';
import { RolePermission } from './entities/role-permission.entity';
import { AclEntry } from './entities/acl-entry.entity';
import { RefreshToken } from './entities/refresh-token.entity';
import { UserDevice } from './entities/user-device.entity';
import { UserService } from './services/user.service';
import { PermissionService } from './services/permission.service';
import { RoleService } from './services/role.service';
import { PolicyEvaluationService } from './services/policy-evaluation.service';
import { RefreshTokenService } from './services/refresh-token.service';
import { UserDeviceService } from './services/user-device.service';
import { PermissionGuard } from './guards/permission.guard';
import { RoleController } from './controllers/role.controller';
import { PermissionController } from './controllers/permission.controller';
import { SuperAdminService } from '../../shared/services/super-admin.service';
import { TenantModule } from '../tenant/tenant.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      Role,
      Permission,
      UserRole,
      RolePermission,
      AclEntry,
      RefreshToken,
      UserDevice,
    ]),
    forwardRef(() => TenantModule),
  ],
  controllers: [RoleController, PermissionController],
  providers: [
    UserService,
    PermissionService,
    RoleService,
    PolicyEvaluationService,
    RefreshTokenService,
    UserDeviceService,
    PermissionGuard,
    SuperAdminService,
  ],
  exports: [
    UserService,
    PermissionService,
    RoleService,
    PolicyEvaluationService,
    RefreshTokenService,
    UserDeviceService,
    PermissionGuard,
    SuperAdminService,
  ],
})
export class IamModule {}

