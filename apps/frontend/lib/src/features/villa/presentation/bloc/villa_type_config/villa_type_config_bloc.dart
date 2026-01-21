import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/villa_type_config_repository.dart';
import 'villa_type_config_event.dart';
import 'villa_type_config_state.dart';

class VillaTypeConfigBloc
    extends Bloc<VillaTypeConfigEvent, VillaTypeConfigState> {
  VillaTypeConfigBloc({
    required VillaTypeConfigRepository repository,
  })  : _repository = repository,
        super(const VillaTypeConfigInitial()) {
    on<LoadVillaTypeConfigList>(_onLoadList);
    on<LoadVillaTypeConfigById>(_onLoadById);
    on<CreateVillaTypeConfig>(_onCreate);
    on<UpdateVillaTypeConfig>(_onUpdate);
    on<DeleteVillaTypeConfig>(_onDelete);
    on<ActivateVillaTypeConfig>(_onActivate);
    on<DeactivateVillaTypeConfig>(_onDeactivate);
  }

  final VillaTypeConfigRepository _repository;

  Future<void> _onLoadList(
    LoadVillaTypeConfigList event,
    Emitter<VillaTypeConfigState> emit,
  ) async {
    emit(const VillaTypeConfigLoading());
    final result = await _repository.getAll(
      includeInactive: event.includeInactive,
    );
    result.fold(
      (error) => emit(VillaTypeConfigError(error.toString())),
      (configs) => emit(VillaTypeConfigListLoaded(configs)),
    );
  }

  Future<void> _onLoadById(
    LoadVillaTypeConfigById event,
    Emitter<VillaTypeConfigState> emit,
  ) async {
    emit(const VillaTypeConfigLoading());
    final result = await _repository.getById(event.id);
    result.fold(
      (error) => emit(VillaTypeConfigError(error.toString())),
      (config) => emit(VillaTypeConfigLoaded(config)),
    );
  }

  Future<void> _onCreate(
    CreateVillaTypeConfig event,
    Emitter<VillaTypeConfigState> emit,
  ) async {
    emit(const VillaTypeConfigLoading());
    final result = await _repository.create(event.dto);
    result.fold(
      (error) => emit(VillaTypeConfigError(error.toString())),
      (config) => emit(VillaTypeConfigCreated(config)),
    );
  }

  Future<void> _onUpdate(
    UpdateVillaTypeConfig event,
    Emitter<VillaTypeConfigState> emit,
  ) async {
    emit(const VillaTypeConfigLoading());
    final result = await _repository.update(event.id, event.dto);
    result.fold(
      (error) => emit(VillaTypeConfigError(error.toString())),
      (config) => emit(VillaTypeConfigUpdated(config)),
    );
  }

  Future<void> _onDelete(
    DeleteVillaTypeConfig event,
    Emitter<VillaTypeConfigState> emit,
  ) async {
    emit(const VillaTypeConfigLoading());
    final result = await _repository.delete(event.id);
    result.fold(
      (error) => emit(VillaTypeConfigError(error.toString())),
      (_) => emit(const VillaTypeConfigDeleted()),
    );
  }

  Future<void> _onActivate(
    ActivateVillaTypeConfig event,
    Emitter<VillaTypeConfigState> emit,
  ) async {
    emit(const VillaTypeConfigLoading());
    final result = await _repository.activate(event.id);
    result.fold(
      (error) => emit(VillaTypeConfigError(error.toString())),
      (config) => emit(VillaTypeConfigActivated(config)),
    );
  }

  Future<void> _onDeactivate(
    DeactivateVillaTypeConfig event,
    Emitter<VillaTypeConfigState> emit,
  ) async {
    emit(const VillaTypeConfigLoading());
    final result = await _repository.deactivate(event.id);
    result.fold(
      (error) => emit(VillaTypeConfigError(error.toString())),
      (config) => emit(VillaTypeConfigDeactivated(config)),
    );
  }
}

