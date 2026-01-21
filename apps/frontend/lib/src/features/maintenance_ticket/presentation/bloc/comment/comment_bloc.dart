import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/comment_entity.dart' as domain_entity;
import '../../../domain/repositories/comment_repository_interface.dart'
    as domain;
import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc({
    required domain.CommentRepositoryInterface repository,
  })  : _repository = repository,
        super(const CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<CreateComment>(_onCreateComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<AddInternalNote>(_onAddInternalNote);
    on<AddWorkNote>(_onAddWorkNote);
  }

  final domain.CommentRepositoryInterface _repository;

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _repository.getComments(event.ticketId);

    result.fold(
      (String error) => emit(CommentError(error)),
      (List<domain_entity.CommentEntity> comments) =>
          emit(CommentsLoaded(comments)),
    );
  }

  Future<void> _onCreateComment(
    CreateComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _repository.createComment(
      event.ticketId,
      content: event.content,
      commentType: event.commentType,
      parentCommentId: event.parentCommentId,
    );

    result.fold(
      (String error) => emit(CommentError(error)),
      (domain_entity.CommentEntity comment) {
        emit(CommentCreated(comment));
        // Reload comments to get updated list
        add(LoadComments(event.ticketId));
      },
    );
  }

  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _repository.updateComment(
      event.ticketId,
      event.commentId,
      content: event.content,
    );

    result.fold(
      (String error) => emit(CommentError(error)),
      (domain_entity.CommentEntity comment) {
        emit(CommentUpdated(comment));
        // Reload comments to get updated list
        add(LoadComments(event.ticketId));
      },
    );
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _repository.deleteComment(
      event.ticketId,
      event.commentId,
    );

    result.fold(
      (String error) => emit(CommentError(error)),
      (void _) {
        emit(CommentDeleted(event.commentId));
        // Reload comments to get updated list
        add(LoadComments(event.ticketId));
      },
    );
  }

  Future<void> _onAddInternalNote(
    AddInternalNote event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _repository.addInternalNote(
      event.ticketId,
      notes: event.notes,
    );

    result.fold(
      (String error) => emit(CommentError(error)),
      (domain_entity.CommentEntity comment) {
        emit(CommentCreated(comment));
        // Reload comments to get updated list
        add(LoadComments(event.ticketId));
      },
    );
  }

  Future<void> _onAddWorkNote(
    AddWorkNote event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());

    final result = await _repository.addWorkNote(
      event.ticketId,
      notes: event.notes,
    );

    result.fold(
      (String error) => emit(CommentError(error)),
      (domain_entity.CommentEntity comment) {
        emit(CommentCreated(comment));
        // Reload comments to get updated list
        add(LoadComments(event.ticketId));
      },
    );
  }
}
