import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Version,
  UseGuards,
} from '@nestjs/common';
import { ApiOperation, ApiTags, ApiOkResponse, ApiBearerAuth } from '@nestjs/swagger';
import { GeminiService } from './gemini.service';
import { GenerateContentDto } from './dto/generate-content.dto';
import { GenerateContentResponseDto } from './dto/generate-content-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { TenantGuard } from '../../shared/guards/tenant.guard';

@ApiTags('gemini')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('gemini')
export class GeminiController {
  constructor(private readonly geminiService: GeminiService) {}

  @Post('generate-content')
  @Version('1')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Generate content using Gemini AI' })
  @ApiOkResponse({
    description: 'Content generated successfully',
    type: GenerateContentResponseDto,
  })
  async generateContent(
    @Body() dto: GenerateContentDto,
  ): Promise<GenerateContentResponseDto> {
    const content = await this.geminiService.generateContent(dto.prompt);
    return { content };
  }
}

