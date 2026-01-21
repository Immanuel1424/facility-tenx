import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/department_repository_interface.dart';
import 'department_event.dart';
import 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  DepartmentBloc({
    required DepartmentRepositoryInterface repository,
  })  : _repository = repository,
        super(const DepartmentInitial()) {
    on<LoadDepartmentList>(_onLoadList);
    on<LoadDepartmentDetail>(_onLoadDetail);
    on<CreateDepartment>(_onCreate);
    on<UpdateDepartment>(_onUpdate);
    on<DeleteDepartment>(_onDelete);
  }

  final DepartmentRepositoryInterface _repository;

  Future<void> _onLoadList(
    LoadDepartmentList event,
    Emitter<DepartmentState> emit,
  ) async {
    emit(const DepartmentLoading());

    final result = await _repository.getDepartments();

    result.fold(
      (error) => emit(DepartmentError(_getErrorMessage(error))),
      (departments) => emit(DepartmentListLoaded(departments)),
    );
  }

  Future<void> _onLoadDetail(
    LoadDepartmentDetail event,
    Emitter<DepartmentState> emit,
  ) async {
    emit(const DepartmentLoading());

    final result = await _repository.getDepartment(event.id);

    result.fold(
      (error) => emit(DepartmentError(_getErrorMessage(error))),
      (department) => emit(DepartmentDetailLoaded(department)),
    );
  }

  Future<void> _onCreate(
    CreateDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    emit(const DepartmentLoading());

    final result = await _repository.createDepartment(
      name: event.name,
      description: event.description,
    );

    result.fold(
      (error) => emit(DepartmentError(_getErrorMessage(error))),
      (department) => emit(DepartmentCreated(department)),
    );
  }

  Future<void> _onUpdate(
    UpdateDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    emit(const DepartmentLoading());

    final result = await _repository.updateDepartment(
      id: event.id,
      name: event.name,
      description: event.description,
    );

    result.fold(
      (error) => emit(DepartmentError(_getErrorMessage(error))),
      (department) => emit(DepartmentUpdated(department)),
    );
  }

  Future<void> _onDelete(
    DeleteDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    emit(const DepartmentLoading());

    // Note: Backend doesn't have delete endpoint, but we'll handle it gracefully
    emit(const DepartmentError('Delete operation not supported'));
  }

  String _getErrorMessage(Exception error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

