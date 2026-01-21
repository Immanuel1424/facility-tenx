import 'package:equatable/equatable.dart';
import '../../../domain/entities/escalation_scheduler_config_entity.dart';

abstract class EscalationSchedulerConfigState extends Equatable {
  const EscalationSchedulerConfigState();

  @override
  List<Object?> get props => [];
}

class EscalationSchedulerConfigInitial extends EscalationSchedulerConfigState {
  const EscalationSchedulerConfigInitial();
}

class EscalationSchedulerConfigLoading extends EscalationSchedulerConfigState {
  const EscalationSchedulerConfigLoading();
}

class EscalationSchedulerConfigLoaded extends EscalationSchedulerConfigState {
  const EscalationSchedulerConfigLoaded(this.config);

  final EscalationSchedulerConfigEntity config;

  @override
  List<Object?> get props => [config];
}

class EscalationSchedulerConfigError extends EscalationSchedulerConfigState {
  const EscalationSchedulerConfigError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class EscalationSchedulerConfigUpdated extends EscalationSchedulerConfigState {
  const EscalationSchedulerConfigUpdated(this.config);

  final EscalationSchedulerConfigEntity config;

  @override
  List<Object?> get props => [config];
}
