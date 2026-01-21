#!/bin/bash

# Test script for villa type auto-fill functionality
# Requires: Backend running, valid JWT token

BASE_URL="${BASE_URL:-http://localhost:3000/api/v1}"
TOKEN="${TOKEN:-your-jwt-token-here}"

echo "🧪 Testing Villa Type Auto-Fill Functionality"
echo "=============================================="
echo ""

# Test 1: Get Villa Types (Lookup Endpoint)
echo "1️⃣ Testing GET /lookup/villa-types"
echo "-----------------------------------"
curl -s -X GET "$BASE_URL/lookup/villa-types" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq '.' || echo "❌ Failed - Make sure backend is running and token is valid"
echo ""
echo ""

# Test 2: Create Villa with Villa Type (Backend Auto-Fill)
echo "2️⃣ Testing POST /villas (with villa type - backend should auto-fill)"
echo "-------------------------------------------------------------------"
VILLA_NUMBER="TEST-$(date +%s)"
curl -s -X POST "$BASE_URL/villas" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"villaNumber\": \"$VILLA_NUMBER\",
    \"villaType\": \"1BHK\"
  }" | jq '.' || echo "❌ Failed"
echo ""
echo ""

# Test 3: Verify Auto-Filled Values
echo "3️⃣ Verifying auto-filled values"
echo "--------------------------------"
VILLA_ID=$(curl -s -X GET "$BASE_URL/villas" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq -r ".[] | select(.villaNumber == \"$VILLA_NUMBER\") | .id" | head -1)

if [ -n "$VILLA_ID" ]; then
  echo "Found villa ID: $VILLA_ID"
  curl -s -X GET "$BASE_URL/villas/$VILLA_ID" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" | jq '{villaNumber, villaType, bedroomCount, floorCount, areaSqm}' || echo "❌ Failed"
else
  echo "⚠️ Could not find created villa"
fi
echo ""
echo ""

# Test 4: Create Villa with Manual Override
echo "4️⃣ Testing manual override (user values should take precedence)"
echo "----------------------------------------------------------------"
VILLA_NUMBER_2="TEST-OVERRIDE-$(date +%s)"
curl -s -X POST "$BASE_URL/villas" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"villaNumber\": \"$VILLA_NUMBER_2\",
    \"villaType\": \"1BHK\",
    \"bedroomCount\": 2,
    \"floorCount\": 2,
    \"areaSqm\": 60.0
  }" | jq '{villaNumber, villaType, bedroomCount, floorCount, areaSqm}' || echo "❌ Failed"
echo ""
echo ""

echo "✅ Testing Complete!"
echo ""
echo "📝 Notes:"
echo "  - Test 1: Should return list of villa types with defaults"
echo "  - Test 2: Backend should auto-fill bedroomCount=1, floorCount=1, areaSqm=50.0"
echo "  - Test 3: Verify the auto-filled values were saved"
echo "  - Test 4: Manual values (2, 2, 60.0) should override defaults"

