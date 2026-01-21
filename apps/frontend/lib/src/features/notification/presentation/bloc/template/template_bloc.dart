import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/notification_repository.dart';
import '../../../data/dto/notification_template_dto.dart';
import 'template_event.dart';
import 'template_state.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(const TemplateInitial()) {
    on<LoadEmailTemplates>(_onLoadEmailTemplates);
    on<LoadTemplate>(_onLoadTemplate);
    on<UpdateTemplate>(_onUpdateTemplate);
    on<SeedEmailTemplates>(_onSeedEmailTemplates);
  }

  final NotificationRepository _repository;

  Future<void> _onLoadEmailTemplates(
    LoadEmailTemplates event,
    Emitter<TemplateState> emit,
  ) async {
    emit(const TemplateLoading());

    final result = await _repository.getEmailTemplates();

    result.fold(
      (Exception error) => emit(TemplateError(error.toString())),
      (List<NotificationTemplateDto> templates) =>
          emit(TemplateListLoaded(templates)),
    );
  }

  Future<void> _onLoadTemplate(
    LoadTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(const TemplateLoading());

    final result = await _repository.getTemplate(event.id);

    result.fold(
      (Exception error) => emit(TemplateError(error.toString())),
      (NotificationTemplateDto template) => emit(TemplateLoaded(template)),
    );
  }

  Future<void> _onUpdateTemplate(
    UpdateTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(const TemplateLoading());

    final result = await _repository.updateTemplate(event.id, event.template);

    result.fold(
      (Exception error) => emit(TemplateError(error.toString())),
      (NotificationTemplateDto template) {
        emit(TemplateUpdated(template));
        // Reload list to update UI
        add(const LoadEmailTemplates());
      },
    );
  }

  Future<void> _onSeedEmailTemplates(
    SeedEmailTemplates event,
    Emitter<TemplateState> emit,
  ) async {
    emit(const TemplateLoading());

    final result = await _repository.seedEmailTemplates();

    result.fold(
      (Exception error) => emit(TemplateError(error.toString())),
      (void _) {
        // Reload templates after seeding
        add(const LoadEmailTemplates());
      },
    );
  }
}
