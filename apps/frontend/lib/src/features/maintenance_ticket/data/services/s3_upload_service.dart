import 'dart:typed_data';
import 'dart:io' show File, HttpClient;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/image_compression.dart';
import '../../../../core/utils/image_validation.dart';

/// Upload status for individual images
enum ImageUploadStatus {
  pending,
  uploading,
  success,
  failed,
  retrying,
}

/// Upload progress information
class ImageUploadProgress {
  const ImageUploadProgress({
    required this.status,
    this.progress = 0.0,
    this.error,
    this.attachmentId,
    this.retryCount = 0,
  });

  final ImageUploadStatus status;
  final double progress; // 0.0 to 1.0
  final String? error;
  final String? attachmentId;
  final int retryCount;

  ImageUploadProgress copyWith({
    ImageUploadStatus? status,
    double? progress,
    String? error,
    String? attachmentId,
    int? retryCount,
  }) {
    return ImageUploadProgress(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      attachmentId: attachmentId ?? this.attachmentId,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Result of S3 direct upload
class S3UploadResult {
  const S3UploadResult({
    required this.success,
    this.attachmentId,
    this.error,
    this.fileName,
    this.s3Key,
  });

  final bool success;
  final String? attachmentId;
  final String? error;
  final String? fileName;
  final String? s3Key;
}

/// Service for direct S3 uploads with presigned URLs
class S3UploadService {
  S3UploadService({
    required ApiClient apiClient,
    Dio? dio, // Optional - not used, kept for potential future use
  })  : _apiClient = apiClient {
    // Create a clean Dio instance for S3 uploads without interceptors or default headers
    // This ensures the presigned URL signature isn't broken by added headers
    _s3Dio = Dio(
      BaseOptions(
        // No base URL - we use the full presigned URL
        // No default headers - presigned URL includes everything in signature
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        validateStatus: (status) {
          // S3 returns 200 on successful PUT
          return status != null && status >= 200 && status < 300;
        },
        followRedirects: false,
      ),
    );
    // Don't add any interceptors - they might modify the request and break the signature
  }

  final ApiClient _apiClient;
  late final Dio _s3Dio; // Clean Dio instance for S3 uploads (no interceptors, no default headers)

  /// Maximum number of retry attempts
  static const int maxRetries = 3;

  /// Retry delay in seconds (exponential backoff)
  static const int baseRetryDelay = 2;

  /// Upload image directly to S3 using presigned URL
  /// Returns attachment ID after successful upload and metadata creation
  Future<S3UploadResult> uploadImageToS3(
    String ticketId,
    PlatformFile file, {
    ProgressCallback? onProgress,
    ImageCompressionConfig? compressionConfig,
    ImageValidationConfig? validationConfig,
  }) async {
    try {
      // Step 1: Validate image
      final validationResult = await ImageValidation.validateImage(
        file,
        config: validationConfig ?? const ImageValidationConfig(),
      );

      if (!validationResult.isValid) {
        return S3UploadResult(
          success: false,
          error: validationResult.error ?? 'Image validation failed',
          fileName: file.name,
        );
      }

      // Step 2: Compress image if needed
      Uint8List imageBytes;
      String mimeType;
      int fileSize;
      int? width;
      int? height;

      if (ImageCompression.needsCompression(
        file,
        compressionConfig ?? const ImageCompressionConfig(),
      )) {
        final compressed = await ImageCompression.compressImage(
          file,
          config: compressionConfig ?? const ImageCompressionConfig(),
        );

        if (compressed == null) {
          return S3UploadResult(
            success: false,
            error: 'Failed to compress image',
            fileName: file.name,
          );
        }

        imageBytes = compressed.bytes;
        mimeType = compressed.mimeType;
        fileSize = compressed.compressedSize;
        width = compressed.width;
        height = compressed.height;
      } else {
        // Use original file
        if (kIsWeb) {
          if (file.bytes == null) {
            return S3UploadResult(
              success: false,
              error: 'File bytes are null',
              fileName: file.name,
            );
          }
          imageBytes = file.bytes!;
        } else {
          if (file.path == null) {
            return S3UploadResult(
              success: false,
              error: 'File path is null',
              fileName: file.name,
            );
          }
          imageBytes = await (await File(file.path!)).readAsBytes();
        }

        // Determine MIME type
        final ext = file.extension?.toLowerCase() ?? '';
        if (ext == 'jpg' || ext == 'jpeg') {
          mimeType = 'image/jpeg';
        } else if (ext == 'png') {
          mimeType = 'image/png';
        } else if (ext == 'webp') {
          mimeType = 'image/webp';
        } else {
          mimeType = 'image/jpeg'; // Default
        }

        fileSize = imageBytes.length;
        width = validationResult.width;
        height = validationResult.height;
      }

      // Step 3: Get presigned URL from backend (using generic endpoint)
      // Industry-standard pattern: No AWS credentials in Flutter, all uploads use pre-signed URLs
      final presignedResponse = await _apiClient.generatePresignedUploadUrlGeneric(
        entityType: 'maintenance-ticket',
        entityId: ticketId,
        fileName: file.name,
        mimeType: mimeType,
        fileSize: fileSize,
      );

      // Step 4: Detect storage type and upload accordingly
      // Local storage URLs start with /api/uploads/ (relative paths)
      // S3 URLs are absolute URLs containing s3.amazonaws.com or other S3 domains
      final presignedUrl = presignedResponse.presignedUrl;
      final isLocalStorage = presignedUrl.startsWith('/api/uploads/') ||
          (presignedUrl.startsWith('/') && !presignedUrl.startsWith('http'));

      if (isLocalStorage) {
        // For local storage, use multipart form upload to backend endpoint
        // The presigned URL is just a reference, we upload via the backend API
        final formData = FormData.fromMap({
          'file': kIsWeb
              ? MultipartFile.fromBytes(
                  imageBytes,
                  filename: file.name,
                )
              : await MultipartFile.fromFile(
                  file.path!,
                  filename: file.name,
                ),
        });

        final uploadResponse = await _apiClient.uploadFileDirectly(
          ticketId: ticketId,
          formData: formData,
          onProgress: onProgress,
        );

        // Use the response from direct upload (already includes attachment metadata)
        return S3UploadResult(
          success: true,
          attachmentId: uploadResponse.id,
          fileName: file.name,
          s3Key: uploadResponse.storage_path,
        );
      }

      // Continue with S3 upload flow below...

      // For S3 storage, upload directly to S3 using presigned URL
      // Note: When AWS SDK adds checksum parameters to the presigned URL query string,
      // they are part of the signature and should NOT be sent as headers.
      // The query parameters in the URL are sufficient for S3 validation.
      
      if (kIsWeb) {
        // For web, use Dio with Content-Type header only
        // Checksum parameters (if present) are in the URL query string, not headers
        final response = await _s3Dio.put<dynamic>(
          presignedResponse.presignedUrl,
          data: imageBytes,
          options: Options(
            // Send Content-Type header to match the presigned URL signature
            headers: <String, dynamic>{
              'Content-Type': mimeType,
            },
            followRedirects: false,
            validateStatus: (status) => status != null && status >= 200 && status < 300,
          ),
          onSendProgress: onProgress,
        );
        
        if (response.statusCode == null ||
            response.statusCode! < 200 ||
            response.statusCode! >= 300) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: 'S3 upload failed with status ${response.statusCode}',
          );
        }
      } else {
        // For mobile, use raw HttpClient for maximum control
        final uri = Uri.parse(presignedResponse.presignedUrl);
        final client = HttpClient();
        
        try {
          final request = await client.putUrl(uri);
          // Set Content-Type header only (checksum params are in URL query string if present)
          request.headers.set('Content-Type', mimeType);
          request.contentLength = imageBytes.length;
          
          // Write data with progress tracking
          int sent = 0;
          const chunkSize = 8192; // 8KB chunks
          for (int i = 0; i < imageBytes.length; i += chunkSize) {
            final end = (i + chunkSize < imageBytes.length)
                ? i + chunkSize
                : imageBytes.length;
            final chunk = imageBytes.sublist(i, end);
            request.add(chunk); // add() is synchronous, returns void
            sent += chunk.length;
            onProgress?.call(sent, imageBytes.length);
          }
          
          // Close the request to send it and get the response
          final response = await request.close();
          final statusCode = response.statusCode;
          
          if (statusCode < 200 || statusCode >= 300) {
            throw Exception('S3 upload failed with status $statusCode');
          }
        } finally {
          client.close();
        }
      }

      // Step 5: Create attachment metadata in backend
      final attachmentResponse = await _apiClient.createAttachmentMetadata(
        ticketId: ticketId,
        fileName: presignedResponse.fileName,
        originalName: file.name,
        mimeType: mimeType,
        fileSize: fileSize,
        storagePath: presignedResponse.s3Key,
        storageUrl: presignedResponse.storageUrl,
        width: width,
        height: height,
      );

      return S3UploadResult(
        success: true,
        attachmentId: attachmentResponse.id,
        fileName: file.name,
        s3Key: presignedResponse.s3Key,
      );
    } on DioException catch (e) {
      String errorMessage = 'Upload failed';
      if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] as String? ??
              errorData['error'] as String? ??
              errorMessage;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return S3UploadResult(
        success: false,
        error: errorMessage,
        fileName: file.name,
      );
    } catch (e) {
      return S3UploadResult(
        success: false,
        error: e.toString(),
        fileName: file.name,
      );
    }
  }

  /// Upload multiple images with retry mechanism
  /// Returns list of upload results with progress tracking
  Future<List<S3UploadResult>> uploadMultipleImagesWithRetry(
    String ticketId,
    List<PlatformFile> files, {
    void Function(int index, ImageUploadProgress progress)? onProgress,
    ImageCompressionConfig? compressionConfig,
    ImageValidationConfig? validationConfig,
    int maxConcurrent = 3,
  }) async {
    final results = <S3UploadResult>[];
    final progressTrackers = List<ImageUploadProgress>.generate(
      files.length,
      (_) => const ImageUploadProgress(status: ImageUploadStatus.pending),
    );

    // Upload in batches
    for (var i = 0; i < files.length; i += maxConcurrent) {
      final batch = files.skip(i).take(maxConcurrent).toList();
      final batchResults = await Future.wait(
        batch.asMap().entries.map(
          (entry) async {
            final index = i + entry.key;
            final file = entry.value;

            // Update progress to uploading
            progressTrackers[index] = progressTrackers[index].copyWith(
              status: ImageUploadStatus.uploading,
            );
            onProgress?.call(index, progressTrackers[index]);

            // Attempt upload with retry
            S3UploadResult? result;
            int retryCount = 0;

            while (retryCount <= maxRetries && result == null) {
              if (retryCount > 0) {
                // Update to retrying status
                progressTrackers[index] = progressTrackers[index].copyWith(
                  status: ImageUploadStatus.retrying,
                  retryCount: retryCount,
                );
                onProgress?.call(index, progressTrackers[index]);

                // Exponential backoff
                await Future<void>.delayed(
                  Duration(seconds: baseRetryDelay * retryCount),
                );
              }

              result = await uploadImageToS3(
                ticketId,
                file,
                onProgress: (sent, total) {
                  final progress = sent / total;
                  progressTrackers[index] = progressTrackers[index].copyWith(
                    progress: progress,
                  );
                  onProgress?.call(index, progressTrackers[index]);
                },
                compressionConfig: compressionConfig,
                validationConfig: validationConfig,
              );

              if (!result.success) {
                if (retryCount < maxRetries) {
                  result = null; // Retry
                  retryCount++;
                } else {
                  // Final failure
                  progressTrackers[index] = progressTrackers[index].copyWith(
                    status: ImageUploadStatus.failed,
                    error: result.error,
                  );
                  onProgress?.call(index, progressTrackers[index]);
                }
              } else {
                // Success
                progressTrackers[index] = progressTrackers[index].copyWith(
                  status: ImageUploadStatus.success,
                  attachmentId: result.attachmentId,
                  progress: 1.0,
                );
                onProgress?.call(index, progressTrackers[index]);
              }
            }

            return result ?? S3UploadResult(
              success: false,
              error: 'Upload failed after $maxRetries retries',
              fileName: file.name,
            );
          },
        ),
      );
      results.addAll(batchResults);
    }

    return results;
  }
}
