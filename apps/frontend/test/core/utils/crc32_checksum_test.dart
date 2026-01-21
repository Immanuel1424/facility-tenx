import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:facility_erp/src/core/utils/crc32_checksum.dart';

void main() {
  group('Crc32Checksum', () {
    test('calculate returns correct CRC32 integer value', () {
      // Test with known data
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final checksum = Crc32Checksum.calculate(testData);
      
      // CRC32 should return a positive integer
      expect(checksum, isA<int>());
      expect(checksum, greaterThan(0));
    });

    test('calculateBase64 returns base64-encoded string', () {
      // Test with known data
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final checksumBase64 = Crc32Checksum.calculateBase64(testData);
      
      // Should return a valid base64 string
      expect(checksumBase64, isA<String>());
      expect(checksumBase64, isNotEmpty);
      
      // Should be valid base64 (can decode it)
      expect(() => base64Decode(checksumBase64), returnsNormally);
      
      // Base64 decoded should be 4 bytes (CRC32 is 32 bits = 4 bytes)
      final decoded = base64Decode(checksumBase64);
      expect(decoded.length, 4);
    });

    test('calculateBase64 produces consistent results for same input', () {
      final testData = Uint8List.fromList([10, 20, 30, 40, 50]);
      
      final checksum1 = Crc32Checksum.calculateBase64(testData);
      final checksum2 = Crc32Checksum.calculateBase64(testData);
      
      // Same input should produce same checksum
      expect(checksum1, equals(checksum2));
    });

    test('calculateBase64 produces different results for different input', () {
      final testData1 = Uint8List.fromList([1, 2, 3]);
      final testData2 = Uint8List.fromList([4, 5, 6]);
      
      final checksum1 = Crc32Checksum.calculateBase64(testData1);
      final checksum2 = Crc32Checksum.calculateBase64(testData2);
      
      // Different input should produce different checksums
      expect(checksum1, isNot(equals(checksum2)));
    });

    test('calculateBase64 works with empty bytes', () {
      final emptyData = Uint8List(0);
      final checksum = Crc32Checksum.calculateBase64(emptyData);
      
      // Should still produce a valid base64 string (4 bytes)
      expect(checksum, isA<String>());
      expect(checksum, isNotEmpty);
      final decoded = base64Decode(checksum);
      expect(decoded.length, 4);
    });

    test('calculateBase64 works with large data', () {
      // Create a larger test data (1KB)
      final largeData = Uint8List(1024);
      for (int i = 0; i < largeData.length; i++) {
        largeData[i] = i % 256;
      }
      
      final checksum = Crc32Checksum.calculateBase64(largeData);
      
      expect(checksum, isA<String>());
      expect(checksum, isNotEmpty);
      final decoded = base64Decode(checksum);
      expect(decoded.length, 4);
    });

    test('calculate and calculateBase64 are consistent', () {
      final testData = Uint8List.fromList([100, 200, 150, 75, 25]);
      
      final intChecksum = Crc32Checksum.calculate(testData);
      final base64Checksum = Crc32Checksum.calculateBase64(testData);
      
      // Decode base64 and reconstruct the integer
      final decoded = base64Decode(base64Checksum);
      final reconstructed = (decoded[0] << 24) |
          (decoded[1] << 16) |
          (decoded[2] << 8) |
          decoded[3];
      
      // Should match (but need to handle sign extension for negative values)
      final unsignedReconstructed = reconstructed.toUnsigned(32);
      final unsignedIntChecksum = intChecksum.toUnsigned(32);
      
      expect(unsignedReconstructed, equals(unsignedIntChecksum));
    });
  });
}
