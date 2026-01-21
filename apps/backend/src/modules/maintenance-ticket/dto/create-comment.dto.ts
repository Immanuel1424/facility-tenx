import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEnum,
  IsUUID,
  MaxLength,
} from 'class-validator';
import { Expose } from 'class-transformer';
import { CommentType } from '../entities/ticket-comment.entity';

export class CreateCommentDto {
  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(5000)
  content!: string;

  @Expose()
  @IsEnum(CommentType)
  @IsOptional()
  comment_type?: CommentType;

  @Expose()
  @IsUUID()
  @IsOptional()
  parent_comment_id?: string;
}

