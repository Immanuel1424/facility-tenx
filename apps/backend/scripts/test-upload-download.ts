import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';
import * as crypto from 'crypto';
import fetch from 'node-fetch';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Comprehensive test suite for upload and download functionality
 * Tests the industry-standard pre-signed URL flow:
 * 1. Request pre-signed URL from backend
 * 2. Upload file directly to S3
 * 3. Download/view file using pre-signed URL
 */
async function testUploadAndDownload(): Promise<void> {
  console.log('🧪 Starting Upload and Download Test Suite\n');
  console.log('=' .repeat(60));
  console.log('TEST: Pre-signed URL Upload and Download Flow');
  console.log('=' .repeat(60) + '\n');

  // Configuration
  const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000/api/v1';
  const accessKeyId = process.env.AWS_S3_ACCESS_KEY_ID;
  const secretAccessKey = process.env.AWS_S3_SECRET_ACCESS_KEY;
  const region = process.env.AWS_S3_REGION || 'ap-south-1';
  const bucketName = process.env.AWS_S3_BUCKET_NAME || 'user1-bucket-test';
  const basePrefix = process.env.AWS_S3_BASE_PREFIX || 'tenx-attachments';

  // Check AWS credentials
  if (!accessKeyId || !secretAccessKey) {
    console.error('❌ AWS S3 credentials are missing!');
    console.error('   Please set AWS_S3_ACCESS_KEY_ID and AWS_S3_SECRET_ACCESS_KEY in .env');
    process.exit(1);
  }

  // Check for JWT token (required for authenticated endpoints)
  const jwtToken = process.env.TEST_JWT_TOKEN;
  if (!jwtToken) {
    console.warn('⚠️  TEST_JWT_TOKEN not set. Some tests may fail.');
    console.warn('   Set TEST_JWT_TOKEN in .env to test authenticated endpoints.\n');
  }

  console.log('📋 Configuration:');
  console.log(`   API Base URL: ${apiBaseUrl}`);
  console.log(`   S3 Bucket: ${bucketName}`);
  console.log(`   S3 Region: ${region}`);
  console.log(`   Base Prefix: ${basePrefix}\n`);

  const s3Client = new S3Client({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  let testResults = {
    passed: 0,
    failed: 0,
    skipped: 0,
  };

  // Helper function to create test image
  function createTestImage(sizeInBytes: number = 1024): Buffer {
    // Create a simple PNG image (minimal valid PNG)
    const pngHeader = Buffer.from([
      0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, // PNG signature
    ]);
    const filler = Buffer.alloc(sizeInBytes - pngHeader.length, 0x00);
    return Buffer.concat([pngHeader, filler]);
  }

  // Test 1: Generate pre-signed URL via backend API
  console.log('📋 Test 1: Generate Pre-signed URL via Backend API');
  console.log('-'.repeat(60));
  let presignedUrl: string | undefined;
  let s3Key: string | undefined;
  let expiresAt: Date | undefined;

  try {
    if (!jwtToken) {
      console.log('⏭️  Skipped (no JWT token)');
      testResults.skipped++;
    } else {
      const testEntityId = crypto.randomUUID();
      const testFileName = 'test-image.png';
      const testMimeType = 'image/png';
      const testFileSize = 2048; // 2KB

      const requestBody = {
        entityType: 'maintenance-ticket',
        entityId: testEntityId,
        fileName: testFileName,
        mimeType: testMimeType,
        fileSize: testFileSize,
      };

      console.log(`   Request: POST ${apiBaseUrl}/uploads/presigned-url`);
      console.log(`   Body: ${JSON.stringify(requestBody, null, 2)}`);

      const response = await fetch(`${apiBaseUrl}/uploads/presigned-url`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${jwtToken}`,
        },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }

      const responseData = await response.json();
      console.log(`   Response Status: ${response.status}`);

      // Handle wrapped response format
      let data = responseData;
      if (responseData.data) {
        data = responseData.data;
      }

      presignedUrl = data.presignedUrl;
      s3Key = data.s3Key;
      expiresAt = new Date(data.expiresAt);

      if (!presignedUrl || !s3Key || !expiresAt) {
        throw new Error('Missing required fields in response');
      }

      console.log(`   ✅ Pre-signed URL generated`);
      console.log(`   S3 Key: ${s3Key}`);
      console.log(`   Expires At: ${expiresAt.toISOString()}`);
      console.log(`   URL Length: ${presignedUrl.length} characters`);

      // Verify expiry is 15 minutes (900 seconds)
      const now = new Date();
      const expirySeconds = Math.floor((expiresAt.getTime() - now.getTime()) / 1000);
      console.log(`   Expiry: ${expirySeconds} seconds (expected: ~900 seconds)`);

      if (expirySeconds >= 890 && expirySeconds <= 910) {
        console.log(`   ✅ Expiry is correct (15 minutes)`);
        testResults.passed++;
      } else {
        console.log(`   ⚠️  Expiry is ${expirySeconds}s, expected ~900s`);
        testResults.failed++;
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 2: Upload file to S3 using pre-signed URL
  console.log('📋 Test 2: Upload File to S3 Using Pre-signed URL');
  console.log('-'.repeat(60));

  try {
    if (!presignedUrl || !s3Key) {
      console.log('⏭️  Skipped (no pre-signed URL from Test 1)');
      testResults.skipped++;
    } else {
      const testImageBytes = createTestImage(2048);
      const testMimeType = 'image/png';

      console.log(`   Uploading ${testImageBytes.length} bytes to S3...`);
      console.log(`   URL: ${presignedUrl.substring(0, 100)}...`);

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

      // Verify file exists in S3
      try {
        const getCommand = new GetObjectCommand({
          Bucket: bucketName,
          Key: s3Key,
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

  // Test 3: Generate pre-signed URL for download/viewing
  console.log('📋 Test 3: Generate Pre-signed URL for Download/Viewing');
  console.log('-'.repeat(60));

  try {
    if (!s3Key) {
      console.log('⏭️  Skipped (no S3 key from Test 1)');
      testResults.skipped++;
    } else {
      const getCommand = new GetObjectCommand({
        Bucket: bucketName,
        Key: s3Key,
      });

      // Generate pre-signed URL for GET operation (1 hour expiry)
      const downloadPresignedUrl = await getSignedUrl(s3Client, getCommand, {
        expiresIn: 3600, // 1 hour
      });

      console.log(`   ✅ Pre-signed download URL generated`);
      console.log(`   URL Length: ${downloadPresignedUrl.length} characters`);
      console.log(`   URL: ${downloadPresignedUrl.substring(0, 100)}...`);

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

  // Test 4: File validation (size limit)
  console.log('📋 Test 4: File Size Validation');
  console.log('-'.repeat(60));

  try {
    if (!jwtToken) {
      console.log('⏭️  Skipped (no JWT token)');
      testResults.skipped++;
    } else {
      const testEntityId = crypto.randomUUID();
      const requestBody = {
        entityType: 'maintenance-ticket',
        entityId: testEntityId,
        fileName: 'large-file.png',
        mimeType: 'image/png',
        fileSize: 11 * 1024 * 1024, // 11MB (exceeds 10MB limit)
      };

      const response = await fetch(`${apiBaseUrl}/uploads/presigned-url`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${jwtToken}`,
        },
        body: JSON.stringify(requestBody),
      });

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

  // Test 5: MIME type validation
  console.log('📋 Test 5: MIME Type Validation');
  console.log('-'.repeat(60));

  try {
    if (!jwtToken) {
      console.log('⏭️  Skipped (no JWT token)');
      testResults.skipped++;
    } else {
      const testEntityId = crypto.randomUUID();
      const requestBody = {
        entityType: 'maintenance-ticket',
        entityId: testEntityId,
        fileName: 'test.exe',
        mimeType: 'application/x-msdownload', // Not allowed
        fileSize: 1024,
      };

      const response = await fetch(`${apiBaseUrl}/uploads/presigned-url`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${jwtToken}`,
        },
        body: JSON.stringify(requestBody),
      });

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

  // Test 6: Different entity types
  console.log('📋 Test 6: Different Entity Types');
  console.log('-'.repeat(60));

  const entityTypes = ['maintenance-ticket', 'villa', 'user', 'announcement'];

  for (const entityType of entityTypes) {
    try {
      if (!jwtToken) {
        console.log(`   ⏭️  Skipped ${entityType} (no JWT token)`);
        testResults.skipped++;
        continue;
      }

      const testEntityId = crypto.randomUUID();
      const requestBody = {
        entityType,
        entityId: testEntityId,
        fileName: 'test.png',
        mimeType: 'image/png',
        fileSize: 1024,
      };

      const response = await fetch(`${apiBaseUrl}/uploads/presigned-url`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${jwtToken}`,
        },
        body: JSON.stringify(requestBody),
      });

      if (response.ok) {
        const responseData = await response.json();
        let data = responseData.data || responseData;
        const generatedS3Key = data.s3Key;

        // Verify S3 key contains entity type
        if (generatedS3Key.includes(entityType)) {
          console.log(`   ✅ ${entityType}: S3 key contains entity type`);
          testResults.passed++;
        } else {
          console.log(`   ⚠️  ${entityType}: S3 key doesn't contain entity type`);
          testResults.failed++;
        }
      } else {
        console.log(`   ⚠️  ${entityType}: Request failed with status ${response.status}`);
        testResults.failed++;
      }
    } catch (error) {
      console.error(`   ❌ ${entityType}: ${error instanceof Error ? error.message : String(error)}`);
      testResults.failed++;
    }
  }

  console.log('');

  // Test 7: Pre-signed URL expiry
  console.log('📋 Test 7: Pre-signed URL Expiry Enforcement');
  console.log('-'.repeat(60));

  try {
    if (!jwtToken) {
      console.log('⏭️  Skipped (no JWT token)');
      testResults.skipped++;
    } else {
      const testEntityId = crypto.randomUUID();
      const requestBody = {
        entityType: 'maintenance-ticket',
        entityId: testEntityId,
        fileName: 'test.png',
        mimeType: 'image/png',
        fileSize: 1024,
      };

      const response = await fetch(`${apiBaseUrl}/uploads/presigned-url`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${jwtToken}`,
        },
        body: JSON.stringify(requestBody),
      });

      if (response.ok) {
        const responseData = await response.json();
        let data = responseData.data || responseData;
        const testPresignedUrl = data.presignedUrl;
        const testExpiresAt = new Date(data.expiresAt);

        const now = new Date();
        const expirySeconds = Math.floor((testExpiresAt.getTime() - now.getTime()) / 1000);

        // Check if expiry is enforced (should be <= 900 seconds)
        if (expirySeconds <= 900) {
          console.log(`   ✅ Expiry enforced correctly (${expirySeconds}s <= 900s)`);
          testResults.passed++;
        } else {
          console.log(`   ⚠️  Expiry not enforced (${expirySeconds}s > 900s)`);
          testResults.failed++;
        }
      } else {
        console.log(`   ⚠️  Failed to generate pre-signed URL`);
        testResults.failed++;
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Summary
  console.log('=' .repeat(60));
  console.log('TEST SUMMARY');
  console.log('=' .repeat(60));
  console.log(`✅ Passed: ${testResults.passed}`);
  console.log(`❌ Failed: ${testResults.failed}`);
  console.log(`⏭️  Skipped: ${testResults.skipped}`);
  console.log(`📊 Total: ${testResults.passed + testResults.failed + testResults.skipped}`);
  console.log('=' .repeat(60) + '\n');

  if (testResults.failed > 0) {
    console.log('❌ Some tests failed. Please review the output above.');
    process.exit(1);
  } else {
    console.log('✅ All tests passed!');
    process.exit(0);
  }
}

// Run tests
testUploadAndDownload().catch((error) => {
  console.error('\n❌ Test suite failed with error:');
  console.error(error);
  process.exit(1);
});
