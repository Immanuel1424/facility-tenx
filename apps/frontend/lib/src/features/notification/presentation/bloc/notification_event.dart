import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationList extends NotificationEvent {
  const LoadNotificationList();
}

class MarkNotificationAsRead extends NotificationEvent {
  const MarkNotificationAsRead(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

