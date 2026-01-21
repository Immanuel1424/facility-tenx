import 'package:equatable/equatable.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompanyList extends CompanyEvent {
  const LoadCompanyList();
}

class LoadCompanyDetail extends CompanyEvent {
  const LoadCompanyDetail(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateCompany extends CompanyEvent {
  const CreateCompany({
    required this.code,
    required this.name,
    this.description,
    this.logoUrl,
    this.timezone,
    this.currency,
    this.isActive,
  });

  final String code;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? timezone;
  final String? currency;
  final bool? isActive;

  @override
  List<Object?> get props => [
        code,
        name,
        description,
        logoUrl,
        timezone,
        currency,
        isActive,
      ];
}

class UpdateCompany extends CompanyEvent {
  const UpdateCompany({
    required this.id,
    this.code,
    this.name,
    this.description,
    this.logoUrl,
    this.timezone,
    this.currency,
    this.isActive,
  });

  final String id;
  final String? code;
  final String? name;
  final String? description;
  final String? logoUrl;
  final String? timezone;
  final String? currency;
  final bool? isActive;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        logoUrl,
        timezone,
        currency,
        isActive,
      ];
}

class DeleteCompany extends CompanyEvent {
  const DeleteCompany(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

