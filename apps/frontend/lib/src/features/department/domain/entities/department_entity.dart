import 'package:equatable/equatable.dart';

class DepartmentEntity extends Equatable {
  const DepartmentEntity({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final String companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isActive,
        companyId,
        createdAt,
        updatedAt,
      ];
}

