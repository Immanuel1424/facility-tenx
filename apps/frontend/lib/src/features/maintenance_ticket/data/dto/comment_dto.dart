import 'user_dto.dart';

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

  String get value {
    switch (this) {
      case CommentType.public:
        return 'PUBLIC';
      case CommentType.internal:
        return 'INTERNAL';
      case CommentType.workNote:
        return 'WORK_NOTE';
      case CommentType.system:
        return 'SYSTEM';
    }
  }
}

class CommentDto {
  const CommentDto({
    required this.id,
    required this.ticket_id,
    required this.created_by_id,
    this.created_by,
    required this.content,
    this.comment_type,
    this.is_edited = false,
    this.edited_at,
    this.parent_comment_id,
    this.is_deleted = false,
    this.deleted_at,
    this.created_at,
    this.updated_at,
  });

  final String id;
  final String ticket_id;
  final String created_by_id;
  final UserDto? created_by;
  final String content;
  final String? comment_type;
  final bool is_edited;
  final DateTime? edited_at;
  final String? parent_comment_id;
  final bool is_deleted;
  final DateTime? deleted_at;
  final DateTime? created_at;
  final DateTime? updated_at;

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (from API) and snake_case (legacy)
    return CommentDto(
      id: json['id'] as String? ?? '',
      ticket_id: json['ticketId'] as String? ?? json['ticket_id'] as String? ?? '',
      created_by_id: json['createdById'] as String? ?? json['created_by_id'] as String? ?? '',
      created_by: json['createdBy'] != null || json['created_by'] != null
          ? UserDto.fromJson((json['createdBy'] ?? json['created_by']) as Map<String, dynamic>)
          : null,
      content: json['content'] as String? ?? '',
      comment_type: json['commentType'] as String? ?? json['comment_type'] as String?,
      is_edited: json['isEdited'] as bool? ?? json['is_edited'] as bool? ?? false,
      edited_at: json['editedAt'] != null || json['edited_at'] != null
          ? DateTime.parse((json['editedAt'] ?? json['edited_at']) as String)
          : null,
      parent_comment_id: json['parentCommentId'] as String? ?? json['parent_comment_id'] as String?,
      is_deleted: json['isDeleted'] as bool? ?? json['is_deleted'] as bool? ?? false,
      deleted_at: json['deletedAt'] != null || json['deleted_at'] != null
          ? DateTime.parse((json['deletedAt'] ?? json['deleted_at']) as String)
          : null,
      created_at: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse((json['createdAt'] ?? json['created_at']) as String)
          : null,
      updated_at: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_id': ticket_id,
        'created_by_id': created_by_id,
        'created_by': created_by?.toJson(),
        'content': content,
        'comment_type': comment_type,
        'is_edited': is_edited,
        'edited_at': edited_at?.toIso8601String(),
        'parent_comment_id': parent_comment_id,
        'is_deleted': is_deleted,
        'deleted_at': deleted_at?.toIso8601String(),
        'created_at': created_at?.toIso8601String(),
        'updated_at': updated_at?.toIso8601String(),
      };
}

class CreateCommentDto {
  const CreateCommentDto({
    required this.content,
    this.comment_type,
    this.parent_comment_id,
  });

  final String content;
  final String? comment_type;
  final String? parent_comment_id;

  Map<String, dynamic> toJson() => {
        'content': content,
        'comment_type': comment_type,
        'parent_comment_id': parent_comment_id,
      };
}

class UpdateCommentDto {
  const UpdateCommentDto({required this.content});

  final String content;

  Map<String, dynamic> toJson() => {'content': content};
}
