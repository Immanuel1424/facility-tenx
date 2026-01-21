import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';
import fetch from 'node-fetch';
import FormData from 'form-data';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Test local storage file upload
 * 
 * Usage:
 *   npm run test:local-storage
 *   OR
 *   ts-node -r tsconfig-paths/register scripts/test-local-storage-upload.ts
 */
async function testLocalStorageUpload(): Promise<void> {
  console.log('🧪 Testing Local Storage File Upload\n');
  console.log('='.repeat(70));
  console.log('TEST: Upload Image to Local Storage');
  console.log('='.repeat(70) + '\n');

  const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:3000/api/v1';
  const storageProvider = process.env.STORAGE_PROVIDER || 'local';
  
  console.log('📋 Configuration:');
  console.log(`   API Base URL: ${apiBaseUrl}`);
  console.log(`   Storage Provider: ${storageProvider}`);
  console.log(`   Expected: local\n`);

  if (storageProvider !== 'local') {
    console.log('⚠️  WARNING: STORAGE_PROVIDER is not set to "local"');
    console.log(`   Current value: ${storageProvider}`);
    console.log('   This test is for local storage. Continuing anyway...\n');
  }

  // Step 1: Get JWT token
  console.log('📋 Step 1: Authenticate');
  console.log('-'.repeat(70));
  let jwtToken: string;

  try {
    const loginUrl = `${apiBaseUrl}/auth/login`;
    console.log(`   Request: POST ${loginUrl}`);

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

    if (!loginResponse.ok) {
      const errorText = await loginResponse.text();
      throw new Error(`Login failed: HTTP ${loginResponse.status}: ${errorText}`);
    }

    const loginData = await loginResponse.json();
    jwtToken = loginData.data?.accessToken || loginData.accessToken;

    if (!jwtToken) {
      throw new Error('No access token in login response');
    }

    console.log(`   ✅ Authentication successful`);
    console.log(`   Token: ${jwtToken.substring(0, 20)}...\n`);
  } catch (error) {
    console.error(`   ❌ Authentication failed: ${error instanceof Error ? error.message : String(error)}`);
    console.error(`   Make sure the backend server is running on ${apiBaseUrl}`);
    process.exit(1);
  }

  // Step 2: Get an existing ticket or create one
  console.log('📋 Step 2: Get/Create Test Ticket');
  console.log('-'.repeat(70));
  let ticketId: string;

  try {
    // Try to get an existing ticket first
    const ticketsUrl = `${apiBaseUrl}/maintenance-tickets?limit=1`;
    console.log(`   Request: GET ${ticketsUrl}`);

    const ticketsResponse = await fetch(ticketsUrl, {
      method: 'GET',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
      },
    });

    if (ticketsResponse.ok) {
      const ticketsData = await ticketsResponse.json();
      const tickets = ticketsData.data?.items || ticketsData.items || [];
      
      if (tickets.length > 0) {
        ticketId = tickets[0].id;
        console.log(`   ✅ Using existing ticket: ${ticketId}\n`);
      } else {
        throw new Error('No tickets found');
      }
    } else {
      // If GET fails, try to create a new test ticket
      console.log('   GET failed, attempting to create test ticket...');
      const createTicketUrl = `${apiBaseUrl}/maintenance-tickets`;
      const createResponse = await fetch(createTicketUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${jwtToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          title: 'Test Ticket for Local Storage',
          description: 'This ticket is for testing local file storage upload',
          priority: 'MEDIUM',
        }),
      });

      if (createResponse.ok) {
        const ticketData = await createResponse.json();
        ticketId = ticketData.data?.id || ticketData.id;
        console.log(`   ✅ Created test ticket: ${ticketId}\n`);
      } else {
        const errorText = await createResponse.text();
        throw new Error(`Failed to create ticket: HTTP ${createResponse.status}: ${errorText}`);
      }
    }
  } catch (error) {
    console.error(`   ❌ Failed: ${error instanceof Error ? error.message : String(error)}`);
    console.error('\n   💡 Please ensure:');
    console.error('      1. Backend server is running');
    console.error('      2. You have at least one ticket in the system');
    console.error('      3. Your user has permission to access tickets');
    console.error('\n   You can create a ticket manually via the UI first.\n');
    process.exit(1);
  }

  // Step 3: Create a test image file
  console.log('📋 Step 3: Create Test Image');
  console.log('-'.repeat(70));
  
  const testImagePath = path.join(__dirname, '../test-image.jpg');
  const testImageBuffer = Buffer.alloc(1024, 0xFF); // 1KB test image (all white pixels)
  
  try {
    fs.writeFileSync(testImagePath, testImageBuffer);
    console.log(`   ✅ Created test image: ${testImagePath}`);
    console.log(`   Size: ${testImageBuffer.length} bytes\n`);
  } catch (error) {
    console.error(`   ❌ Failed to create test image: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
  }

  // Step 4: Upload the image
  console.log('📋 Step 4: Upload Image to Local Storage');
  console.log('-'.repeat(70));

  try {
    const uploadUrl = `${apiBaseUrl}/maintenance-tickets/${ticketId}/attachments/upload`;
    console.log(`   Request: POST ${uploadUrl}`);

    const formData = new FormData();
    formData.append('file', fs.createReadStream(testImagePath), {
      filename: 'test-image.jpg',
      contentType: 'image/jpeg',
    });

    const uploadResponse = await fetch(uploadUrl, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${jwtToken}`,
        ...formData.getHeaders(),
      },
      body: formData,
    });

    if (!uploadResponse.ok) {
      const errorText = await uploadResponse.text();
      throw new Error(`Upload failed: HTTP ${uploadResponse.status}: ${errorText}`);
    }

    const uploadData = await uploadResponse.json();
    const attachment = uploadData.data || uploadData;

    console.log(`   ✅ Upload successful!`);
    console.log(`   Attachment ID: ${attachment.id}`);
    console.log(`   Storage Path: ${attachment.storagePath}`);
    console.log(`   Storage URL: ${attachment.storageUrl}`);
    console.log(`   File Name: ${attachment.fileName}\n`);

    // Step 5: Verify file exists on disk
    console.log('📋 Step 5: Verify File on Disk');
    console.log('-'.repeat(70));

    const uploadsDir = process.env.UPLOADS_DIR || 'uploads';
    const expectedFilePath = path.join(process.cwd(), uploadsDir, attachment.storagePath);
    
    console.log(`   Expected file path: ${expectedFilePath}`);

    if (fs.existsSync(expectedFilePath)) {
      const stats = fs.statSync(expectedFilePath);
      console.log(`   ✅ File exists on disk!`);
      console.log(`   File size: ${stats.size} bytes`);
      console.log(`   Created: ${stats.birthtime}`);
    } else {
      console.log(`   ❌ File NOT found on disk!`);
      console.log(`   Check if STORAGE_PROVIDER=local is set`);
    }

    // Step 6: Test file access via URL
    console.log('\n📋 Step 6: Test File Access via URL');
    console.log('-'.repeat(70));

    const fileUrl = attachment.storageUrl;
    console.log(`   File URL: ${fileUrl}`);

    // Construct full URL
    const baseUrl = apiBaseUrl.replace('/api/v1', '');
    const fullFileUrl = fileUrl.startsWith('http') ? fileUrl : `${baseUrl}${fileUrl}`;
    console.log(`   Full URL: ${fullFileUrl}`);

    const fileResponse = await fetch(fullFileUrl, {
      method: 'GET',
    });

    if (fileResponse.ok) {
      const fileSize = (await fileResponse.arrayBuffer()).byteLength;
      console.log(`   ✅ File accessible via URL!`);
      console.log(`   Downloaded size: ${fileSize} bytes`);
    } else {
      console.log(`   ⚠️  File not accessible via URL (HTTP ${fileResponse.status})`);
      console.log(`   This might be normal if static file serving is not configured`);
    }

    // Cleanup
    console.log('\n📋 Cleanup');
    console.log('-'.repeat(70));
    try {
      fs.unlinkSync(testImagePath);
      console.log(`   ✅ Removed test image: ${testImagePath}`);
    } catch (error) {
      console.log(`   ⚠️  Could not remove test image: ${error instanceof Error ? error.message : String(error)}`);
    }

    // Summary
    console.log('\n' + '='.repeat(70));
    console.log('TEST SUMMARY');
    console.log('='.repeat(70));
    console.log('✅ Local storage upload test completed!');
    console.log(`   Storage Provider: ${storageProvider}`);
    console.log(`   File saved to: ${attachment.storagePath}`);
    console.log(`   Accessible at: ${attachment.storageUrl}`);
    console.log('='.repeat(70) + '\n');

  } catch (error) {
    console.error(`   ❌ Upload failed: ${error instanceof Error ? error.message : String(error)}`);
    
    // Cleanup on error
    try {
      if (fs.existsSync(testImagePath)) {
        fs.unlinkSync(testImagePath);
      }
    } catch {}

    process.exit(1);
  }
}

// Run test
testLocalStorageUpload().catch((error) => {
  console.error('\n❌ Test suite failed with error:');
  console.error(error);
  process.exit(1);
});
