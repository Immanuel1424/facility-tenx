import * as dotenv from 'dotenv';
import * as path from 'path';
import fetch from 'node-fetch';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Test to verify checksum parameters are NOT in presigned URLs
 * This test ensures the fix for 403 Forbidden errors is working
 * 
 * Usage:
 *   npm run test:checksum-fix
 *   OR
 *   ts-node -r tsconfig-paths/register scripts/test-checksum-fix.ts
 */
async function testChecksumFix(): Promise<void> {
  console.log('🧪 Testing Checksum Parameter Fix\n');
  console.log('='.repeat(60));
  console.log('TEST: Verify Presigned URLs Do NOT Contain Checksum Parameters');
  console.log('='.repeat(60) + '\n');

  const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000/api/v1';
  let jwtToken = process.env.TEST_JWT_TOKEN;

  // Auto-fetch JWT token if not provided
  if (!jwtToken) {
    console.log('🔑 TEST_JWT_TOKEN not set. Attempting to auto-login...\n');
    try {
      const loginUrl = `${apiBaseUrl}/auth/login`;
      const loginResponse = await fetch(loginUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          siteCode: '',
          email: 'superadmin@system.local',
          password: 'SuperAdmin@2025!',
        }),
      });

      if (loginResponse.ok) {
        const loginData = await loginResponse.json();
        jwtToken = loginData.data?.accessToken || loginData.accessToken;
        if (jwtToken) {
          console.log('✅ Auto-login successful!\n');
        } else {
          throw new Error('No access token in login response');
        }
      } else {
        const errorText = await loginResponse.text();
        throw new Error(`Login failed: HTTP ${loginResponse.status}: ${errorText}`);
      }
    } catch (error) {
      console.error('❌ Auto-login failed!');
      console.error(`   Error: ${error instanceof Error ? error.message : String(error)}`);
      process.exit(1);
    }
  }

  console.log('📋 Configuration:');
  console.log(`   API Base URL: ${apiBaseUrl}`);
  console.log(`   JWT Token: ${jwtToken.substring(0, 20)}...\n`);

  let testResults = {
    passed: 0,
    failed: 0,
  };

  // Test: Generate presigned URL and check for checksum parameters
  console.log('📋 Test: Generate Presigned URL and Check for Checksum Parameters');
  console.log('-'.repeat(60));

  try {
    const url = `${apiBaseUrl}/uploads/presigned-url`;
    const requestBody = {
      entityType: 'maintenance-ticket',
      entityId: 'test-123',
      fileName: 'test.jpg',
      mimeType: 'image/jpeg',
      fileSize: 1024,
    };

    console.log(`   Request: POST ${url}`);
    console.log(`   Body: ${JSON.stringify(requestBody, null, 2)}`);

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    const responseData = await response.json();
    let data = responseData.data || responseData;

    const presignedUrl = data.presignedUrl;

    if (!presignedUrl) {
      throw new Error('Missing presignedUrl in response');
    }

    console.log(`   ✅ Presigned URL generated`);
    console.log(`   URL Length: ${presignedUrl.length} characters`);
    console.log(`   URL Preview: ${presignedUrl.substring(0, 150)}...\n`);

    // Check for checksum parameters
    const hasChecksum = presignedUrl.includes('x-amz-checksum') || presignedUrl.includes('x-amz-sdk-checksum');

    if (hasChecksum) {
      console.log('   ❌ FAILED: Presigned URL contains checksum parameters!');
      console.log('   This will cause 403 Forbidden errors when uploading.');
      console.log('   Checksum parameters found:');
      
      if (presignedUrl.includes('x-amz-checksum-crc32')) {
        console.log('     - x-amz-checksum-crc32');
      }
      if (presignedUrl.includes('x-amz-sdk-checksum')) {
        console.log('     - x-amz-sdk-checksum-algorithm');
      }
      
      console.log(`   Full URL: ${presignedUrl}\n`);
      testResults.failed++;
    } else {
      console.log('   ✅ SUCCESS: No checksum parameters found in presigned URL');
      console.log('   The fix is working correctly - uploads should work without 403 errors.\n');
      testResults.passed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  // Summary
  console.log('='.repeat(60));
  console.log('TEST SUMMARY');
  console.log('='.repeat(60));
  console.log(`✅ Passed: ${testResults.passed}`);
  console.log(`❌ Failed: ${testResults.failed}`);
  console.log('='.repeat(60) + '\n');

  if (testResults.failed > 0) {
    console.log('❌ Test failed! Checksum parameters are still present.');
    console.log('\n💡 Troubleshooting:');
    console.log('   1. Verify the middleware is configured correctly in S3StorageService');
    console.log('   2. Check that @aws-sdk/middleware-flexible-checksums is installed');
    console.log('   3. Ensure the S3Client middlewareStack.use() is being called');
    console.log('   4. Restart the backend server after code changes');
    process.exit(1);
  } else {
    console.log('✅ All tests passed!');
    console.log('\n🎉 Checksum fix is working correctly!');
    console.log('   Presigned URLs will NOT contain checksum parameters.');
    console.log('   Uploads should work without 403 Forbidden errors.');
    process.exit(0);
  }
}

// Run tests
testChecksumFix().catch((error) => {
  console.error('\n❌ Test suite failed with error:');
  console.error(error);
  process.exit(1);
});
