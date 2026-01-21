import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/sla_configuration_repository_interface.dart';
import 'sla_configuration_event.dart';
import 'sla_configuration_state.dart';

class SlaConfigurationBloc
    extends Bloc<SlaConfigurationEvent, SlaConfigurationState> {
  SlaConfigurationBloc({
    required SlaConfigurationRepositoryInterface repository,
  })  : _repository = repository,
        super(const SlaConfigurationInitial()) {
    on<LoadSlaConfigurationList>(_onLoadList);
    on<LoadActiveSlaConfigurationList>(_onLoadActiveList);
    on<LoadSlaConfigurationById>(_onLoadById);
    on<CreateSlaConfiguration>(_onCreate);
    on<UpdateSlaConfiguration>(_onUpdate);
    on<DeleteSlaConfiguration>(_onDelete);
  }

  final SlaConfigurationRepositoryInterface _repository;

  Future<void> _onLoadList(
    LoadSlaConfigurationList event,
    Emitter<SlaConfigurationState> emit,
  ) async {
    emit(const SlaConfigurationLoading());
    final result = await _repository.getAll();
    result.fold(
      (error) => emit(SlaConfigurationError(error)),
      (configurations) => emit(SlaConfigurationListLoaded(configurations)),
    );
  }

  Future<void> _onLoadActiveList(
    LoadActiveSlaConfigurationList event,
    Emitter<SlaConfigurationState> emit,
  ) async {
    emit(const SlaConfigurationLoading());
    final result = await _repository.getActive();
    result.fold(
      (error) => emit(SlaConfigurationError(error)),
      (configurations) => emit(SlaConfigurationListLoaded(configurations)),
    );
  }

  Future<void> _onLoadById(
    LoadSlaConfigurationById event,
    Emitter<SlaConfigurationState> emit,
  ) async {
    emit(const SlaConfigurationLoading());
    final result = await _repository.getById(event.id);
    result.fold(
      (error) => emit(SlaConfigurationError(error)),
      (configuration) => emit(SlaConfigurationLoaded(configuration)),
    );
  }

  Future<void> _onCreate(
    CreateSlaConfiguration event,
    Emitter<SlaConfigurationState> emit,
  ) async {
    emit(const SlaConfigurationLoading());
    final result = await _repository.create(event.configuration);
    result.fold(
      (error) => emit(SlaConfigurationError(error)),
      (configuration) => emit(SlaConfigurationCreated(configuration)),
    );
  }

  Future<void> _onUpdate(
    UpdateSlaConfiguration event,
    Emitter<SlaConfigurationState> emit,
  ) async {
    emit(const SlaConfigurationLoading());
    final result = await _repository.update(event.id, event.configuration);
    result.fold(
      (error) => emit(SlaConfigurationError(error)),
      (configuration) => emit(SlaConfigurationUpdated(configuration)),
    );
  }

  Future<void> _onDelete(
    DeleteSlaConfiguration event,
    Emitter<SlaConfigurationState> emit,
  ) async {
    emit(const SlaConfigurationLoading());
    final result = await _repository.delete(event.id);
    result.fold(
      (error) => emit(SlaConfigurationError(error)),
      (_) => emit(const SlaConfigurationDeleted()),
    );
  }
}
