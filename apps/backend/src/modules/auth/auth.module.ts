import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthController } from './controllers/auth.controller';
import { AuthService } from './services/auth.service';
import { AuthJwtService } from './services/jwt.service';
import { OidcService } from './services/oidc.service';
import { PasswordResetService } from './services/password-reset.service';
import { EmailService } from './services/email.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { IamModule } from '../iam/iam.module';
import { TenantModule } from '../tenant/tenant.module';
import { PasswordResetToken } from './entities/password-reset-token.entity';
import { User } from '../iam/entities/user.entity';

@Module({
  imports: [
    IamModule,
    TenantModule,
    TypeOrmModule.forFeature([PasswordResetToken, User]),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_ACCESS_SECRET') || 'access-secret',
        signOptions: {
          expiresIn: configService.get<string>('JWT_ACCESS_EXPIRES_IN') || '15m',
        },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    AuthJwtService,
    OidcService,
    PasswordResetService,
    EmailService,
    JwtStrategy,
    JwtAuthGuard,
  ],
  exports: [AuthService, AuthJwtService, JwtAuthGuard, PasswordResetService, EmailService],
})
export class AuthModule {}
