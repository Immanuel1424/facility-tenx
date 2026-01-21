import 'package:equatable/equatable.dart';
import '../../domain/entities/announcement_entity.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {
  const AnnouncementInitial();
}

class AnnouncementLoading extends AnnouncementState {
  const AnnouncementLoading();
}

class AnnouncementListLoaded extends AnnouncementState {
  const AnnouncementListLoaded({
    required this.announcements,
    required this.total,
  });

  final List<AnnouncementEntity> announcements;
  final int total;

  @override
  List<Object?> get props => [announcements, total];
}

class AnnouncementDetailLoaded extends AnnouncementState {
  const AnnouncementDetailLoaded(this.announcement);

  final AnnouncementEntity announcement;

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementCreated extends AnnouncementState {
  const AnnouncementCreated(this.announcement);

  final AnnouncementEntity announcement;

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementUpdated extends AnnouncementState {
  const AnnouncementUpdated(this.announcement);

  final AnnouncementEntity announcement;

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementDeleted extends AnnouncementState {
  const AnnouncementDeleted();
}

class AnnouncementPublished extends AnnouncementState {
  const AnnouncementPublished(this.announcement);

  final AnnouncementEntity announcement;

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementMarkedAsRead extends AnnouncementState {
  const AnnouncementMarkedAsRead(this.announcementId);

  final String announcementId;

  @override
  List<Object?> get props => [announcementId];
}

class UnreadCountLoaded extends AnnouncementState {
  const UnreadCountLoaded(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

class UnreadAnnouncementsLoaded extends AnnouncementState {
  const UnreadAnnouncementsLoaded({
    required this.announcements,
    required this.total,
  });

  final List<AnnouncementEntity> announcements;
  final int total;

  @override
  List<Object?> get props => [announcements, total];
}

class AnnouncementError extends AnnouncementState {
  const AnnouncementError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

