import 'package:equatable/equatable.dart';

import '../../../domain/entities/role_entity.dart';

abstract class RoleState extends Equatable {
  const RoleState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<RoleEntity> roles) listLoaded,
    required T Function(RoleEntity role) detailLoaded,
    required T Function(RoleEntity role) created,
    required T Function(RoleEntity role) updated,
    required T Function() deleted,
    required T Function(String message) error,
  }) {
    if (this is RoleInitial) {
      return initial();
    } else if (this is RoleLoading) {
      return loading();
    } else if (this is RoleListLoaded) {
      return listLoaded((this as RoleListLoaded).roles);
    } else if (this is RoleDetailLoaded) {
      return detailLoaded((this as RoleDetailLoaded).role);
    } else if (this is RoleCreated) {
      return created((this as RoleCreated).role);
    } else if (this is RoleUpdated) {
      return updated((this as RoleUpdated).role);
    } else if (this is RoleDeleted) {
      return deleted();
    } else if (this is RoleError) {
      return error((this as RoleError).message);
    }
    throw Exception('Unknown RoleState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<RoleEntity> roles)? listLoaded,
    T Function(RoleEntity role)? detailLoaded,
    T Function(RoleEntity role)? created,
    T Function(RoleEntity role)? updated,
    T Function()? deleted,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is RoleInitial && initial != null) {
      return initial();
    } else if (this is RoleLoading && loading != null) {
      return loading();
    } else if (this is RoleListLoaded && listLoaded != null) {
      return listLoaded((this as RoleListLoaded).roles);
    } else if (this is RoleDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as RoleDetailLoaded).role);
    } else if (this is RoleCreated && created != null) {
      return created((this as RoleCreated).role);
    } else if (this is RoleUpdated && updated != null) {
      return updated((this as RoleUpdated).role);
    } else if (this is RoleDeleted && deleted != null) {
      return deleted();
    } else if (this is RoleError && error != null) {
      return error((this as RoleError).message);
    }
    return orElse();
  }
}

class RoleInitial extends RoleState {
  const RoleInitial();
}

class RoleLoading extends RoleState {
  const RoleLoading();
}

class RoleListLoaded extends RoleState {
  const RoleListLoaded(this.roles);

  final List<RoleEntity> roles;

  @override
  List<Object> get props => [roles];
}

class RoleDetailLoaded extends RoleState {
  const RoleDetailLoaded(this.role);

  final RoleEntity role;

  @override
  List<Object> get props => [role];
}

class RoleCreated extends RoleState {
  const RoleCreated(this.role);

  final RoleEntity role;

  @override
  List<Object> get props => [role];
}

class RoleUpdated extends RoleState {
  const RoleUpdated(this.role);

  final RoleEntity role;

  @override
  List<Object> get props => [role];
}

class RoleDeleted extends RoleState {
  const RoleDeleted();
}

class RoleError extends RoleState {
  const RoleError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

