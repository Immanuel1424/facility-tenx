import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class AddNotesDto {
  @IsString()
  @IsNotEmpty()
  notes!: string;
}

