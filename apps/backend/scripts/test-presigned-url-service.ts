import { S3StorageService } from '../src/modules/maintenance-ticket/services/s3-storage.service';
import { ConfigService } from '@nestjs/config';
import * as dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

async function testPresignedUrlService(): Promise<void> {
  console.log('🧪 Testing S3StorageService.generatePresignedUploadUrl()...\n');

  // Create a mock ConfigService that reads from environment
  const configService = {
    get: (key: string): string | undefined => {
      return process.env[key];
    },
  } as ConfigService;

  try {
    // Initialize the service
    const s3Service = new S3StorageService(configService);
    console.log('✅ S3StorageService initialized\n');

    // Test data
    const ticketId = 'test-ticket-' + Date.now();
    const fileName = 'test-image.png';
    const mimeType = 'image/png';
    const fileSize = 1024; // 1KB

    console.log('📋 Test Parameters:');
    console.log(`   Ticket ID: ${ticketId}`);
    console.log(`   File Name: ${fileName}`);
    console.log(`   MIME Type: ${mimeType}`);
    console.log(`   File Size: ${fileSize} bytes\n`);

    // Generate presigned URL
    console.log('🔗 Generating presigned URL...');
    const result = await s3Service.generatePresignedUploadUrl(
      ticketId,
      fileName,
      mimeType,
      fileSize,
    );

    console.log('✅ Presigned URL generated successfully!\n');

    // Check for checksum parameters
    console.log('🔍 Analyzing presigned URL...');
    const url = new URL(result.presignedUrl);
    const checksumParams = [
      'x-amz-checksum-crc32',
      'x-amz-checksum-crc32c',
      'x-amz-checksum-sha1',
      'x-amz-checksum-sha256',
      'x-amz-sdk-checksum-algorithm',
    ];

    const foundChecksumParams: string[] = [];
    for (const param of checksumParams) {
      if (url.searchParams.has(param)) {
        foundChecksumParams.push(param);
      }
    }

    console.log(`   URL Length: ${result.presignedUrl.length} characters`);
    console.log(`   S3 Key: ${result.s3Key}`);
    console.log(`   Expires At: ${result.expiresAt.toISOString()}`);
    console.log(`   Storage URL: ${result.storageUrl}\n`);

    if (foundChecksumParams.length > 0) {
      console.error('❌ TEST FAILED: Presigned URL contains checksum parameters!');
      console.error(`   Found parameters: ${foundChecksumParams.join(', ')}`);
      console.error('\n   This will cause upload failures because:');
      console.error('   1. The signature includes these parameters');
      console.error('   2. The client doesn\'t send matching checksum headers');
      console.error('   3. S3 rejects the request due to signature mismatch\n');
      console.error(`   URL Preview: ${result.presignedUrl.substring(0, 200)}...\n`);
      process.exit(1);
    } else {
      console.log('✅ TEST PASSED: No checksum parameters found in presigned URL');
      console.log('   This means the URL should work correctly for client-side uploads\n');
    }

    // Display a portion of the URL for manual inspection
    console.log('📋 URL Preview (first 150 chars):');
    console.log(`   ${result.presignedUrl.substring(0, 150)}...\n`);

    console.log('✅ All tests passed! The presigned URL generation is working correctly.\n');
  } catch (error: unknown) {
    console.error('\n❌ Test failed with error:');
    if (error instanceof Error) {
      console.error(`   Message: ${error.message}`);
      if (error.stack) {
        console.error(`   Stack: ${error.stack}`);
      }
    } else {
      console.error(`   Unknown error: ${error}`);
    }
    process.exit(1);
  }
}

// Run the test
testPresignedUrlService().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
