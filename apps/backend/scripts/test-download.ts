import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';
import fetch from 'node-fetch';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Test script for downloading files using the new generic presigned URL endpoint
 * Tests: GET /api/v1/uploads/presigned-url?storagePath=...
 * 
 * Usage:
 *   npm run test:download
 *   OR
 *   ts-node -r tsconfig-paths/register scripts/test-download.ts [storagePath]
 * 
 * Example:
 *   ts-node -r tsconfig-paths/register scripts/test-download.ts "tenx-attachments/maintenance-ticket/f41edb81-6df9-4667-8ab1-636562bd3c57/938d0449-54a1-42d4-8c21-6568066b8180.jpg"
 */
async function testDownload(): Promise<void> {
  console.log('🧪 Testing File Download via Presigned URL\n');
  console.log('='.repeat(60));
  console.log('TEST: Generic Download Endpoint');
  console.log('='.repeat(60) + '\n');

  // Configuration
  const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000/api/v1';
  let jwtToken = process.env.TEST_JWT_TOKEN;

  // Get storage path from command line argument or use default test file
  const storagePath =
    process.argv[2] ||
    'tenx-attachments/maintenance-ticket/f41edb81-6df9-4667-8ab1-636562bd3c57/938d0449-54a1-42d4-8c21-6568066b8180.jpg';

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
      console.error('\n   Please set TEST_JWT_TOKEN in .env file or ensure backend is running.');
      console.error('   You can get a token manually by:');
      console.error(`   curl -X POST ${apiBaseUrl}/auth/login \\`);
      console.error('     -H "Content-Type: application/json" \\');
      console.error('     -d \'{"siteCode":"","email":"superadmin@system.local","password":"SuperAdmin@2025!"}\'');
      process.exit(1);
    }
  }

  console.log('📋 Configuration:');
  console.log(`   API Base URL: ${apiBaseUrl}`);
  console.log(`   Storage Path: ${storagePath}`);
  console.log(`   JWT Token: ${jwtToken.substring(0, 20)}...\n`);

  let testResults = {
    passed: 0,
    failed: 0,
    skipped: 0,
  };

  // Test 1: Generate presigned URL for download
  console.log('📋 Test 1: Generate Presigned URL for Download');
  console.log('-'.repeat(60));

  let presignedUrl: string | undefined;
  let expiresIn: number | undefined;

  try {
    const url = `${apiBaseUrl}/uploads/presigned-url?storagePath=${encodeURIComponent(storagePath)}`;
    console.log(`   Request: GET ${url}`);

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
        'Content-Type': 'application/json',
      },
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
    expiresIn = data.expiresIn;

    if (!presignedUrl) {
      throw new Error('Missing presignedUrl in response');
    }

    console.log(`   ✅ Presigned URL generated`);
    console.log(`   URL Length: ${presignedUrl.length} characters`);
    console.log(`   Expires In: ${expiresIn || 'N/A'} seconds`);
    console.log(`   URL Preview: ${presignedUrl.substring(0, 100)}...`);

    // Verify it's an S3 URL
    if (presignedUrl.includes('.s3.') && presignedUrl.includes('.amazonaws.com')) {
      console.log(`   ✅ URL is a valid S3 presigned URL`);
      testResults.passed++;
    } else {
      console.log(`   ⚠️  URL doesn't look like an S3 presigned URL`);
      testResults.failed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 2: Download file using presigned URL
  console.log('📋 Test 2: Download File Using Presigned URL');
  console.log('-'.repeat(60));

  try {
    if (!presignedUrl) {
      console.log('⏭️  Skipped (no presigned URL from Test 1)');
      testResults.skipped++;
    } else {
      console.log(`   Downloading from: ${presignedUrl.substring(0, 100)}...`);

      const downloadResponse = await fetch(presignedUrl, {
        method: 'GET',
      });

      if (!downloadResponse.ok) {
        const errorText = await downloadResponse.text();
        throw new Error(`Download failed: HTTP ${downloadResponse.status}: ${errorText}`);
      }

      const contentType = downloadResponse.headers.get('content-type') || 'unknown';
      const contentLength = downloadResponse.headers.get('content-length');

      console.log(`   ✅ Download successful (Status: ${downloadResponse.status})`);
      console.log(`   Content-Type: ${contentType}`);
      console.log(`   Content-Length: ${contentLength || 'unknown'} bytes`);

      // Read the file data
      const fileBuffer = await downloadResponse.buffer();
      console.log(`   ✅ File downloaded: ${fileBuffer.length} bytes`);

      // Verify it's a valid image (if it's an image)
      if (contentType.startsWith('image/')) {
        // Check for image magic bytes
        const isJpeg = fileBuffer[0] === 0xff && fileBuffer[1] === 0xd8;
        const isPng = fileBuffer[0] === 0x89 && fileBuffer[1] === 0x50;
        const isWebp = fileBuffer[8] === 0x57 && fileBuffer[9] === 0x45;

        if (isJpeg || isPng || isWebp) {
          console.log(`   ✅ File is a valid image (${contentType})`);
          testResults.passed++;
        } else {
          console.log(`   ⚠️  File claims to be ${contentType} but magic bytes don't match`);
          testResults.failed++;
        }
      } else {
        console.log(`   ℹ️  File type: ${contentType} (not an image, skipping image validation)`);
        testResults.passed++;
      }

      // Save the file locally for inspection
      const fileName = path.basename(storagePath);
      const downloadsDir = path.join(__dirname, '../downloads');
      const savePath = path.join(downloadsDir, fileName);

      if (!fs.existsSync(downloadsDir)) {
        fs.mkdirSync(downloadsDir, { recursive: true });
      }

      fs.writeFileSync(savePath, fileBuffer);
      console.log(`   💾 File saved to: ${savePath}`);
      console.log(`   📂 Full path: ${path.resolve(savePath)}`);
      
      // Try to open the file if on macOS
      if (process.platform === 'darwin') {
        const { exec } = require('child_process');
        exec(`open "${savePath}"`, (error: Error | null) => {
          if (error) {
            console.log(`   ℹ️  Could not auto-open file. Please open manually: ${savePath}`);
          } else {
            console.log(`   🖼️  Opening image in default viewer...`);
          }
        });
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 3: Test with custom expiry
  console.log('📋 Test 3: Test with Custom Expiry Time');
  console.log('-'.repeat(60));

  try {
    const customExpiresIn = 1800; // 30 minutes
    const url = `${apiBaseUrl}/uploads/presigned-url?storagePath=${encodeURIComponent(storagePath)}&expiresIn=${customExpiresIn}`;
    console.log(`   Request: GET ${url}`);

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    const responseData = await response.json();
    let data = responseData.data || responseData;

    if (data.expiresIn === customExpiresIn) {
      console.log(`   ✅ Custom expiry time accepted: ${data.expiresIn}s`);
      testResults.passed++;
    } else {
      console.log(`   ⚠️  Expected ${customExpiresIn}s, got ${data.expiresIn}s`);
      testResults.failed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 4: Test with invalid storage path
  console.log('📋 Test 4: Test with Invalid Storage Path');
  console.log('-'.repeat(60));

  try {
    const invalidPath = 'invalid/path/to/file.jpg';
    const url = `${apiBaseUrl}/uploads/presigned-url?storagePath=${encodeURIComponent(invalidPath)}`;

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
        'Content-Type': 'application/json',
      },
    });

    if (response.status === 400) {
      console.log(`   ✅ Invalid path correctly rejected (Status: ${response.status})`);
      testResults.passed++;
    } else {
      console.log(`   ⚠️  Expected 400, got ${response.status}`);
      testResults.failed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 5: Test without authentication
  console.log('📋 Test 5: Test Without Authentication');
  console.log('-'.repeat(60));

  try {
    const url = `${apiBaseUrl}/uploads/presigned-url?storagePath=${encodeURIComponent(storagePath)}`;

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        // No Authorization header
      },
    });

    if (response.status === 401) {
      console.log(`   ✅ Unauthenticated request correctly rejected (Status: ${response.status})`);
      testResults.passed++;
    } else {
      console.log(`   ⚠️  Expected 401, got ${response.status}`);
      testResults.failed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Summary
  console.log('='.repeat(60));
  console.log('TEST SUMMARY');
  console.log('='.repeat(60));
  console.log(`✅ Passed: ${testResults.passed}`);
  console.log(`❌ Failed: ${testResults.failed}`);
  console.log(`⏭️  Skipped: ${testResults.skipped}`);
  console.log(`📊 Total: ${testResults.passed + testResults.failed + testResults.skipped}`);
  console.log('='.repeat(60) + '\n');

  if (testResults.failed > 0) {
    console.log('❌ Some tests failed. Please review the output above.');
    process.exit(1);
  } else {
    console.log('✅ All tests passed!');
    process.exit(0);
  }
}

// Run tests
testDownload().catch((error) => {
  console.error('\n❌ Test suite failed with error:');
  console.error(error);
  process.exit(1);
});
