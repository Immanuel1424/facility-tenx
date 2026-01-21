import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/attachment_entity.dart';
import '../../domain/repositories/attachment_repository_interface.dart';
import '../dto/attachment_dto.dart';
import '../mappers/attachment_mapper.dart';

class AttachmentRepository implements AttachmentRepositoryInterface {
  AttachmentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<String, List<AttachmentEntity>>> getAttachments(
    String ticketId,
  ) async {
    try {
      final dtos = await _apiClient.getTicketAttachments(ticketId);
      final attachments = dtos
          .map((dto) => AttachmentMapper.toEntity(dto))
          .toList();
      return Right(attachments);
    } on DioException catch (e) {
      // Handle 404 gracefully - no attachments is not an error
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(e.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AttachmentEntity>> getAttachment(
    String ticketId,
    String attachmentId,
  ) async {
    try {
      final dto =
          await _apiClient.getTicketAttachment(ticketId, attachmentId);
      return Right(AttachmentMapper.toEntity(dto));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
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
  }) async {
    try {
      final dto = CreateAttachmentDto(
        file_name: fileName,
        original_name: originalName,
        mime_type: mimeType,
        file_size: fileSize,
        storage_path: storagePath,
        storage_url: storageUrl,
        attachment_type: attachmentType,
        attachment_context: attachmentContext,
        description: description,
        comment_id: commentId,
        image_width: imageWidth,
        image_height: imageHeight,
        thumbnail_url: thumbnailUrl,
      );
      final response =
          await _apiClient.createTicketAttachment(ticketId, dto);
      return Right(AttachmentMapper.toEntity(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteAttachment(
    String ticketId,
    String attachmentId,
  ) async {
    try {
      await _apiClient.deleteTicketAttachment(ticketId, attachmentId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<AttachmentEntity>>> getAttachmentsByContext(
    String ticketId,
    String context,
  ) async {
    try {
      final dtos =
          await _apiClient.getTicketAttachmentsByContext(ticketId, context);
      final attachments = dtos
          .map((dto) => AttachmentMapper.toEntity(dto))
          .toList();
      return Right(attachments);
    } on DioException catch (e) {
      // Handle 404 gracefully - no attachments is not an error
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      return Left(e.toString());
    } catch (e) {
      return Left(e.toString());
    }
  }
}

