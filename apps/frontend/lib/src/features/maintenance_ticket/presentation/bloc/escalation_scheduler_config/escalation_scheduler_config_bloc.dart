import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/escalation_scheduler_config_repository_interface.dart';
import 'escalation_scheduler_config_event.dart';
import 'escalation_scheduler_config_state.dart';

class EscalationSchedulerConfigBloc
    extends Bloc<EscalationSchedulerConfigEvent, EscalationSchedulerConfigState> {
  EscalationSchedulerConfigBloc({
    required EscalationSchedulerConfigRepositoryInterface repository,
  })  : _repository = repository,
        super(const EscalationSchedulerConfigInitial()) {
    on<LoadEscalationSchedulerConfig>(_onLoadConfig);
    on<UpdateEscalationSchedulerConfig>(_onUpdateConfig);
  }

  final EscalationSchedulerConfigRepositoryInterface _repository;

  Future<void> _onLoadConfig(
    LoadEscalationSchedulerConfig event,
    Emitter<EscalationSchedulerConfigState> emit,
  ) async {
    emit(const EscalationSchedulerConfigLoading());
    final result = await _repository.getConfig();
    result.fold(
      (error) => emit(EscalationSchedulerConfigError(error)),
      (config) => emit(EscalationSchedulerConfigLoaded(config)),
    );
  }

  Future<void> _onUpdateConfig(
    UpdateEscalationSchedulerConfig event,
    Emitter<EscalationSchedulerConfigState> emit,
  ) async {
    emit(const EscalationSchedulerConfigLoading());
    final result = await _repository.updateConfig(event.intervalMinutes);
    result.fold(
      (error) => emit(EscalationSchedulerConfigError(error)),
      (config) => emit(EscalationSchedulerConfigUpdated(config)),
    );
  }
}
