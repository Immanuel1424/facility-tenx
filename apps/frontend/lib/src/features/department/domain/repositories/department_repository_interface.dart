import 'package:fpdart/fpdart.dart';

import '../entities/department_entity.dart';

abstract class DepartmentRepositoryInterface {
  Future<Either<Exception, List<DepartmentEntity>>> getDepartments();
  Future<Either<Exception, DepartmentEntity>> getDepartment(String id);
  Future<Either<Exception, DepartmentEntity>> createDepartment({
    required String name,
    String? description,
  });
  Future<Either<Exception, DepartmentEntity>> updateDepartment({
    required String id,
    String? name,
    String? description,
  });
}

