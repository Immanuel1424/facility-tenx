import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Utility class for calculating CRC32 checksums
/// Used for S3 uploads where checksum headers are required by AWS SDK
class Crc32Checksum {
  /// Calculate CRC32 checksum for the given bytes
  /// Returns the checksum as a base64-encoded string (as required by AWS S3)
  /// 
  /// AWS S3 requires the CRC32 checksum to be sent as a base64-encoded header
  /// when the presigned URL includes checksum parameters in its signature.
  static String calculateBase64(Uint8List bytes) {
    // Use the archive package's getCrc32 function
    final checksumValue = getCrc32(bytes);
    
    // Convert to bytes (4 bytes for CRC32, big-endian)
    final checksumBytes = Uint8List(4);
    checksumBytes[0] = (checksumValue >> 24) & 0xFF;
    checksumBytes[1] = (checksumValue >> 16) & 0xFF;
    checksumBytes[2] = (checksumValue >> 8) & 0xFF;
    checksumBytes[3] = checksumValue & 0xFF;
    
    // Encode to base64 (as required by AWS S3)
    return base64Encode(checksumBytes);
  }
  
  /// Calculate CRC32 checksum and return as integer
  static int calculate(Uint8List bytes) {
    return getCrc32(bytes);
  }
}
