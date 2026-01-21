import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentEvent {
  const LoadComments(this.ticketId);

  final String ticketId;

  @override
  List<Object?> get props => [ticketId];
}

class CreateComment extends CommentEvent {
  const CreateComment({
    required this.ticketId,
    required this.content,
    this.commentType,
    this.parentCommentId,
  });

  final String ticketId;
  final String content;
  final String? commentType;
  final String? parentCommentId;

  @override
  List<Object?> get props => [ticketId, content, commentType, parentCommentId];
}

class UpdateComment extends CommentEvent {
  const UpdateComment({
    required this.ticketId,
    required this.commentId,
    required this.content,
  });

  final String ticketId;
  final String commentId;
  final String content;

  @override
  List<Object?> get props => [ticketId, commentId, content];
}

class DeleteComment extends CommentEvent {
  const DeleteComment({
    required this.ticketId,
    required this.commentId,
  });

  final String ticketId;
  final String commentId;

  @override
  List<Object?> get props => [ticketId, commentId];
}

class AddInternalNote extends CommentEvent {
  const AddInternalNote({
    required this.ticketId,
    required this.notes,
  });

  final String ticketId;
  final String notes;

  @override
  List<Object?> get props => [ticketId, notes];
}

class AddWorkNote extends CommentEvent {
  const AddWorkNote({
    required this.ticketId,
    required this.notes,
  });

  final String ticketId;
  final String notes;

  @override
  List<Object?> get props => [ticketId, notes];
}

