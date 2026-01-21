import 'package:equatable/equatable.dart';

import '../../../domain/entities/sla_configuration_entity.dart';

abstract class SlaConfigurationEvent extends Equatable {
  const SlaConfigurationEvent();

  @override
  List<Object?> get props => [];
}

class LoadSlaConfigurationList extends SlaConfigurationEvent {
  const LoadSlaConfigurationList();
}

class LoadActiveSlaConfigurationList extends SlaConfigurationEvent {
  const LoadActiveSlaConfigurationList();
}

class LoadSlaConfigurationById extends SlaConfigurationEvent {
  const LoadSlaConfigurationById(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateSlaConfiguration extends SlaConfigurationEvent {
  const CreateSlaConfiguration(this.configuration);

  final SlaConfigurationEntity configuration;

  @override
  List<Object?> get props => [configuration];
}

class UpdateSlaConfiguration extends SlaConfigurationEvent {
  const UpdateSlaConfiguration(this.id, this.configuration);

  final String id;
  final SlaConfigurationEntity configuration;

  @override
  List<Object?> get props => [id, configuration];
}

class DeleteSlaConfiguration extends SlaConfigurationEvent {
  const DeleteSlaConfiguration(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
