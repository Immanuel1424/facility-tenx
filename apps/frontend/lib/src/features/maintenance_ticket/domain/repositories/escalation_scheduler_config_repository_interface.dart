import 'package:fpdart/fpdart.dart';
import '../entities/escalation_scheduler_config_entity.dart';

abstract class EscalationSchedulerConfigRepositoryInterface {
  Future<Either<String, EscalationSchedulerConfigEntity>> getConfig();
  Future<Either<String, EscalationSchedulerConfigEntity>> updateConfig(
    int intervalMinutes,
  );
}
