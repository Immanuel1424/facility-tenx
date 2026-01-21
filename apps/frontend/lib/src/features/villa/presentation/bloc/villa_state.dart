import 'package:equatable/equatable.dart';

import '../../domain/entities/villa_entity.dart';

abstract class VillaState extends Equatable {
  const VillaState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<VillaEntity> villas) listLoaded,
    required T Function(VillaEntity villa) detailLoaded,
    required T Function(VillaEntity villa) created,
    required T Function(VillaEntity villa) updated,
    required T Function() deleted,
    required T Function(VillaEntity villa) activated,
    required T Function(VillaEntity villa) deactivated,
    required T Function(String message) error,
  }) {
    if (this is VillaInitial) {
      return initial();
    } else if (this is VillaLoading) {
      return loading();
    } else if (this is VillaListLoaded) {
      return listLoaded((this as VillaListLoaded).villas);
    } else if (this is VillaDetailLoaded) {
      return detailLoaded((this as VillaDetailLoaded).villa);
    } else if (this is VillaCreated) {
      return created((this as VillaCreated).villa);
    } else if (this is VillaUpdated) {
      return updated((this as VillaUpdated).villa);
    } else if (this is VillaDeleted) {
      return deleted();
    } else if (this is VillaActivated) {
      return activated((this as VillaActivated).villa);
    } else if (this is VillaDeactivated) {
      return deactivated((this as VillaDeactivated).villa);
    } else if (this is VillaError) {
      return error((this as VillaError).message);
    }
    throw Exception('Unknown VillaState');
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<VillaEntity> villas)? listLoaded,
    T Function(VillaEntity villa)? detailLoaded,
    T Function(VillaEntity villa)? created,
    T Function(VillaEntity villa)? updated,
    T Function()? deleted,
    T Function(VillaEntity villa)? activated,
    T Function(VillaEntity villa)? deactivated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is VillaInitial && initial != null) {
      return initial();
    } else if (this is VillaLoading && loading != null) {
      return loading();
    } else if (this is VillaListLoaded && listLoaded != null) {
      return listLoaded((this as VillaListLoaded).villas);
    } else if (this is VillaDetailLoaded && detailLoaded != null) {
      return detailLoaded((this as VillaDetailLoaded).villa);
    } else if (this is VillaCreated && created != null) {
      return created((this as VillaCreated).villa);
    } else if (this is VillaUpdated && updated != null) {
      return updated((this as VillaUpdated).villa);
    } else if (this is VillaDeleted && deleted != null) {
      return deleted();
    } else if (this is VillaActivated && activated != null) {
      return activated((this as VillaActivated).villa);
    } else if (this is VillaDeactivated && deactivated != null) {
      return deactivated((this as VillaDeactivated).villa);
    } else if (this is VillaError && error != null) {
      return error((this as VillaError).message);
    }
    return orElse();
  }
}

class VillaInitial extends VillaState {
  const VillaInitial();
}

class VillaLoading extends VillaState {
  const VillaLoading();
}

class VillaListLoaded extends VillaState {
  const VillaListLoaded(this.villas);

  final List<VillaEntity> villas;

  @override
  List<Object?> get props => [villas];
}

class VillaDetailLoaded extends VillaState {
  const VillaDetailLoaded(this.villa);

  final VillaEntity villa;

  @override
  List<Object?> get props => [villa];
}

class VillaCreated extends VillaState {
  const VillaCreated(this.villa);

  final VillaEntity villa;

  @override
  List<Object?> get props => [villa];
}

class VillaUpdated extends VillaState {
  const VillaUpdated(this.villa);

  final VillaEntity villa;

  @override
  List<Object?> get props => [villa];
}

class VillaDeleted extends VillaState {
  const VillaDeleted();
}

class VillaActivated extends VillaState {
  const VillaActivated(this.villa);

  final VillaEntity villa;

  @override
  List<Object?> get props => [villa];
}

class VillaDeactivated extends VillaState {
  const VillaDeactivated(this.villa);

  final VillaEntity villa;

  @override
  List<Object?> get props => [villa];
}

class VillaError extends VillaState {
  const VillaError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
