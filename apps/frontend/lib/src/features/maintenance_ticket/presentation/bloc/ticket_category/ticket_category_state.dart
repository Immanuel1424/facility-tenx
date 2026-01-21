import 'package:equatable/equatable.dart';

import '../../../domain/entities/ticket_category_entity.dart';

abstract class TicketCategoryState extends Equatable {
  const TicketCategoryState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<TicketCategoryEntity> categories) listLoaded,
    required T Function(TicketCategoryEntity category) loaded,
    required T Function(TicketCategoryEntity category) created,
    required T Function(TicketCategoryEntity category) updated,
    required T Function() deleted,
    required T Function(TicketCategoryEntity category) activated,
    required T Function(TicketCategoryEntity category) deactivated,
    required T Function(String message) error,
  }) {
    if (this is TicketCategoryInitial) {
      return initial();
    } else if (this is TicketCategoryLoading) {
      return loading();
    } else if (this is TicketCategoryListLoaded) {
      return listLoaded((this as TicketCategoryListLoaded).categories);
    } else if (this is TicketCategoryLoaded) {
      return loaded((this as TicketCategoryLoaded).category);
    } else if (this is TicketCategoryCreated) {
      return created((this as TicketCategoryCreated).category);
    } else if (this is TicketCategoryUpdated) {
      return updated((this as TicketCategoryUpdated).category);
    } else if (this is TicketCategoryDeleted) {
      return deleted();
    } else if (this is TicketCategoryActivated) {
      return activated((this as TicketCategoryActivated).category);
    } else if (this is TicketCategoryDeactivated) {
      return deactivated((this as TicketCategoryDeactivated).category);
    } else if (this is TicketCategoryError) {
      return error((this as TicketCategoryError).message);
    }
    throw Exception('Unknown TicketCategoryState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<TicketCategoryEntity> categories)? listLoaded,
    T Function(TicketCategoryEntity category)? loaded,
    T Function(TicketCategoryEntity category)? created,
    T Function(TicketCategoryEntity category)? updated,
    T Function()? deleted,
    T Function(TicketCategoryEntity category)? activated,
    T Function(TicketCategoryEntity category)? deactivated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is TicketCategoryInitial && initial != null) {
      return initial();
    } else if (this is TicketCategoryLoading && loading != null) {
      return loading();
    } else if (this is TicketCategoryListLoaded && listLoaded != null) {
      return listLoaded((this as TicketCategoryListLoaded).categories);
    } else if (this is TicketCategoryLoaded && loaded != null) {
      return loaded((this as TicketCategoryLoaded).category);
    } else if (this is TicketCategoryCreated && created != null) {
      return created((this as TicketCategoryCreated).category);
    } else if (this is TicketCategoryUpdated && updated != null) {
      return updated((this as TicketCategoryUpdated).category);
    } else if (this is TicketCategoryDeleted && deleted != null) {
      return deleted();
    } else if (this is TicketCategoryActivated && activated != null) {
      return activated((this as TicketCategoryActivated).category);
    } else if (this is TicketCategoryDeactivated && deactivated != null) {
      return deactivated((this as TicketCategoryDeactivated).category);
    } else if (this is TicketCategoryError && error != null) {
      return error((this as TicketCategoryError).message);
    }
    return orElse();
  }
}

class TicketCategoryInitial extends TicketCategoryState {
  const TicketCategoryInitial();
}

class TicketCategoryLoading extends TicketCategoryState {
  const TicketCategoryLoading();
}

class TicketCategoryListLoaded extends TicketCategoryState {
  const TicketCategoryListLoaded(this.categories);

  final List<TicketCategoryEntity> categories;

  @override
  List<Object?> get props => [categories];
}

class TicketCategoryLoaded extends TicketCategoryState {
  const TicketCategoryLoaded(this.category);

  final TicketCategoryEntity category;

  @override
  List<Object?> get props => [category];
}

class TicketCategoryCreated extends TicketCategoryState {
  const TicketCategoryCreated(this.category);

  final TicketCategoryEntity category;

  @override
  List<Object?> get props => [category];
}

class TicketCategoryUpdated extends TicketCategoryState {
  const TicketCategoryUpdated(this.category);

  final TicketCategoryEntity category;

  @override
  List<Object?> get props => [category];
}

class TicketCategoryDeleted extends TicketCategoryState {
  const TicketCategoryDeleted();
}

class TicketCategoryActivated extends TicketCategoryState {
  const TicketCategoryActivated(this.category);

  final TicketCategoryEntity category;

  @override
  List<Object?> get props => [category];
}

class TicketCategoryDeactivated extends TicketCategoryState {
  const TicketCategoryDeactivated(this.category);

  final TicketCategoryEntity category;

  @override
  List<Object?> get props => [category];
}

class TicketCategoryError extends TicketCategoryState {
  const TicketCategoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
