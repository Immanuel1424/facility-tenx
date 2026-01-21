import 'package:equatable/equatable.dart';

import '../../../domain/entities/permission_entity.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<PermissionEntity> permissions) listLoaded,
    required T Function(PermissionEntity permission) detailLoaded,
    required T Function(PermissionEntity permission) created,
    required T Function(PermissionEntity permission) updated,
    required T Function() deleted,
    required T Function(String message) error,
  }) {
    if (this is PermissionInitial) {
      return initial();
    } else if (this is PermissionLoading) {
      return loading();
    } else if (this is PermissionListLoaded) {
      return listLoaded((this as PermissionListLoaded).permissions);
    } else if (this is PermissionDetailLoaded) {
      return detailLoaded((this as PermissionDetailLoaded).permission);
    } else if (this is PermissionCreated) {
      return created((this as PermissionCreated).permission);
    } else if (this is PermissionUpdated) {
      return updated((this as PermissionUpdated).permission);
    } else if (this is PermissionDeleted) {
      return deleted();
    } else if (this is PermissionError) {
      return error((this as PermissionError).message);
    }
    throw Exception('Unknown PermissionState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<PermissionEntity> permissions)? listLoaded,
    T Function(PermissionEntity permission)? detailLoaded,
    T Function(PermissionEntity permission)? created,
    T Function(PermissionEntity permission)? updated,
    T Function()? deleted,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is PermissionInitial && initial != null) {
      return initial();
    } else if (this is PermissionLoading && loading != null) {
      return loading();
    } else if (this is PermissionListLoaded && listLoaded != null) {
      return listLoaded((this as PermissionListLoaded).permissions);
    } else if (this is PermissionDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as PermissionDetailLoaded).permission);
    } else if (this is PermissionCreated && created != null) {
      return created((this as PermissionCreated).permission);
    } else if (this is PermissionUpdated && updated != null) {
      return updated((this as PermissionUpdated).permission);
    } else if (this is PermissionDeleted && deleted != null) {
      return deleted();
    } else if (this is PermissionError && error != null) {
      return error((this as PermissionError).message);
    }
    return orElse();
  }
}

class PermissionInitial extends PermissionState {
  const PermissionInitial();
}

class PermissionLoading extends PermissionState {
  const PermissionLoading();
}

class PermissionListLoaded extends PermissionState {
  const PermissionListLoaded(this.permissions);

  final List<PermissionEntity> permissions;

  @override
  List<Object> get props => [permissions];
}

class PermissionDetailLoaded extends PermissionState {
  const PermissionDetailLoaded(this.permission);

  final PermissionEntity permission;

  @override
  List<Object> get props => [permission];
}

class PermissionCreated extends PermissionState {
  const PermissionCreated(this.permission);

  final PermissionEntity permission;

  @override
  List<Object> get props => [permission];
}

class PermissionUpdated extends PermissionState {
  const PermissionUpdated(this.permission);

  final PermissionEntity permission;

  @override
  List<Object> get props => [permission];
}

class PermissionDeleted extends PermissionState {
  const PermissionDeleted();
}

class PermissionError extends PermissionState {
  const PermissionError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

