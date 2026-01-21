"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TenantModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const tenant_service_1 = require("./tenant.service");
const tenant_controller_1 = require("./tenant.controller");
const lookup_controller_1 = require("./lookup.controller");
const public_lookup_controller_1 = require("./public-lookup.controller");
const villa_controller_1 = require("./villa.controller");
const villa_service_1 = require("./villa.service");
const villa_type_config_controller_1 = require("./villa-type-config.controller");
const villa_type_config_service_1 = require("./villa-type-config.service");
const city_location_service_1 = require("./services/city-location.service");
const user_site_service_1 = require("./services/user-site.service");
const company_entity_1 = require("./entities/company.entity");
const site_entity_1 = require("./entities/site.entity");
const space_category_entity_1 = require("./entities/space-category.entity");
const space_entity_1 = require("./entities/space.entity");
const villa_entity_1 = require("./entities/villa.entity");
const villa_type_config_entity_1 = require("./entities/villa-type-config.entity");
const city_entity_1 = require("./entities/city.entity");
const location_entity_1 = require("./entities/location.entity");
const user_site_entity_1 = require("./entities/user-site.entity");
const user_entity_1 = require("../iam/entities/user.entity");
const iam_module_1 = require("../iam/iam.module");
let TenantModule = class TenantModule {
};
exports.TenantModule = TenantModule;
exports.TenantModule = TenantModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forFeature([
                company_entity_1.Company,
                site_entity_1.Site,
                space_category_entity_1.SpaceCategory,
                space_entity_1.Space,
                villa_entity_1.Villa,
                villa_type_config_entity_1.VillaTypeConfig,
                city_entity_1.City,
                location_entity_1.Location,
                user_site_entity_1.UserSite,
                user_entity_1.User,
            ]),
            (0, common_1.forwardRef)(() => iam_module_1.IamModule),
        ],
        providers: [
            tenant_service_1.TenantService,
            villa_service_1.VillaService,
            villa_type_config_service_1.VillaTypeConfigService,
            city_location_service_1.CityLocationService,
            user_site_service_1.UserSiteService,
        ],
        controllers: [
            tenant_controller_1.TenantController,
            lookup_controller_1.LookupController,
            public_lookup_controller_1.PublicLookupController,
            villa_controller_1.VillaController,
            villa_type_config_controller_1.VillaTypeConfigController,
        ],
        exports: [tenant_service_1.TenantService, villa_service_1.VillaService, villa_type_config_service_1.VillaTypeConfigService, user_site_service_1.UserSiteService],
    })
], TenantModule);
