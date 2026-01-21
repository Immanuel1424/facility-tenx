import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

import '../../../domain/entities/attachment_entity.dart' as domain_entity;
import '../../../domain/repositories/attachment_repository_interface.dart' as domain;
import 'attachment_event.dart';
import 'attachment_state.dart';

class AttachmentBloc extends Bloc<AttachmentEvent, AttachmentState> {
  AttachmentBloc({
    required domain.AttachmentRepositoryInterface repository,
  })  : _repository = repository,
        super(const AttachmentInitial()) {
    on<LoadAttachments>(_onLoadAttachments);
    on<UploadAttachment>(_onUploadAttachment);
    on<DeleteAttachment>(_onDeleteAttachment);
    on<LoadAttachmentsByContext>(_onLoadAttachmentsByContext);
  }

  final domain.AttachmentRepositoryInterface _repository;

  Future<void> _onLoadAttachments(
    LoadAttachments event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(const AttachmentLoading());

    final result = await _repository.getAttachments(event.ticketId);

    result.fold(
      (String error) => emit(AttachmentError(error)),
      (List<domain_entity.AttachmentEntity> attachments) =>
          emit(AttachmentsLoaded(attachments)),
    );
  }

  Future<void> _onUploadAttachment(
    UploadAttachment event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(const AttachmentLoading());

    try {
      // In a real implementation, you would upload the file to a storage service
      // (e.g., S3, Firebase Storage) and get back a storage URL
      // For now, we'll use the file path as storage path
      // TODO: Implement actual file upload to storage service

      final fileName = path.basename(event.filePath);
      final storagePath = event.filePath; // In production, this would be the storage service path

      final result = await _repository.createAttachment(
        event.ticketId,
        fileName: fileName,
        originalName: event.fileName,
        mimeType: event.mimeType,
        fileSize: event.fileSize,
        storagePath: storagePath,
        storageUrl: null, // Would be set after upload to storage service
        attachmentType: _getAttachmentType(event.mimeType),
        attachmentContext: event.attachmentContext,
        description: event.description,
      );

      result.fold(
        (String error) => emit(AttachmentError(error)),
        (domain_entity.AttachmentEntity attachment) {
          emit(AttachmentUploaded(attachment));
          // Reload attachments to get updated list
          add(LoadAttachments(event.ticketId));
        },
      );
    } catch (e) {
      emit(AttachmentError(e.toString()));
    }
  }

  Future<void> _onDeleteAttachment(
    DeleteAttachment event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(const AttachmentLoading());

    final result = await _repository.deleteAttachment(
      event.ticketId,
      event.attachmentId,
    );

    result.fold(
      (String error) => emit(AttachmentError(error)),
      (void _) {
        emit(AttachmentDeleted(event.attachmentId));
        // Reload attachments to get updated list
        add(LoadAttachments(event.ticketId));
      },
    );
  }

  Future<void> _onLoadAttachmentsByContext(
    LoadAttachmentsByContext event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(const AttachmentLoading());

    final result = await _repository.getAttachmentsByContext(
      event.ticketId,
      event.context,
    );

    result.fold(
      (String error) => emit(AttachmentError(error)),
      (List<domain_entity.AttachmentEntity> attachments) =>
          emit(AttachmentsLoaded(attachments)),
    );
  }

  String _getAttachmentType(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return 'IMAGE';
    } else if (mimeType.startsWith('video/')) {
      return 'VIDEO';
    } else if (mimeType.startsWith('audio/')) {
      return 'AUDIO';
    } else if (mimeType.contains('pdf') ||
        mimeType.contains('document') ||
        mimeType.contains('text')) {
      return 'DOCUMENT';
    }
    return 'OTHER';
  }
}

