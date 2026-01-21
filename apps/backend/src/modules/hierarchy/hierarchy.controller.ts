import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
  Version,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { HierarchyService } from './hierarchy.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { TenantGuard } from '../../shared/guards/tenant.guard';
import { PermissionGuard } from '../iam/guards/permission.guard';
import { RequirePermission } from '../iam/decorators/require-permission.decorator';
import { CurrentUser } from '../iam/decorators/current-user.decorator';
import { CurrentUserData } from '../iam/decorators/current-user.decorator';
import { CreateHierarchyNodeDto } from './dto/create-hierarchy-node.dto';

@ApiTags('hierarchy')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard, PermissionGuard)
@Controller('hierarchy')
export class HierarchyController {
  constructor(private readonly hierarchyService: HierarchyService) {}

  @Post('nodes')
  @Version('1')
  @RequirePermission('hierarchy', 'write')
  @ApiOperation({ summary: 'Create a hierarchy node for current company' })
  async createNode(
    @CurrentUser() currentUser: CurrentUserData,
    @Body() dto: CreateHierarchyNodeDto,
  ) {
    return this.hierarchyService.createNode(currentUser.companyId, dto);
  }

  @Get('nodes/:id/children')
  @Version('1')
  @RequirePermission('hierarchy', 'read')
  @ApiOperation({ summary: 'Get children of a hierarchy node' })
  async getSubtree(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') id: string,
  ) {
    return this.hierarchyService.getSubtree(currentUser.companyId, id);
  }
}


