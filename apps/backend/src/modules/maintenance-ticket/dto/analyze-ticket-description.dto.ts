import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AnalyzeTicketDescriptionDto {
  @ApiProperty({
    description: 'The ticket description to analyze',
    example: 'The air conditioning in my living room stopped working yesterday. It\'s making a loud noise and not cooling at all.',
    minLength: 10,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(10, { message: 'Description must be at least 10 characters long' })
  description!: string;
}

