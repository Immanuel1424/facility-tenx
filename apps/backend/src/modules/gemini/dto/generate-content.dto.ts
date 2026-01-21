import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GenerateContentDto {
  @ApiProperty({
    description: 'The prompt/text to send to Gemini AI',
    example: 'Write a short story about a robot learning to paint.',
  })
  @IsString()
  @IsNotEmpty()
  prompt!: string;
}

