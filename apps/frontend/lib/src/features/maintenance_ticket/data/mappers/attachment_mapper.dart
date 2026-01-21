import '../../domain/entities/attachment_entity.dart' as domain;
import '../dto/attachment_dto.dart';

class AttachmentMapper {
  static domain.AttachmentEntity toEntity(AttachmentDto dto) {
    return domain.AttachmentEntity(
      id: dto.id,
      ticketId: dto.ticket_id,
      uploadedById: dto.uploaded_by_id,
      uploadedBy: dto.uploaded_by != null
          ? '${dto.uploaded_by!.first_name ?? ''} ${dto.uploaded_by!.last_name ?? ''}'.trim().isEmpty
              ? dto.uploaded_by!.email ?? 'Unknown'
              : '${dto.uploaded_by!.first_name ?? ''} ${dto.uploaded_by!.last_name ?? ''}'.trim()
          : null,
      fileName: dto.file_name,
      originalName: dto.original_name,
      mimeType: dto.mime_type,
      fileSize: dto.file_size,
      storagePath: dto.storage_path,
      storageUrl: dto.storage_url,
      attachmentType: dto.attachment_type != null
          ? domain.AttachmentType.fromString(dto.attachment_type!)
          : _inferAttachmentTypeFromMimeType(dto.mime_type),
      attachmentContext: dto.attachment_context != null
          ? domain.AttachmentContext.fromString(dto.attachment_context!)
          : domain.AttachmentContext.ticketCreation,
      description: dto.description,
      checksum: dto.checksum,
      isDeleted: dto.is_deleted,
      deletedAt: dto.deleted_at,
      commentId: dto.comment_id,
      imageWidth: dto.image_width,
      imageHeight: dto.image_height,
      thumbnailUrl: dto.thumbnail_url,
      createdAt: dto.created_at ?? DateTime.now(),
      updatedAt: dto.updated_at ?? DateTime.now(),
    );
  }

  static domain.AttachmentType _inferAttachmentTypeFromMimeType(String mimeType) {
    final lowerMime = mimeType.toLowerCase();
    if (lowerMime.startsWith('image/')) {
      return domain.AttachmentType.image;
    } else if (lowerMime.startsWith('video/')) {
      return domain.AttachmentType.video;
    } else if (lowerMime.startsWith('audio/')) {
      return domain.AttachmentType.audio;
    } else if (lowerMime.contains('pdf') ||
        lowerMime.contains('document') ||
        lowerMime.contains('word') ||
        lowerMime.contains('excel') ||
        lowerMime.contains('spreadsheet') ||
        lowerMime.contains('text')) {
      return domain.AttachmentType.document;
    }
    return domain.AttachmentType.other;
  }
}

