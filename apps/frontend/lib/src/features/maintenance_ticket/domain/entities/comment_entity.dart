import 'package:equatable/equatable.dart';

enum CommentType {
  public,
  internal,
  workNote,
  system;

  static CommentType fromString(String value) {
    return CommentType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll('_', ''),
      orElse: () => CommentType.public,
    );
  }

  String get displayName {
    switch (this) {
      case CommentType.public:
        return 'Public';
      case CommentType.internal:
        return 'Internal';
      case CommentType.workNote:
        return 'Work Note';
      case CommentType.system:
        return 'System';
    }
  }
}

class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.ticketId,
    required this.createdById,
    this.createdBy,
    required this.content,
    this.commentType = CommentType.public,
    this.isEdited = false,
    this.editedAt,
    this.parentCommentId,
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ticketId;
  final String createdById;
  final String? createdBy; // User name or email
  final String content;
  final CommentType commentType;
  final bool isEdited;
  final DateTime? editedAt;
  final String? parentCommentId;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        ticketId,
        createdById,
        createdBy,
        content,
        commentType,
        isEdited,
        editedAt,
        parentCommentId,
        isDeleted,
        deletedAt,
        createdAt,
        updatedAt,
      ];
}

