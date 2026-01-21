import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../data/repositories/iam_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({
    required IamRepository repository,
  })  : _repository = repository,
        super(const UserInitial()) {
    on<LoadUserList>(_onLoadList);
    on<LoadUserDetail>(_onLoadDetail);
    on<CreateUser>(_onCreate);
    on<UpdateUser>(_onUpdate);
    on<ActivateUser>(_onActivate);
    on<DeactivateUser>(_onDeactivate);
    on<ResetUserPassword>(_onResetPassword);
    on<DeleteUser>(_onDelete);
  }

  final IamRepository _repository;

  Future<void> _onLoadList(
    LoadUserList event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.getUsers(companyId: event.companyId);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (users) => emit(UserListLoaded(users)),
    );
  }

  Future<void> _onLoadDetail(
    LoadUserDetail event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.getUser(event.id, companyId: event.companyId);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (user) => emit(UserDetailLoaded(user)),
    );
  }

  Future<void> _onCreate(
    CreateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.createUser(event.dto);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (user) => emit(UserCreated(user)),
    );
  }

  Future<void> _onUpdate(
    UpdateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.updateUser(event.id, event.dto);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (user) => emit(UserUpdated(user)),
    );
  }

  Future<void> _onActivate(
    ActivateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.activateUser(event.id);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (user) => emit(UserActivated(user)),
    );
  }

  Future<void> _onDeactivate(
    DeactivateUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.deactivateUser(event.id);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (user) => emit(UserDeactivated(user)),
    );
  }

  Future<void> _onResetPassword(
    ResetUserPassword event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.resetUserPassword(event.id, event.dto);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (_) => emit(const UserPasswordReset()),
    );
  }

  Future<void> _onDelete(
    DeleteUser event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _repository.deleteUser(event.id);

    result.fold(
      (error) => emit(UserError(_getErrorMessage(error))),
      (_) => emit(const UserDeleted()),
    );
  }

  String _getErrorMessage(Exception error) {
    if (error is DioException && error.message != null) {
      return error.message!;
    }
    return error.toString();
  }
}

