import { IsBoolean, IsOptional } from 'class-validator';

export class ConfirmCompletionDto {
  @IsBoolean()
  @IsOptional()
  confirmed?: boolean = true;
}

