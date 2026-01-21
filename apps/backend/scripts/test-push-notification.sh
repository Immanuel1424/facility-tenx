#!/bin/bash

# Test Push Notification Script
# This script sends a test push notification to the authenticated user

# Configuration
API_BASE_URL="${API_BASE_URL:-http://localhost:3000/api/v1}"
COMPANY_ID="${COMPANY_ID:-eb75a65b-055f-4408-a58c-71d233443c17}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧪 Test Push Notification Script${NC}"
echo "=========================================="
echo ""

# Check if JWT token is provided
if [ -z "$JWT_TOKEN" ]; then
  echo -e "${RED}❌ Error: JWT_TOKEN environment variable is required${NC}"
  echo ""
  echo "Usage:"
  echo "  1. Login first to get JWT token:"
  echo "     curl -X POST $API_BASE_URL/auth/login \\"
  echo "       -H 'Content-Type: application/json' \\"
  echo "       -H 'x-company-id: $COMPANY_ID' \\"
  echo "       -d '{\"email\":\"your-email@example.com\",\"password\":\"your-password\"}'"
  echo ""
  echo "  2. Set JWT_TOKEN and run this script:"
  echo "     export JWT_TOKEN=\"your-jwt-token-here\""
  echo "     ./test-push-notification.sh"
  echo ""
  exit 1
fi

# Optional: Override title and body
TITLE="${TITLE:-Test Notification}"
BODY="${BODY:-This is a test push notification from the backend}"
TICKET_ID="${TICKET_ID:-}"

echo -e "${GREEN}📤 Sending test push notification...${NC}"
echo "  Title: $TITLE"
echo "  Body: $BODY"
if [ -n "$TICKET_ID" ]; then
  echo "  Ticket ID: $TICKET_ID"
fi
echo ""

# Prepare JSON payload
if [ -n "$TICKET_ID" ]; then
  PAYLOAD=$(cat <<EOF
{
  "title": "$TITLE",
  "body": "$BODY",
  "ticketId": "$TICKET_ID"
}
EOF
)
else
  PAYLOAD=$(cat <<EOF
{
  "title": "$TITLE",
  "body": "$BODY"
}
EOF
)
fi

# Send the request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE_URL/notifications/test/push" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "x-company-id: $COMPANY_ID" \
  -d "$PAYLOAD")

# Extract HTTP status code (last line)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
# Extract response body (all but last line)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check response
if [ "$HTTP_CODE" -eq 201 ] || [ "$HTTP_CODE" -eq 200 ]; then
  echo -e "${GREEN}✅ Success! Push notification sent${NC}"
  echo ""
  echo "Response:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
  echo ""
  echo -e "${GREEN}📱 Check your web browser for the notification!${NC}"
else
  echo -e "${RED}❌ Error: Failed to send notification${NC}"
  echo "HTTP Status: $HTTP_CODE"
  echo "Response:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
  exit 1
fi

