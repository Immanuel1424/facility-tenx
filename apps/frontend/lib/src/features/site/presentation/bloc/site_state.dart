import 'package:equatable/equatable.dart';

import '../../domain/entities/site_entity.dart';

abstract class SiteState extends Equatable {
  const SiteState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<SiteEntity> sites) listLoaded,
    required T Function(SiteEntity site) detailLoaded,
    required T Function(SiteEntity site) created,
    required T Function(SiteEntity site) updated,
    required T Function() deleted,
    required T Function(String message) error,
  }) {
    if (this is SiteInitial) {
      return initial();
    } else if (this is SiteLoading) {
      return loading();
    } else if (this is SiteListLoaded) {
      return listLoaded((this as SiteListLoaded).sites);
    } else if (this is SiteDetailLoaded) {
      return detailLoaded((this as SiteDetailLoaded).site);
    } else if (this is SiteCreated) {
      return created((this as SiteCreated).site);
    } else if (this is SiteUpdated) {
      return updated((this as SiteUpdated).site);
    } else if (this is SiteDeleted) {
      return deleted();
    } else if (this is SiteError) {
      return error((this as SiteError).message);
    }
    throw Exception('Unknown SiteState');
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<SiteEntity> sites)? listLoaded,
    T Function(SiteEntity site)? detailLoaded,
    T Function(SiteEntity site)? created,
    T Function(SiteEntity site)? updated,
    T Function()? deleted,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is SiteInitial && initial != null) {
      return initial();
    } else if (this is SiteLoading && loading != null) {
      return loading();
    } else if (this is SiteListLoaded && listLoaded != null) {
      return listLoaded((this as SiteListLoaded).sites);
    } else if (this is SiteDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as SiteDetailLoaded).site);
    } else if (this is SiteCreated && created != null) {
      return created((this as SiteCreated).site);
    } else if (this is SiteUpdated && updated != null) {
      return updated((this as SiteUpdated).site);
    } else if (this is SiteDeleted && deleted != null) {
      return deleted();
    } else if (this is SiteError && error != null) {
      return error((this as SiteError).message);
    }
    return orElse();
  }
}

class SiteInitial extends SiteState {
  const SiteInitial();
}

class SiteLoading extends SiteState {
  const SiteLoading();
}

class SiteListLoaded extends SiteState {
  const SiteListLoaded(this.sites);

  final List<SiteEntity> sites;

  @override
  List<Object?> get props => [sites];
}

class SiteDetailLoaded extends SiteState {
  const SiteDetailLoaded(this.site);

  final SiteEntity site;

  @override
  List<Object?> get props => [site];
}

class SiteCreated extends SiteState {
  const SiteCreated(this.site);

  final SiteEntity site;

  @override
  List<Object?> get props => [site];
}

class SiteUpdated extends SiteState {
  const SiteUpdated(this.site);

  final SiteEntity site;

  @override
  List<Object?> get props => [site];
}

class SiteDeleted extends SiteState {
  const SiteDeleted();
}

class SiteError extends SiteState {
  const SiteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

