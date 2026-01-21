#!/usr/bin/env ts-node
/**
 * Script to configure CORS on S3 bucket for web application access
 * 
 * Usage:
 *   npx ts-node -r tsconfig-paths/register scripts/configure-s3-cors.ts
 */

import * as dotenv from 'dotenv';
import * as path from 'path';
import { S3Client, PutBucketCorsCommand, GetBucketCorsCommand } from '@aws-sdk/client-s3';

// Load environment variables
dotenv.config({ path: path.join(__dirname, '../.env') });

async function configureS3Cors(): Promise<void> {
  const accessKeyId = process.env.AWS_S3_ACCESS_KEY_ID;
  const secretAccessKey = process.env.AWS_S3_SECRET_ACCESS_KEY;
  const region = process.env.AWS_S3_REGION || 'ap-south-1';
  const bucketName = process.env.AWS_S3_BUCKET_NAME || 'user1-bucket-test';

  if (!accessKeyId || !secretAccessKey) {
    console.error('❌ AWS S3 credentials are missing!');
    console.error(
      'Please set AWS_S3_ACCESS_KEY_ID and AWS_S3_SECRET_ACCESS_KEY in your .env file',
    );
    process.exit(1);
  }

  console.log('🔧 Configuring S3 CORS...');
  console.log(`   Bucket: ${bucketName}`);
  console.log(`   Region: ${region}`);

  const s3Client = new S3Client({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  // CORS configuration
  const corsConfig = {
    CORSRules: [
      {
        AllowedOrigins: [
          'http://localhost:*', // Allow any localhost port for development
          'https://tenx-demo.helixsense.com', // Production domain
          'https://*.helixsense.com', // All subdomains
        ],
        AllowedMethods: ['GET', 'HEAD', 'PUT', 'POST'],
        AllowedHeaders: ['*'],
        ExposeHeaders: [
          'ETag',
          'x-amz-server-side-encryption',
          'x-amz-request-id',
          'x-amz-id-2',
          'Content-Length',
          'Content-Type',
        ],
        MaxAgeSeconds: 3000, // Cache preflight requests for 50 minutes
      },
    ],
  };

  try {
    // Check current CORS configuration
    console.log('\n📋 Checking current CORS configuration...');
    try {
      const currentCors = await s3Client.send(
        new GetBucketCorsCommand({ Bucket: bucketName }),
      );
      console.log('   Current CORS rules:', JSON.stringify(currentCors.CORSRules, null, 2));
    } catch (error: unknown) {
      if (error instanceof Error && error.name === 'NoSuchCORSConfiguration') {
        console.log('   No existing CORS configuration found');
      } else {
        throw error;
      }
    }

    // Apply new CORS configuration
    console.log('\n📝 Applying new CORS configuration...');
    await s3Client.send(
      new PutBucketCorsCommand({
        Bucket: bucketName,
        CORSConfiguration: corsConfig,
      }),
    );

    console.log('   ✅ CORS configuration applied successfully!');

    // Verify the configuration
    console.log('\n🔍 Verifying CORS configuration...');
    const verifyCors = await s3Client.send(
      new GetBucketCorsCommand({ Bucket: bucketName }),
    );
    console.log('   ✅ Verified CORS rules:', JSON.stringify(verifyCors.CORSRules, null, 2));

    console.log('\n✅ S3 CORS configuration completed successfully!');
    console.log('\n📝 Next steps:');
    console.log('   1. Clear your browser cache');
    console.log('   2. Reload your Flutter web application');
    console.log('   3. Try loading an image attachment');
    console.log('   4. CORS errors should be resolved');
  } catch (error: unknown) {
    console.error('\n❌ Failed to configure S3 CORS!');
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

// Run the script
configureS3Cors().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
