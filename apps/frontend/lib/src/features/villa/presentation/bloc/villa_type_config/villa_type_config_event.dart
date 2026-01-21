import 'package:equatable/equatable.dart';

import '../../../data/dto/create_villa_type_config_dto.dart';
import '../../../data/dto/update_villa_type_config_dto.dart';

abstract class VillaTypeConfigEvent extends Equatable {
  const VillaTypeConfigEvent();

  @override
  List<Object?> get props => [];
}

class LoadVillaTypeConfigList extends VillaTypeConfigEvent {
  const LoadVillaTypeConfigList({this.includeInactive = false});

  final bool includeInactive;

  @override
  List<Object?> get props => [includeInactive];
}

class LoadVillaTypeConfigById extends VillaTypeConfigEvent {
  const LoadVillaTypeConfigById(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateVillaTypeConfig extends VillaTypeConfigEvent {
  const CreateVillaTypeConfig(this.dto);

  final CreateVillaTypeConfigDto dto;

  @override
  List<Object?> get props => [dto];
}

class UpdateVillaTypeConfig extends VillaTypeConfigEvent {
  const UpdateVillaTypeConfig(this.id, this.dto);

  final String id;
  final UpdateVillaTypeConfigDto dto;

  @override
  List<Object?> get props => [id, dto];
}

class DeleteVillaTypeConfig extends VillaTypeConfigEvent {
  const DeleteVillaTypeConfig(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ActivateVillaTypeConfig extends VillaTypeConfigEvent {
  const ActivateVillaTypeConfig(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class DeactivateVillaTypeConfig extends VillaTypeConfigEvent {
  const DeactivateVillaTypeConfig(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

