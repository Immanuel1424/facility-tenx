import 'package:equatable/equatable.dart';

import '../../../data/dto/permission_dto.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPermissionList extends PermissionEvent {
  const LoadPermissionList();
}

class LoadPermissionDetail extends PermissionEvent {
  const LoadPermissionDetail(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class CreatePermission extends PermissionEvent {
  const CreatePermission(this.dto);

  final CreatePermissionDto dto;

  @override
  List<Object> get props => [dto];
}

class UpdatePermission extends PermissionEvent {
  const UpdatePermission(this.id, this.dto);

  final String id;
  final UpdatePermissionDto dto;

  @override
  List<Object> get props => [id, dto];
}

class DeletePermission extends PermissionEvent {
  const DeletePermission(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

