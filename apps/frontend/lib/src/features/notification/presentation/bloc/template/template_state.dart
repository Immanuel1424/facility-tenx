import 'package:equatable/equatable.dart';
import '../../../data/dto/notification_template_dto.dart';

abstract class TemplateState extends Equatable {
  const TemplateState();

  @override
  List<Object?> get props => [];

  T maybeWhen<T>({
    T Function()? orElse,
    T Function()? initial,
    T Function()? loading,
    T Function(List<NotificationTemplateDto> templates)? listLoaded,
    T Function(NotificationTemplateDto template)? loaded,
    T Function(NotificationTemplateDto template)? updated,
    T Function(String message)? error,
  }) {
    if (this is TemplateInitial && initial != null) {
      return initial();
    }
    if (this is TemplateLoading && loading != null) {
      return loading();
    }
    if (this is TemplateListLoaded && listLoaded != null) {
      return listLoaded((this as TemplateListLoaded).templates);
    }
    if (this is TemplateLoaded && loaded != null) {
      return loaded((this as TemplateLoaded).template);
    }
    if (this is TemplateUpdated && updated != null) {
      return updated((this as TemplateUpdated).template);
    }
    if (this is TemplateError && error != null) {
      return error((this as TemplateError).message);
    }
    if (orElse != null) {
      return orElse();
    }
    throw Exception('No handler for state: $this');
  }

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<NotificationTemplateDto> templates) listLoaded,
    required T Function(NotificationTemplateDto template) loaded,
    required T Function(NotificationTemplateDto template) updated,
    required T Function(String message) error,
  }) {
    if (this is TemplateInitial) {
      return initial();
    }
    if (this is TemplateLoading) {
      return loading();
    }
    if (this is TemplateListLoaded) {
      return listLoaded((this as TemplateListLoaded).templates);
    }
    if (this is TemplateLoaded) {
      return loaded((this as TemplateLoaded).template);
    }
    if (this is TemplateUpdated) {
      return updated((this as TemplateUpdated).template);
    }
    if (this is TemplateError) {
      return error((this as TemplateError).message);
    }
    throw Exception('Unknown state: $this');
  }
}

class TemplateInitial extends TemplateState {
  const TemplateInitial();
}

class TemplateLoading extends TemplateState {
  const TemplateLoading();
}

class TemplateListLoaded extends TemplateState {
  const TemplateListLoaded(this.templates);

  final List<NotificationTemplateDto> templates;

  @override
  List<Object?> get props => [templates];
}

class TemplateLoaded extends TemplateState {
  const TemplateLoaded(this.template);

  final NotificationTemplateDto template;

  @override
  List<Object?> get props => [template];
}

class TemplateUpdated extends TemplateState {
  const TemplateUpdated(this.template);

  final NotificationTemplateDto template;

  @override
  List<Object?> get props => [template];
}

class TemplateError extends TemplateState {
  const TemplateError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

