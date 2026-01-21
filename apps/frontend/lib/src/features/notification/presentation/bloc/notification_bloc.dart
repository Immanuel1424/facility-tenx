import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(const NotificationInitial()) {
    on<LoadNotificationList>(_onLoadList);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
  }

  final NotificationRepository _repository;

  Future<void> _onLoadList(
    LoadNotificationList event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _repository.getNotifications();

    result.fold(
      (error) => emit(NotificationError(error.toString())),
      (notifications) => emit(NotificationListLoaded(notifications)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.markAsRead(event.id);

    result.fold(
      (error) => emit(NotificationError(error.toString())),
      (notification) {
        emit(NotificationMarkedAsRead(notification));
        // Reload list to update UI
        add(const LoadNotificationList());
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Get current notifications
    emit(const NotificationLoading());
    final result = await _repository.markAllAsRead();
    result.fold(
      (error) => emit(NotificationError(error.toString())),
      (_) {
        emit(const NotificationMarkedAsRead(null));
        add(const LoadNotificationList());
      },
    );
  }
}
