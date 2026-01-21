import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface GeminiApiResponse {
  candidates?: Array<{
    content?: {
      parts?: Array<{
        text?: string;
      }>;
    };
  }>;
  error?: {
    message?: string;
    code?: number;
  };
}

@Injectable()
export class GeminiService {
  private readonly apiKey: string;
  private readonly baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  constructor(private readonly configService: ConfigService) {
    this.apiKey = this.configService.get<string>('GEMINI_API_KEY') || '';
  }

  async generateContent(prompt: string): Promise<string> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException(
        'Gemini API key is not configured. Please set GEMINI_API_KEY environment variable.',
      );
    }

    if (!prompt || prompt.trim().length === 0) {
      throw new ServiceUnavailableException('Prompt cannot be empty');
    }

    const endpoint = `${this.baseUrl}/gemini-flash-latest:generateContent`;
    const url = `${endpoint}?key=${this.apiKey}`;

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [{ text: prompt }],
            },
          ],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          },
        }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        const errorMessage = errorData.error?.message || `HTTP ${response.status}`;
        throw new ServiceUnavailableException(
          `Gemini API error: ${errorMessage}`,
        );
      }

      const data: GeminiApiResponse = await response.json();

      if (data.error) {
        throw new ServiceUnavailableException(
          `Gemini API error: ${data.error.message || 'Unknown error'}`,
        );
      }

      const candidates = data.candidates;
      if (!candidates || candidates.length === 0) {
        throw new ServiceUnavailableException('No response candidates from Gemini API');
      }

      const content = candidates[0].content;
      if (!content) {
        throw new ServiceUnavailableException('No content in Gemini response');
      }

      const parts = content.parts;
      if (!parts || parts.length === 0) {
        throw new ServiceUnavailableException('No content parts in Gemini response');
      }

      const text = parts[0].text;
      if (!text || text.trim().length === 0) {
        throw new ServiceUnavailableException('Empty text in Gemini response');
      }

      return text;
    } catch (error) {
      if (error instanceof ServiceUnavailableException) {
        throw error;
      }
      throw new ServiceUnavailableException(
        `Failed to call Gemini API: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }
}

