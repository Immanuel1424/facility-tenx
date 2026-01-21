import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/announcement_repository_interface.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc
    extends Bloc<AnnouncementEvent, AnnouncementState> {
  AnnouncementBloc({
    required AnnouncementRepositoryInterface repository,
  })  : _repository = repository,
        super(const AnnouncementInitial()) {
    on<LoadAnnouncements>(_onLoadAnnouncements);
    on<LoadAnnouncementsForAdmin>(_onLoadAnnouncementsForAdmin);
    on<LoadAnnouncementDetail>(_onLoadAnnouncementDetail);
    on<CreateAnnouncement>(_onCreateAnnouncement);
    on<UpdateAnnouncement>(_onUpdateAnnouncement);
    on<DeleteAnnouncement>(_onDeleteAnnouncement);
    on<PublishAnnouncement>(_onPublishAnnouncement);
    on<MarkAnnouncementAsRead>(_onMarkAsRead);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<LoadUnreadAnnouncements>(_onLoadUnreadAnnouncements);
  }

  final AnnouncementRepositoryInterface _repository;

  Future<void> _onLoadAnnouncements(
    LoadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.getAnnouncements(
      category: event.category,
      priority: event.priority,
      search: event.search,
      page: event.page,
      limit: event.limit,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (paginatedResult) {
        emit(
          AnnouncementListLoaded(
            announcements: paginatedResult.data,
            total: paginatedResult.total,
          ),
        );
      },
    );
  }

  Future<void> _onLoadAnnouncementsForAdmin(
    LoadAnnouncementsForAdmin event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.getAnnouncementsForAdmin(
      category: event.category,
      priority: event.priority,
      search: event.search,
      page: event.page,
      limit: event.limit,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (paginatedResult) {
        emit(
          AnnouncementListLoaded(
            announcements: paginatedResult.data,
            total: paginatedResult.total,
          ),
        );
      },
    );
  }

  Future<void> _onLoadAnnouncementDetail(
    LoadAnnouncementDetail event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.getAnnouncement(event.id);

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (announcement) => emit(AnnouncementDetailLoaded(announcement)),
    );
  }

  Future<void> _onCreateAnnouncement(
    CreateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.createAnnouncement(
      title: event.title,
      message: event.message,
      category: event.category,
      priority: event.priority,
      targetAudience: event.targetAudience,
      targetRoles: event.targetRoles,
      scheduledAt: event.scheduledAt,
      expiresAt: event.expiresAt,
      publishImmediately: event.publishImmediately,
    );

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (announcement) => emit(AnnouncementCreated(announcement)),
    );
  }

  Future<void> _onUpdateAnnouncement(
    UpdateAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.updateAnnouncement(
      event.id,
      title: event.title,
      message: event.message,
      category: event.category,
      priority: event.priority,
      targetAudience: event.targetAudience,
      targetRoles: event.targetRoles,
      scheduledAt: event.scheduledAt,
      expiresAt: event.expiresAt,
    );

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (announcement) => emit(AnnouncementUpdated(announcement)),
    );
  }

  Future<void> _onDeleteAnnouncement(
    DeleteAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.deleteAnnouncement(event.id);

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(const AnnouncementDeleted()),
    );
  }

  Future<void> _onPublishAnnouncement(
    PublishAnnouncement event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.publishAnnouncement(event.id);

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (announcement) => emit(AnnouncementPublished(announcement)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAnnouncementAsRead event,
    Emitter<AnnouncementState> emit,
  ) async {
    final result = await _repository.markAsRead(event.id);

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementMarkedAsRead(event.id)),
    );
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<AnnouncementState> emit,
  ) async {
    final result = await _repository.getUnreadCount();

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (count) => emit(UnreadCountLoaded(count)),
    );
  }

  Future<void> _onLoadUnreadAnnouncements(
    LoadUnreadAnnouncements event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(const AnnouncementLoading());

    final result = await _repository.getUnreadAnnouncements(
      category: event.category,
      priority: event.priority,
      search: event.search,
      page: event.page,
      limit: event.limit,
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
    );

    result.fold(
      (error) => emit(AnnouncementError(error)),
      (paginatedResult) {
        emit(
          UnreadAnnouncementsLoaded(
            announcements: paginatedResult.data,
            total: paginatedResult.total,
          ),
        );
      },
    );
  }
}

