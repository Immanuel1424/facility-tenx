import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/ticket_category_repository.dart';
import 'ticket_category_event.dart';
import 'ticket_category_state.dart';

class TicketCategoryBloc
    extends Bloc<TicketCategoryEvent, TicketCategoryState> {
  TicketCategoryBloc({
    required TicketCategoryRepository repository,
  })  : _repository = repository,
        super(const TicketCategoryInitial()) {
    on<LoadTicketCategoryList>(_onLoadList);
    on<LoadTicketCategoryById>(_onLoadById);
    on<CreateTicketCategory>(_onCreate);
    on<UpdateTicketCategory>(_onUpdate);
    on<DeleteTicketCategory>(_onDelete);
    on<ActivateTicketCategory>(_onActivate);
    on<DeactivateTicketCategory>(_onDeactivate);
  }

  final TicketCategoryRepository _repository;

  Future<void> _onLoadList(
    LoadTicketCategoryList event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    final result = await _repository.getAll(activeOnly: event.activeOnly);
    result.fold(
      (error) => emit(TicketCategoryError(error.toString())),
      (categories) => emit(TicketCategoryListLoaded(categories)),
    );
  }

  Future<void> _onLoadById(
    LoadTicketCategoryById event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    final result = await _repository.getById(event.id);
    result.fold(
      (error) => emit(TicketCategoryError(error.toString())),
      (category) => emit(TicketCategoryLoaded(category)),
    );
  }

  Future<void> _onCreate(
    CreateTicketCategory event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    final result = await _repository.create(event.dto);
    result.fold(
      (error) => emit(TicketCategoryError(error.toString())),
      (category) => emit(TicketCategoryCreated(category)),
    );
  }

  Future<void> _onUpdate(
    UpdateTicketCategory event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    final result = await _repository.update(event.id, event.dto);
    result.fold(
      (error) => emit(TicketCategoryError(error.toString())),
      (category) => emit(TicketCategoryUpdated(category)),
    );
  }

  Future<void> _onDelete(
    DeleteTicketCategory event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    final result = await _repository.delete(event.id);
    result.fold(
      (error) => emit(TicketCategoryError(error.toString())),
      (_) => emit(const TicketCategoryDeleted()),
    );
  }

  Future<void> _onActivate(
    ActivateTicketCategory event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    final result = await _repository.activate(event.id);
    result.fold(
      (error) => emit(TicketCategoryError(error.toString())),
      (category) => emit(TicketCategoryActivated(category)),
    );
  }

  Future<void> _onDeactivate(
    DeactivateTicketCategory event,
    Emitter<TicketCategoryState> emit,
  ) async {
    emit(const TicketCategoryLoading());
    final result = await _repository.deactivate(event.id);
    result.fold(
      (error) => emit(TicketCategoryError(error.toString())),
      (category) => emit(TicketCategoryDeactivated(category)),
    );
  }
}

