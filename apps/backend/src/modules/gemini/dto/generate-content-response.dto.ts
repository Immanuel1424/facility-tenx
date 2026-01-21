import { ApiProperty } from '@nestjs/swagger';

export class GenerateContentResponseDto {
  @ApiProperty({
    description: 'The generated content from Gemini AI',
    example: 'Once upon a time, in a small workshop filled with brushes and canvases...',
  })
  content!: string;
}

