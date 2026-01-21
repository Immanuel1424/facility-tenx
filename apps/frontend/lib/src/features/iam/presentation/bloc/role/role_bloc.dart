import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/iam_repository.dart';
import 'role_event.dart';
import 'role_state.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  RoleBloc({
    required IamRepository repository,
  })  : _repository = repository,
        super(const RoleInitial()) {
    on<LoadRoleList>(_onLoadList);
    on<LoadRoleDetail>(_onLoadDetail);
    on<CreateRole>(_onCreate);
    on<UpdateRole>(_onUpdate);
    on<DeleteRole>(_onDelete);
    on<AssignPermissionToRole>(_onAssignPermission);
  }

  final IamRepository _repository;

  Future<void> _onLoadList(
    LoadRoleList event,
    Emitter<RoleState> emit,
  ) async {
    emit(const RoleLoading());

    final result = await _repository.getRoles(companyId: event.companyId);

    result.fold(
      (error) => emit(RoleError(error.toString())),
      (roles) => emit(RoleListLoaded(roles)),
    );
  }

  Future<void> _onLoadDetail(
    LoadRoleDetail event,
    Emitter<RoleState> emit,
  ) async {
    emit(const RoleLoading());

    final result = await _repository.getRole(event.id);

    result.fold(
      (error) => emit(RoleError(error.toString())),
      (role) => emit(RoleDetailLoaded(role)),
    );
  }

  Future<void> _onCreate(
    CreateRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(const RoleLoading());

    final result = await _repository.createRole(event.dto);

    result.fold(
      (error) => emit(RoleError(error.toString())),
      (role) => emit(RoleCreated(role)),
    );
  }

  Future<void> _onUpdate(
    UpdateRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(const RoleLoading());

    final result = await _repository.updateRole(event.id, event.dto);

    result.fold(
      (error) => emit(RoleError(error.toString())),
      (role) => emit(RoleUpdated(role)),
    );
  }

  Future<void> _onDelete(
    DeleteRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(const RoleLoading());

    final result = await _repository.deleteRole(event.id);

    result.fold(
      (error) => emit(RoleError(error.toString())),
      (_) => emit(const RoleDeleted()),
    );
  }

  Future<void> _onAssignPermission(
    AssignPermissionToRole event,
    Emitter<RoleState> emit,
  ) async {
    emit(const RoleLoading());

    final result = await _repository.assignPermissionToRole(
      event.roleId,
      event.permissionId,
    );

    result.fold(
      (error) => emit(RoleError(error.toString())),
      (_) {
        // Reload role detail after assigning permission
        add(LoadRoleDetail(event.roleId));
      },
    );
  }
}
