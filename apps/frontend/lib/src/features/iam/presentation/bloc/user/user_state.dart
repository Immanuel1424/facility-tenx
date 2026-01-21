import 'package:equatable/equatable.dart';

import '../../../data/dto/user_dto.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<UserDto> users) listLoaded,
    required T Function(UserDto user) detailLoaded,
    required T Function(UserDto user) created,
    required T Function(UserDto user) updated,
    required T Function(UserDto user) activated,
    required T Function(UserDto user) deactivated,
    required T Function() passwordReset,
    required T Function() deleted,
    required T Function(String message) error,
  }) {
    if (this is UserInitial) {
      return initial();
    } else if (this is UserLoading) {
      return loading();
    } else if (this is UserListLoaded) {
      return listLoaded((this as UserListLoaded).users);
    } else if (this is UserDetailLoaded) {
      return detailLoaded((this as UserDetailLoaded).user);
    } else if (this is UserCreated) {
      return created((this as UserCreated).user);
    } else if (this is UserUpdated) {
      return updated((this as UserUpdated).user);
    } else if (this is UserActivated) {
      return activated((this as UserActivated).user);
    } else if (this is UserDeactivated) {
      return deactivated((this as UserDeactivated).user);
    } else if (this is UserPasswordReset) {
      return passwordReset();
    } else if (this is UserDeleted) {
      return deleted();
    } else if (this is UserError) {
      return error((this as UserError).message);
    }
    throw Exception('Unknown UserState');
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<UserDto> users)? listLoaded,
    T Function(UserDto user)? detailLoaded,
    T Function(UserDto user)? created,
    T Function(UserDto user)? updated,
    T Function(UserDto user)? activated,
    T Function(UserDto user)? deactivated,
    T Function()? passwordReset,
    T Function()? deleted,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is UserInitial && initial != null) {
      return initial();
    } else if (this is UserLoading && loading != null) {
      return loading();
    } else if (this is UserListLoaded && listLoaded != null) {
      return listLoaded((this as UserListLoaded).users);
    } else if (this is UserDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as UserDetailLoaded).user);
    } else if (this is UserCreated && created != null) {
      return created((this as UserCreated).user);
    } else if (this is UserUpdated && updated != null) {
      return updated((this as UserUpdated).user);
    } else if (this is UserActivated && activated != null) {
      return activated((this as UserActivated).user);
    } else if (this is UserDeactivated && deactivated != null) {
      return deactivated((this as UserDeactivated).user);
    } else if (this is UserPasswordReset && passwordReset != null) {
      return passwordReset();
    } else if (this is UserDeleted && deleted != null) {
      return deleted();
    } else if (this is UserError && error != null) {
      return error((this as UserError).message);
    }
    return orElse();
  }
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserListLoaded extends UserState {
  const UserListLoaded(this.users);

  final List<UserDto> users;

  @override
  List<Object> get props => [users];
}

class UserDetailLoaded extends UserState {
  const UserDetailLoaded(this.user);

  final UserDto user;

  @override
  List<Object> get props => [user];
}

class UserCreated extends UserState {
  const UserCreated(this.user);

  final UserDto user;

  @override
  List<Object> get props => [user];
}

class UserUpdated extends UserState {
  const UserUpdated(this.user);

  final UserDto user;

  @override
  List<Object> get props => [user];
}

class UserActivated extends UserState {
  const UserActivated(this.user);

  final UserDto user;

  @override
  List<Object> get props => [user];
}

class UserDeactivated extends UserState {
  const UserDeactivated(this.user);

  final UserDto user;

  @override
  List<Object> get props => [user];
}

class UserPasswordReset extends UserState {
  const UserPasswordReset();
}

class UserDeleted extends UserState {
  const UserDeleted();
}

class UserError extends UserState {
  const UserError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
