import 'package:equatable/equatable.dart';

enum AttachmentType {
  image,
  document,
  video,
  audio,
  other;

  static AttachmentType fromString(String value) {
    return AttachmentType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AttachmentType.other,
    );
  }
}

enum AttachmentContext {
  ticketCreation,
  workProgress,
  completion,
  comment;

  static AttachmentContext fromString(String value) {
    return AttachmentContext.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll('_', ''),
      orElse: () => AttachmentContext.ticketCreation,
    );
  }
}

class AttachmentEntity extends Equatable {
  const AttachmentEntity({
    required this.id,
    required this.ticketId,
    required this.uploadedById,
    this.uploadedBy,
    required this.fileName,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.storagePath,
    this.storageUrl,
    this.attachmentType = AttachmentType.other,
    this.attachmentContext = AttachmentContext.ticketCreation,
    this.description,
    this.checksum,
    this.isDeleted = false,
    this.deletedAt,
    this.commentId,
    this.imageWidth,
    this.imageHeight,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ticketId;
  final String uploadedById;
  final String? uploadedBy; // User name or email
  final String fileName;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String storagePath;
  final String? storageUrl;
  final AttachmentType attachmentType;
  final AttachmentContext attachmentContext;
  final String? description;
  final String? checksum;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? commentId;
  final int? imageWidth;
  final int? imageHeight;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isImage {
    // Check attachment type first
    if (attachmentType == AttachmentType.image) {
      return true;
    }
    // Fallback: check MIME type for robustness
    final lowerMime = mimeType.toLowerCase();
    return lowerMime.startsWith('image/');
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  List<Object?> get props => [
        id,
        ticketId,
        uploadedById,
        uploadedBy,
        fileName,
        originalName,
        mimeType,
        fileSize,
        storagePath,
        storageUrl,
        attachmentType,
        attachmentContext,
        description,
        checksum,
        isDeleted,
        deletedAt,
        commentId,
        imageWidth,
        imageHeight,
        thumbnailUrl,
        createdAt,
        updatedAt,
      ];
}

