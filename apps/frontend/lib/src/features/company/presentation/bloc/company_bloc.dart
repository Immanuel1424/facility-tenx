import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/company_repository_interface.dart';
import 'company_event.dart';
import 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc({
    required CompanyRepositoryInterface repository,
  })  : _repository = repository,
        super(const CompanyInitial()) {
    on<LoadCompanyList>(_onLoadList);
    on<LoadCompanyDetail>(_onLoadDetail);
    on<CreateCompany>(_onCreate);
    on<UpdateCompany>(_onUpdate);
    on<DeleteCompany>(_onDelete);
  }

  final CompanyRepositoryInterface _repository;

  Future<void> _onLoadList(
    LoadCompanyList event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());

    final result = await _repository.getCompanies();

    result.fold(
      (error) => emit(CompanyError(_getErrorMessage(error))),
      (companies) => emit(CompanyListLoaded(companies)),
    );
  }

  Future<void> _onLoadDetail(
    LoadCompanyDetail event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());

    final result = await _repository.getCompany(event.id);

    result.fold(
      (error) => emit(CompanyError(_getErrorMessage(error))),
      (company) => emit(CompanyDetailLoaded(company)),
    );
  }

  Future<void> _onCreate(
    CreateCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());

    final result = await _repository.createCompany(
      code: event.code,
      name: event.name,
      description: event.description,
      logoUrl: event.logoUrl,
      timezone: event.timezone,
      currency: event.currency,
      isActive: event.isActive,
    );

    result.fold(
      (error) => emit(CompanyError(_getErrorMessage(error))),
      (company) => emit(CompanyCreated(company)),
    );
  }

  Future<void> _onUpdate(
    UpdateCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());

    final result = await _repository.updateCompany(
      event.id,
      code: event.code,
      name: event.name,
      description: event.description,
      logoUrl: event.logoUrl,
      timezone: event.timezone,
      currency: event.currency,
      isActive: event.isActive,
    );

    result.fold(
      (error) => emit(CompanyError(_getErrorMessage(error))),
      (company) => emit(CompanyUpdated(company)),
    );
  }

  Future<void> _onDelete(
    DeleteCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());

    final result = await _repository.deleteCompany(event.id);

    result.fold(
      (error) => emit(CompanyError(_getErrorMessage(error))),
      (_) => emit(const CompanyDeleted()),
    );
  }

  String _getErrorMessage(Exception error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

