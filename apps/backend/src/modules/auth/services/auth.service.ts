import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuthJwtService } from './jwt.service';
import { OidcService } from './oidc.service';
import { UserService } from '../../iam/services/user.service';
import { PermissionService } from '../../iam/services/permission.service';
import { RefreshTokenService } from '../../iam/services/refresh-token.service';
import { TenantService } from '../../tenant/tenant.service';
import { UserSiteService } from '../../tenant/services/user-site.service';
import { User, AuthProvider } from '../../iam/entities/user.entity';
import { TokenResponseDto } from '../dto/token-response.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: AuthJwtService,
    private readonly oidcService: OidcService,
    private readonly userService: UserService,
    private readonly permissionService: PermissionService,
    private readonly refreshTokenService: RefreshTokenService,
    private readonly tenantService: TenantService,
    private readonly userSiteService: UserSiteService,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async login(
    siteCode: string,
    email: string,
    password: string,
    companyId?: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<TokenResponseDto> {
    const normalizedSiteCode = (siteCode || '').trim().toUpperCase();

    // SYSTEM / SUPER_ADMIN login path: no site context, only SYSTEM company
    if (!normalizedSiteCode || normalizedSiteCode === 'SYSTEM') {
      // Lookup SYSTEM company by code
      const systemCompany = await this.tenantService.getCompanyByCode('SYSTEM');
      const systemCompanyId = systemCompany.id;

      // Find user by email within SYSTEM company
      const user = await this.userService.findByEmail(systemCompanyId, email);

      if (!user || !user.passwordHash) {
        throw new UnauthorizedException('Invalid credentials');
      }

      // Verify password
      const isValid = await this.userService.validatePassword(
        password,
        user.passwordHash,
      );

      if (!isValid) {
        throw new UnauthorizedException('Invalid credentials');
      }

      // Ensure user has SUPER_ADMIN role when logging in without site context
      const roles = await this.userService.getUserRoles(systemCompanyId, user.id);
      const isSuperAdmin = roles.some(
        (r) => r.name.toUpperCase() === 'SUPER_ADMIN',
      );

      if (!isSuperAdmin) {
        throw new UnauthorizedException(
          'Only SUPER_ADMIN users can login without a site code',
        );
      }

      await this.userService.updateLastLogin(systemCompanyId, user.id);

      const permissions =
        await this.permissionService.getUserPermissions(systemCompanyId, user.id);

      const companyName = systemCompany.name;

      const accessToken = await this.jwtService.generateAccessToken({
        sub: user.id,
        email: user.email,
        companyId: systemCompanyId,
        companyName,
        // No concrete site context for SYSTEM login
        siteId: '',
        siteCode: 'SYSTEM',
        roles: roles.map((r) => r.name),
        permissions: permissions.map((p) => `${p.resource}:${p.action}`),
      });

      const refreshToken = await this.jwtService.generateRefreshToken(
        user.id,
        systemCompanyId,
        '',
        ipAddress,
        userAgent,
      );

      return {
        accessToken,
        refreshToken,
        expiresIn: 900,
        tokenType: 'Bearer',
      };
    }

    // Normal site-scoped login path
    // Strategy: If companyId is provided, use it. Otherwise, find user first to get their companyId,
    // then scope site lookup to that company. This prevents finding wrong site when site codes
    // are not globally unique.
    let resolvedCompanyId = companyId;
    let user: User | null = null;

    if (!resolvedCompanyId) {
      // No companyId provided - find user first to get their company
      // Search across all companies (site codes might not be globally unique)
      user = await this.userRepository.findOne({
        where: { email: email.toLowerCase() },
        relations: ['userRoles', 'userRoles.role'],
      });

      if (!user) {
        throw new UnauthorizedException('Invalid credentials');
      }

      resolvedCompanyId = user.companyId;
      console.log(
        `[AuthService] No companyId provided, found user in company: ${resolvedCompanyId}`,
      );
    }

    // Find site by code within the resolved company
    const site = await this.tenantService.getSiteByCode(
      normalizedSiteCode,
      resolvedCompanyId,
    );

    if (!site.isActive) {
      throw new UnauthorizedException('Site is inactive');
    }

    if (!resolvedCompanyId) {
      resolvedCompanyId = site.companyId;
    }

    if (!resolvedCompanyId) {
      throw new BadRequestException('Site is not associated with a company');
    }

    // Find user by email within the company (if not already found)
    if (!user) {
      user = await this.userService.findByEmail(resolvedCompanyId, email);
    }

    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isValid = await this.userService.validatePassword(
      password,
      user.passwordHash,
    );

    if (!isValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify user is assigned to this site (unless SUPER_ADMIN)
    const isSuperAdmin = user.userRoles?.some(
      (ur) => ur.role?.name?.toUpperCase() === 'SUPER_ADMIN',
    );

    if (!isSuperAdmin) {
      // Debug logging
      console.log(
        `[AuthService] Checking user-site assignment: ` +
          `companyId=${resolvedCompanyId}, userId=${user.id}, siteId=${site.id}, ` +
          `siteCode=${normalizedSiteCode}, userCompanyId=${user.companyId}`,
      );

      const isAssigned = await this.userSiteService.isUserAssignedToSite(
        resolvedCompanyId,
        user.id,
        site.id,
      );

      if (!isAssigned) {
        console.error(
          `[AuthService] User-site assignment check failed: ` +
            `companyId=${resolvedCompanyId}, userId=${user.id}, siteId=${site.id}`,
        );
        throw new UnauthorizedException(
          `User is not assigned to site '${normalizedSiteCode}'. ` +
            `Please contact an administrator to assign you to this site, or use the assignment API endpoint.`,
        );
      }
    }

    await this.userService.updateLastLogin(resolvedCompanyId, user.id);

    const permissions =
      await this.permissionService.getUserPermissions(resolvedCompanyId, user.id);
    const roles = await this.userService.getUserRoles(resolvedCompanyId, user.id);

    // Fetch company name
    let companyName: string | undefined;
    try {
      const company = await this.tenantService.getCompanyById(resolvedCompanyId);
      companyName = company.name;
    } catch (error) {
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

    const refreshToken = await this.jwtService.generateRefreshToken(
      user.id,
      resolvedCompanyId,
      site.id,
      ipAddress,
      userAgent,
    );

    return {
      accessToken,
      refreshToken,
      expiresIn: 900,
      tokenType: 'Bearer',
    };
  }

  async refreshToken(
    refreshToken: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<TokenResponseDto> {
    const payload = await this.jwtService.verifyRefreshToken(refreshToken);

    const companyId = payload.companyId;
    const siteId = payload.siteId;

    const user = await this.userService.findById(companyId, payload.sub);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    const permissions =
      await this.permissionService.getUserPermissions(companyId, user.id);
    const roles = await this.userService.getUserRoles(companyId, user.id);

    // Fetch company name
    let companyName: string | undefined;
    try {
      const company = await this.tenantService.getCompanyById(companyId);
      companyName = company.name;
    } catch (error) {
      console.warn(`Company with id ${companyId} not found:`, error);
    }

    // SYSTEM / SUPER_ADMIN refresh: no site context in token
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

      const newRefreshToken = await this.jwtService.generateRefreshToken(
        user.id,
        companyId,
        '',
        ipAddress,
        userAgent,
      );

      await this.refreshTokenService.revoke(payload.tokenId, companyId);

      return {
        accessToken,
        refreshToken: newRefreshToken,
        expiresIn: 900,
        tokenType: 'Bearer',
      };
    }

    // Site-scoped refresh path
    // Get site to retrieve siteCode
    const site = await this.tenantService.getSiteById(siteId);
    if (site.companyId !== companyId) {
      throw new UnauthorizedException('Invalid token: site-company mismatch');
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

    const newRefreshToken = await this.jwtService.generateRefreshToken(
      user.id,
      companyId,
      site.id,
      ipAddress,
      userAgent,
    );

    await this.refreshTokenService.revoke(payload.tokenId, companyId);

    return {
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: 900,
      tokenType: 'Bearer',
    };
  }

  generateOAuthState(): string {
    return this.oidcService.generateState();
  }

  generateCodeVerifier(): string {
    return this.oidcService.generateCodeVerifier();
  }

  async getOAuth2AuthorizationUrl(
    provider: string,
    redirectUri: string,
    state: string,
    codeVerifier: string,
  ): Promise<string> {
    const codeChallenge = this.oidcService.generateCodeChallenge(codeVerifier);
    return this.oidcService.getAuthorizationUrl(
      provider,
      redirectUri,
      state,
      codeChallenge,
    );
  }

  async handleOAuth2Callback(
    provider: string,
    code: string,
    state: string,
    redirectUri: string,
    companyId: string,
    session: Record<string, unknown>,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<TokenResponseDto> {
    const storedState = session[`oauth2_${provider}_state`] as string;
    const codeVerifier = session[`oauth2_${provider}_code_verifier`] as string;

    if (!storedState || storedState !== state) {
      throw new BadRequestException('Invalid state parameter');
    }

    const tokenResponse = await this.oidcService.exchangeCodeForToken(
      provider,
      code,
      redirectUri,
      codeVerifier,
    );

    const userInfo = await this.oidcService.getUserInfo(
      provider,
      tokenResponse.access_token,
    );

    const authProvider = this.mapProviderName(provider);
    const user = await this.userService.createOrUpdateOidcUser(
      companyId,
      userInfo.sub,
      authProvider,
      userInfo.email,
      {
        firstName: userInfo.given_name,
        lastName: userInfo.family_name,
        emailVerified: userInfo.email_verified,
      },
    );

    const permissions =
      await this.permissionService.getUserPermissions(companyId, user.id);
    const roles = await this.userService.getUserRoles(companyId, user.id);

    // Fetch company name
    let companyName: string | undefined;
    try {
      const company = await this.tenantService.getCompanyById(companyId);
      companyName = company.name;
    } catch (error) {
      // If company not found, continue without company name
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

    const refreshToken = await this.jwtService.generateRefreshToken(
      user.id,
      companyId,
      '',
      ipAddress,
      userAgent,
    );

    delete session[`oauth2_${provider}_state`];
    delete session[`oauth2_${provider}_code_verifier`];

    return {
      accessToken,
      refreshToken,
      expiresIn: 900,
      tokenType: 'Bearer',
    };
  }

  async logout(userId: string, companyId: string): Promise<void> {
    await this.refreshTokenService.revokeAllUserTokens(userId, companyId);
  }

  private mapProviderName(provider: string): AuthProvider {
    const mapping: Record<string, AuthProvider> = {
      azure_ad: AuthProvider.AZURE_AD,
      okta: AuthProvider.OKTA,
      auth0: AuthProvider.AUTH0,
      keycloak: AuthProvider.KEYCLOAK,
    };

    return mapping[provider.toLowerCase()] || AuthProvider.LOCAL;
  }
}

