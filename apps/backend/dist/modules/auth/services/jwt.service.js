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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthJwtService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const refresh_token_service_1 = require("../../iam/services/refresh-token.service");
let AuthJwtService = class AuthJwtService {
    constructor(jwtService, configService, refreshTokenService) {
        this.jwtService = jwtService;
        this.configService = configService;
        this.refreshTokenService = refreshTokenService;
    }
    async generateAccessToken(payload) {
        return this.jwtService.signAsync(payload, {
            secret: this.configService.get('JWT_ACCESS_SECRET') || 'access-secret',
            expiresIn: this.configService.get('JWT_ACCESS_EXPIRES_IN') || '15m',
        });
    }
    async generateRefreshToken(userId, companyId, siteId, ipAddress, userAgent) {
        const expiresIn = this.configService.get('JWT_REFRESH_EXPIRES_IN_DAYS') || 30;
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + expiresIn);
        const token = await this.jwtService.signAsync({
            sub: userId,
            companyId,
            siteId,
        }, {
            secret: this.configService.get('JWT_REFRESH_SECRET') || 'refresh-secret',
            expiresIn: `${expiresIn}d`,
        });
        const refreshTokenEntity = await this.refreshTokenService.create(userId, companyId, token, expiresAt, ipAddress, userAgent);
        return this.jwtService.signAsync({
            sub: userId,
            tokenId: refreshTokenEntity.id,
            companyId,
            siteId,
        }, {
            secret: this.configService.get('JWT_REFRESH_SECRET') || 'refresh-secret',
            expiresIn: `${expiresIn}d`,
        });
    }
    async verifyAccessToken(token) {
        try {
            return await this.jwtService.verifyAsync(token, {
                secret: this.configService.get('JWT_ACCESS_SECRET') || 'access-secret',
            });
        }
        catch (error) {
            throw new common_1.UnauthorizedException('Invalid or expired access token');
        }
    }
    async verifyRefreshToken(token) {
        try {
            const payload = await this.jwtService.verifyAsync(token, {
                secret: this.configService.get('JWT_REFRESH_SECRET') || 'refresh-secret',
            });
            const isValid = await this.refreshTokenService.validate(payload.tokenId, payload.sub, payload.companyId);
            if (!isValid) {
                throw new common_1.UnauthorizedException('Refresh token has been revoked');
            }
            return payload;
        }
        catch (error) {
            if (error instanceof common_1.UnauthorizedException) {
                throw error;
            }
            throw new common_1.UnauthorizedException('Invalid or expired refresh token');
        }
    }
};
exports.AuthJwtService = AuthJwtService;
exports.AuthJwtService = AuthJwtService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [jwt_1.JwtService,
        config_1.ConfigService,
        refresh_token_service_1.RefreshTokenService])
], AuthJwtService);
