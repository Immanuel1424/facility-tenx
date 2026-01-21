import 'package:equatable/equatable.dart';

abstract class SiteEvent extends Equatable {
  const SiteEvent();

  @override
  List<Object?> get props => [];
}

class LoadSiteList extends SiteEvent {
  const LoadSiteList({this.companyId});

  final String? companyId;

  @override
  List<Object?> get props => [companyId];
}

class LoadSiteDetail extends SiteEvent {
  const LoadSiteDetail(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateSite extends SiteEvent {
  const CreateSite({
    required this.name,
    required this.isParent,
    this.code,
    this.parentSiteId,
    this.createAdmin,
    this.adminEmail,
    this.adminPassword,
    this.adminFirstName,
    this.adminLastName,
    this.companyId,
  });

  final String? code;
  final String name;
  final bool isParent;
  final String? parentSiteId;
  final bool? createAdmin;
  final String? adminEmail;
  final String? adminPassword;
  final String? adminFirstName;
  final String? adminLastName;
  final String? companyId;

  @override
  List<Object?> get props => [
        code,
        name,
        isParent,
        parentSiteId,
        createAdmin,
        adminEmail,
        adminPassword,
        adminFirstName,
        adminLastName,
        companyId,
      ];
}

class UpdateSite extends SiteEvent {
  const UpdateSite({
    required this.id,
    this.code,
    this.name,
    this.description,
    this.address,
    this.city,
    this.country,
    this.isParent,
    this.isActive,
    this.parentSiteId,
  });

  final String id;
  final String? code;
  final String? name;
  final String? description;
  final String? address;
  final String? city;
  final String? country;
  final bool? isParent;
  final bool? isActive;
  final String? parentSiteId;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        address,
        city,
        country,
        isParent,
        isActive,
        parentSiteId,
      ];
}

class DeleteSite extends SiteEvent {
  const DeleteSite(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

