import 'package:equatable/equatable.dart';

abstract class AttachmentEvent extends Equatable {
  const AttachmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttachments extends AttachmentEvent {
  const LoadAttachments(this.ticketId);

  final String ticketId;

  @override
  List<Object?> get props => [ticketId];
}

class UploadAttachment extends AttachmentEvent {
  const UploadAttachment({
    required this.ticketId,
    required this.filePath,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.description,
    this.attachmentContext,
  });

  final String ticketId;
  final String filePath;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String? description;
  final String? attachmentContext;

  @override
  List<Object?> get props => [
        ticketId,
        filePath,
        fileName,
        mimeType,
        fileSize,
        description,
        attachmentContext,
      ];
}

class DeleteAttachment extends AttachmentEvent {
  const DeleteAttachment({
    required this.ticketId,
    required this.attachmentId,
  });

  final String ticketId;
  final String attachmentId;

  @override
  List<Object?> get props => [ticketId, attachmentId];
}

class LoadAttachmentsByContext extends AttachmentEvent {
  const LoadAttachmentsByContext({
    required this.ticketId,
    required this.context,
  });

  final String ticketId;
  final String context;

  @override
  List<Object?> get props => [ticketId, context];
}

