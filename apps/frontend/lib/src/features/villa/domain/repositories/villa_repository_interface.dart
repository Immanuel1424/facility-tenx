import 'package:fpdart/fpdart.dart';

import '../entities/villa_entity.dart';

abstract class VillaRepositoryInterface {
  Future<Either<Exception, List<VillaEntity>>> getVillas();
  Future<Either<Exception, List<VillaEntity>>> getActiveVillas();
  Future<Either<Exception, VillaEntity>> getVilla(String id);
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
  });
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
  });
  Future<Either<Exception, void>> deleteVilla(String id);
  Future<Either<Exception, VillaEntity>> activateVilla(String id);
  Future<Either<Exception, VillaEntity>> deactivateVilla(String id);
}

