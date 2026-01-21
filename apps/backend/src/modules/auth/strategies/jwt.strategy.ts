import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { JwtPayload } from '../interfaces/jwt-payload.interface';
import { UserService } from '../../iam/services/user.service';
import { UserStatus } from '../../iam/entities/user.entity';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly configService: ConfigService,
    private readonly userService: UserService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        configService.get<string>('JWT_ACCESS_SECRET') || 'access-secret',
    });
  }

  async validate(payload: JwtPayload): Promise<{
    userId: string;
    email: string;
    companyId: string;
    siteId: string;
    siteCode: string;
    roles: string[];
    permissions: string[];
  }> {
    const user = await this.userService.findById(
      payload.companyId,
      payload.sub,
    );

    if (!user || user.status !== UserStatus.ACTIVE) {
      throw new UnauthorizedException('User not found or inactive');
    }

    return {
      userId: payload.sub,
      email: payload.email,
      companyId: payload.companyId,
      siteId: payload.siteId,
      siteCode: payload.siteCode,
      roles: payload.roles || [],
      permissions: payload.permissions || [],
    };
  }
}
