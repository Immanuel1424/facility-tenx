#!/bin/bash

# Simple test script for local storage upload
# Usage: ./scripts/test-local-upload-simple.sh [TICKET_ID]

set -e

API_URL="http://localhost:3000/api/v1"
TICKET_ID="${1:-}"

echo "🧪 Testing Local Storage Upload"
echo "=================================="
echo ""

# Step 1: Login
echo "📋 Step 1: Authenticate"
echo "------------------------"
TOKEN=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "siteCode": "",
    "email": "superadmin@system.local",
    "password": "SuperAdmin@2025!"
  }' | jq -r '.data.accessToken // .accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "❌ Authentication failed"
  exit 1
fi

echo "✅ Authentication successful"
echo ""

# Step 2: Get ticket ID if not provided
if [ -z "$TICKET_ID" ]; then
  echo "📋 Step 2: Get Ticket ID"
  echo "------------------------"
  echo "⚠️  No ticket ID provided. Please provide a ticket ID as argument:"
  echo "   ./scripts/test-local-upload-simple.sh <ticket-id>"
  echo ""
  echo "Or get a ticket ID from the database:"
  echo "   psql -d facility_erp -c \"SELECT id, title FROM maintenance_ticket LIMIT 1;\""
  exit 1
fi

echo "📋 Step 2: Using Ticket ID: $TICKET_ID"
echo ""

# Step 3: Create test image
echo "📋 Step 3: Create Test Image"
echo "------------------------"
TEST_IMAGE="/tmp/test-upload-$(date +%s).jpg"
# Create a 1KB test image (simple JPEG header + data)
echo -n -e '\xFF\xD8\xFF\xE0\x00\x10JFIF' > "$TEST_IMAGE"
dd if=/dev/zero of="$TEST_IMAGE" bs=1 count=1017 seek=7 2>/dev/null
echo "✅ Created test image: $TEST_IMAGE ($(stat -f%z "$TEST_IMAGE" 2>/dev/null || stat -c%s "$TEST_IMAGE" 2>/dev/null) bytes)"
echo ""

# Step 4: Upload image
echo "📋 Step 4: Upload Image"
echo "------------------------"
UPLOAD_URL="$API_URL/maintenance-tickets/$TICKET_ID/attachments/upload"

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$UPLOAD_URL" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@$TEST_IMAGE;type=image/jpeg")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
  echo "✅ Upload successful!"
  echo ""
  echo "Response:"
  echo "$BODY" | jq '.'
  echo ""
  
  # Extract storage path and URL
  STORAGE_PATH=$(echo "$BODY" | jq -r '.data.storagePath // .storagePath')
  STORAGE_URL=$(echo "$BODY" | jq -r '.data.storageUrl // .storageUrl')
  
  if [ -n "$STORAGE_PATH" ] && [ "$STORAGE_PATH" != "null" ]; then
    echo "📋 Step 5: Verify File on Disk"
    echo "------------------------"
    UPLOADS_DIR="${UPLOADS_DIR:-uploads}"
    EXPECTED_FILE="$(pwd)/$UPLOADS_DIR/$STORAGE_PATH"
    
    if [ -f "$EXPECTED_FILE" ]; then
      FILE_SIZE=$(stat -f%z "$EXPECTED_FILE" 2>/dev/null || stat -c%s "$EXPECTED_FILE" 2>/dev/null)
      echo "✅ File exists on disk!"
      echo "   Path: $EXPECTED_FILE"
      echo "   Size: $FILE_SIZE bytes"
    else
      echo "❌ File NOT found on disk!"
      echo "   Expected: $EXPECTED_FILE"
      echo "   Check STORAGE_PROVIDER=local is set"
    fi
    echo ""
    
    echo "📋 Step 6: Test File Access"
    echo "------------------------"
    if [ -n "$STORAGE_URL" ] && [ "$STORAGE_URL" != "null" ]; then
      FILE_URL="$STORAGE_URL"
      if [[ ! "$FILE_URL" =~ ^http ]]; then
        FILE_URL="http://localhost:3000$FILE_URL"
      fi
      
      HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FILE_URL")
      if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ File accessible via URL: $FILE_URL"
      else
        echo "⚠️  File not accessible via URL (HTTP $HTTP_CODE)"
        echo "   URL: $FILE_URL"
      fi
    fi
  fi
else
  echo "❌ Upload failed (HTTP $HTTP_CODE)"
  echo "Response:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
  rm -f "$TEST_IMAGE"
  exit 1
fi

# Cleanup
rm -f "$TEST_IMAGE"

echo ""
echo "=================================="
echo "✅ Test completed successfully!"
echo "=================================="
