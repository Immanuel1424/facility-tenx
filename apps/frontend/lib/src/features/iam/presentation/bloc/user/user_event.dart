import 'package:equatable/equatable.dart';

import '../../../data/dto/user_dto.dart';

export '../../../data/dto/user_dto.dart' show CreateUserDto, UpdateUserDto, ResetPasswordDto;

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserList extends UserEvent {
  const LoadUserList({this.companyId});

  final String? companyId;

  @override
  List<Object?> get props => [companyId];
}

class LoadUserDetail extends UserEvent {
  const LoadUserDetail(this.id, {this.companyId});

  final String id;
  final String? companyId;

  @override
  List<Object?> get props => [id, companyId];
}

class CreateUser extends UserEvent {
  const CreateUser(this.dto);

  final CreateUserDto dto;

  @override
  List<Object> get props => [dto];
}

class UpdateUser extends UserEvent {
  const UpdateUser(this.id, this.dto);

  final String id;
  final UpdateUserDto dto;

  @override
  List<Object> get props => [id, dto];
}

class ActivateUser extends UserEvent {
  const ActivateUser(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class DeactivateUser extends UserEvent {
  const DeactivateUser(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class ResetUserPassword extends UserEvent {
  const ResetUserPassword(this.id, this.dto);

  final String id;
  final ResetPasswordDto dto;

  @override
  List<Object> get props => [id, dto];
}

class DeleteUser extends UserEvent {
  const DeleteUser(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

