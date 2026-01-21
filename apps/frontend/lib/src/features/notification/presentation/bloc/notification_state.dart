import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<NotificationEntity> notifications) listLoaded,
    required T Function(NotificationEntity? notification) markedAsRead,
    required T Function(String message) error,
  }) {
    if (this is NotificationInitial) {
      return initial();
    } else if (this is NotificationLoading) {
      return loading();
    } else if (this is NotificationListLoaded) {
      return listLoaded((this as NotificationListLoaded).notifications);
    } else if (this is NotificationMarkedAsRead) {
      return markedAsRead((this as NotificationMarkedAsRead).notification);
    } else if (this is NotificationError) {
      return error((this as NotificationError).message);
    }
    throw Exception('Unknown NotificationState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<NotificationEntity> notifications)? listLoaded,
    T Function(NotificationEntity? notification)? markedAsRead,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is NotificationInitial && initial != null) {
      return initial();
    } else if (this is NotificationLoading && loading != null) {
      return loading();
    } else if (this is NotificationListLoaded && listLoaded != null) {
      return listLoaded((this as NotificationListLoaded).notifications);
    } else if (this is NotificationMarkedAsRead && markedAsRead != null) {
      return markedAsRead((this as NotificationMarkedAsRead).notification);
    } else if (this is NotificationError && error != null) {
      return error((this as NotificationError).message);
    }
    return orElse();
  }
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationListLoaded extends NotificationState {
  const NotificationListLoaded(this.notifications);

  final List<NotificationEntity> notifications;

  @override
  List<Object> get props => [notifications];
}

class NotificationMarkedAsRead extends NotificationState {
  const NotificationMarkedAsRead(this.notification);

  final NotificationEntity? notification;

  @override
  List<Object?> get props => [notification];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
