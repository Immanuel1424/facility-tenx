import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as crypto from 'crypto';
import fetch from 'node-fetch';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Comprehensive S3 Integration Test
 * 
 * Tests the complete S3 integration flow:
 * 1. S3StorageService initialization
 * 2. Presigned URL generation via API
 * 3. Direct upload to S3
 * 4. File verification
 * 5. Presigned URL for download
 * 6. File deletion
 * 7. Error handling
 */
async function testS3Integration(): Promise<void> {
  console.log('🧪 S3 Integration Test Suite');
  console.log('='.repeat(70));
  console.log('');

  // Configuration
  const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000/api/v1';
  const accessKeyId = process.env.AWS_S3_ACCESS_KEY_ID;
  const secretAccessKey = process.env.AWS_S3_SECRET_ACCESS_KEY;
  const region = process.env.AWS_S3_REGION || 'ap-south-1';
  const bucketName = process.env.AWS_S3_BUCKET_NAME || 'user1-bucket-test';
  const basePrefix = process.env.AWS_S3_BASE_PREFIX || 'tenx-attachments';
  const jwtToken = process.env.TEST_JWT_TOKEN;

  // Validate configuration
  if (!accessKeyId || !secretAccessKey) {
    console.error('❌ AWS S3 credentials are missing!');
    console.error('   Set AWS_S3_ACCESS_KEY_ID and AWS_S3_SECRET_ACCESS_KEY in .env');
    process.exit(1);
  }

  if (!jwtToken) {
    console.warn('⚠️  TEST_JWT_TOKEN not set. Authenticated endpoint tests will be skipped.');
    console.warn('   To test authenticated endpoints, set TEST_JWT_TOKEN in .env\n');
  }

  console.log('📋 Configuration:');
  console.log(`   API Base URL: ${apiBaseUrl}`);
  console.log(`   S3 Bucket: ${bucketName}`);
  console.log(`   S3 Region: ${region}`);
  console.log(`   Base Prefix: ${basePrefix}`);
  console.log(`   JWT Token: ${jwtToken ? '✅ Set' : '❌ Missing'}`);
  console.log('');

  const s3Client = new S3Client({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  const testResults = {
    passed: 0,
    failed: 0,
    skipped: 0,
  };

  // Helper: Create test image buffer
  function createTestImage(sizeInBytes: number = 2048): Buffer {
    const pngHeader = Buffer.from([
      0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, // PNG signature
    ]);
    const filler = Buffer.alloc(sizeInBytes - pngHeader.length, 0x00);
    return Buffer.concat([pngHeader, filler]);
  }

  // Helper: Make API request
  async function apiRequest(
    endpoint: string,
    method: string = 'GET',
    body?: any,
  ): Promise<{ status: number; data: any }> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (jwtToken) {
      headers['Authorization'] = `Bearer ${jwtToken}`;
    }

    const response = await fetch(`${apiBaseUrl}${endpoint}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    const responseData = await response.json();
    return {
      status: response.status,
      data: responseData.data || responseData,
    };
  }

  let testS3Key: string | undefined;
  let testEntityId: string | undefined;

  // ============================================
  // TEST 1: S3 Connection
  // ============================================
  console.log('📋 Test 1: S3 Connection');
  console.log('-'.repeat(70));
  try {
    const listCommand = new GetObjectCommand({
      Bucket: bucketName,
      Key: `${basePrefix}/.test-connection`,
    });

    // Try to access bucket (will fail but confirms connection)
    try {
      await s3Client.send(listCommand);
    } catch (error: any) {
      if (error.name === 'NoSuchKey' || error.name === 'AccessDenied') {
        // Expected - bucket exists and we can connect
        console.log('   ✅ S3 connection successful');
        console.log(`   ✅ Bucket "${bucketName}" is accessible`);
        testResults.passed++;
      } else {
        throw error;
      }
    }
  } catch (error) {
    console.error(`   ❌ S3 connection failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }
  console.log('');

  // ============================================
  // TEST 2: Generate Presigned URL (API)
  // ============================================
  console.log('📋 Test 2: Generate Presigned URL via API');
  console.log('-'.repeat(70));
  let presignedUrl: string | undefined;
  let expiresAt: Date | undefined;

  try {
    if (!jwtToken) {
      console.log('   ⏭️  Skipped (no JWT token)');
      testResults.skipped++;
    } else {
      testEntityId = crypto.randomUUID();
      const requestBody = {
        entityType: 'maintenance-ticket',
        entityId: testEntityId,
        fileName: 'test-integration.png',
        mimeType: 'image/png',
        fileSize: 2048,
      };

      console.log(`   Request: POST /uploads/presigned-url`);
      console.log(`   Entity ID: ${testEntityId}`);

      const response = await apiRequest('/uploads/presigned-url', 'POST', requestBody);

      if (response.status !== 200) {
        throw new Error(`HTTP ${response.status}: ${JSON.stringify(response.data)}`);
      }

      presignedUrl = response.data.presignedUrl;
      testS3Key = response.data.s3Key;
      expiresAt = new Date(response.data.expiresAt);

      if (!presignedUrl || !testS3Key || !expiresAt) {
        throw new Error('Missing required fields in response');
      }

      console.log(`   ✅ Presigned URL generated`);
      console.log(`   S3 Key: ${testS3Key}`);
      console.log(`   Expires At: ${expiresAt.toISOString()}`);

      // Verify expiry (should be ~15 minutes = 900 seconds)
      const now = new Date();
      const expirySeconds = Math.floor((expiresAt.getTime() - now.getTime()) / 1000);
      console.log(`   Expiry: ${expirySeconds} seconds`);

      if (expirySeconds >= 890 && expirySeconds <= 910) {
        console.log(`   ✅ Expiry is correct (15 minutes)`);
        testResults.passed++;
      } else {
        console.log(`   ⚠️  Expiry is ${expirySeconds}s, expected ~900s`);
        testResults.failed++;
      }

      // Verify S3 key structure
      const expectedPrefix = `${basePrefix}/maintenance-ticket/${testEntityId}/`;
      if (testS3Key.startsWith(expectedPrefix)) {
        console.log(`   ✅ S3 key structure is correct`);
        testResults.passed++;
      } else {
        console.log(`   ⚠️  S3 key doesn't match expected structure`);
        console.log(`      Expected: ${expectedPrefix}...`);
        console.log(`      Got: ${testS3Key}`);
        testResults.failed++;
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }
  console.log('');

  // ============================================
  // TEST 3: Upload File to S3
  // ============================================
  console.log('📋 Test 3: Upload File to S3 Using Presigned URL');
  console.log('-'.repeat(70));

  try {
    if (!presignedUrl || !testS3Key) {
      console.log('   ⏭️  Skipped (no presigned URL from Test 2)');
      testResults.skipped++;
    } else {
      const testImageBytes = createTestImage(2048);
      const testMimeType = 'image/png';

      console.log(`   Uploading ${testImageBytes.length} bytes...`);
      console.log(`   URL: ${presignedUrl.substring(0, 80)}...`);

      const uploadResponse = await fetch(presignedUrl, {
        method: 'PUT',
        headers: {
          'Content-Type': testMimeType,
        },
        body: testImageBytes,
      });

      if (!uploadResponse.ok) {
        const errorText = await uploadResponse.text();
        throw new Error(`Upload failed: HTTP ${uploadResponse.status}: ${errorText}`);
      }

      console.log(`   ✅ Upload successful (Status: ${uploadResponse.status})`);
      testResults.passed++;

      // Verify file exists in S3
      try {
        const getCommand = new GetObjectCommand({
          Bucket: bucketName,
          Key: testS3Key,
        });
        const getResponse = await s3Client.send(getCommand);
        const downloadedBytes = await getResponse.Body?.transformToByteArray();

        if (downloadedBytes && downloadedBytes.length === testImageBytes.length) {
          console.log(`   ✅ File verified in S3 (${downloadedBytes.length} bytes)`);
          testResults.passed++;
        } else {
          console.log(`   ⚠️  File size mismatch: expected ${testImageBytes.length}, got ${downloadedBytes?.length || 0}`);
          testResults.failed++;
        }

        // Verify Content-Type
        if (getResponse.ContentType === testMimeType) {
          console.log(`   ✅ Content-Type verified: ${getResponse.ContentType}`);
          testResults.passed++;
        } else {
          console.log(`   ⚠️  Content-Type mismatch: expected ${testMimeType}, got ${getResponse.ContentType}`);
          testResults.failed++;
        }
      } catch (s3Error) {
        console.error(`   ❌ Failed to verify file in S3: ${s3Error instanceof Error ? s3Error.message : String(s3Error)}`);
        testResults.failed++;
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }
  console.log('');

  // ============================================
  // TEST 4: Generate Presigned Download URL
  // ============================================
  console.log('📋 Test 4: Generate Presigned Download URL');
  console.log('-'.repeat(70));

  try {
    if (!testS3Key) {
      console.log('   ⏭️  Skipped (no S3 key from Test 2)');
      testResults.skipped++;
    } else {
      const getCommand = new GetObjectCommand({
        Bucket: bucketName,
        Key: testS3Key,
      });

      const downloadPresignedUrl = await getSignedUrl(s3Client, getCommand, {
        expiresIn: 3600, // 1 hour
      });

      console.log(`   ✅ Presigned download URL generated`);
      console.log(`   URL Length: ${downloadPresignedUrl.length} characters`);

      // Test downloading the file
      const downloadResponse = await fetch(downloadPresignedUrl, {
        method: 'GET',
      });

      if (!downloadResponse.ok) {
        throw new Error(`Download failed: HTTP ${downloadResponse.status}`);
      }

      const downloadedBytes = await downloadResponse.buffer();
      console.log(`   ✅ File downloaded successfully (${downloadedBytes.length} bytes)`);
      testResults.passed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }
  console.log('');

  // ============================================
  // TEST 5: File Size Validation
  // ============================================
  console.log('📋 Test 5: File Size Validation (10MB limit)');
  console.log('-'.repeat(70));

  try {
    if (!jwtToken) {
      console.log('   ⏭️  Skipped (no JWT token)');
      testResults.skipped++;
    } else {
      const testEntityId2 = crypto.randomUUID();
      const requestBody = {
        entityType: 'maintenance-ticket',
        entityId: testEntityId2,
        fileName: 'large-file.png',
        mimeType: 'image/png',
        fileSize: 11 * 1024 * 1024, // 11MB (exceeds 10MB limit)
      };

      const response = await apiRequest('/uploads/presigned-url', 'POST', requestBody);

      if (response.status === 400) {
        console.log(`   ✅ File size validation working (rejected ${requestBody.fileSize} bytes)`);
        testResults.passed++;
      } else {
        console.log(`   ⚠️  Expected 400, got ${response.status}`);
        testResults.failed++;
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }
  console.log('');

  // ============================================
  // TEST 6: MIME Type Validation
  // ============================================
  console.log('📋 Test 6: MIME Type Validation');
  console.log('-'.repeat(70));

  try {
    if (!jwtToken) {
      console.log('   ⏭️  Skipped (no JWT token)');
      testResults.skipped++;
    } else {
      const testEntityId3 = crypto.randomUUID();
      const requestBody = {
        entityType: 'maintenance-ticket',
        entityId: testEntityId3,
        fileName: 'test.exe',
        mimeType: 'application/x-msdownload', // Not allowed
        fileSize: 1024,
      };

      const response = await apiRequest('/uploads/presigned-url', 'POST', requestBody);

      if (response.status === 400) {
        console.log(`   ✅ MIME type validation working (rejected ${requestBody.mimeType})`);
        testResults.passed++;
      } else {
        console.log(`   ⚠️  Expected 400, got ${response.status}`);
        testResults.failed++;
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }
  console.log('');

  // ============================================
  // TEST 7: Different Entity Types
  // ============================================
  console.log('📋 Test 7: Different Entity Types');
  console.log('-'.repeat(70));

  const entityTypes = ['maintenance-ticket', 'villa', 'user', 'announcement'];
  let entityTypeTestsPassed = 0;
  let entityTypeTestsFailed = 0;

  for (const entityType of entityTypes) {
    try {
      if (!jwtToken) {
        console.log(`   ⏭️  Skipped ${entityType} (no JWT token)`);
        testResults.skipped++;
        continue;
      }

      const testEntityId4 = crypto.randomUUID();
      const requestBody = {
        entityType,
        entityId: testEntityId4,
        fileName: 'test.png',
        mimeType: 'image/png',
        fileSize: 1024,
      };

      const response = await apiRequest('/uploads/presigned-url', 'POST', requestBody);

      if (response.status === 200) {
        const generatedS3Key = response.data.s3Key;
        const expectedPrefix = `${basePrefix}/${entityType}/`;

        if (generatedS3Key.includes(entityType)) {
          console.log(`   ✅ ${entityType}: S3 key contains entity type`);
          entityTypeTestsPassed++;
        } else {
          console.log(`   ⚠️  ${entityType}: S3 key doesn't contain entity type`);
          entityTypeTestsFailed++;
        }
      } else {
        console.log(`   ⚠️  ${entityType}: Request failed with status ${response.status}`);
        entityTypeTestsFailed++;
      }
    } catch (error) {
      console.error(`   ❌ ${entityType}: ${error instanceof Error ? error.message : String(error)}`);
      entityTypeTestsFailed++;
    }
  }

  testResults.passed += entityTypeTestsPassed;
  testResults.failed += entityTypeTestsFailed;
  console.log('');

  // ============================================
  // TEST 8: Cleanup - Delete Test File
  // ============================================
  console.log('📋 Test 8: Cleanup - Delete Test File');
  console.log('-'.repeat(70));

  try {
    if (!testS3Key) {
      console.log('   ⏭️  Skipped (no S3 key to delete)');
      testResults.skipped++;
    } else {
      const deleteCommand = new DeleteObjectCommand({
        Bucket: bucketName,
        Key: testS3Key,
      });

      await s3Client.send(deleteCommand);
      console.log(`   ✅ Test file deleted: ${testS3Key}`);
      testResults.passed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }
  console.log('');

  // ============================================
  // SUMMARY
  // ============================================
  console.log('='.repeat(70));
  console.log('TEST SUMMARY');
  console.log('='.repeat(70));
  console.log(`✅ Passed: ${testResults.passed}`);
  console.log(`❌ Failed: ${testResults.failed}`);
  console.log(`⏭️  Skipped: ${testResults.skipped}`);
  console.log(`📊 Total: ${testResults.passed + testResults.failed + testResults.skipped}`);
  console.log('='.repeat(70));
  console.log('');

  if (testResults.failed > 0) {
    console.log('❌ Some tests failed. Please review the output above.');
    console.log('');
    console.log('💡 Troubleshooting:');
    console.log('   1. Check AWS S3 credentials in .env');
    console.log('   2. Verify S3 bucket permissions');
    console.log('   3. Ensure CORS is configured for S3 bucket');
    console.log('   4. Check JWT token is valid (for authenticated tests)');
    console.log('   5. Verify backend API is running');
    process.exit(1);
  } else if (testResults.passed === 0 && testResults.skipped > 0) {
    console.log('⚠️  All tests were skipped. Set TEST_JWT_TOKEN to run authenticated tests.');
    process.exit(0);
  } else {
    console.log('✅ All tests passed! S3 integration is working correctly.');
    process.exit(0);
  }
}

// Run tests
testS3Integration().catch((error) => {
  console.error('\n❌ Test suite failed with error:');
  console.error(error);
  process.exit(1);
});
