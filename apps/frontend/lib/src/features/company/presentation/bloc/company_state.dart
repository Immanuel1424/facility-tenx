import 'package:equatable/equatable.dart';

import '../../domain/entities/company_entity.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<CompanyEntity> companies) listLoaded,
    required T Function(CompanyEntity company) detailLoaded,
    required T Function(CompanyEntity company) created,
    required T Function(CompanyEntity company) updated,
    required T Function() deleted,
    required T Function(String message) error,
  }) {
    if (this is CompanyInitial) {
      return initial();
    } else if (this is CompanyLoading) {
      return loading();
    } else if (this is CompanyListLoaded) {
      return listLoaded((this as CompanyListLoaded).companies);
    } else if (this is CompanyDetailLoaded) {
      return detailLoaded((this as CompanyDetailLoaded).company);
    } else if (this is CompanyCreated) {
      return created((this as CompanyCreated).company);
    } else if (this is CompanyUpdated) {
      return updated((this as CompanyUpdated).company);
    } else if (this is CompanyDeleted) {
      return deleted();
    } else if (this is CompanyError) {
      return error((this as CompanyError).message);
    }
    throw Exception('Unknown CompanyState');
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<CompanyEntity> companies)? listLoaded,
    T Function(CompanyEntity company)? detailLoaded,
    T Function(CompanyEntity company)? created,
    T Function(CompanyEntity company)? updated,
    T Function()? deleted,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is CompanyInitial && initial != null) {
      return initial();
    } else if (this is CompanyLoading && loading != null) {
      return loading();
    } else if (this is CompanyListLoaded && listLoaded != null) {
      return listLoaded((this as CompanyListLoaded).companies);
    } else if (this is CompanyDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as CompanyDetailLoaded).company);
    } else if (this is CompanyCreated && created != null) {
      return created((this as CompanyCreated).company);
    } else if (this is CompanyUpdated && updated != null) {
      return updated((this as CompanyUpdated).company);
    } else if (this is CompanyDeleted && deleted != null) {
      return deleted();
    } else if (this is CompanyError && error != null) {
      return error((this as CompanyError).message);
    }
    return orElse();
  }
}

class CompanyInitial extends CompanyState {
  const CompanyInitial();
}

class CompanyLoading extends CompanyState {
  const CompanyLoading();
}

class CompanyListLoaded extends CompanyState {
  const CompanyListLoaded(this.companies);

  final List<CompanyEntity> companies;

  @override
  List<Object?> get props => [companies];
}

class CompanyDetailLoaded extends CompanyState {
  const CompanyDetailLoaded(this.company);

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}

class CompanyCreated extends CompanyState {
  const CompanyCreated(this.company);

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}

class CompanyUpdated extends CompanyState {
  const CompanyUpdated(this.company);

  final CompanyEntity company;

  @override
  List<Object?> get props => [company];
}

class CompanyDeleted extends CompanyState {
  const CompanyDeleted();
}

class CompanyError extends CompanyState {
  const CompanyError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

