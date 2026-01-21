import {
  IsString,
  IsNotEmpty,
  MaxLength,
} from 'class-validator';
import { Expose } from 'class-transformer';

export class UpdateCommentDto {
  @Expose()
  @IsString()
  @IsNotEmpty()
  @MaxLength(5000)
  content!: string;
}

