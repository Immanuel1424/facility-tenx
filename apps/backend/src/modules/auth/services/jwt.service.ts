import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { JwtPayload, JwtRefreshPayload } from '../interfaces/jwt-payload.interface';
import { RefreshTokenService } from '../../iam/services/refresh-token.service';

@Injectable()
export class AuthJwtService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly refreshTokenService: RefreshTokenService,
  ) {}

  async generateAccessToken(payload: Omit<JwtPayload, 'iat' | 'exp'>): Promise<string> {
    return this.jwtService.signAsync(payload, {
      secret: this.configService.get<string>('JWT_ACCESS_SECRET') || 'access-secret',
      expiresIn: this.configService.get<string>('JWT_ACCESS_EXPIRES_IN') || '15m',
    });
  }

  async generateRefreshToken(
    userId: string,
    companyId: string,
    siteId: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<string> {
    const expiresIn = this.configService.get<number>('JWT_REFRESH_EXPIRES_IN_DAYS') || 30;
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + expiresIn);

    const token = await this.jwtService.signAsync(
      {
        sub: userId,
        companyId,
        siteId,
      },
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET') || 'refresh-secret',
        expiresIn: `${expiresIn}d`,
      },
    );

    const refreshTokenEntity = await this.refreshTokenService.create(
      userId,
      companyId,
      token,
      expiresAt,
      ipAddress,
      userAgent,
    );

    return this.jwtService.signAsync(
      {
        sub: userId,
        tokenId: refreshTokenEntity.id,
        companyId,
        siteId,
      },
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET') || 'refresh-secret',
        expiresIn: `${expiresIn}d`,
      },
    );
  }

  async verifyAccessToken(token: string): Promise<JwtPayload> {
    try {
      return await this.jwtService.verifyAsync<JwtPayload>(token, {
        secret: this.configService.get<string>('JWT_ACCESS_SECRET') || 'access-secret',
      });
    } catch (error) {
      throw new UnauthorizedException('Invalid or expired access token');
    }
  }

  async verifyRefreshToken(token: string): Promise<JwtRefreshPayload> {
    try {
      const payload = await this.jwtService.verifyAsync<JwtRefreshPayload>(token, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET') || 'refresh-secret',
      });

      const isValid = await this.refreshTokenService.validate(
        payload.tokenId,
        payload.sub,
        payload.companyId,
      );

      if (!isValid) {
        throw new UnauthorizedException('Refresh token has been revoked');
      }

      return payload;
    } catch (error) {
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }
}

