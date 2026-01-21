import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/villa_repository_interface.dart';
import '../../data/repositories/villa_repository.dart';
import 'villa_event.dart';
import 'villa_state.dart';

class VillaBloc extends Bloc<VillaEvent, VillaState> {
  VillaBloc({
    required VillaRepositoryInterface repository,
  })  : _repository = repository,
        super(const VillaInitial()) {
    on<LoadVillaList>(_onLoadList);
    on<LoadActiveVillaList>(_onLoadActiveList);
    on<LoadAvailableVillaList>(_onLoadAvailableList);
    on<LoadVillaDetail>(_onLoadDetail);
    on<CreateVilla>(_onCreate);
    on<UpdateVilla>(_onUpdate);
    on<DeleteVilla>(_onDelete);
    on<ActivateVilla>(_onActivate);
    on<DeactivateVilla>(_onDeactivate);
  }

  final VillaRepositoryInterface _repository;

  Future<void> _onLoadList(
    LoadVillaList event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.getVillas();

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (villas) => emit(VillaListLoaded(villas)),
    );
  }

  Future<void> _onLoadActiveList(
    LoadActiveVillaList event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.getActiveVillas();

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (villas) => emit(VillaListLoaded(villas)),
    );
  }

  Future<void> _onLoadAvailableList(
    LoadAvailableVillaList event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    // Check if repository has getAvailableVillas method
    if (_repository is VillaRepository) {
      final repository = _repository as VillaRepository;
      final result = await repository.getAvailableVillas();
      
      result.fold(
        (error) => emit(VillaError(_getErrorMessage(error))),
        (villas) => emit(VillaListLoaded(villas)),
      );
    } else {
      // Fallback to getActiveVillas if method not available
      final result = await _repository.getActiveVillas();
      result.fold(
        (error) => emit(VillaError(_getErrorMessage(error))),
        (villas) => emit(VillaListLoaded(villas)),
      );
    }
  }

  Future<void> _onLoadDetail(
    LoadVillaDetail event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.getVilla(event.id);

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (villa) => emit(VillaDetailLoaded(villa)),
    );
  }

  Future<void> _onCreate(
    CreateVilla event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.createVilla(
      villaNumber: event.villaNumber,
      villaCode: event.villaCode,
      siteId: event.siteId,
      spaceId: event.spaceId,
      ownerName: event.ownerName,
      tenantName: event.tenantName,
      contactPhone: event.contactPhone,
      contactEmail: event.contactEmail,
      block: event.block,
      street: event.street,
      city: event.city,
      pinCode: event.pinCode,
      makaniNumber: event.makaniNumber,
      poBox: event.poBox,
      isActive: event.isActive,
      isOccupied: event.isOccupied,
      floorCount: event.floorCount,
      bedroomCount: event.bedroomCount,
      bathroomCount: event.bathroomCount,
      areaSqm: event.areaSqm,
      villaType: event.villaType,
      buildingName: event.buildingName,
      openFrom: event.openFrom,
      unitNo: event.unitNo,
      unitName: event.unitName,
      primaryView: event.primaryView,
      unitCategory: event.unitCategory,
      floor: event.floor,
      parkingSlotNumber: event.parkingSlotNumber,
      meterNumber: event.meterNumber,
      waterMeterNumber: event.waterMeterNumber,
      measure: event.measure,
      externalArea: event.externalArea,
      remarks: event.remarks,
    );

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (villa) => emit(VillaCreated(villa)),
    );
  }

  Future<void> _onUpdate(
    UpdateVilla event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.updateVilla(
      id: event.id,
      villaNumber: event.villaNumber,
      villaCode: event.villaCode,
      siteId: event.siteId,
      spaceId: event.spaceId,
      ownerName: event.ownerName,
      tenantName: event.tenantName,
      contactPhone: event.contactPhone,
      contactEmail: event.contactEmail,
      block: event.block,
      street: event.street,
      city: event.city,
      pinCode: event.pinCode,
      makaniNumber: event.makaniNumber,
      poBox: event.poBox,
      isActive: event.isActive,
      isOccupied: event.isOccupied,
      floorCount: event.floorCount,
      bedroomCount: event.bedroomCount,
      bathroomCount: event.bathroomCount,
      areaSqm: event.areaSqm,
      villaType: event.villaType,
      buildingName: event.buildingName,
      openFrom: event.openFrom,
      unitNo: event.unitNo,
      unitName: event.unitName,
      primaryView: event.primaryView,
      unitCategory: event.unitCategory,
      floor: event.floor,
      parkingSlotNumber: event.parkingSlotNumber,
      meterNumber: event.meterNumber,
      waterMeterNumber: event.waterMeterNumber,
      measure: event.measure,
      externalArea: event.externalArea,
      remarks: event.remarks,
    );

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (villa) => emit(VillaUpdated(villa)),
    );
  }

  Future<void> _onDelete(
    DeleteVilla event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.deleteVilla(event.id);

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (_) => emit(const VillaDeleted()),
    );
  }

  Future<void> _onActivate(
    ActivateVilla event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.activateVilla(event.id);

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (villa) => emit(VillaActivated(villa)),
    );
  }

  Future<void> _onDeactivate(
    DeactivateVilla event,
    Emitter<VillaState> emit,
  ) async {
    emit(const VillaLoading());

    final result = await _repository.deactivateVilla(event.id);

    result.fold(
      (error) => emit(VillaError(_getErrorMessage(error))),
      (villa) => emit(VillaDeactivated(villa)),
    );
  }

  String _getErrorMessage(Exception error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

