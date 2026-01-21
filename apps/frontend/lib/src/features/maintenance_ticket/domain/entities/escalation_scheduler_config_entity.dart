import 'package:equatable/equatable.dart';

class EscalationSchedulerConfigEntity extends Equatable {
  const EscalationSchedulerConfigEntity({
    required this.intervalMinutes,
  });

  final int intervalMinutes;

  @override
  List<Object?> get props => [intervalMinutes];
}
