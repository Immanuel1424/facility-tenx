"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const jwt_service_1 = require("./jwt.service");
const oidc_service_1 = require("./oidc.service");
const user_service_1 = require("../../iam/services/user.service");
const permission_service_1 = require("../../iam/services/permission.service");
const refresh_token_service_1 = require("../../iam/services/refresh-token.service");
const tenant_service_1 = require("../../tenant/tenant.service");
const user_site_service_1 = require("../../tenant/services/user-site.service");
const user_entity_1 = require("../../iam/entities/user.entity");
let AuthService = class AuthService {
    constructor(jwtService, oidcService, userService, permissionService, refreshTokenService, tenantService, userSiteService, userRepository) {
        this.jwtService = jwtService;
        this.oidcService = oidcService;
        this.userService = userService;
        this.permissionService = permissionService;
        this.refreshTokenService = refreshTokenService;
        this.tenantService = tenantService;
        this.userSiteService = userSiteService;
        this.userRepository = userRepository;
    }
    async login(siteCode, email, password, companyId, ipAddress, userAgent) {
        const normalizedSiteCode = (siteCode || '').trim().toUpperCase();
        if (!normalizedSiteCode || normalizedSiteCode === 'SYSTEM') {
            const systemCompany = await this.tenantService.getCompanyByCode('SYSTEM');
            const systemCompanyId = systemCompany.id;
            const user = await this.userService.findByEmail(systemCompanyId, email);
            if (!user || !user.passwordHash) {
                throw new common_1.UnauthorizedException('Invalid credentials');
            }
            const isValid = await this.userService.validatePassword(password, user.passwordHash);
            if (!isValid) {
                throw new common_1.UnauthorizedException('Invalid credentials');
            }
            const roles = await this.userService.getUserRoles(systemCompanyId, user.id);
            const isSuperAdmin = roles.some((r) => r.name.toUpperCase() === 'SUPER_ADMIN');
            if (!isSuperAdmin) {
                throw new common_1.UnauthorizedException('Only SUPER_ADMIN users can login without a site code');
            }
            await this.userService.updateLastLogin(systemCompanyId, user.id);
            const permissions = await this.permissionService.getUserPermissions(systemCompanyId, user.id);
            const companyName = systemCompany.name;
            const accessToken = await this.jwtService.generateAccessToken({
                sub: user.id,
                email: user.email,
                companyId: systemCompanyId,
                companyName,
                siteId: '',
                siteCode: 'SYSTEM',
                roles: roles.map((r) => r.name),
                permissions: permissions.map((p) => `${p.resource}:${p.action}`),
            });
            const refreshToken = await this.jwtService.generateRefreshToken(user.id, systemCompanyId, '', ipAddress, userAgent);
            return {
                accessToken,
                refreshToken,
                expiresIn: 900,
                tokenType: 'Bearer',
            };
        }
        let resolvedCompanyId = companyId;
        let user = null;
        if (!resolvedCompanyId) {
            user = await this.userRepository.findOne({
                where: { email: email.toLowerCase() },
                relations: ['userRoles', 'userRoles.role'],
            });
            if (!user) {
                throw new common_1.UnauthorizedException('Invalid credentials');
            }
            resolvedCompanyId = user.companyId;
            console.log(`[AuthService] No companyId provided, found user in company: ${resolvedCompanyId}`);
        }
        const site = await this.tenantService.getSiteByCode(normalizedSiteCode, resolvedCompanyId);
        if (!site.isActive) {
            throw new common_1.UnauthorizedException('Site is inactive');
        }
        if (!resolvedCompanyId) {
            resolvedCompanyId = site.companyId;
        }
        if (!resolvedCompanyId) {
            throw new common_1.BadRequestException('Site is not associated with a company');
        }
        if (!user) {
            user = await this.userService.findByEmail(resolvedCompanyId, email);
        }
        if (!user || !user.passwordHash) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const isValid = await this.userService.validatePassword(password, user.passwordHash);
        if (!isValid) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const isSuperAdmin = user.userRoles?.some((ur) => ur.role?.name?.toUpperCase() === 'SUPER_ADMIN');
        if (!isSuperAdmin) {
            console.log(`[AuthService] Checking user-site assignment: ` +
                `companyId=${resolvedCompanyId}, userId=${user.id}, siteId=${site.id}, ` +
                `siteCode=${normalizedSiteCode}, userCompanyId=${user.companyId}`);
            const isAssigned = await this.userSiteService.isUserAssignedToSite(resolvedCompanyId, user.id, site.id);
            if (!isAssigned) {
                console.error(`[AuthService] User-site assignment check failed: ` +
                    `companyId=${resolvedCompanyId}, userId=${user.id}, siteId=${site.id}`);
                throw new common_1.UnauthorizedException('User is not assigned to this site');
            }
        }
        await this.userService.updateLastLogin(resolvedCompanyId, user.id);
        const permissions = await this.permissionService.getUserPermissions(resolvedCompanyId, user.id);
        const roles = await this.userService.getUserRoles(resolvedCompanyId, user.id);
        let companyName;
        try {
            const company = await this.tenantService.getCompanyById(resolvedCompanyId);
            companyName = company.name;
        }
        catch (error) {
            console.warn(`Company with id ${resolvedCompanyId} not found:`, error);
        }
        const accessToken = await this.jwtService.generateAccessToken({
            sub: user.id,
            email: user.email,
            companyId: resolvedCompanyId,
            companyName,
            siteId: site.id,
            siteCode: site.code,
            roles: roles.map((r) => r.name),
            permissions: permissions.map((p) => `${p.resource}:${p.action}`),
        });
        const refreshToken = await this.jwtService.generateRefreshToken(user.id, resolvedCompanyId, site.id, ipAddress, userAgent);
        return {
            accessToken,
            refreshToken,
            expiresIn: 900,
            tokenType: 'Bearer',
        };
    }
    async refreshToken(refreshToken, ipAddress, userAgent) {
        const payload = await this.jwtService.verifyRefreshToken(refreshToken);
        const companyId = payload.companyId;
        const siteId = payload.siteId;
        const user = await this.userService.findById(companyId, payload.sub);
        if (!user) {
            throw new common_1.UnauthorizedException('User not found');
        }
        const permissions = await this.permissionService.getUserPermissions(companyId, user.id);
        const roles = await this.userService.getUserRoles(companyId, user.id);
        let companyName;
        try {
            const company = await this.tenantService.getCompanyById(companyId);
            companyName = company.name;
        }
        catch (error) {
            console.warn(`Company with id ${companyId} not found:`, error);
        }
        if (!siteId) {
            const accessToken = await this.jwtService.generateAccessToken({
                sub: user.id,
                email: user.email,
                companyId,
                companyName,
                siteId: '',
                siteCode: 'SYSTEM',
                roles: roles.map((r) => r.name),
                permissions: permissions.map((p) => `${p.resource}:${p.action}`),
            });
            const newRefreshToken = await this.jwtService.generateRefreshToken(user.id, companyId, '', ipAddress, userAgent);
            await this.refreshTokenService.revoke(payload.tokenId, companyId);
            return {
                accessToken,
                refreshToken: newRefreshToken,
                expiresIn: 900,
                tokenType: 'Bearer',
            };
        }
        const site = await this.tenantService.getSiteById(siteId);
        if (site.companyId !== companyId) {
            throw new common_1.UnauthorizedException('Invalid token: site-company mismatch');
        }
        const accessToken = await this.jwtService.generateAccessToken({
            sub: user.id,
            email: user.email,
            companyId,
            companyName,
            siteId: site.id,
            siteCode: site.code,
            roles: roles.map((r) => r.name),
            permissions: permissions.map((p) => `${p.resource}:${p.action}`),
        });
        const newRefreshToken = await this.jwtService.generateRefreshToken(user.id, companyId, site.id, ipAddress, userAgent);
        await this.refreshTokenService.revoke(payload.tokenId, companyId);
        return {
            accessToken,
            refreshToken: newRefreshToken,
            expiresIn: 900,
            tokenType: 'Bearer',
        };
    }
    generateOAuthState() {
        return this.oidcService.generateState();
    }
    generateCodeVerifier() {
        return this.oidcService.generateCodeVerifier();
    }
    async getOAuth2AuthorizationUrl(provider, redirectUri, state, codeVerifier) {
        const codeChallenge = this.oidcService.generateCodeChallenge(codeVerifier);
        return this.oidcService.getAuthorizationUrl(provider, redirectUri, state, codeChallenge);
    }
    async handleOAuth2Callback(provider, code, state, redirectUri, companyId, session, ipAddress, userAgent) {
        const storedState = session[`oauth2_${provider}_state`];
        const codeVerifier = session[`oauth2_${provider}_code_verifier`];
        if (!storedState || storedState !== state) {
            throw new common_1.BadRequestException('Invalid state parameter');
        }
        const tokenResponse = await this.oidcService.exchangeCodeForToken(provider, code, redirectUri, codeVerifier);
        const userInfo = await this.oidcService.getUserInfo(provider, tokenResponse.access_token);
        const authProvider = this.mapProviderName(provider);
        const user = await this.userService.createOrUpdateOidcUser(companyId, userInfo.sub, authProvider, userInfo.email, {
            firstName: userInfo.given_name,
            lastName: userInfo.family_name,
            emailVerified: userInfo.email_verified,
        });
        const permissions = await this.permissionService.getUserPermissions(companyId, user.id);
        const roles = await this.userService.getUserRoles(companyId, user.id);
        let companyName;
        try {
            const company = await this.tenantService.getCompanyById(companyId);
            companyName = company.name;
        }
        catch (error) {
            console.warn(`Company with id ${companyId} not found:`, error);
        }
        const accessToken = await this.jwtService.generateAccessToken({
            sub: user.id,
            email: user.email,
            companyId,
            companyName,
            siteId: '',
            siteCode: '',
            roles: roles.map((r) => r.name),
            permissions: permissions.map((p) => `${p.resource}:${p.action}`),
        });
        const refreshToken = await this.jwtService.generateRefreshToken(user.id, companyId, '', ipAddress, userAgent);
        delete session[`oauth2_${provider}_state`];
        delete session[`oauth2_${provider}_code_verifier`];
        return {
            accessToken,
            refreshToken,
            expiresIn: 900,
            tokenType: 'Bearer',
        };
    }
    async logout(userId, companyId) {
        await this.refreshTokenService.revokeAllUserTokens(userId, companyId);
    }
    mapProviderName(provider) {
        const mapping = {
            azure_ad: user_entity_1.AuthProvider.AZURE_AD,
            okta: user_entity_1.AuthProvider.OKTA,
            auth0: user_entity_1.AuthProvider.AUTH0,
            keycloak: user_entity_1.AuthProvider.KEYCLOAK,
        };
        return mapping[provider.toLowerCase()] || user_entity_1.AuthProvider.LOCAL;
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __param(7, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [jwt_service_1.AuthJwtService,
        oidc_service_1.OidcService,
        user_service_1.UserService,
        permission_service_1.PermissionService,
        refresh_token_service_1.RefreshTokenService,
        tenant_service_1.TenantService,
        user_site_service_1.UserSiteService,
        typeorm_2.Repository])
], AuthService);
