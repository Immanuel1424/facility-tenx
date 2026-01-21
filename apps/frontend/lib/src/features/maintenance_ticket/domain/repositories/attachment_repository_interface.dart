import 'package:fpdart/fpdart.dart';

import '../entities/attachment_entity.dart';

abstract class AttachmentRepositoryInterface {
  Future<Either<String, List<AttachmentEntity>>> getAttachments(
    String ticketId,
  );

  Future<Either<String, AttachmentEntity>> getAttachment(
    String ticketId,
    String attachmentId,
  );

  Future<Either<String, AttachmentEntity>> createAttachment(
    String ticketId, {
    required String fileName,
    required String originalName,
    required String mimeType,
    required int fileSize,
    required String storagePath,
    String? storageUrl,
    String? attachmentType,
    String? attachmentContext,
    String? description,
    String? commentId,
    int? imageWidth,
    int? imageHeight,
    String? thumbnailUrl,
  });

  Future<Either<String, void>> deleteAttachment(
    String ticketId,
    String attachmentId,
  );

  Future<Either<String, List<AttachmentEntity>>> getAttachmentsByContext(
    String ticketId,
    String context,
  );
}

