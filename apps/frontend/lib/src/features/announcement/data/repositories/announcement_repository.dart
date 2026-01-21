import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/entities/announcement_read_entity.dart';
import '../../domain/repositories/announcement_repository_interface.dart';
import '../../../../core/network/api_client.dart';
import '../dto/create_announcement_dto.dart';
import '../mappers/announcement_mapper.dart';

class AnnouncementRepository implements AnnouncementRepositoryInterface {
  AnnouncementRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<String, PaginatedAnnouncementsResult>> getAnnouncements({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await _apiClient.getAnnouncements(
        category: category,
        priority: priority,
        search: search,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      return Right(
        PaginatedAnnouncementsResult(
          data: AnnouncementMapper.toEntityList(response.data),
          total: response.total,
        ),
      );
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to fetch announcements');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, PaginatedAnnouncementsResult>> getAnnouncementsForAdmin({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await _apiClient.getAnnouncementsForAdmin(
        category: category,
        priority: priority,
        search: search,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      return Right(
        PaginatedAnnouncementsResult(
          data: AnnouncementMapper.toEntityList(response.data),
          total: response.total,
        ),
      );
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to fetch announcements');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, AnnouncementEntity>> getAnnouncement(String id) async {
    try {
      final dto = await _apiClient.getAnnouncement(id);
      return Right(AnnouncementMapper.toEntity(dto));
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to fetch announcement');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, AnnouncementEntity>> createAnnouncement({
    required String title,
    required String message,
    required String category,
    required String priority,
    required String targetAudience,
    List<String>? targetRoles,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    bool? publishImmediately,
  }) async {
    try {
      final dto = CreateAnnouncementDto(
        title: title,
        message: message,
        category: category,
        priority: priority,
        target_audience: targetAudience,
        target_roles: targetRoles,
        scheduled_at: scheduledAt?.toIso8601String(),
        expires_at: expiresAt?.toIso8601String(),
        publish_immediately: publishImmediately,
      );

      final response = await _apiClient.createAnnouncement(dto);
      return Right(AnnouncementMapper.toEntity(response));
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to create announcement');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, AnnouncementEntity>> updateAnnouncement(
    String id, {
    String? title,
    String? message,
    String? category,
    String? priority,
    String? targetAudience,
    List<String>? targetRoles,
    DateTime? scheduledAt,
    DateTime? expiresAt,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (message != null) data['message'] = message;
      if (category != null) data['category'] = category;
      if (priority != null) data['priority'] = priority;
      if (targetAudience != null) data['targetAudience'] = targetAudience;
      if (targetRoles != null) data['targetRoles'] = targetRoles;
      if (scheduledAt != null) data['scheduledAt'] = scheduledAt.toIso8601String();
      if (expiresAt != null) data['expiresAt'] = expiresAt.toIso8601String();

      final response = await _apiClient.updateAnnouncement(id, data);
      return Right(AnnouncementMapper.toEntity(response));
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to update announcement');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteAnnouncement(String id) async {
    try {
      await _apiClient.deleteAnnouncement(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to delete announcement');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, AnnouncementEntity>> publishAnnouncement(
    String id,
  ) async {
    try {
      final response = await _apiClient.publishAnnouncement(id);
      return Right(AnnouncementMapper.toEntity(response));
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to publish announcement');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, AnnouncementReadEntity>> markAsRead(String id) async {
    try {
      final response = await _apiClient.markAnnouncementAsRead(id);
      // Parse the response to create AnnouncementReadEntity
      return Right(
        AnnouncementReadEntity(
          id: response['id'] as String,
          companyId: (response['company_id'] ?? response['companyId']) as String,
          announcementId: (response['announcement_id'] ??
              response['announcementId']) as String,
          userId: (response['user_id'] ?? response['userId']) as String,
          readAt: DateTime.parse(
            (response['read_at'] ?? response['readAt']) as String,
          ),
          createdAt: DateTime.parse(
            (response['created_at'] ?? response['createdAt']) as String,
          ),
        ),
      );
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to mark announcement as read');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    try {
      final response = await _apiClient.getUnreadAnnouncementCount();
      return Right(response['count'] as int? ?? 0);
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to get unread count');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, PaginatedAnnouncementsResult>> getUnreadAnnouncements({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await _apiClient.getUnreadAnnouncements(
        category: category,
        priority: priority,
        search: search,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      return Right(
        PaginatedAnnouncementsResult(
          data: AnnouncementMapper.toEntityList(response.data),
          total: response.total,
        ),
      );
    } on DioException catch (e) {
      return Left(e.message ?? 'Failed to fetch unread announcements');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }
}

