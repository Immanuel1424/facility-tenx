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
exports.OidcService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const openid_client_1 = require("openid-client");
let OidcService = class OidcService {
    constructor(configService) {
        this.configService = configService;
        this.clients = new Map();
    }
    generateState() {
        return openid_client_1.generators.state();
    }
    generateCodeVerifier() {
        return openid_client_1.generators.codeVerifier();
    }
    generateCodeChallenge(verifier) {
        return openid_client_1.generators.codeChallenge(verifier);
    }
    async getAuthorizationUrl(provider, redirectUri, state, codeChallenge) {
        const client = await this.getClient(provider);
        const params = {
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
    async exchangeCodeForToken(provider, code, redirectUri, codeVerifier) {
        const client = await this.getClient(provider);
        const params = {
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
        }
        catch (error) {
            throw new common_1.UnauthorizedException(`OIDC token exchange failed: ${error}`);
        }
    }
    async getUserInfo(provider, accessToken) {
        const client = await this.getClient(provider);
        try {
            const userInfo = await client.userinfo(accessToken);
            return userInfo;
        }
        catch (error) {
            throw new common_1.UnauthorizedException(`Failed to fetch user info: ${error}`);
        }
    }
    async getClient(provider) {
        if (this.clients.has(provider)) {
            return this.clients.get(provider);
        }
        const config = this.getProviderConfig(provider);
        const issuer = await openid_client_1.Issuer.discover(config.issuer);
        const client = new issuer.Client({
            client_id: config.clientId,
            client_secret: config.clientSecret,
            redirect_uris: [config.redirectUri],
            response_types: ['code'],
        });
        this.clients.set(provider, client);
        return client;
    }
    getProviderConfig(provider) {
        const prefix = `OIDC_${provider.toUpperCase()}_`;
        return {
            issuer: this.configService.get(`${prefix}ISSUER`) || '',
            clientId: this.configService.get(`${prefix}CLIENT_ID`) || '',
            clientSecret: this.configService.get(`${prefix}CLIENT_SECRET`) || '',
            redirectUri: this.configService.get(`${prefix}REDIRECT_URI`) || '',
            scopes: this.configService
                .get(`${prefix}SCOPES`)
                ?.split(',')
                .map((s) => s.trim()) || ['openid', 'email', 'profile'],
        };
    }
};
exports.OidcService = OidcService;
exports.OidcService = OidcService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], OidcService);
