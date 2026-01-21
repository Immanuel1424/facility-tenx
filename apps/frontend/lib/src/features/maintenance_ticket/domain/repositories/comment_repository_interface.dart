import 'package:fpdart/fpdart.dart';

import '../entities/comment_entity.dart';

abstract class CommentRepositoryInterface {
  Future<Either<String, List<CommentEntity>>> getComments(String ticketId);

  Future<Either<String, CommentEntity>> getComment(
    String ticketId,
    String commentId,
  );

  Future<Either<String, CommentEntity>> createComment(
    String ticketId, {
    required String content,
    String? commentType,
    String? parentCommentId,
  });

  Future<Either<String, CommentEntity>> updateComment(
    String ticketId,
    String commentId, {
    required String content,
  });

  Future<Either<String, void>> deleteComment(
    String ticketId,
    String commentId,
  );

  Future<Either<String, CommentEntity>> addInternalNote(
    String ticketId, {
    required String notes,
  });

  Future<Either<String, CommentEntity>> addWorkNote(
    String ticketId, {
    required String notes,
  });
}

