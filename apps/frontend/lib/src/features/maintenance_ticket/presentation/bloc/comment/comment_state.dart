import 'package:equatable/equatable.dart';

import '../../../domain/entities/comment_entity.dart' as domain;

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {
  const CommentInitial();
}

class CommentLoading extends CommentState {
  const CommentLoading();
}

class CommentsLoaded extends CommentState {
  const CommentsLoaded(this.comments);

  final List<domain.CommentEntity> comments;

  @override
  List<Object?> get props => [comments];
}

class CommentCreated extends CommentState {
  const CommentCreated(this.comment);

  final domain.CommentEntity comment;

  @override
  List<Object?> get props => [comment];
}

class CommentUpdated extends CommentState {
  const CommentUpdated(this.comment);

  final domain.CommentEntity comment;

  @override
  List<Object?> get props => [comment];
}

class CommentDeleted extends CommentState {
  const CommentDeleted(this.commentId);

  final String commentId;

  @override
  List<Object?> get props => [commentId];
}

class CommentError extends CommentState {
  const CommentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
