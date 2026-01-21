import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/iam_repository.dart';
import 'permission_event.dart';
import 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc({
    required IamRepository repository,
  })  : _repository = repository,
        super(const PermissionInitial()) {
    on<LoadPermissionList>(_onLoadList);
    on<LoadPermissionDetail>(_onLoadDetail);
    on<CreatePermission>(_onCreate);
    on<UpdatePermission>(_onUpdate);
    on<DeletePermission>(_onDelete);
  }

  final IamRepository _repository;

  Future<void> _onLoadList(
    LoadPermissionList event,
    Emitter<PermissionState> emit,
  ) async {
    emit(const PermissionLoading());

    final result = await _repository.getPermissions();

    result.fold(
      (error) => emit(PermissionError(error.toString())),
      (permissions) => emit(PermissionListLoaded(permissions)),
    );
  }

  Future<void> _onLoadDetail(
    LoadPermissionDetail event,
    Emitter<PermissionState> emit,
  ) async {
    emit(const PermissionLoading());

    final result = await _repository.getPermission(event.id);

    result.fold(
      (error) => emit(PermissionError(error.toString())),
      (permission) => emit(PermissionDetailLoaded(permission)),
    );
  }

  Future<void> _onCreate(
    CreatePermission event,
    Emitter<PermissionState> emit,
  ) async {
    emit(const PermissionLoading());

    final result = await _repository.createPermission(event.dto);

    result.fold(
      (error) => emit(PermissionError(error.toString())),
      (permission) => emit(PermissionCreated(permission)),
    );
  }

  Future<void> _onUpdate(
    UpdatePermission event,
    Emitter<PermissionState> emit,
  ) async {
    emit(const PermissionLoading());

    final result = await _repository.updatePermission(event.id, event.dto);

    result.fold(
      (error) => emit(PermissionError(error.toString())),
      (permission) => emit(PermissionUpdated(permission)),
    );
  }

  Future<void> _onDelete(
    DeletePermission event,
    Emitter<PermissionState> emit,
  ) async {
    emit(const PermissionLoading());

    final result = await _repository.deletePermission(event.id);

    result.fold(
      (error) => emit(PermissionError(error.toString())),
      (_) => emit(const PermissionDeleted()),
    );
  }
}

