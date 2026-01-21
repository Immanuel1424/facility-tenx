import 'package:equatable/equatable.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnnouncements extends AnnouncementEvent {
  const LoadAnnouncements({
    this.category,
    this.priority,
    this.search,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
  });

  final String? category;
  final String? priority;
  final String? search;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  @override
  List<Object?> get props => [
        category,
        priority,
        search,
        page,
        limit,
        sortBy,
        sortOrder,
      ];
}

class LoadAnnouncementsForAdmin extends AnnouncementEvent {
  const LoadAnnouncementsForAdmin({
    this.category,
    this.priority,
    this.search,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
  });

  final String? category;
  final String? priority;
  final String? search;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  @override
  List<Object?> get props => [
        category,
        priority,
        search,
        page,
        limit,
        sortBy,
        sortOrder,
      ];
}

class LoadAnnouncementDetail extends AnnouncementEvent {
  const LoadAnnouncementDetail(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateAnnouncement extends AnnouncementEvent {
  const CreateAnnouncement({
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.targetAudience,
    this.targetRoles,
    this.scheduledAt,
    this.expiresAt,
    this.publishImmediately,
  });

  final String title;
  final String message;
  final String category;
  final String priority;
  final String targetAudience;
  final List<String>? targetRoles;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;
  final bool? publishImmediately;

  @override
  List<Object?> get props => [
        title,
        message,
        category,
        priority,
        targetAudience,
        targetRoles,
        scheduledAt,
        expiresAt,
        publishImmediately,
      ];
}

class UpdateAnnouncement extends AnnouncementEvent {
  const UpdateAnnouncement({
    required this.id,
    this.title,
    this.message,
    this.category,
    this.priority,
    this.targetAudience,
    this.targetRoles,
    this.scheduledAt,
    this.expiresAt,
  });

  final String id;
  final String? title;
  final String? message;
  final String? category;
  final String? priority;
  final String? targetAudience;
  final List<String>? targetRoles;
  final DateTime? scheduledAt;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        category,
        priority,
        targetAudience,
        targetRoles,
        scheduledAt,
        expiresAt,
      ];
}

class DeleteAnnouncement extends AnnouncementEvent {
  const DeleteAnnouncement(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class PublishAnnouncement extends AnnouncementEvent {
  const PublishAnnouncement(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class MarkAnnouncementAsRead extends AnnouncementEvent {
  const MarkAnnouncementAsRead(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class LoadUnreadCount extends AnnouncementEvent {
  const LoadUnreadCount();
}

class LoadUnreadAnnouncements extends AnnouncementEvent {
  const LoadUnreadAnnouncements({
    this.category,
    this.priority,
    this.search,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
    this.sortOrder,
  });

  final String? category;
  final String? priority;
  final String? search;
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder;

  @override
  List<Object?> get props => [
        category,
        priority,
        search,
        page,
        limit,
        sortBy,
        sortOrder,
      ];
}

