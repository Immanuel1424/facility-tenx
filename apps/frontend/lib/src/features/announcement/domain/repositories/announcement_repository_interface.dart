import 'package:fpdart/fpdart.dart';
import '../entities/announcement_entity.dart';
import '../entities/announcement_read_entity.dart';

class PaginatedAnnouncementsResult {
  final List<AnnouncementEntity> data;
  final int total;

  PaginatedAnnouncementsResult({
    required this.data,
    required this.total,
  });
}

abstract class AnnouncementRepositoryInterface {
  Future<Either<String, PaginatedAnnouncementsResult>> getAnnouncements({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  });

  Future<Either<String, PaginatedAnnouncementsResult>> getAnnouncementsForAdmin({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  });

  Future<Either<String, AnnouncementEntity>> getAnnouncement(String id);

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
  });

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
  });

  Future<Either<String, void>> deleteAnnouncement(String id);

  Future<Either<String, AnnouncementEntity>> publishAnnouncement(String id);

  Future<Either<String, AnnouncementReadEntity>> markAsRead(String id);

  Future<Either<String, int>> getUnreadCount();

  Future<Either<String, PaginatedAnnouncementsResult>> getUnreadAnnouncements({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  });
}

