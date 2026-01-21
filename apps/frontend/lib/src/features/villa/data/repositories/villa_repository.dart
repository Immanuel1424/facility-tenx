import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/villa_dto.dart';
import '../mappers/villa_mapper.dart';
import '../../domain/repositories/villa_repository_interface.dart';
import '../../domain/entities/villa_entity.dart';

class VillaRepository implements VillaRepositoryInterface {
  VillaRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Either<Exception, List<VillaEntity>>> getVillas() async {
    try {
      final dtos = await _apiClient.getVillasList();
      final entities = VillaMapper.toEntityList(dtos);
      // Sort by createdAt descending (newest first)
      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<VillaEntity>>> getActiveVillas() async {
    try {
      final dtos = await _apiClient.getActiveVillasList();
      final entities = VillaMapper.toEntityList(dtos);
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, List<VillaEntity>>> getAvailableVillas() async {
    try {
      final dtos = await _apiClient.getAvailableVillasList();
      final entities = VillaMapper.toEntityList(dtos);
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, VillaEntity>> getVilla(String id) async {
    try {
      final dto = await _apiClient.getVillaById(id);
      final entity = VillaMapper.toEntity(dto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, VillaEntity>> createVilla({
    required String villaNumber,
    String? villaCode,
    String? siteId,
    String? spaceId,
    String? ownerName,
    String? tenantName,
    String? contactPhone,
    String? contactEmail,
    String? block,
    String? street,
    String? city,
    String? pinCode,
    String? makaniNumber,
    String? poBox,
    bool? isActive,
    bool? isOccupied,
    int? floorCount,
    int? bedroomCount,
    int? bathroomCount,
    double? areaSqm,
    String? villaType,
    String? buildingName,
    DateTime? openFrom,
    String? unitNo,
    String? unitName,
    String? primaryView,
    String? unitCategory,
    String? floor,
    String? parkingSlotNumber,
    String? meterNumber,
    String? waterMeterNumber,
    String? measure,
    String? externalArea,
    String? remarks,
  }) async {
    try {
      final dto = CreateVillaDto(
        villaNumber: villaNumber,
        villaCode: villaCode,
        siteId: siteId,
        spaceId: spaceId,
        ownerName: ownerName,
        tenantName: tenantName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        block: block,
        street: street,
        city: city,
        pinCode: pinCode,
        makaniNumber: makaniNumber,
        poBox: poBox,
        isActive: isActive,
        isOccupied: isOccupied,
        floorCount: floorCount,
        bedroomCount: bedroomCount,
        bathroomCount: bathroomCount,
        areaSqm: areaSqm,
        villaType: villaType,
        buildingName: buildingName,
        openFrom: openFrom,
        unitNo: unitNo,
        unitName: unitName,
        primaryView: primaryView,
        unitCategory: unitCategory,
        floor: floor,
        parkingSlotNumber: parkingSlotNumber,
        meterNumber: meterNumber,
        waterMeterNumber: waterMeterNumber,
        measure: measure,
        externalArea: externalArea,
        remarks: remarks,
      );
      final createdDto = await _apiClient.createVilla(dto);
      final entity = VillaMapper.toEntity(createdDto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, VillaEntity>> updateVilla({
    required String id,
    String? villaNumber,
    String? villaCode,
    String? siteId,
    String? spaceId,
    String? ownerName,
    String? tenantName,
    String? contactPhone,
    String? contactEmail,
    String? block,
    String? street,
    String? city,
    String? pinCode,
    String? makaniNumber,
    String? poBox,
    bool? isActive,
    bool? isOccupied,
    int? floorCount,
    int? bedroomCount,
    int? bathroomCount,
    double? areaSqm,
    String? villaType,
    String? buildingName,
    DateTime? openFrom,
    String? unitNo,
    String? unitName,
    String? primaryView,
    String? unitCategory,
    String? floor,
    String? parkingSlotNumber,
    String? meterNumber,
    String? waterMeterNumber,
    String? measure,
    String? externalArea,
    String? remarks,
  }) async {
    try {
      final dto = UpdateVillaDto(
        villaNumber: villaNumber,
        villaCode: villaCode,
        siteId: siteId,
        spaceId: spaceId,
        ownerName: ownerName,
        tenantName: tenantName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        block: block,
        street: street,
        city: city,
        pinCode: pinCode,
        makaniNumber: makaniNumber,
        poBox: poBox,
        isActive: isActive,
        isOccupied: isOccupied,
        floorCount: floorCount,
        bedroomCount: bedroomCount,
        bathroomCount: bathroomCount,
        areaSqm: areaSqm,
        villaType: villaType,
        buildingName: buildingName,
        openFrom: openFrom,
        unitNo: unitNo,
        unitName: unitName,
        primaryView: primaryView,
        unitCategory: unitCategory,
        floor: floor,
        parkingSlotNumber: parkingSlotNumber,
        meterNumber: meterNumber,
        waterMeterNumber: waterMeterNumber,
        measure: measure,
        externalArea: externalArea,
        remarks: remarks,
      );
      final updatedDto = await _apiClient.updateVilla(id, dto);
      final entity = VillaMapper.toEntity(updatedDto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> deleteVilla(String id) async {
    try {
      await _apiClient.deleteVilla(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, VillaEntity>> activateVilla(String id) async {
    try {
      final dto = await _apiClient.activateVilla(id);
      final entity = VillaMapper.toEntity(dto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, VillaEntity>> deactivateVilla(String id) async {
    try {
      final dto = await _apiClient.deactivateVilla(id);
      final entity = VillaMapper.toEntity(dto);
      return Right(entity);
    } on Exception catch (e) {
      return Left(e);
    }
  }
}

