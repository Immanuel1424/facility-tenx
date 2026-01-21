import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  Issuer,
  Client,
  generators,
  TokenSet,
  UserinfoResponse,
} from 'openid-client';
import {
  OidcProviderConfig,
  OidcTokenResponse,
  OidcUserInfo,
} from '../interfaces/oidc-provider.interface';

@Injectable()
export class OidcService {
  private clients: Map<string, Client> = new Map();

  constructor(private readonly configService: ConfigService) {}

  generateState(): string {
    return generators.state();
  }

  generateCodeVerifier(): string {
    return generators.codeVerifier();
  }

  generateCodeChallenge(verifier: string): string {
    return generators.codeChallenge(verifier);
  }

  async getAuthorizationUrl(
    provider: string,
    redirectUri: string,
    state: string,
    codeChallenge?: string,
  ): Promise<string> {
    const client = await this.getClient(provider);
    const params: Record<string, string> = {
      redirect_uri: redirectUri,
      response_type: 'code',
      scope: 'openid email profile',
      state,
    };

    if (codeChallenge) {
      params.code_challenge = codeChallenge;
      params.code_challenge_method = 'S256';
    }

    return client.authorizationUrl(params);
  }

  async exchangeCodeForToken(
    provider: string,
    code: string,
    redirectUri: string,
    codeVerifier?: string,
  ): Promise<OidcTokenResponse> {
    const client = await this.getClient(provider);
    const params: Record<string, string> = {
      code,
      redirect_uri: redirectUri,
    };

    if (codeVerifier) {
      params.code_verifier = codeVerifier;
    }

    try {
      const tokenSet = await client.callback(redirectUri, params);
      return {
        access_token: tokenSet.access_token || '',
        refresh_token: tokenSet.refresh_token,
        id_token: tokenSet.id_token,
        expires_in: tokenSet.expires_in || 3600,
        token_type: tokenSet.token_type || 'Bearer',
      };
    } catch (error) {
      throw new UnauthorizedException(`OIDC token exchange failed: ${error}`);
    }
  }

  async getUserInfo(provider: string, accessToken: string): Promise<OidcUserInfo> {
    const client = await this.getClient(provider);
    try {
      const userInfo = await client.userinfo(accessToken);
      return userInfo as OidcUserInfo;
    } catch (error) {
      throw new UnauthorizedException(`Failed to fetch user info: ${error}`);
    }
  }

  private async getClient(provider: string): Promise<Client> {
    if (this.clients.has(provider)) {
      return this.clients.get(provider)!;
    }

    const config = this.getProviderConfig(provider);
    const issuer = await Issuer.discover(config.issuer);
    const client = new issuer.Client({
      client_id: config.clientId,
      client_secret: config.clientSecret,
      redirect_uris: [config.redirectUri],
      response_types: ['code'],
    });

    this.clients.set(provider, client);
    return client;
  }

  private getProviderConfig(provider: string): OidcProviderConfig {
    const prefix = `OIDC_${provider.toUpperCase()}_`;
    return {
      issuer: this.configService.get<string>(`${prefix}ISSUER`) || '',
      clientId: this.configService.get<string>(`${prefix}CLIENT_ID`) || '',
      clientSecret: this.configService.get<string>(`${prefix}CLIENT_SECRET`) || '',
      redirectUri: this.configService.get<string>(`${prefix}REDIRECT_URI`) || '',
      scopes: this.configService
        .get<string>(`${prefix}SCOPES`)
        ?.split(',')
        .map((s) => s.trim()) || ['openid', 'email', 'profile'],
    };
  }
}

