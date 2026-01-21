"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var TenantResolutionMiddleware_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.TenantResolutionMiddleware = void 0;
const common_1 = require("@nestjs/common");
let TenantResolutionMiddleware = TenantResolutionMiddleware_1 = class TenantResolutionMiddleware {
    use(req, _res, next) {
        const headerCompanyId = req.header('x-company-id');
        const headerSiteId = req.header('x-site-id');
        if (req.user?.companyId && req.user?.siteId) {
            req.companyId = req.user.companyId;
            req.siteId = req.user.siteId;
        }
        else {
            req.companyId = headerCompanyId ?? req.user?.companyId ?? undefined;
            req.siteId = headerSiteId ?? req.user?.siteId ?? undefined;
        }
        next();
    }
    static create() {
        const instance = new TenantResolutionMiddleware_1();
        return instance.use.bind(instance);
    }
};
exports.TenantResolutionMiddleware = TenantResolutionMiddleware;
exports.TenantResolutionMiddleware = TenantResolutionMiddleware = TenantResolutionMiddleware_1 = __decorate([
    (0, common_1.Injectable)()
], TenantResolutionMiddleware);
