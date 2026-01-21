import { S3Client, ListObjectsV2Command, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, '../.env') });

async function testS3Connection(imagePath?: string): Promise<void> {
  const accessKeyId = process.env.AWS_S3_ACCESS_KEY_ID;
  const secretAccessKey = process.env.AWS_S3_SECRET_ACCESS_KEY;
  const region = process.env.AWS_S3_REGION || 'ap-south-1';
  const bucketName = process.env.AWS_S3_BUCKET_NAME || 'user1-bucket-test';
  const basePrefix = process.env.AWS_S3_BASE_PREFIX || 'tenx-attachments';

  if (!accessKeyId || !secretAccessKey) {
    console.error('❌ AWS S3 credentials are missing!');
    console.error('Please set AWS_S3_ACCESS_KEY_ID and AWS_S3_SECRET_ACCESS_KEY in your .env file');
    process.exit(1);
  }

  console.log('🔍 Testing S3 Connection...');
  console.log(`   Bucket: ${bucketName}`);
  console.log(`   Region: ${region}`);
  console.log(`   Prefix: ${basePrefix}`);

  const s3Client = new S3Client({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  try {
    // Test 1: List objects in the prefix directory
    console.log('\n📋 Test 1: Listing objects in prefix directory...');
    const listCommand = new ListObjectsV2Command({
      Bucket: bucketName,
      Prefix: `${basePrefix}/`,
      MaxKeys: 5,
    });

    const listResponse = await s3Client.send(listCommand);
    console.log(`   ✅ Successfully connected to S3!`);
    console.log(`   Found ${listResponse.KeyCount || 0} objects in prefix`);
    
    if (listResponse.Contents && listResponse.Contents.length > 0) {
      console.log('   Sample objects:');
      listResponse.Contents.slice(0, 3).forEach((obj) => {
        console.log(`     - ${obj.Key} (${obj.Size} bytes)`);
      });
    }

    // Test 2: Upload a test file (image if provided, otherwise text file)
    console.log('\n📤 Test 2: Uploading test file...');
    let testKey: string;
    let fileBody: Buffer | string;
    let contentType: string;
    let fileName: string;

    if (imagePath && fs.existsSync(imagePath)) {
      // Upload the provided image file
      fileName = path.basename(imagePath);
      const fileExtension = path.extname(imagePath).toLowerCase();
      const mimeTypes: Record<string, string> = {
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.png': 'image/png',
        '.webp': 'image/webp',
      };
      contentType = mimeTypes[fileExtension] || 'image/jpeg';
      
      fileBody = fs.readFileSync(imagePath);
      testKey = `${basePrefix}/test/image-upload-test-${Date.now()}${fileExtension}`;
      
      console.log(`   📷 Uploading image: ${fileName}`);
      console.log(`   📏 File size: ${(fileBody.length / 1024).toFixed(2)} KB`);
      console.log(`   🎨 Content type: ${contentType}`);
    } else {
      // Upload a text test file
      fileName = 'connection-test.txt';
      testKey = `${basePrefix}/test/connection-test-${Date.now()}.txt`;
      fileBody = `S3 Connection Test - ${new Date().toISOString()}`;
      contentType = 'text/plain';
      
      if (imagePath) {
        console.log(`   ⚠️  Image file not found: ${imagePath}`);
        console.log(`   📝 Falling back to text file upload...`);
      }
    }

    const putCommand = new PutObjectCommand({
      Bucket: bucketName,
      Key: testKey,
      Body: fileBody,
      ContentType: contentType,
      Metadata: {
        originalName: fileName,
        uploadedAt: new Date().toISOString(),
        testType: imagePath ? 'image' : 'text',
      },
    });

    await s3Client.send(putCommand);
    console.log(`   ✅ Successfully uploaded file: ${testKey}`);

    // Test 3: Verify the uploaded file
    console.log('\n🔍 Test 3: Verifying uploaded file...');
    const verifyListCommand = new ListObjectsV2Command({
      Bucket: bucketName,
      Prefix: testKey,
    });

    const verifyResponse = await s3Client.send(verifyListCommand);
    if (verifyResponse.Contents && verifyResponse.Contents.length > 0) {
      const uploadedFile = verifyResponse.Contents[0];
      console.log(`   ✅ File verified: ${uploadedFile.Key}`);
      console.log(`   📏 Size: ${uploadedFile.Size} bytes`);
      console.log(`   📅 Last modified: ${uploadedFile.LastModified?.toISOString()}`);
    }

    // Test 4: Generate presigned URL and verify file can be accessed
    if (imagePath && fs.existsSync(imagePath)) {
      console.log('\n🔗 Test 4: Generating presigned URL for image access...');
      try {
        const getCommand = new GetObjectCommand({
          Bucket: bucketName,
          Key: testKey,
        });
        const presignedUrl = await getSignedUrl(s3Client, getCommand, { expiresIn: 3600 });
        console.log(`   ✅ Presigned URL generated (expires in 1 hour)`);
        console.log(`   🔗 URL: ${presignedUrl.substring(0, 80)}...`);
        console.log(`   💡 You can use this URL to access the image directly`);
      } catch (error) {
        console.log(`   ⚠️  Could not generate presigned URL: ${error instanceof Error ? error.message : 'Unknown error'}`);
      }
    }

    console.log('\n✅ All S3 connection tests passed!');
    console.log('\n📝 Summary:');
    console.log(`   - Bucket: ${bucketName}`);
    console.log(`   - Region: ${region}`);
    console.log(`   - Prefix: ${basePrefix}`);
    console.log(`   - Access: ✅ Working`);
    console.log(`   - Upload: ✅ Working`);
    console.log('\n🎉 S3 integration is ready to use!');
  } catch (error: unknown) {
    console.error('\n❌ S3 connection test failed!');
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

testS3Connection(imagePath).catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});

