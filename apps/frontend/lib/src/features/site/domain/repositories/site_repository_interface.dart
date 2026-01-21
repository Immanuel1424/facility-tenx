import 'package:fpdart/fpdart.dart';
import '../../domain/entities/site_entity.dart';

abstract class SiteRepositoryInterface {
  Future<Either<Exception, List<SiteEntity>>> getSites({String? companyId});
  Future<Either<Exception, SiteEntity>> getSiteById(String id);
  Future<Either<Exception, SiteEntity>> createSite({
    required String name,
    required bool isParent,
    String? code,
    String? parentSiteId,
    bool? createAdmin,
    String? adminEmail,
    String? adminPassword,
    String? adminFirstName,
    String? adminLastName,
    String? companyId,
  });
  Future<Either<Exception, SiteEntity>> updateSite(
    String id, {
    String? code,
    String? name,
    String? description,
    String? address,
    String? city,
    String? country,
    bool? isParent,
    bool? isActive,
    String? parentSiteId,
  });
  Future<Either<Exception, void>> deleteSite(String id);
}

