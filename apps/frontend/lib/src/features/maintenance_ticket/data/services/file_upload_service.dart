import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

/// Result of file upload operation
class UploadResult {
  const UploadResult({
    required this.success,
    this.attachmentId,
    this.error,
    this.fileName,
  });

  final bool success;
  final String? attachmentId;
  final String? error;
  final String? fileName;
}

/// Service for uploading files to the backend
class FileUploadService {
  FileUploadService(this._dio);

  final Dio _dio;

  /// Upload a single image file
  /// Returns attachment metadata on success
  Future<UploadResult> uploadImage(
    String ticketId,
    PlatformFile file, {
    ProgressCallback? onProgress,
  }) async {
    try {
      // Prepare file for upload
      FormData formData;
      if (kIsWeb) {
        // Web: Use bytes
        if (file.bytes == null) {
          return const UploadResult(
            success: false,
            error: 'File bytes are null',
          );
        }
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
        });
      } else {
        // Mobile: Use file path
        if (file.path == null) {
          return const UploadResult(
            success: false,
            error: 'File path is null',
          );
        }
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          ),
        });
      }

      // Upload to backend
      final response = await _dio.post<Map<String, dynamic>>(
        '/maintenance-tickets/$ticketId/attachments/upload',
        data: formData,
        onSendProgress: onProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Parse response
      final data = response.data;
      if (data == null) {
        return const UploadResult(
          success: false,
          error: 'Empty response from server',
        );
      }

      // Handle wrapped response format
      Map<String, dynamic> attachmentData;
      if (data.containsKey('data')) {
        attachmentData = data['data'] as Map<String, dynamic>;
      } else {
        attachmentData = data;
      }

      final attachmentId = attachmentData['id'] as String?;
      if (attachmentId == null) {
        return const UploadResult(
          success: false,
          error: 'No attachment ID in response',
        );
      }

      return UploadResult(
        success: true,
        attachmentId: attachmentId,
        fileName: attachmentData['fileName'] as String? ?? file.name,
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

      return UploadResult(
        success: false,
        error: errorMessage,
        fileName: file.name,
      );
    } catch (e) {
      return UploadResult(
        success: false,
        error: e.toString(),
        fileName: file.name,
      );
    }
  }

  /// Upload multiple images in parallel (max 3 concurrent)
  Future<List<UploadResult>> uploadMultipleImages(
    String ticketId,
    List<PlatformFile> files, {
    void Function(int index, int sent, int total)? onProgress,
  }) async {
    final results = <UploadResult>[];
    const maxConcurrent = 3;

    // Upload in batches
    for (var i = 0; i < files.length; i += maxConcurrent) {
      final batch = files.skip(i).take(maxConcurrent).toList();
      final batchResults = await Future.wait(
        batch.asMap().entries.map(
          (entry) async {
            final index = i + entry.key;
            final file = entry.value;
            return uploadImage(
              ticketId,
              file,
              onProgress: (sent, total) {
                onProgress?.call(index, sent, total);
              },
            );
          },
        ),
      );
      results.addAll(batchResults);
    }

    return results;
  }
}
