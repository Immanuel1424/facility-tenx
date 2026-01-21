import { Injectable, BadRequestException, ServiceUnavailableException } from '@nestjs/common';
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
export class GeminiAiService {
  private readonly apiKey: string;
  private readonly baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  constructor(private readonly configService: ConfigService) {
    this.apiKey = this.configService.get<string>('GEMINI_API_KEY') || '';
  }

  async analyzeTicketDescription(description: string): Promise<any> {
    if (!this.apiKey) {
      throw new ServiceUnavailableException(
        'Gemini API key is not configured. Please set GEMINI_API_KEY environment variable.',
      );
    }

    if (!description || description.trim().length < 10) {
      throw new BadRequestException('Description must be at least 10 characters long');
    }

    const prompt = this.createAnalysisPrompt(description);
    const endpoints = [
      `${this.baseUrl}/gemini-flash-latest:generateContent`,
      `${this.baseUrl}/gemini-pro:generateContent`,
      `${this.baseUrl}/gemini-pro:generateContent`.replace('/v1beta/', '/v1/'),
    ];

    let lastError: string | null = null;

    for (const endpoint of endpoints) {
      try {
        const response = await fetch(`${endpoint}?key=${this.apiKey}`, {
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
              temperature: 0.3,
              topK: 40,
              topP: 0.95,
              maxOutputTokens: 1024,
            },
          }),
        });

        if (!response.ok) {
          const errorData = await response.json().catch(() => ({}));
          lastError = errorData.error?.message || `HTTP ${response.status}`;
          continue;
        }

        const data: GeminiApiResponse = await response.json();

        if (data.error) {
          lastError = data.error.message || 'Unknown error';
          continue;
        }

        return this.processGeminiResponse(data);
      } catch (error) {
        lastError = error instanceof Error ? error.message : String(error);
        continue;
      }
    }

    throw new ServiceUnavailableException(
      `Gemini API error: All endpoints failed. Last error: ${lastError || 'Unknown error'}`,
    );
  }

  private createAnalysisPrompt(description: string): string {
    return `You are an AI assistant that analyzes maintenance ticket descriptions and extracts structured information.

Analyze the following maintenance request description and return a JSON object with the following structure:
{
  "title": "A concise, descriptive title (max 100 characters)",
  "category": "One of: ELECTRICAL, PLUMBING, AIR_CONDITIONING, CARPENTRY, MECHANICAL, FIRE, CIVIL, DATA_CCTV, MISCELLANEOUS, OTHER",
  "priority": "One of: LOW, MEDIUM, HIGH, URGENT",
  "description": "A refined, professional description of the issue",
  "location": "The location where the issue occurs (e.g., 'Living Room', 'Kitchen', 'Bedroom 2')",
  "contact_number": "Extracted phone number if mentioned, otherwise null",
  "preferred_time": "Preferred time for visit if mentioned, otherwise null"
}

Guidelines:
- Title should be clear and specific (e.g., "AC Not Cooling in Living Room")
- Category should match the type of maintenance needed
- Priority: URGENT for safety issues (fire, electrical hazards), HIGH for critical systems (AC in summer, plumbing leaks), MEDIUM for general issues, LOW for minor/non-urgent
- Description should be professional and detailed
- Location should be specific if mentioned
- Extract contact number only if clearly mentioned
- Extract preferred time only if mentioned

User's description:
${description}

Return ONLY the JSON object, no additional text or markdown formatting.`;
  }

  private processGeminiResponse(responseData: GeminiApiResponse): any {
    const candidates = responseData.candidates;
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

    // Extract JSON from text (remove markdown code blocks if present)
    let cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      const lines = cleaned.split('\n');
      if (lines[0].includes('```')) {
        cleaned = lines.slice(1).join('\n');
      }
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3).trim();
      }
    }

    // Find JSON object boundaries
    const jsonStart = cleaned.indexOf('{');
    const jsonEnd = cleaned.lastIndexOf('}');
    if (jsonStart !== -1 && jsonEnd !== -1 && jsonEnd > jsonStart) {
      cleaned = cleaned.substring(jsonStart, jsonEnd + 1);
    }

    try {
      const jsonData = JSON.parse(cleaned);
      
      // Ensure all fields match frontend DTO format
      // Frontend expects: title, category, priority, description, location, contact_number, preferred_time
      const result: any = {
        title: jsonData.title || '',
        category: jsonData.category || 'MISCELLANEOUS',
        priority: jsonData.priority || 'MEDIUM',
      };

      // Only include optional fields if they exist and are not null/empty
      if (jsonData.description && jsonData.description.trim()) {
        result.description = jsonData.description;
      }
      
      if (jsonData.location && jsonData.location.trim()) {
        result.location = jsonData.location;
      }
      
      const contactNumber = jsonData.contact_number || jsonData.contactNumber;
      if (contactNumber && contactNumber.trim()) {
        result.contact_number = contactNumber;
      }
      
      const preferredTime = jsonData.preferred_time || jsonData.preferredTime;
      if (preferredTime && preferredTime.trim()) {
        result.preferred_time = preferredTime;
      }

      return result;
    } catch (error) {
      throw new ServiceUnavailableException(
        `Failed to parse Gemini response: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }
}

