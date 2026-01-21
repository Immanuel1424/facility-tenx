# Gemini API Migration to Backend

## Overview

The Gemini API integration has been moved from the frontend to the backend for improved security and better architecture.

## Changes Made

### Backend Changes

1. **New Service**: `apps/backend/src/modules/maintenance-ticket/services/gemini-ai.service.ts`
   - Handles all Gemini API calls
   - Uses Node.js native `fetch` API
   - Implements error handling and retry logic

2. **New DTOs**:
   - `analyze-ticket-description.dto.ts` - Request DTO
   - `ai-ticket-analysis-response.dto.ts` - Response DTO

3. **New Endpoint**: `POST /api/v1/maintenance-tickets/analyze-description`
   - Requires authentication (JWT)
   - Requires TENANT or ADMIN role
   - Accepts description text
   - Returns structured analysis

4. **Module Updates**:
   - Added `GeminiAiService` to `maintenance-ticket.module.ts`
   - Added endpoint to `maintenance-ticket.controller.ts`

### Frontend Changes

1. **Service Updated**: `apps/frontend/lib/src/features/maintenance_ticket/data/services/ai_ticket_service.dart`
   - Now calls backend API endpoint instead of Gemini directly
   - Removed all Gemini API key handling
   - Simplified implementation

2. **ApiClient**: Added `analyzeTicketDescription` method
   - Calls `/maintenance-tickets/analyze-description`
   - Uses standard API client with authentication

3. **Configuration Removed**:
   - Removed `GEMINI_API_KEY` from `app_config.dart`
   - Removed `GEMINI_API_KEY` from `docker-entrypoint.sh`
   - Removed `GEMINI_API_KEY` from `docker-compose.prod.yml` frontend service

4. **Service Locator**: Updated to pass `ApiClient` instead of API key

## Configuration

### Backend Environment Variable

Add `GEMINI_API_KEY` to your backend `.env` file:

```env
# Gemini AI API Key (for AI ticket analysis feature)
# Get your key from: https://makersuite.google.com/app/apikey
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

**Location**: `apps/backend/.env`

### Production Deployment

For production, add `GEMINI_API_KEY` to your backend environment variables:

```yaml
# docker-compose.prod.yml (backend service)
environment:
  # ... other variables ...
  GEMINI_API_KEY: ${GEMINI_API_KEY:-}
```

And in your `.env` file:

```env
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

## API Endpoint

### Request

```http
POST /api/v1/maintenance-tickets/analyze-description
Content-Type: application/json
Authorization: Bearer <access_token>

{
  "description": "The air conditioning in my living room stopped working yesterday."
}
```

### Response

```json
{
  "title": "AC Not Working in Living Room",
  "category": "AIR_CONDITIONING",
  "priority": "HIGH",
  "description": "Air conditioning unit in living room has stopped functioning.",
  "location": "Living Room",
  "contact_number": null,
  "preferred_time": null
}
```

## Benefits

1. **Security**: API key is stored only on the backend, never exposed to clients
2. **Rate Limiting**: Can be implemented at backend level
3. **Caching**: Can cache responses at backend level
4. **Monitoring**: Easier to monitor and log API usage
5. **Error Handling**: Centralized error handling and retry logic
6. **Cost Control**: Better visibility and control over API usage

## Migration Steps

1. ✅ Backend service created
2. ✅ Backend endpoint added
3. ✅ Frontend service updated
4. ✅ Frontend configuration cleaned up
5. ⏳ Add `GEMINI_API_KEY` to backend `.env`
6. ⏳ Test the endpoint
7. ⏳ Deploy

## Testing

### Test Backend Endpoint

```bash
# Get access token first
TOKEN="your_jwt_token"

# Test the endpoint
curl -X POST http://localhost:3000/api/v1/maintenance-tickets/analyze-description \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-company-id: your-company-id" \
  -d '{
    "description": "The air conditioning in my living room stopped working yesterday."
  }'
```

### Test from Frontend

1. Navigate to AI ticket creation page
2. Enter a description
3. Click analyze
4. Verify structured data is returned

## Troubleshooting

### Backend Error: "Gemini API key is not configured"

**Solution**: Add `GEMINI_API_KEY` to `apps/backend/.env` file

### Backend Error: "All endpoints failed"

**Check**:
- API key is valid
- API key has Generative Language API enabled
- Network connectivity from backend server

**Solution**: Verify API key at https://makersuite.google.com/app/apikey

### Frontend Error: 401 Unauthorized

**Solution**: Ensure user is logged in and has TENANT or ADMIN role

### Frontend Error: 403 Forbidden

**Solution**: Ensure user has TENANT or ADMIN role

## Rollback Plan

If needed, you can rollback by:

1. Revert frontend service to call Gemini directly
2. Add `GEMINI_API_KEY` back to frontend configuration
3. Remove backend endpoint

However, the backend approach is recommended for security reasons.

