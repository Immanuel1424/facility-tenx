import '../../domain/entities/comment_entity.dart' as domain;
import '../dto/comment_dto.dart';

class CommentMapper {
  static domain.CommentEntity toEntity(CommentDto dto) {
    return domain.CommentEntity(
      id: dto.id,
      ticketId: dto.ticket_id,
      createdById: dto.created_by_id,
      createdBy: dto.created_by != null
          ? '${dto.created_by!.first_name ?? ''} ${dto.created_by!.last_name ?? ''}'.trim().isEmpty
              ? dto.created_by!.email ?? 'Unknown'
              : '${dto.created_by!.first_name ?? ''} ${dto.created_by!.last_name ?? ''}'.trim()
          : null,
      content: dto.content,
      commentType: dto.comment_type != null
          ? domain.CommentType.fromString(dto.comment_type!)
          : domain.CommentType.public,
      isEdited: dto.is_edited,
      editedAt: dto.edited_at,
      parentCommentId: dto.parent_comment_id,
      isDeleted: dto.is_deleted,
      deletedAt: dto.deleted_at,
      createdAt: dto.created_at ?? DateTime.now(),
      updatedAt: dto.updated_at ?? DateTime.now(),
    );
  }
}

