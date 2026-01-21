import { ApiProperty } from '@nestjs/swagger';

export class AiTicketAnalysisResponseDto {
  @ApiProperty({
    description: 'Generated ticket title',
    example: 'AC Not Working in Living Room',
  })
  title!: string;

  @ApiProperty({
    description: 'Detected ticket category',
    enum: [
      'ELECTRICAL',
      'PLUMBING',
      'AIR_CONDITIONING',
      'CARPENTRY',
      'MECHANICAL',
      'FIRE',
      'CIVIL',
      'DATA_CCTV',
      'MISCELLANEOUS',
      'OTHER',
    ],
    example: 'AIR_CONDITIONING',
  })
  category!: string;

  @ApiProperty({
    description: 'Detected priority level',
    enum: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'],
    example: 'HIGH',
  })
  priority!: string;

  @ApiProperty({
    description: 'Refined description',
    required: false,
    example: 'Air conditioning unit in living room has stopped functioning. Unit is making loud noise and not providing cooling.',
  })
  description?: string;

  @ApiProperty({
    description: 'Location where the issue occurs',
    required: false,
    example: 'Living Room',
  })
  location?: string;

  @ApiProperty({
    description: 'Contact number if mentioned',
    required: false,
    example: null,
  })
  contact_number?: string;

  @ApiProperty({
    description: 'Preferred time for visit if mentioned',
    required: false,
    example: null,
  })
  preferred_time?: string;
}

