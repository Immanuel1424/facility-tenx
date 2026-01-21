import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { RefreshToken } from '../entities/refresh-token.entity';

@Injectable()
export class RefreshTokenService {
  constructor(
    @InjectRepository(RefreshToken)
    private readonly refreshTokenRepository: Repository<RefreshToken>,
  ) {}

  async create(
    userId: string,
    companyId: string,
    token: string,
    expiresAt: Date,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<RefreshToken> {
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

  async validate(
    tokenId: string,
    userId: string,
    companyId: string,
  ): Promise<boolean> {
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

  async revoke(tokenId: string, companyId: string): Promise<void> {
    await this.refreshTokenRepository.update(
      { id: tokenId, companyId },
      { revokedAt: new Date() },
    );
  }

  async revokeAllUserTokens(userId: string, companyId: string): Promise<void> {
    await this.refreshTokenRepository.update(
      { userId, companyId, revokedAt: IsNull() },
      { revokedAt: new Date() },
    );
  }

  async cleanupExpiredTokens(): Promise<number> {
    const result = await this.refreshTokenRepository
      .createQueryBuilder()
      .delete()
      .where('expires_at < :now', { now: new Date() })
      .orWhere('revoked_at IS NOT NULL')
      .execute();

    return result.affected || 0;
  }
}

