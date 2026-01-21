import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Image validation configuration
class ImageValidationConfig {
  const ImageValidationConfig({
    this.maxFileSizeMB = 10,
    this.maxWidth = 4096,
    this.maxHeight = 4096,
    this.minWidth = 1,
    this.minHeight = 1,
    this.allowedMimeTypes = const [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
    ],
  });

  final int maxFileSizeMB;
  final int maxWidth;
  final int maxHeight;
  final int minWidth;
  final int minHeight;
  final List<String> allowedMimeTypes;
}

/// Image validation result
class ImageValidationResult {
  const ImageValidationResult({
    required this.isValid,
    this.error,
    this.width,
    this.height,
    this.fileSize,
    this.mimeType,
  });

  final bool isValid;
  final String? error;
  final int? width;
  final int? height;
  final int? fileSize;
  final String? mimeType;

  static const ImageValidationResult valid = ImageValidationResult(isValid: true);
}

/// Utility for validating images before upload
class ImageValidation {
  /// Validate image file
  static Future<ImageValidationResult> validateImage(
    PlatformFile file, {
    ImageValidationConfig config = const ImageValidationConfig(),
  }) async {
    // Check file size
    final fileSizeMB = file.size / (1024 * 1024);
    if (fileSizeMB > config.maxFileSizeMB) {
      return ImageValidationResult(
        isValid: false,
        error:
            'Image size exceeds maximum allowed size of ${config.maxFileSizeMB}MB',
        fileSize: file.size,
      );
    }

    // Check MIME type
    String? mimeType;
    if (file.extension != null) {
      final ext = file.extension!.toLowerCase();
      switch (ext) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = null;
      }
    }

    if (mimeType == null || !config.allowedMimeTypes.contains(mimeType)) {
      return ImageValidationResult(
        isValid: false,
        error:
            'Invalid image format. Allowed formats: ${config.allowedMimeTypes.join(', ')}',
        mimeType: mimeType,
      );
    }

    // Validate image dimensions
    try {
      Uint8List? imageBytes;
      if (kIsWeb) {
        if (file.bytes == null) {
          return const ImageValidationResult(
            isValid: false,
            error: 'Image bytes are null',
          );
        }
        imageBytes = file.bytes;
      } else {
        if (file.path == null) {
          return const ImageValidationResult(
            isValid: false,
            error: 'Image path is null',
          );
        }
        final fileData = await (await File(file.path!)).readAsBytes();
        imageBytes = fileData;
      }

      if (imageBytes == null || imageBytes.isEmpty) {
        return const ImageValidationResult(
          isValid: false,
          error: 'Image file is empty',
        );
      }

      // Decode image to get dimensions
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final width = image.width;
      final height = image.height;

      image.dispose();

      // Validate dimensions
      if (width < config.minWidth || height < config.minHeight) {
        return ImageValidationResult(
          isValid: false,
          error:
              'Image dimensions too small. Minimum: ${config.minWidth}x${config.minHeight}px',
          width: width,
          height: height,
        );
      }

      if (width > config.maxWidth || height > config.maxHeight) {
        return ImageValidationResult(
          isValid: false,
          error:
              'Image dimensions too large. Maximum: ${config.maxWidth}x${config.maxHeight}px',
          width: width,
          height: height,
        );
      }

      return ImageValidationResult(
        isValid: true,
        width: width,
        height: height,
        fileSize: file.size,
        mimeType: mimeType,
      );
    } catch (e) {
      return ImageValidationResult(
        isValid: false,
        error: 'Failed to validate image: $e',
      );
    }
  }

  /// Quick validation (checks file size and extension only, no image decoding)
  static ImageValidationResult quickValidate(
    PlatformFile file, {
    ImageValidationConfig config = const ImageValidationConfig(),
  }) {
    // Check file size
    final fileSizeMB = file.size / (1024 * 1024);
    if (fileSizeMB > config.maxFileSizeMB) {
      return ImageValidationResult(
        isValid: false,
        error:
            'Image size exceeds maximum allowed size of ${config.maxFileSizeMB}MB',
        fileSize: file.size,
      );
    }

    // Check extension
    if (file.extension == null) {
      return const ImageValidationResult(
        isValid: false,
        error: 'Image file must have an extension',
      );
    }

    final ext = file.extension!.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    if (!allowedExtensions.contains(ext)) {
      return ImageValidationResult(
        isValid: false,
        error:
            'Invalid image format. Allowed formats: ${allowedExtensions.join(', ')}',
      );
    }

    return const ImageValidationResult(isValid: true);
  }
}
