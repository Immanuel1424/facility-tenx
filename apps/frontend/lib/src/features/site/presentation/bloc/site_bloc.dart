import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/site_repository_interface.dart';
import 'site_event.dart';
import 'site_state.dart';

class SiteBloc extends Bloc<SiteEvent, SiteState> {
  SiteBloc({
    required SiteRepositoryInterface repository,
  })  : _repository = repository,
        super(const SiteInitial()) {
    on<LoadSiteList>(_onLoadList);
    on<LoadSiteDetail>(_onLoadDetail);
    on<CreateSite>(_onCreate);
    on<UpdateSite>(_onUpdate);
    on<DeleteSite>(_onDelete);
  }

  final SiteRepositoryInterface _repository;

  Future<void> _onLoadList(
    LoadSiteList event,
    Emitter<SiteState> emit,
  ) async {
    emit(const SiteLoading());

    final result = await _repository.getSites(companyId: event.companyId);

    result.fold(
      (error) => emit(SiteError(_getErrorMessage(error))),
      (sites) => emit(SiteListLoaded(sites)),
    );
  }

  Future<void> _onLoadDetail(
    LoadSiteDetail event,
    Emitter<SiteState> emit,
  ) async {
    emit(const SiteLoading());

    final result = await _repository.getSiteById(event.id);

    result.fold(
      (error) => emit(SiteError(_getErrorMessage(error))),
      (site) => emit(SiteDetailLoaded(site)),
    );
  }

  Future<void> _onCreate(
    CreateSite event,
    Emitter<SiteState> emit,
  ) async {
    emit(const SiteLoading());

    final result = await _repository.createSite(
      name: event.name,
      isParent: event.isParent,
      code: event.code,
      parentSiteId: event.parentSiteId,
      createAdmin: event.createAdmin,
      adminEmail: event.adminEmail,
      adminPassword: event.adminPassword,
      adminFirstName: event.adminFirstName,
      adminLastName: event.adminLastName,
      companyId: event.companyId,
    );

    result.fold(
      (error) => emit(SiteError(_getErrorMessage(error))),
      (site) => emit(SiteCreated(site)),
    );
  }

  Future<void> _onUpdate(
    UpdateSite event,
    Emitter<SiteState> emit,
  ) async {
    emit(const SiteLoading());

    final result = await _repository.updateSite(
      event.id,
      code: event.code,
      name: event.name,
      description: event.description,
      address: event.address,
      city: event.city,
      country: event.country,
      isParent: event.isParent,
      isActive: event.isActive,
      parentSiteId: event.parentSiteId,
    );

    result.fold(
      (error) => emit(SiteError(_getErrorMessage(error))),
      (site) => emit(SiteUpdated(site)),
    );
  }

  Future<void> _onDelete(
    DeleteSite event,
    Emitter<SiteState> emit,
  ) async {
    emit(const SiteLoading());

    final result = await _repository.deleteSite(event.id);

    result.fold(
      (error) => emit(SiteError(_getErrorMessage(error))),
      (_) => emit(const SiteDeleted()),
    );
  }

  String _getErrorMessage(Exception error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

