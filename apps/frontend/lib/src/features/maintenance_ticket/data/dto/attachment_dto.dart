import 'user_dto.dart';

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

  String get value {
    switch (this) {
      case AttachmentType.image:
        return 'IMAGE';
      case AttachmentType.document:
        return 'DOCUMENT';
      case AttachmentType.video:
        return 'VIDEO';
      case AttachmentType.audio:
        return 'AUDIO';
      case AttachmentType.other:
        return 'OTHER';
    }
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

  String get value {
    switch (this) {
      case AttachmentContext.ticketCreation:
        return 'TICKET_CREATION';
      case AttachmentContext.workProgress:
        return 'WORK_PROGRESS';
      case AttachmentContext.completion:
        return 'COMPLETION';
      case AttachmentContext.comment:
        return 'COMMENT';
    }
  }
}

class AttachmentDto {
  const AttachmentDto({
    required this.id,
    required this.ticket_id,
    required this.uploaded_by_id,
    this.uploaded_by,
    required this.file_name,
    required this.original_name,
    required this.mime_type,
    required this.file_size,
    required this.storage_path,
    this.storage_url,
    this.attachment_type,
    this.attachment_context,
    this.description,
    this.checksum,
    this.is_deleted = false,
    this.deleted_at,
    this.comment_id,
    this.image_width,
    this.image_height,
    this.thumbnail_url,
    this.created_at,
    this.updated_at,
  });

  final String id;
  final String ticket_id;
  final String uploaded_by_id;
  final UserDto? uploaded_by;
  final String file_name;
  final String original_name;
  final String mime_type;
  final int file_size;
  final String storage_path;
  final String? storage_url;
  final String? attachment_type;
  final String? attachment_context;
  final String? description;
  final String? checksum;
  final bool is_deleted;
  final DateTime? deleted_at;
  final String? comment_id;
  final int? image_width;
  final int? image_height;
  final String? thumbnail_url;
  final DateTime? created_at;
  final DateTime? updated_at;

  factory AttachmentDto.fromJson(Map<String, dynamic> json) {
    // Helper function to get value from either camelCase or snake_case
    T? getValue<T>(String camelKey, String snakeKey) {
      return json[camelKey] as T? ?? json[snakeKey] as T?;
    }

    String getString(String camelKey, String snakeKey) {
      return getValue<String>(camelKey, snakeKey) ?? '';
    }

    return AttachmentDto(
      id: json['id'] as String,
      ticket_id: getString('ticketId', 'ticket_id'),
      uploaded_by_id: getString('uploadedById', 'uploaded_by_id'),
      uploaded_by: getValue<Map<String, dynamic>>('uploadedBy', 'uploaded_by') != null
          ? UserDto.fromJson(
              getValue<Map<String, dynamic>>('uploadedBy', 'uploaded_by')!)
          : null,
      file_name: getString('fileName', 'file_name'),
      original_name: getString('originalName', 'original_name'),
      mime_type: getString('mimeType', 'mime_type'),
      file_size: (getValue<num>('fileSize', 'file_size') ?? 0).toInt(),
      storage_path: getString('storagePath', 'storage_path'),
      storage_url: getValue<String>('storageUrl', 'storage_url'),
      attachment_type: getValue<String>('attachmentType', 'attachment_type'),
      attachment_context:
          getValue<String>('attachmentContext', 'attachment_context'),
      description: getValue<String>('description', 'description'),
      checksum: getValue<String>('checksum', 'checksum'),
      is_deleted: getValue<bool>('isDeleted', 'is_deleted') ?? false,
      deleted_at: getValue<String>('deletedAt', 'deleted_at') != null
          ? DateTime.parse(getValue<String>('deletedAt', 'deleted_at')!)
          : null,
      comment_id: getValue<String>('commentId', 'comment_id'),
      image_width: (getValue<num>('imageWidth', 'image_width'))?.toInt(),
      image_height: (getValue<num>('imageHeight', 'image_height'))?.toInt(),
      thumbnail_url: getValue<String>('thumbnailUrl', 'thumbnail_url'),
      created_at: getValue<String>('createdAt', 'created_at') != null
          ? DateTime.parse(getValue<String>('createdAt', 'created_at')!)
          : null,
      updated_at: getValue<String>('updatedAt', 'updated_at') != null
          ? DateTime.parse(getValue<String>('updatedAt', 'updated_at')!)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_id': ticket_id,
        'uploaded_by_id': uploaded_by_id,
        'uploaded_by': uploaded_by?.toJson(),
        'file_name': file_name,
        'original_name': original_name,
        'mime_type': mime_type,
        'file_size': file_size,
        'storage_path': storage_path,
        'storage_url': storage_url,
        'attachment_type': attachment_type,
        'attachment_context': attachment_context,
        'description': description,
        'checksum': checksum,
        'is_deleted': is_deleted,
        'deleted_at': deleted_at?.toIso8601String(),
        'comment_id': comment_id,
        'image_width': image_width,
        'image_height': image_height,
        'thumbnail_url': thumbnail_url,
        'created_at': created_at?.toIso8601String(),
        'updated_at': updated_at?.toIso8601String(),
      };
}

class CreateAttachmentDto {
  const CreateAttachmentDto({
    required this.file_name,
    required this.original_name,
    required this.mime_type,
    required this.file_size,
    required this.storage_path,
    this.storage_url,
    this.attachment_type,
    this.attachment_context,
    this.description,
    this.checksum,
    this.comment_id,
    this.image_width,
    this.image_height,
    this.thumbnail_url,
  });

  final String file_name;
  final String original_name;
  final String mime_type;
  final int file_size;
  final String storage_path;
  final String? storage_url;
  final String? attachment_type;
  final String? attachment_context;
  final String? description;
  final String? checksum;
  final String? comment_id;
  final int? image_width;
  final int? image_height;
  final String? thumbnail_url;

  Map<String, dynamic> toJson() => {
        'file_name': file_name,
        'original_name': original_name,
        'mime_type': mime_type,
        'file_size': file_size,
        'storage_path': storage_path,
        'storage_url': storage_url,
        'attachment_type': attachment_type,
        'attachment_context': attachment_context,
        'description': description,
        'checksum': checksum,
        'comment_id': comment_id,
        'image_width': image_width,
        'image_height': image_height,
        'thumbnail_url': thumbnail_url,
      };
}

/// Presigned URL response for direct S3 upload
class PresignedUploadUrlDto {
  const PresignedUploadUrlDto({
    required this.presignedUrl,
    required this.s3Key,
    required this.storageUrl,
    required this.expiresAt,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.checksum,
  });

  final String presignedUrl;
  final String s3Key;
  final String storageUrl;
  final DateTime expiresAt;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String? checksum;

  factory PresignedUploadUrlDto.fromJson(Map<String, dynamic> json) {
    return PresignedUploadUrlDto(
      presignedUrl: json['presignedUrl'] as String? ??
          json['presigned_url'] as String? ??
          '',
      s3Key: json['s3Key'] as String? ?? json['s3_key'] as String? ?? '',
      storageUrl: json['storageUrl'] as String? ??
          json['storage_url'] as String? ??
          '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : (json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : DateTime.now().add(const Duration(hours: 1))),
      fileName: json['fileName'] as String? ??
          json['file_name'] as String? ??
          '',
      mimeType: json['mimeType'] as String? ??
          json['mime_type'] as String? ??
          '',
      fileSize: (json['fileSize'] as num? ?? json['file_size'] as num? ?? 0)
          .toInt(),
      checksum: json['checksum'] as String?,
    );
  }
}
