import 'package:equatable/equatable.dart';

abstract class EscalationSchedulerConfigEvent extends Equatable {
  const EscalationSchedulerConfigEvent();

  @override
  List<Object?> get props => [];
}

class LoadEscalationSchedulerConfig extends EscalationSchedulerConfigEvent {
  const LoadEscalationSchedulerConfig();
}

class UpdateEscalationSchedulerConfig extends EscalationSchedulerConfigEvent {
  const UpdateEscalationSchedulerConfig(this.intervalMinutes);

  final int intervalMinutes;

  @override
  List<Object?> get props => [intervalMinutes];
}
