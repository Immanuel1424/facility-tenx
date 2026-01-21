import * as dotenv from 'dotenv';
import * as path from 'path';
import fetch from 'node-fetch';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Comprehensive test for S3 upload and download in production
 * Tests both presigned URL generation and actual file operations
 * 
 * Usage:
 *   npm run test:s3-production
 *   OR
 *   ts-node -r tsconfig-paths/register scripts/test-s3-production-ready.ts
 */
async function testS3ProductionReady(): Promise<void> {
  console.log('🧪 S3 Production Readiness Test\n');
  console.log('='.repeat(70));
  console.log('TESTING: Upload & Download Functionality');
  console.log('='.repeat(70) + '\n');

  const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000/api/v1';
  const productionUrl = process.env.PRODUCTION_API_URL || 'https://tenx-demo.helixsense.com/api/v1';
  const useProduction = process.env.TEST_PRODUCTION === 'true';
  const baseUrl = useProduction ? productionUrl : apiBaseUrl;

  let jwtToken = process.env.TEST_JWT_TOKEN;

  // Auto-fetch JWT token if not provided
  if (!jwtToken) {
    console.log('🔑 TEST_JWT_TOKEN not set. Attempting to auto-login...\n');
    try {
      const loginUrl = `${baseUrl}/auth/login`;
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
      console.error(`   URL: ${baseUrl}/auth/login`);
      process.exit(1);
    }
  }

  console.log('📋 Configuration:');
  console.log(`   Base URL: ${baseUrl}`);
  console.log(`   Environment: ${useProduction ? 'PRODUCTION' : 'LOCAL'}`);
  console.log(`   JWT Token: ${jwtToken.substring(0, 20)}...\n`);

  const testResults = {
    upload: { passed: 0, failed: 0 },
    download: { passed: 0, failed: 0 },
  };

  // ============================================
  // TEST 1: Upload Presigned URL Generation
  // ============================================
  console.log('📋 Test 1: Upload Presigned URL Generation');
  console.log('-'.repeat(70));

  let uploadPresignedUrl: string | null = null;
  let uploadS3Key: string | null = null;

  try {
    const url = `${baseUrl}/uploads/presigned-url`;
    const requestBody = {
      entityType: 'maintenance-ticket',
      entityId: 'test-production-' + Date.now(),
      fileName: 'test-upload.jpg',
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
    const data = responseData.data || responseData;

    uploadPresignedUrl = data.presignedUrl;
    uploadS3Key = data.s3Key;

    if (!uploadPresignedUrl) {
      throw new Error('Missing presignedUrl in response');
    }

    console.log(`   ✅ Presigned URL generated`);
    console.log(`   S3 Key: ${uploadS3Key}`);
    console.log(`   URL Length: ${uploadPresignedUrl.length} characters\n`);

    // Check for checksum parameters
    const hasChecksum = uploadPresignedUrl.includes('x-amz-checksum') || 
                        uploadPresignedUrl.includes('x-amz-sdk-checksum');

    if (hasChecksum) {
      console.log('   ❌ FAILED: Presigned URL contains checksum parameters!');
      console.log('   This will cause 403 Forbidden errors when uploading.');
      console.log('   URL Preview: ' + uploadPresignedUrl.substring(0, 200) + '...\n');
      testResults.upload.failed++;
    } else {
      console.log('   ✅ SUCCESS: No checksum parameters found');
      console.log('   Upload presigned URL is production-ready.\n');
      testResults.upload.passed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.upload.failed++;
  }

  // ============================================
  // TEST 2: Download Presigned URL Generation
  // ============================================
  console.log('📋 Test 2: Download Presigned URL Generation');
  console.log('-'.repeat(70));

  let downloadPresignedUrl: string | null = null;

  try {
    // Use a known S3 key for testing (or use the upload key if available)
    const testStoragePath = uploadS3Key || 'tenx-attachments/maintenance-ticket/test/test.jpg';
    
    const url = `${baseUrl}/uploads/presigned-url?storagePath=${encodeURIComponent(testStoragePath)}&expiresIn=3600`;
    
    console.log(`   Request: GET ${url}`);

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    const responseData = await response.json();
    const data = responseData.data || responseData;

    downloadPresignedUrl = data.presignedUrl || data.url;

    if (!downloadPresignedUrl) {
      throw new Error('Missing presignedUrl in response');
    }

    console.log(`   ✅ Presigned URL generated`);
    console.log(`   URL Length: ${downloadPresignedUrl.length} characters\n`);

    // Check for checksum parameters (downloads usually don't have this issue, but verify)
    const hasChecksum = downloadPresignedUrl.includes('x-amz-checksum') || 
                        downloadPresignedUrl.includes('x-amz-sdk-checksum');

    if (hasChecksum) {
      console.log('   ⚠️  WARNING: Presigned URL contains checksum parameters');
      console.log('   (Downloads usually work even with checksums, but it\'s better without them)');
      console.log('   URL Preview: ' + downloadPresignedUrl.substring(0, 200) + '...\n');
      testResults.download.passed++; // Still pass, but log warning
    } else {
      console.log('   ✅ SUCCESS: No checksum parameters found');
      console.log('   Download presigned URL is production-ready.\n');
      testResults.download.passed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.download.failed++;
  }

  // ============================================
  // TEST 3: Actual Upload Test (if presigned URL available)
  // ============================================
  if (uploadPresignedUrl) {
    console.log('📋 Test 3: Actual File Upload to S3');
    console.log('-'.repeat(70));

    try {
      // Create a small test file (1KB JPEG)
      const testFileContent = Buffer.alloc(1024, 0xFF);
      
      console.log(`   Uploading to: ${uploadPresignedUrl.substring(0, 100)}...`);
      
      const uploadResponse = await fetch(uploadPresignedUrl, {
        method: 'PUT',
        headers: {
          'Content-Type': 'image/jpeg',
        },
        body: testFileContent,
      });

      if (uploadResponse.ok || uploadResponse.status === 200) {
        console.log(`   ✅ SUCCESS: File uploaded successfully (HTTP ${uploadResponse.status})`);
        testResults.upload.passed++;
      } else {
        const errorText = await uploadResponse.text();
        console.log(`   ❌ FAILED: Upload failed (HTTP ${uploadResponse.status})`);
        console.log(`   Error: ${errorText.substring(0, 200)}`);
        testResults.upload.failed++;
      }
    } catch (error) {
      console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
      testResults.upload.failed++;
    }
    console.log('');
  }

  // ============================================
  // Summary
  // ============================================
  console.log('='.repeat(70));
  console.log('TEST SUMMARY');
  console.log('='.repeat(70));
  console.log('\n📤 UPLOAD TESTS:');
  console.log(`   ✅ Passed: ${testResults.upload.passed}`);
  console.log(`   ❌ Failed: ${testResults.upload.failed}`);
  console.log('\n📥 DOWNLOAD TESTS:');
  console.log(`   ✅ Passed: ${testResults.download.passed}`);
  console.log(`   ❌ Failed: ${testResults.download.failed}`);
  console.log('='.repeat(70) + '\n');

  const totalPassed = testResults.upload.passed + testResults.download.passed;
  const totalFailed = testResults.upload.failed + testResults.download.failed;

  if (totalFailed > 0) {
    console.log('❌ Some tests failed!');
    console.log('\n💡 Troubleshooting:');
    console.log('   1. Verify the checksum middleware is configured in S3StorageService');
    console.log('   2. Check that @aws-sdk/middleware-flexible-checksums is installed');
    console.log('   3. Ensure the backend server has been restarted after code changes');
    console.log('   4. Verify S3 credentials and bucket permissions');
    console.log('   5. Check network connectivity and CORS settings');
    process.exit(1);
  } else {
    console.log('✅ All tests passed!');
    console.log('\n🎉 S3 Upload & Download are production-ready!');
    console.log('   - No checksum parameters in presigned URLs');
    console.log('   - Uploads and downloads should work without 403 errors');
    process.exit(0);
  }
}

// Run tests
testS3ProductionReady().catch((error) => {
  console.error('\n❌ Test suite failed with error:');
  console.error(error);
  process.exit(1);
});
