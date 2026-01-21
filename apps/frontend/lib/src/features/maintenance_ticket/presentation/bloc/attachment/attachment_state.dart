import 'package:equatable/equatable.dart';

import '../../../domain/entities/attachment_entity.dart' as domain;

abstract class AttachmentState extends Equatable {
  const AttachmentState();

  @override
  List<Object?> get props => [];
}

class AttachmentInitial extends AttachmentState {
  const AttachmentInitial();
}

class AttachmentLoading extends AttachmentState {
  const AttachmentLoading();
}

class AttachmentsLoaded extends AttachmentState {
  const AttachmentsLoaded(this.attachments);

  final List<domain.AttachmentEntity> attachments;

  @override
  List<Object?> get props => [attachments];
}

class AttachmentUploaded extends AttachmentState {
  const AttachmentUploaded(this.attachment);

  final domain.AttachmentEntity attachment;

  @override
  List<Object?> get props => [attachment];
}

class AttachmentDeleted extends AttachmentState {
  const AttachmentDeleted(this.attachmentId);

  final String attachmentId;

  @override
  List<Object?> get props => [attachmentId];
}

class AttachmentError extends AttachmentState {
  const AttachmentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

