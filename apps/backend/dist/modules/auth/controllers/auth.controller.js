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
exports.AuthController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const auth_service_1 = require("../services/auth.service");
const password_reset_service_1 = require("../services/password-reset.service");
const tenant_service_1 = require("../../tenant/tenant.service");
const login_dto_1 = require("../dto/login.dto");
const forgot_password_dto_1 = require("../dto/forgot-password.dto");
const public_decorator_1 = require("../decorators/public.decorator");
const super_admin_service_1 = require("../../../shared/services/super-admin.service");
let AuthController = class AuthController {
    constructor(authService, passwordResetService, tenantService, superAdminService) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
        this.tenantService = tenantService;
        this.superAdminService = superAdminService;
    }
    async login(loginDto, req) {
        return this.authService.login(loginDto.siteCode, loginDto.email, loginDto.password, loginDto.companyId, req.ip, req.get('user-agent'));
    }
    async refresh(refreshDto, req) {
        return this.authService.refreshToken(refreshDto.refreshToken, req.ip, req.get('user-agent'));
    }
    async authorizeOAuth2(provider, req, res) {
        const redirectUri = `${req.protocol}://${req.get('host')}/api/v1/auth/oauth2/${provider}/callback`;
        const state = this.authService.generateOAuthState();
        const codeVerifier = this.authService.generateCodeVerifier();
        if (req.session) {
            req.session[`oauth2_${provider}_state`] = state;
            req.session[`oauth2_${provider}_code_verifier`] = codeVerifier;
        }
        const authUrl = await this.authService.getOAuth2AuthorizationUrl(provider, redirectUri, state, codeVerifier);
        res.redirect(authUrl);
    }
    async oauth2Callback(query, provider, req) {
        const redirectUri = `${req.protocol}://${req.get('host')}/api/v1/auth/oauth2/${provider}/callback`;
        return this.authService.handleOAuth2Callback(provider, query.code, query.state || '', redirectUri, req.companyId || '', req.session || {}, req.ip, req.get('user-agent'));
    }
    async logout(req) {
        if (req.user?.userId && req.companyId) {
            await this.authService.logout(req.user.userId, req.companyId);
        }
    }
    async forgotPassword(forgotPasswordDto, req) {
        if (!req.companyId) {
            throw new common_1.BadRequestException('x-company-id header is required');
        }
        const companyId = req.companyId.trim();
        const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(companyId);
        if (!isUuid) {
            throw new common_1.BadRequestException('x-company-id header must be a valid company UUID.');
        }
        try {
            await this.tenantService.getCompanyById(companyId);
        }
        catch {
            throw new common_1.BadRequestException(`Invalid company id: ${companyId}`);
        }
        return this.passwordResetService.initiatePasswordReset(companyId, forgotPasswordDto.email, req.ip);
    }
    async verifyOtp(verifyOtpDto, req) {
        if (!req.companyId) {
            throw new common_1.BadRequestException('x-company-id header is required');
        }
        const companyId = req.companyId.trim();
        const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(companyId);
        if (!isUuid) {
            throw new common_1.BadRequestException('x-company-id header must be a valid company UUID.');
        }
        try {
            await this.tenantService.getCompanyById(companyId);
        }
        catch {
            throw new common_1.BadRequestException(`Invalid company id: ${companyId}`);
        }
        return this.passwordResetService.verifyOtp(companyId, verifyOtpDto.email, verifyOtpDto.otp);
    }
    async resetPassword(resetPasswordDto, req) {
        if (!req.companyId) {
            throw new common_1.BadRequestException('x-company-id header is required');
        }
        const companyId = req.companyId.trim();
        const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(companyId);
        if (!isUuid) {
            throw new common_1.BadRequestException('x-company-id header must be a valid company UUID.');
        }
        try {
            await this.tenantService.getCompanyById(companyId);
        }
        catch {
            throw new common_1.BadRequestException(`Invalid company id: ${companyId}`);
        }
        return this.passwordResetService.resetPassword(companyId, resetPasswordDto.email, resetPasswordDto.token, resetPasswordDto.newPassword);
    }
};
exports.AuthController = AuthController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('login'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: 'Login with site code, email and password' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [login_dto_1.LoginDto, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "login", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('refresh'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: 'Refresh access token' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [login_dto_1.RefreshTokenDto, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "refresh", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('oauth2/:provider/authorize'),
    (0, swagger_1.ApiOperation)({ summary: 'Initiate OAuth2/OIDC login flow' }),
    __param(0, (0, common_1.Query)('provider')),
    __param(1, (0, common_1.Req)()),
    __param(2, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "authorizeOAuth2", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)('oauth2/:provider/callback'),
    (0, swagger_1.ApiOperation)({ summary: 'OAuth2/OIDC callback handler' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)('provider')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [login_dto_1.OAuth2CallbackDto, String, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "oauth2Callback", null);
__decorate([
    (0, common_1.Post)('logout'),
    (0, common_1.HttpCode)(common_1.HttpStatus.NO_CONTENT),
    (0, swagger_1.ApiBearerAuth)('access-token'),
    (0, swagger_1.ApiOperation)({ summary: 'Logout and revoke refresh token' }),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "logout", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('forgot-password'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: 'Request password reset - sends OTP to email' }),
    (0, swagger_1.ApiHeader)({
        name: 'x-company-id',
        description: 'Company ID (UUID) for the tenant. This should be the company UUID resolved from the public lookup / company selection flow.',
        required: true,
        example: 'eb75a65b-055f-4408-a58c-71d233443c17',
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [forgot_password_dto_1.ForgotPasswordDto, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "forgotPassword", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('verify-otp'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: 'Verify OTP and get reset token' }),
    (0, swagger_1.ApiHeader)({
        name: 'x-company-id',
        description: 'Company ID (UUID) for the tenant. This should be the company UUID resolved from the public lookup / company selection flow.',
        required: true,
        example: 'eb75a65b-055f-4408-a58c-71d233443c17',
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [forgot_password_dto_1.VerifyOtpDto, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "verifyOtp", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)('reset-password'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: 'Reset password using token from OTP verification' }),
    (0, swagger_1.ApiHeader)({
        name: 'x-company-id',
        description: 'Company ID (UUID) for the tenant. This should be the company UUID resolved from the public lookup / company selection flow.',
        required: true,
        example: 'eb75a65b-055f-4408-a58c-71d233443c17',
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [forgot_password_dto_1.ResetPasswordDto, Object]),
    __metadata("design:returntype", Promise)
], AuthController.prototype, "resetPassword", null);
exports.AuthController = AuthController = __decorate([
    (0, swagger_1.ApiTags)('Authentication'),
    (0, common_1.Controller)('auth'),
    __metadata("design:paramtypes", [auth_service_1.AuthService,
        password_reset_service_1.PasswordResetService,
        tenant_service_1.TenantService,
        super_admin_service_1.SuperAdminService])
], AuthController);
