import 'package:equatable/equatable.dart';

import '../../../domain/entities/villa_type_config_entity.dart';

abstract class VillaTypeConfigState extends Equatable {
  const VillaTypeConfigState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<VillaTypeConfigEntity> configs) listLoaded,
    required T Function(VillaTypeConfigEntity config) loaded,
    required T Function(VillaTypeConfigEntity config) created,
    required T Function(VillaTypeConfigEntity config) updated,
    required T Function() deleted,
    required T Function(VillaTypeConfigEntity config) activated,
    required T Function(VillaTypeConfigEntity config) deactivated,
    required T Function(String message) error,
  }) {
    if (this is VillaTypeConfigInitial) {
      return initial();
    } else if (this is VillaTypeConfigLoading) {
      return loading();
    } else if (this is VillaTypeConfigListLoaded) {
      return listLoaded((this as VillaTypeConfigListLoaded).configs);
    } else if (this is VillaTypeConfigLoaded) {
      return loaded((this as VillaTypeConfigLoaded).config);
    } else if (this is VillaTypeConfigCreated) {
      return created((this as VillaTypeConfigCreated).config);
    } else if (this is VillaTypeConfigUpdated) {
      return updated((this as VillaTypeConfigUpdated).config);
    } else if (this is VillaTypeConfigDeleted) {
      return deleted();
    } else if (this is VillaTypeConfigActivated) {
      return activated((this as VillaTypeConfigActivated).config);
    } else if (this is VillaTypeConfigDeactivated) {
      return deactivated((this as VillaTypeConfigDeactivated).config);
    } else if (this is VillaTypeConfigError) {
      return error((this as VillaTypeConfigError).message);
    }
    throw Exception('Unknown VillaTypeConfigState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<VillaTypeConfigEntity> configs)? listLoaded,
    T Function(VillaTypeConfigEntity config)? loaded,
    T Function(VillaTypeConfigEntity config)? created,
    T Function(VillaTypeConfigEntity config)? updated,
    T Function()? deleted,
    T Function(VillaTypeConfigEntity config)? activated,
    T Function(VillaTypeConfigEntity config)? deactivated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is VillaTypeConfigInitial && initial != null) {
      return initial();
    } else if (this is VillaTypeConfigLoading && loading != null) {
      return loading();
    } else if (this is VillaTypeConfigListLoaded && listLoaded != null) {
      return listLoaded((this as VillaTypeConfigListLoaded).configs);
    } else if (this is VillaTypeConfigLoaded && loaded != null) {
      return loaded((this as VillaTypeConfigLoaded).config);
    } else if (this is VillaTypeConfigCreated && created != null) {
      return created((this as VillaTypeConfigCreated).config);
    } else if (this is VillaTypeConfigUpdated && updated != null) {
      return updated((this as VillaTypeConfigUpdated).config);
    } else if (this is VillaTypeConfigDeleted && deleted != null) {
      return deleted();
    } else if (this is VillaTypeConfigActivated && activated != null) {
      return activated((this as VillaTypeConfigActivated).config);
    } else if (this is VillaTypeConfigDeactivated && deactivated != null) {
      return deactivated((this as VillaTypeConfigDeactivated).config);
    } else if (this is VillaTypeConfigError && error != null) {
      return error((this as VillaTypeConfigError).message);
    }
    return orElse();
  }
}

class VillaTypeConfigInitial extends VillaTypeConfigState {
  const VillaTypeConfigInitial();
}

class VillaTypeConfigLoading extends VillaTypeConfigState {
  const VillaTypeConfigLoading();
}

class VillaTypeConfigListLoaded extends VillaTypeConfigState {
  const VillaTypeConfigListLoaded(this.configs);

  final List<VillaTypeConfigEntity> configs;

  @override
  List<Object?> get props => [configs];
}

class VillaTypeConfigLoaded extends VillaTypeConfigState {
  const VillaTypeConfigLoaded(this.config);

  final VillaTypeConfigEntity config;

  @override
  List<Object?> get props => [config];
}

class VillaTypeConfigCreated extends VillaTypeConfigState {
  const VillaTypeConfigCreated(this.config);

  final VillaTypeConfigEntity config;

  @override
  List<Object?> get props => [config];
}

class VillaTypeConfigUpdated extends VillaTypeConfigState {
  const VillaTypeConfigUpdated(this.config);

  final VillaTypeConfigEntity config;

  @override
  List<Object?> get props => [config];
}

class VillaTypeConfigDeleted extends VillaTypeConfigState {
  const VillaTypeConfigDeleted();
}

class VillaTypeConfigActivated extends VillaTypeConfigState {
  const VillaTypeConfigActivated(this.config);

  final VillaTypeConfigEntity config;

  @override
  List<Object?> get props => [config];
}

class VillaTypeConfigDeactivated extends VillaTypeConfigState {
  const VillaTypeConfigDeactivated(this.config);

  final VillaTypeConfigEntity config;

  @override
  List<Object?> get props => [config];
}

class VillaTypeConfigError extends VillaTypeConfigState {
  const VillaTypeConfigError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
