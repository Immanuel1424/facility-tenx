import 'package:equatable/equatable.dart';

import '../../../domain/entities/sla_configuration_entity.dart';

abstract class SlaConfigurationState extends Equatable {
  const SlaConfigurationState();

  @override
  List<Object?> get props => [];
}

class SlaConfigurationInitial extends SlaConfigurationState {
  const SlaConfigurationInitial();
}

class SlaConfigurationLoading extends SlaConfigurationState {
  const SlaConfigurationLoading();
}

class SlaConfigurationListLoaded extends SlaConfigurationState {
  const SlaConfigurationListLoaded(this.configurations);

  final List<SlaConfigurationEntity> configurations;

  @override
  List<Object?> get props => [configurations];
}

class SlaConfigurationLoaded extends SlaConfigurationState {
  const SlaConfigurationLoaded(this.configuration);

  final SlaConfigurationEntity configuration;

  @override
  List<Object?> get props => [configuration];
}

class SlaConfigurationCreated extends SlaConfigurationState {
  const SlaConfigurationCreated(this.configuration);

  final SlaConfigurationEntity configuration;

  @override
  List<Object?> get props => [configuration];
}

class SlaConfigurationUpdated extends SlaConfigurationState {
  const SlaConfigurationUpdated(this.configuration);

  final SlaConfigurationEntity configuration;

  @override
  List<Object?> get props => [configuration];
}

class SlaConfigurationDeleted extends SlaConfigurationState {
  const SlaConfigurationDeleted();
}

class SlaConfigurationError extends SlaConfigurationState {
  const SlaConfigurationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
