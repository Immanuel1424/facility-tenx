import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

/// Image compression configuration
class ImageCompressionConfig {
  const ImageCompressionConfig({
    this.maxWidth = 1920,
    this.maxHeight = 1920,
    this.quality = 85,
    this.maxFileSizeKB = 2048, // 2MB
  });

  final int maxWidth;
  final int maxHeight;
  final int quality; // 0-100
  final int maxFileSizeKB;
}

/// Result of image compression
class CompressedImageResult {
  const CompressedImageResult({
    required this.bytes,
    required this.width,
    required this.height,
    required this.originalSize,
    required this.compressedSize,
    required this.mimeType,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int originalSize;
  final int compressedSize;
  final String mimeType;

  double get compressionRatio => compressedSize / originalSize;
  int get sizeReductionKB => (originalSize - compressedSize) ~/ 1024;
}

/// Utility for compressing images before upload
class ImageCompression {
  /// Compress image from PlatformFile
  /// Returns compressed image bytes with metadata
  static Future<CompressedImageResult?> compressImage(
    PlatformFile file, {
    ImageCompressionConfig config = const ImageCompressionConfig(),
  }) async {
    try {
      Uint8List? imageBytes;
      if (kIsWeb) {
        if (file.bytes == null) {
          return null;
        }
        imageBytes = file.bytes;
      } else {
        if (file.path == null) {
          return null;
        }
        final fileData = await (await File(file.path!)).readAsBytes();
        imageBytes = fileData;
      }

      if (imageBytes == null || imageBytes.isEmpty) {
        return null;
      }

      final originalSize = imageBytes.length;

      // Decode image using image package
      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      final originalWidth = decodedImage.width;
      final originalHeight = decodedImage.height;

      // Calculate new dimensions maintaining aspect ratio
      double scale = 1.0;
      if (originalWidth > config.maxWidth || originalHeight > config.maxHeight) {
        final widthScale = config.maxWidth / originalWidth;
        final heightScale = config.maxHeight / originalHeight;
        scale = widthScale < heightScale ? widthScale : heightScale;
      }

      final newWidth = (originalWidth * scale).round();
      final newHeight = (originalHeight * scale).round();

      // Resize image if needed
      img.Image resizedImage = decodedImage;
      if (scale < 1.0) {
        resizedImage = img.copyResize(
          decodedImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Determine output format based on original
      String mimeType = 'image/jpeg';
      Uint8List compressedBytes;

      // Try JPEG first (better compression)
      compressedBytes = Uint8List.fromList(
        img.encodeJpg(
          resizedImage,
          quality: config.quality,
        ),
      );

      // If still too large, reduce quality iteratively
      int currentQuality = config.quality;
      while (compressedBytes.length > config.maxFileSizeKB * 1024 &&
          currentQuality > 20) {
        currentQuality -= 10;
        compressedBytes = Uint8List.fromList(
          img.encodeJpg(
            resizedImage,
            quality: currentQuality,
          ),
        );
      }

      // If JPEG compression didn't work well, try PNG (for images with transparency)
      if (compressedBytes.length > config.maxFileSizeKB * 1024 &&
          file.extension?.toLowerCase() == 'png') {
        compressedBytes = Uint8List.fromList(
          img.encodePng(resizedImage),
        );
        mimeType = 'image/png';
      }

      return CompressedImageResult(
        bytes: compressedBytes,
        width: newWidth,
        height: newHeight,
        originalSize: originalSize,
        compressedSize: compressedBytes.length,
        mimeType: mimeType,
      );
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Check if image needs compression
  static bool needsCompression(
    PlatformFile file,
    ImageCompressionConfig config,
  ) {
    final fileSizeKB = (file.size / 1024).round();
    return fileSizeKB > config.maxFileSizeKB;
  }
}
