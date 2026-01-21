import 'package:equatable/equatable.dart';

import '../../../data/dto/role_dto.dart';

abstract class RoleEvent extends Equatable {
  const RoleEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoleList extends RoleEvent {
  const LoadRoleList({this.companyId});

  final String? companyId;

  @override
  List<Object?> get props => [companyId];
}

class LoadRoleDetail extends RoleEvent {
  const LoadRoleDetail(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class CreateRole extends RoleEvent {
  const CreateRole(this.dto);

  final CreateRoleDto dto;

  @override
  List<Object> get props => [dto];
}

class UpdateRole extends RoleEvent {
  const UpdateRole(this.id, this.dto);

  final String id;
  final UpdateRoleDto dto;

  @override
  List<Object> get props => [id, dto];
}

class DeleteRole extends RoleEvent {
  const DeleteRole(this.id);

  final String id;

  @override
  List<Object> get props => [id];
}

class AssignPermissionToRole extends RoleEvent {
  const AssignPermissionToRole(this.roleId, this.permissionId);

  final String roleId;
  final String permissionId;

  @override
  List<Object> get props => [roleId, permissionId];
}
