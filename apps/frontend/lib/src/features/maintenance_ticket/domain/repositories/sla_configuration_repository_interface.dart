import 'package:fpdart/fpdart.dart';

import '../entities/sla_configuration_entity.dart';

abstract class SlaConfigurationRepositoryInterface {
  Future<Either<String, List<SlaConfigurationEntity>>> getAll();

  Future<Either<String, List<SlaConfigurationEntity>>> getActive();

  Future<Either<String, SlaConfigurationEntity>> getById(String id);

  Future<Either<String, SlaConfigurationEntity>> create(
    SlaConfigurationEntity entity,
  );

  Future<Either<String, SlaConfigurationEntity>> update(
    String id,
    SlaConfigurationEntity entity,
  );

  Future<Either<String, void>> delete(String id);
}
