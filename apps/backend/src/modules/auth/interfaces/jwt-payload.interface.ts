export interface JwtPayload {
  sub: string;
  email: string;
  companyId: string;
  companyName?: string;
  siteId: string;
  siteCode: string;
  roles?: string[];
  permissions?: string[];
  iat?: number;
  exp?: number;
}

export interface JwtRefreshPayload {
  sub: string;
  tokenId: string;
  companyId: string;
  siteId: string;
  iat?: number;
  exp?: number;
}

