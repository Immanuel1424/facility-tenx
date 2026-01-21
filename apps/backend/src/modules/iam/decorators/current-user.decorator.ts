import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export interface CurrentUserData {
  userId: string;
  email: string;
  companyId: string;
  siteId?: string;
  roles?: string[];
  permissions?: string[];
}

export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext): CurrentUserData | string | string[] | undefined => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as CurrentUserData;
    
    if (!user) {
      return undefined;
    }
    
    // If a property name is provided, return that property
    if (data) {
      const value = user[data as keyof CurrentUserData];
      return value;
    }
    
    // Otherwise return the entire user object
    return user;
  },
);

