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
exports.RefreshTokenService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const refresh_token_entity_1 = require("../entities/refresh-token.entity");
let RefreshTokenService = class RefreshTokenService {
    constructor(refreshTokenRepository) {
        this.refreshTokenRepository = refreshTokenRepository;
    }
    async create(userId, companyId, token, expiresAt, ipAddress, userAgent) {
        const refreshToken = this.refreshTokenRepository.create({
            userId,
            companyId,
            token,
            expiresAt,
            ipAddress,
            userAgent,
        });
        return this.refreshTokenRepository.save(refreshToken);
    }
    async validate(tokenId, userId, companyId) {
        const token = await this.refreshTokenRepository.findOne({
            where: { id: tokenId, userId, companyId },
        });
        if (!token) {
            return false;
        }
        if (token.revokedAt) {
            return false;
        }
        if (token.expiresAt < new Date()) {
            return false;
        }
        return true;
    }
    async revoke(tokenId, companyId) {
        await this.refreshTokenRepository.update({ id: tokenId, companyId }, { revokedAt: new Date() });
    }
    async revokeAllUserTokens(userId, companyId) {
        await this.refreshTokenRepository.update({ userId, companyId, revokedAt: (0, typeorm_2.IsNull)() }, { revokedAt: new Date() });
    }
    async cleanupExpiredTokens() {
        const result = await this.refreshTokenRepository
            .createQueryBuilder()
            .delete()
            .where('expires_at < :now', { now: new Date() })
            .orWhere('revoked_at IS NOT NULL')
            .execute();
        return result.affected || 0;
    }
};
exports.RefreshTokenService = RefreshTokenService;
exports.RefreshTokenService = RefreshTokenService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(refresh_token_entity_1.RefreshToken)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], RefreshTokenService);
