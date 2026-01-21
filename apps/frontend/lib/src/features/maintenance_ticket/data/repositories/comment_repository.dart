import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository_interface.dart';
import '../dto/comment_dto.dart';
import '../dto/maintenance_ticket_dto.dart';
import '../mappers/comment_mapper.dart';

class CommentRepository implements CommentRepositoryInterface {
  CommentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<String, List<CommentEntity>>> getComments(
    String ticketId,
  ) async {
    try {
      final dtos = await _apiClient.getTicketComments(ticketId);
      final comments = dtos
          .map((dto) => CommentMapper.toEntity(dto))
          .toList();
      return Right(comments);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to load comments';
      return Left(errorMessage);
    } catch (e) {
      return Left('Failed to load comments: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, CommentEntity>> getComment(
    String ticketId,
    String commentId,
  ) async {
    try {
      final dto = await _apiClient.getTicketComment(ticketId, commentId);
      return Right(CommentMapper.toEntity(dto));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CommentEntity>> createComment(
    String ticketId, {
    required String content,
    String? commentType,
    String? parentCommentId,
  }) async {
    try {
      final dto = CreateCommentDto(
        content: content,
        comment_type: commentType,
        parent_comment_id: parentCommentId,
      );
      final response = await _apiClient.createTicketComment(ticketId, dto);
      return Right(CommentMapper.toEntity(response));
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] as String? ??
          e.message ??
          'Failed to create comment';
      return Left(errorMessage);
    } catch (e) {
      return Left('Failed to create comment: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, CommentEntity>> updateComment(
    String ticketId,
    String commentId, {
    required String content,
  }) async {
    try {
      final dto = UpdateCommentDto(content: content);
      final response =
          await _apiClient.updateTicketComment(ticketId, commentId, dto);
      return Right(CommentMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteComment(
    String ticketId,
    String commentId,
  ) async {
    try {
      await _apiClient.deleteTicketComment(ticketId, commentId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CommentEntity>> addInternalNote(
    String ticketId, {
    required String notes,
  }) async {
    try {
      final dto = AddNotesDto(notes: notes);
      final response = await _apiClient.addInternalNote(ticketId, dto);
      return Right(CommentMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CommentEntity>> addWorkNote(
    String ticketId, {
    required String notes,
  }) async {
    try {
      final dto = AddNotesDto(notes: notes);
      final response = await _apiClient.addWorkNote(ticketId, dto);
      return Right(CommentMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }
}

