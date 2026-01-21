import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TenantService } from './tenant.service';
import { TenantController } from './tenant.controller';
import { LookupController } from './lookup.controller';
import { PublicLookupController } from './public-lookup.controller';
import { VillaController } from './villa.controller';
import { VillaService } from './villa.service';
import { VillaTypeConfigController } from './villa-type-config.controller';
import { VillaTypeConfigService } from './villa-type-config.service';
import { CityLocationService } from './services/city-location.service';
import { UserSiteService } from './services/user-site.service';
import { Company } from './entities/company.entity';
import { Site } from './entities/site.entity';
import { SpaceCategory } from './entities/space-category.entity';
import { Space } from './entities/space.entity';
import { Villa } from './entities/villa.entity';
import { VillaTypeConfig } from './entities/villa-type-config.entity';
import { City } from './entities/city.entity';
import { Location } from './entities/location.entity';
import { UserSite } from './entities/user-site.entity';
import { User } from '../iam/entities/user.entity';
import { IamModule } from '../iam/iam.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Company,
      Site,
      SpaceCategory,
      Space,
      Villa,
      VillaTypeConfig,
      City,
      Location,
      UserSite,
      User,
    ]),
    forwardRef(() => IamModule),
  ],
  providers: [
    TenantService,
    VillaService,
    VillaTypeConfigService,
    CityLocationService,
    UserSiteService,
  ],
  controllers: [
    TenantController,
    LookupController,
    PublicLookupController,
    VillaController,
    VillaTypeConfigController,
  ],
  exports: [TenantService, VillaService, VillaTypeConfigService, UserSiteService],
})
export class TenantModule {}


