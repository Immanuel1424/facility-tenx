import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Get,
  Query,
  Req,
  Res,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiHeader } from '@nestjs/swagger';
import { AuthService } from '../services/auth.service';
import { PasswordResetService } from '../services/password-reset.service';
import { TenantService } from '../../tenant/tenant.service';
import { LoginDto, RefreshTokenDto, OAuth2CallbackDto } from '../dto/login.dto';
import {
  ForgotPasswordDto,
  VerifyOtpDto,
  ResetPasswordDto,
} from '../dto/forgot-password.dto';
import { TokenResponseDto } from '../dto/token-response.dto';
import { Public } from '../decorators/public.decorator';
import { TenantAwareRequest } from '../../../shared/middleware/tenant-resolution.middleware';
import { SuperAdminService } from '../../../shared/services/super-admin.service';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly passwordResetService: PasswordResetService,
    private readonly tenantService: TenantService,
    private readonly superAdminService: SuperAdminService,
  ) {}

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with site code, email and password' })
  async login(
    @Body() loginDto: LoginDto,
    @Req() req: TenantAwareRequest,
  ): Promise<TokenResponseDto> {
    return this.authService.login(
      loginDto.siteCode,
      loginDto.email,
      loginDto.password,
      loginDto.companyId,
      req.ip,
      req.get('user-agent'),
    );
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token' })
  async refresh(
    @Body() refreshDto: RefreshTokenDto,
    @Req() req: TenantAwareRequest,
  ): Promise<TokenResponseDto> {
    return this.authService.refreshToken(
      refreshDto.refreshToken,
      req.ip,
      req.get('user-agent'),
    );
  }

  @Public()
  @Get('oauth2/:provider/authorize')
  @ApiOperation({ summary: 'Initiate OAuth2/OIDC login flow' })
  async authorizeOAuth2(
    @Query('provider') provider: string,
    @Req() req: TenantAwareRequest & { session?: Record<string, unknown> },
    @Res() res: Response,
  ): Promise<void> {
    const redirectUri = `${req.protocol}://${req.get('host')}/api/v1/auth/oauth2/${provider}/callback`;
    const state = this.authService.generateOAuthState();
    const codeVerifier = this.authService.generateCodeVerifier();

    if (req.session) {
      req.session[`oauth2_${provider}_state`] = state;
      req.session[`oauth2_${provider}_code_verifier`] = codeVerifier;
    }

    const authUrl = await this.authService.getOAuth2AuthorizationUrl(
      provider,
      redirectUri,
      state,
      codeVerifier,
    );

    res.redirect(authUrl);
  }

  @Public()
  @Get('oauth2/:provider/callback')
  @ApiOperation({ summary: 'OAuth2/OIDC callback handler' })
  async oauth2Callback(
    @Query() query: OAuth2CallbackDto,
    @Query('provider') provider: string,
    @Req() req: TenantAwareRequest & { session?: Record<string, unknown> },
  ): Promise<TokenResponseDto> {
    const redirectUri = `${req.protocol}://${req.get('host')}/api/v1/auth/oauth2/${provider}/callback`;

    return this.authService.handleOAuth2Callback(
      provider,
      query.code,
      query.state || '',
      redirectUri,
      req.companyId || '',
      req.session || {},
      req.ip,
      req.get('user-agent'),
    );
  }

  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Logout and revoke refresh token' })
  async logout(@Req() req: TenantAwareRequest & { user?: { userId: string } }): Promise<void> {
    if (req.user?.userId && req.companyId) {
      await this.authService.logout(req.user.userId, req.companyId);
    }
  }

  @Public()
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Request password reset - sends OTP to email' })
  @ApiHeader({
    name: 'x-company-id',
    description:
      'Company ID (UUID) for the tenant. This should be the company UUID resolved from the public lookup / company selection flow.',
    required: true,
    example: 'eb75a65b-055f-4408-a58c-71d233443c17',
  })
  async forgotPassword(
    @Body() forgotPasswordDto: ForgotPasswordDto,
    @Req() req: TenantAwareRequest,
  ): Promise<{ message: string }> {
    if (!req.companyId) {
      throw new BadRequestException('x-company-id header is required');
    }

    const companyId = req.companyId.trim();
    const isUuid =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        companyId,
      );

    if (!isUuid) {
      throw new BadRequestException(
        'x-company-id header must be a valid company UUID.',
      );
    }

    // Optional safety check - ensure company exists
    try {
      await this.tenantService.getCompanyById(companyId);
    } catch {
      throw new BadRequestException(`Invalid company id: ${companyId}`);
    }

    return this.passwordResetService.initiatePasswordReset(
      companyId,
      forgotPasswordDto.email,
      req.ip,
    );
  }

  @Public()
  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP and get reset token' })
  @ApiHeader({
    name: 'x-company-id',
    description:
      'Company ID (UUID) for the tenant. This should be the company UUID resolved from the public lookup / company selection flow.',
    required: true,
    example: 'eb75a65b-055f-4408-a58c-71d233443c17',
  })
  async verifyOtp(
    @Body() verifyOtpDto: VerifyOtpDto,
    @Req() req: TenantAwareRequest,
  ): Promise<{ token: string; message: string }> {
    if (!req.companyId) {
      throw new BadRequestException('x-company-id header is required');
    }

    const companyId = req.companyId.trim();
    const isUuid =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        companyId,
      );

    if (!isUuid) {
      throw new BadRequestException(
        'x-company-id header must be a valid company UUID.',
      );
    }

    // Optional safety check - ensure company exists
    try {
      await this.tenantService.getCompanyById(companyId);
    } catch {
      throw new BadRequestException(`Invalid company id: ${companyId}`);
    }

    return this.passwordResetService.verifyOtp(
      companyId,
      verifyOtpDto.email,
      verifyOtpDto.otp,
    );
  }

  @Public()
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reset password using token from OTP verification' })
  @ApiHeader({
    name: 'x-company-id',
    description:
      'Company ID (UUID) for the tenant. This should be the company UUID resolved from the public lookup / company selection flow.',
    required: true,
    example: 'eb75a65b-055f-4408-a58c-71d233443c17',
  })
  async resetPassword(
    @Body() resetPasswordDto: ResetPasswordDto,
    @Req() req: TenantAwareRequest,
  ): Promise<{ message: string }> {
    if (!req.companyId) {
      throw new BadRequestException('x-company-id header is required');
    }

    const companyId = req.companyId.trim();
    const isUuid =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        companyId,
      );

    if (!isUuid) {
      throw new BadRequestException(
        'x-company-id header must be a valid company UUID.',
      );
    }

    // Optional safety check - ensure company exists
    try {
      await this.tenantService.getCompanyById(companyId);
    } catch {
      throw new BadRequestException(`Invalid company id: ${companyId}`);
    }

    return this.passwordResetService.resetPassword(
      companyId,
      resetPasswordDto.email,
      resetPasswordDto.token,
      resetPasswordDto.newPassword,
    );
  }
}

