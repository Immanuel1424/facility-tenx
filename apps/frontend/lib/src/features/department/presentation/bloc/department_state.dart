import 'package:equatable/equatable.dart';

import '../../domain/entities/department_entity.dart';

abstract class DepartmentState extends Equatable {
  const DepartmentState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<DepartmentEntity> departments) listLoaded,
    required T Function(DepartmentEntity department) detailLoaded,
    required T Function(DepartmentEntity department) created,
    required T Function(DepartmentEntity department) updated,
    required T Function() deleted,
    required T Function(String message) error,
  }) {
    if (this is DepartmentInitial) {
      return initial();
    } else if (this is DepartmentLoading) {
      return loading();
    } else if (this is DepartmentListLoaded) {
      return listLoaded((this as DepartmentListLoaded).departments);
    } else if (this is DepartmentDetailLoaded) {
      return detailLoaded((this as DepartmentDetailLoaded).department);
    } else if (this is DepartmentCreated) {
      return created((this as DepartmentCreated).department);
    } else if (this is DepartmentUpdated) {
      return updated((this as DepartmentUpdated).department);
    } else if (this is DepartmentDeleted) {
      return deleted();
    } else if (this is DepartmentError) {
      return error((this as DepartmentError).message);
    }
    throw Exception('Unknown DepartmentState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<DepartmentEntity> departments)? listLoaded,
    T Function(DepartmentEntity department)? detailLoaded,
    T Function(DepartmentEntity department)? created,
    T Function(DepartmentEntity department)? updated,
    T Function()? deleted,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is DepartmentInitial && initial != null) {
      return initial();
    } else if (this is DepartmentLoading && loading != null) {
      return loading();
    } else if (this is DepartmentListLoaded && listLoaded != null) {
      return listLoaded((this as DepartmentListLoaded).departments);
    } else if (this is DepartmentDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as DepartmentDetailLoaded).department);
    } else if (this is DepartmentCreated && created != null) {
      return created((this as DepartmentCreated).department);
    } else if (this is DepartmentUpdated && updated != null) {
      return updated((this as DepartmentUpdated).department);
    } else if (this is DepartmentDeleted && deleted != null) {
      return deleted();
    } else if (this is DepartmentError && error != null) {
      return error((this as DepartmentError).message);
    }
    return orElse();
  }
}

class DepartmentInitial extends DepartmentState {
  const DepartmentInitial();
}

class DepartmentLoading extends DepartmentState {
  const DepartmentLoading();
}

class DepartmentListLoaded extends DepartmentState {
  const DepartmentListLoaded(this.departments);

  final List<DepartmentEntity> departments;

  @override
  List<Object?> get props => [departments];
}

class DepartmentDetailLoaded extends DepartmentState {
  const DepartmentDetailLoaded(this.department);

  final DepartmentEntity department;

  @override
  List<Object?> get props => [department];
}

class DepartmentCreated extends DepartmentState {
  const DepartmentCreated(this.department);

  final DepartmentEntity department;

  @override
  List<Object?> get props => [department];
}

class DepartmentUpdated extends DepartmentState {
  const DepartmentUpdated(this.department);

  final DepartmentEntity department;

  @override
  List<Object?> get props => [department];
}

class DepartmentDeleted extends DepartmentState {
  const DepartmentDeleted();
}

class DepartmentError extends DepartmentState {
  const DepartmentError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

