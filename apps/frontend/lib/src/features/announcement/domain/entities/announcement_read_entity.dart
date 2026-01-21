import 'package:equatable/equatable.dart';

class AnnouncementReadEntity extends Equatable {
  const AnnouncementReadEntity({
    required this.id,
    required this.companyId,
    required this.announcementId,
    required this.userId,
    required this.readAt,
    required this.createdAt,
  });

  final String id;
  final String companyId;
  final String announcementId;
  final String userId;
  final DateTime readAt;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        companyId,
        announcementId,
        userId,
        readAt,
        createdAt,
      ];
}

