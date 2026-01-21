import { NestFactory } from '@nestjs/core';
import { VersioningType, ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { NestExpressApplication } from '@nestjs/platform-express';
import session from 'express-session';
import { writeFileSync } from 'fs';
import { join } from 'path';
import * as express from 'express';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './shared/filters/global-exception.filter';
import { TenantResolutionMiddleware } from './shared/middleware/tenant-resolution.middleware';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Enable CORS for Flutter web and mobile development
  // In development, allow all origins (including embedded browsers like Cursor's browser tab)
  // In production, restrict to specific origins for security
  const isDevelopment = process.env.NODE_ENV !== 'production';
  const allowedOrigins = process.env.CORS_ORIGIN
    ? process.env.CORS_ORIGIN.split(',')
    : [
        'http://localhost:3000',
        'http://localhost:8080',
        'http://localhost:5000',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:8080',
        'http://127.0.0.1:5000',
      ];

  app.enableCors({
    // In development, allow all origins to support embedded browsers (Cursor, VS Code, etc.)
    // In production, use the configured origins
    origin: isDevelopment ? true : allowedOrigins,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-company-id', 'x-site-id'],
  });

  app.setGlobalPrefix('api');

  // Serve static files from uploads directory (for local storage)
  // This allows direct access to uploaded files via /api/uploads/* URLs
  // Must be added AFTER setGlobalPrefix to get /api/uploads path
  const uploadsDir = process.env.UPLOADS_DIR || 'uploads';
  app.use('/api/uploads', express.static(join(process.cwd(), uploadsDir)));
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
        exposeDefaultValues: true,
      },
    }),
  );

  app.use(
    session({
      secret: process.env.SESSION_SECRET || 'your-session-secret-change-in-production',
      resave: false,
      saveUninitialized: false,
      cookie: {
        secure: process.env.NODE_ENV === 'production',
        httpOnly: true,
        maxAge: 60000 * 60,
      },
    }),
  );

  app.useGlobalFilters(new GlobalExceptionFilter());
  app.use(TenantResolutionMiddleware.create());

  const config = new DocumentBuilder()
    .setTitle('TENX API')
    .setDescription('Multi-tenant SaaS ERP backend API')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        in: 'header',
      },
      'access-token',
    )
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  // Persist OpenAPI spec for client generation (optional - don't fail if write fails)
  try {
    const openApiPath = join(process.cwd(), 'openapi-v1.json');
    writeFileSync(openApiPath, JSON.stringify(document, null, 2));
  } catch (error) {
    // Log warning but don't fail startup if OpenAPI file can't be written
    console.warn('Warning: Could not write openapi-v1.json file:', error instanceof Error ? error.message : String(error));
  }

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}/api`);
}

void bootstrap();


