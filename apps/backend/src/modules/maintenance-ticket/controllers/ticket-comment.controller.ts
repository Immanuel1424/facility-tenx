import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
  Version,
} from '@nestjs/common';
import { TicketCommentService } from '../services/ticket-comment.service';
import { CreateCommentDto } from '../dto/create-comment.dto';
import { UpdateCommentDto } from '../dto/update-comment.dto';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { RolesGuard, RequireRoles } from '../guards/roles.guard';
import { UserRole } from '../enums/user-role.enum';
import { ApiResponseUtil } from '../../../shared/utils/api-response.util';
import { AddNotesDto } from '../dto/add-notes.dto';

@Controller('maintenance-tickets/:ticketId/comments')
@UseGuards(RolesGuard)
export class TicketCommentController {
  constructor(private readonly commentService: TicketCommentService) {}

  @Post()
  @Version('1')
  async create(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Body() createDto: CreateCommentDto,
  ) {
    const comment = await this.commentService.create(
      user.companyId,
      ticketId,
      user.userId,
      user.roles || [],
      createDto,
    );
    return ApiResponseUtil.created(comment, 'Comment added successfully');
  }

  @Get()
  @Version('1')
  async findAll(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
  ) {
    const comments = await this.commentService.findAllByTicket(
      user.companyId,
      ticketId,
      user.roles || [],
    );
    return ApiResponseUtil.success(comments, 'Comments retrieved successfully');
  }

  @Get(':commentId')
  @Version('1')
  async findOne(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Param('commentId') commentId: string,
  ) {
    const comment = await this.commentService.findOne(
      user.companyId,
      ticketId,
      commentId,
      user.roles || [],
    );
    return ApiResponseUtil.success(comment, 'Comment retrieved successfully');
  }

  @Put(':commentId')
  @Version('1')
  async update(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Param('commentId') commentId: string,
    @Body() updateDto: UpdateCommentDto,
  ) {
    const comment = await this.commentService.update(
      user.companyId,
      ticketId,
      commentId,
      user.userId,
      user.roles || [],
      updateDto,
    );
    return ApiResponseUtil.success(comment, 'Comment updated successfully');
  }

  @Delete(':commentId')
  @Version('1')
  @HttpCode(HttpStatus.OK)
  async delete(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Param('commentId') commentId: string,
  ) {
    await this.commentService.delete(
      user.companyId,
      ticketId,
      commentId,
      user.userId,
      user.roles || [],
    );
    return ApiResponseUtil.noContent('Comment deleted successfully');
  }

  @Post('internal-note')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async addInternalNote(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Body() notesDto: AddNotesDto,
  ) {
    const comment = await this.commentService.addInternalNote(
      user.companyId,
      ticketId,
      user.userId,
      notesDto.notes,
    );
    return ApiResponseUtil.created(comment, 'Internal note added successfully');
  }

  @Post('work-note')
  @Version('1')
  @RequireRoles(
    UserRole.ADMIN,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async addWorkNote(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Body() notesDto: AddNotesDto,
  ) {
    const comment = await this.commentService.addWorkNote(
      user.companyId,
      ticketId,
      user.userId,
      notesDto.notes,
    );
    return ApiResponseUtil.created(comment, 'Work note added successfully');
  }
}

