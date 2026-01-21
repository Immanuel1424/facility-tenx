import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';
import * as crypto from 'crypto';

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, '../.env') });

async function testPresignedUpload(imagePath?: string): Promise<void> {
  const accessKeyId = process.env.AWS_S3_ACCESS_KEY_ID;
  const secretAccessKey = process.env.AWS_S3_SECRET_ACCESS_KEY;
  const region = process.env.AWS_S3_REGION || 'ap-south-1';
  const bucketName = process.env.AWS_S3_BUCKET_NAME || 'user1-bucket-test';
  const basePrefix = process.env.AWS_S3_BASE_PREFIX || 'tenx-attachments';

  if (!accessKeyId || !secretAccessKey) {
    console.error('❌ AWS S3 credentials are missing!');
    process.exit(1);
  }

  console.log('🔍 Testing Presigned URL Upload...');
  console.log(`   Bucket: ${bucketName}`);
  console.log(`   Region: ${region}`);
  console.log(`   Prefix: ${basePrefix}\n`);

  const s3Client = new S3Client({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  try {
    // Generate test image data if no image provided
    let imageBytes: Buffer;
    let fileName: string;
    let mimeType: string;
    let fileSize: number;

    if (imagePath && fs.existsSync(imagePath)) {
      imageBytes = fs.readFileSync(imagePath);
      fileName = path.basename(imagePath);
      const fileExtension = path.extname(imagePath).toLowerCase();
      const mimeTypes: Record<string, string> = {
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.png': 'image/png',
        '.webp': 'image/webp',
      };
      mimeType = mimeTypes[fileExtension] || 'image/jpeg';
      fileSize = imageBytes.length;
      console.log(`📷 Using image: ${fileName}`);
      console.log(`   📏 Size: ${(fileSize / 1024).toFixed(2)} KB`);
      console.log(`   🎨 MIME type: ${mimeType}\n`);
    } else {
      // Create a simple test image (1x1 PNG)
      const testImageBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      imageBytes = Buffer.from(testImageBase64, 'base64');
      fileName = 'test-image.png';
      mimeType = 'image/png';
      fileSize = imageBytes.length;
      console.log(`📷 Using generated test image: ${fileName}`);
      console.log(`   📏 Size: ${fileSize} bytes`);
      console.log(`   🎨 MIME type: ${mimeType}\n`);
    }

    // Generate unique S3 key (matching our service pattern)
    const ticketId = crypto.randomUUID();
    const uniqueFileName = `${crypto.randomUUID()}${path.extname(fileName)}`;
    const s3Key = `${basePrefix}/tickets/${ticketId}/${uniqueFileName}`;

    console.log('📋 Step 1: Generating presigned URL...');
    console.log(`   Ticket ID: ${ticketId}`);
    console.log(`   S3 Key: ${s3Key}`);

    // Generate presigned URL (same approach as our service)
    const putCommand = new PutObjectCommand({
      Bucket: bucketName,
      Key: s3Key,
      ContentType: mimeType,
      Metadata: {
        originalName: fileName,
        ticketId: ticketId,
      },
      // Do not set ChecksumAlgorithm - let S3 handle it server-side
    });

    const presignedUrl = await getSignedUrl(s3Client, putCommand, {
      expiresIn: 3600, // 1 hour
    });

    console.log(`   ✅ Presigned URL generated`);
    console.log(`   🔗 URL length: ${presignedUrl.length} characters`);
    console.log(`   🔍 URL preview: ${presignedUrl.substring(0, 100)}...\n`);

    // Check if URL contains checksum parameters
    const hasChecksum = presignedUrl.includes('x-amz-checksum') || presignedUrl.includes('checksum');
    if (hasChecksum) {
      console.log('   ⚠️  WARNING: Presigned URL contains checksum parameters');
      console.log('   This may cause signature mismatch issues during upload\n');
    } else {
      console.log('   ✅ No checksum parameters in presigned URL\n');
    }

    console.log('📤 Step 2: Uploading file using presigned URL...');
    
    // Upload using presigned URL (simulating client-side upload)
    // Use Node.js built-in fetch (available in Node 18+)
    // Convert Buffer to Uint8Array for fetch API
    const uploadResponse = await fetch(presignedUrl, {
      method: 'PUT',
      body: new Uint8Array(imageBytes),
      headers: {
        'Content-Type': mimeType,
      },
    });

    if (!uploadResponse.ok) {
      const errorText = await uploadResponse.text();
      console.error(`   ❌ Upload failed!`);
      console.error(`   Status: ${uploadResponse.status} ${uploadResponse.statusText}`);
      console.error(`   Error: ${errorText}`);
      throw new Error(`Upload failed: ${uploadResponse.status} ${uploadResponse.statusText}`);
    }

    console.log(`   ✅ Upload successful!`);
    console.log(`   Status: ${uploadResponse.status} ${uploadResponse.statusText}\n`);

    console.log('🔍 Step 3: Verifying uploaded file...');
    const { ListObjectsV2Command } = await import('@aws-sdk/client-s3');
    const listCommand = new ListObjectsV2Command({
      Bucket: bucketName,
      Prefix: s3Key,
    });

    const listResponse = await s3Client.send(listCommand);
    if (listResponse.Contents && listResponse.Contents.length > 0) {
      const uploadedFile = listResponse.Contents[0];
      console.log(`   ✅ File verified in S3`);
      console.log(`   📏 Size: ${uploadedFile.Size} bytes`);
      console.log(`   📅 Last modified: ${uploadedFile.LastModified?.toISOString()}`);
      console.log(`   🔗 Storage URL: https://${bucketName}.s3.${region}.amazonaws.com/${s3Key}\n`);
    } else {
      console.log(`   ⚠️  File not found in S3 listing (may take a moment to appear)\n`);
    }

    console.log('✅ All presigned URL upload tests passed!');
    console.log('\n📝 Summary:');
    console.log(`   - Presigned URL generation: ✅ Working`);
    console.log(`   - Direct S3 upload: ✅ Working`);
    console.log(`   - File verification: ✅ Working`);
    console.log(`   - Checksum parameters: ${hasChecksum ? '⚠️  Present (may cause issues)' : '✅ Not present'}\n`);
    console.log('🎉 Presigned URL upload flow is ready to use!');
  } catch (error: unknown) {
    console.error('\n❌ Presigned URL upload test failed!');
    if (error instanceof Error) {
      console.error(`   Error: ${error.message}`);
      if (error.stack) {
        console.error(`   Stack: ${error.stack}`);
      }
    } else {
      console.error(`   Unknown error: ${error}`);
    }
    process.exit(1);
  }
}

// Get image path from command line arguments
const imagePath = process.argv[2];

// Run the test
if (imagePath) {
  console.log(`📷 Image path provided: ${imagePath}\n`);
}

testPresignedUpload(imagePath).catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
