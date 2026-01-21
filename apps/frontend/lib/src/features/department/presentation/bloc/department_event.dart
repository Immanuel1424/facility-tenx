import 'package:equatable/equatable.dart';

abstract class DepartmentEvent extends Equatable {
  const DepartmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDepartmentList extends DepartmentEvent {
  const LoadDepartmentList();
}

class LoadDepartmentDetail extends DepartmentEvent {
  const LoadDepartmentDetail(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateDepartment extends DepartmentEvent {
  const CreateDepartment({
    required this.name,
    this.description,
  });

  final String name;
  final String? description;

  @override
  List<Object?> get props => [name, description];
}

class UpdateDepartment extends DepartmentEvent {
  const UpdateDepartment({
    required this.id,
    this.name,
    this.description,
  });

  final String id;
  final String? name;
  final String? description;

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteDepartment extends DepartmentEvent {
  const DeleteDepartment(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

