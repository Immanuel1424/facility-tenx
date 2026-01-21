import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';
import fetch from 'node-fetch';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Production-like test for file download functionality
 * Tests the actual production URL patterns and redirect flow
 * 
 * This test simulates:
 * 1. Frontend requesting: https://tenx-demo.helixsense.com/uploads/tenx-attachments/.../file.jpg
 * 2. Nginx proxying to: http://localhost:3000/api/v1/uploads/tenx-attachments/.../file.jpg
 * 3. Backend redirecting to S3 presigned URL
 * 4. Browser downloading from S3
 * 
 * Usage:
 *   npm run test:download-production
 *   OR
 *   ts-node -r tsconfig-paths/register scripts/test-download-production.ts [storagePath]
 * 
 * Example:
 *   ts-node -r tsconfig-paths/register scripts/test-download-production.ts "tenx-attachments/maintenance-ticket/d03d9e3b-0119-4a8e-ba7c-7706613922a4/770f2b0f-a69c-4ed1-9266-34a8bd1b6885.jpg"
 */
async function testDownloadProduction(): Promise<void> {
  console.log('🧪 Testing File Download - Production Scenario\n');
  console.log('='.repeat(60));
  console.log('TEST: Production URL Pattern & Redirect Flow');
  console.log('='.repeat(60) + '\n');

  // Configuration
  const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000/api/v1';
  const baseUrl = process.env.API_BASE_URL?.replace('/api/v1', '') || 'http://localhost:3000';
  let jwtToken = process.env.TEST_JWT_TOKEN;

  // Get storage path from command line argument or use default test file
  const storagePath =
    process.argv[2] ||
    'tenx-attachments/maintenance-ticket/d03d9e3b-0119-4a8e-ba7c-7706613922a4/770f2b0f-a69c-4ed1-9266-34a8bd1b6885.jpg';

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
      process.exit(1);
    }
  }

  console.log('📋 Configuration:');
  console.log(`   API Base URL: ${apiBaseUrl}`);
  console.log(`   Base URL: ${baseUrl}`);
  console.log(`   Storage Path: ${storagePath}`);
  console.log(`   JWT Token: ${jwtToken.substring(0, 20)}...\n`);

  let testResults = {
    passed: 0,
    failed: 0,
    skipped: 0,
  };

  // Test 1: Test redirect endpoint via API route (what nginx proxies to)
  // In production: Frontend -> Nginx -> /api/v1/uploads/{storagePath} -> Backend redirects to S3
  console.log('📋 Test 1: Redirect Endpoint via API Route');
  console.log('-'.repeat(60));
  console.log('   Testing: GET /api/v1/uploads/{storagePath}');
  console.log('   Expected: Backend redirects (302) to S3 presigned URL\n');

  let redirectLocation: string | undefined;

  try {
    // Test the actual API route (what nginx proxies to in production)
    const apiUrl = `${apiBaseUrl}/uploads/${storagePath}`;
    console.log(`   Request: GET ${apiUrl}`);

    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
      },
      redirect: 'manual', // Don't follow redirect automatically
    });

    console.log(`   Response Status: ${response.status}`);

    if (response.status === 302 || response.status === 307 || response.status === 308) {
      redirectLocation = response.headers.get('location') || undefined;
      console.log(`   ✅ Redirect received (Status: ${response.status})`);
      console.log(`   Location: ${redirectLocation?.substring(0, 100)}...`);

      // Verify it's an S3 presigned URL
      if (redirectLocation && redirectLocation.includes('.s3.') && redirectLocation.includes('.amazonaws.com')) {
        console.log(`   ✅ Redirect location is a valid S3 presigned URL`);
        testResults.passed++;
      } else {
        console.log(`   ❌ Redirect location is not a valid S3 URL`);
        testResults.failed++;
      }
    } else {
      const errorText = await response.text();
      throw new Error(`Expected redirect (302/307/308), got ${response.status}: ${errorText}`);
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 2: Follow redirect and download file
  console.log('📋 Test 2: Follow Redirect and Download File');
  console.log('-'.repeat(60));

  try {
    if (!redirectLocation) {
      console.log('⏭️  Skipped (no redirect location from Test 1)');
      testResults.skipped++;
    } else {
      console.log(`   Following redirect to: ${redirectLocation.substring(0, 100)}...`);

      const downloadResponse = await fetch(redirectLocation, {
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

      // Verify it's a valid image
      if (contentType.startsWith('image/')) {
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
      const savePath = path.join(__dirname, '../downloads', fileName);
      const downloadsDir = path.dirname(savePath);

      if (!fs.existsSync(downloadsDir)) {
        fs.mkdirSync(downloadsDir, { recursive: true });
      }

      fs.writeFileSync(savePath, fileBuffer);
      console.log(`   💾 File saved to: ${savePath}`);
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 3: Test generic presigned URL endpoint (new pattern)
  console.log('📋 Test 3: Generic Presigned URL Endpoint (New Pattern)');
  console.log('-'.repeat(60));
  console.log('   Testing: GET /api/v1/uploads/presigned-url?storagePath=...\n');

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
    let data = responseData.data || responseData;

    const presignedUrl = data.presignedUrl;
    const expiresIn = data.expiresIn;

    if (!presignedUrl) {
      throw new Error('Missing presignedUrl in response');
    }

    console.log(`   ✅ Presigned URL generated`);
    console.log(`   URL Length: ${presignedUrl.length} characters`);
    console.log(`   Expires In: ${expiresIn || 'N/A'} seconds`);

    // Verify it's an S3 URL
    if (presignedUrl.includes('.s3.') && presignedUrl.includes('.amazonaws.com')) {
      console.log(`   ✅ URL is a valid S3 presigned URL`);
      testResults.passed++;
    } else {
      console.log(`   ❌ URL doesn't look like an S3 presigned URL`);
      testResults.failed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 4: Test without authentication (should fail)
  console.log('📋 Test 4: Test Without Authentication (Should Fail)');
  console.log('-'.repeat(60));

  try {
    const url = `${apiBaseUrl}/uploads/${storagePath}`;
    console.log(`   Request: GET ${url} (no Authorization header)`);

    const response = await fetch(url, {
      method: 'GET',
      redirect: 'manual',
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

  // Test 5: Test with invalid storage path
  console.log('📋 Test 5: Test With Invalid Storage Path');
  console.log('-'.repeat(60));

  try {
    const invalidPath = 'invalid/path/to/file.jpg';
    const url = `${apiBaseUrl}/uploads/${invalidPath}`;
    console.log(`   Request: GET ${url}`);

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
      },
      redirect: 'manual',
    });

    if (response.status === 404 || response.status === 400) {
      console.log(`   ✅ Invalid path correctly rejected (Status: ${response.status})`);
      testResults.passed++;
    } else {
      console.log(`   ⚠️  Expected 404 or 400, got ${response.status}`);
      testResults.failed++;
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 6: Test full end-to-end flow (like browser would do)
  console.log('📋 Test 6: Full End-to-End Flow (Browser Simulation)');
  console.log('-'.repeat(60));
  console.log('   Simulating: Browser requests /api/v1/uploads/... and follows redirect\n');

  try {
    const apiUrl = `${apiBaseUrl}/uploads/${storagePath}`;
    console.log(`   Step 1: Request ${apiUrl}`);

    // First request - should get redirect
    const redirectResponse = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
      },
      redirect: 'manual',
    });

    if (redirectResponse.status !== 302 && redirectResponse.status !== 307 && redirectResponse.status !== 308) {
      const errorText = await redirectResponse.text();
      throw new Error(`Expected redirect, got ${redirectResponse.status}: ${errorText}`);
    }

    const s3Url = redirectResponse.headers.get('location');
    if (!s3Url) {
      throw new Error('No location header in redirect response');
    }

    console.log(`   ✅ Received redirect to S3`);
    console.log(`   Step 2: Following redirect to S3...`);

    // Follow redirect and download
    const downloadResponse = await fetch(s3Url, {
      method: 'GET',
    });

    if (!downloadResponse.ok) {
      throw new Error(`S3 download failed: HTTP ${downloadResponse.status}`);
    }

    const fileBuffer = await downloadResponse.buffer();
    console.log(`   ✅ File downloaded successfully: ${fileBuffer.length} bytes`);
    console.log(`   ✅ End-to-end flow working correctly`);
    testResults.passed++;
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    testResults.failed++;
  }

  console.log('');

  // Test 7: Test with production-like domain (if configured)
  // This tests the full production flow: Frontend -> Nginx -> Backend -> S3
  const productionDomain = process.env.PRODUCTION_DOMAIN;
  if (productionDomain) {
    console.log('📋 Test 7: Production Domain Test (Full Stack)');
    console.log('-'.repeat(60));
    console.log(`   Testing with production domain: ${productionDomain}`);
    console.log(`   This simulates: Frontend -> Nginx -> Backend -> S3\n`);

    try {
      // In production, frontend requests: https://domain.com/uploads/{storagePath}
      // Nginx proxies to: http://localhost:3000/api/v1/uploads/{storagePath}
      const productionUrl = `https://${productionDomain}/uploads/${storagePath}`;
      console.log(`   Request: GET ${productionUrl}`);

      const response = await fetch(productionUrl, {
        method: 'GET',
        headers: {
          Authorization: `Bearer ${jwtToken}`,
        },
        redirect: 'manual',
      });

      console.log(`   Response Status: ${response.status}`);

      if (response.status === 302 || response.status === 307 || response.status === 308) {
        const location = response.headers.get('location');
        console.log(`   ✅ Redirect received`);
        console.log(`   Location: ${location?.substring(0, 100)}...`);

        if (location && location.includes('.s3.')) {
          console.log(`   ✅ Redirect to S3 presigned URL working`);
          testResults.passed++;
        } else {
          console.log(`   ⚠️  Redirect location doesn't look like S3 URL`);
          testResults.failed++;
        }
      } else {
        const errorText = await response.text();
        console.log(`   ⚠️  Expected redirect, got ${response.status}`);
        console.log(`   Response: ${errorText.substring(0, 200)}`);
        testResults.failed++;
      }
    } catch (error) {
      console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
      console.error(`   Note: This test requires network access to production domain`);
      console.error(`   Set PRODUCTION_DOMAIN in .env to test production flow`);
      testResults.failed++;
    }

    console.log('');
  } else {
    console.log('📋 Test 7: Production Domain Test');
    console.log('-'.repeat(60));
    console.log('   ⏭️  Skipped (PRODUCTION_DOMAIN not set)');
    console.log('   Set PRODUCTION_DOMAIN=tenx-demo.helixsense.com in .env to test production flow\n');
    testResults.skipped++;
  }

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
    console.log('\n💡 Troubleshooting Tips:');
    console.log('   1. Ensure backend is running on port 3000');
    console.log('   2. Check that S3 credentials are configured correctly');
    console.log('   3. Verify the storage path exists in S3');
    console.log('   4. Check nginx configuration if testing production domain');
    console.log('   5. Verify JWT token is valid and not expired');
    console.log('   6. In production, ensure nginx proxies /uploads/ to /api/v1/uploads/');
    console.log('   7. Check that the wildcard route @Get("*") is working correctly');
    process.exit(1);
  } else {
    console.log('✅ All tests passed!');
    console.log('\n🎉 Production download flow is working correctly!');
    console.log('\n📝 Production Deployment Checklist:');
    console.log('   ✅ Backend redirect endpoint working');
    console.log('   ✅ Generic presigned URL endpoint working');
    console.log('   ✅ Authentication required');
    console.log('   ✅ Invalid paths rejected');
    console.log('   ✅ End-to-end flow working');
    console.log('\n⚠️  For Production:');
    console.log('   1. Ensure nginx is configured to proxy /uploads/ to /api/v1/uploads/');
    console.log('   2. Verify nginx passes Authorization header');
    console.log('   3. Test with: PRODUCTION_DOMAIN=tenx-demo.helixsense.com npm run test:download-production');
    process.exit(0);
  }
}

// Run tests
testDownloadProduction().catch((error) => {
  console.error('\n❌ Test suite failed with error:');
  console.error(error);
  process.exit(1);
});
