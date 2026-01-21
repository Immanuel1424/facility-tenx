import 'package:equatable/equatable.dart';

import '../../../data/dto/create_ticket_category_dto.dart';
import '../../../data/dto/update_ticket_category_dto.dart';

abstract class TicketCategoryEvent extends Equatable {
  const TicketCategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadTicketCategoryList extends TicketCategoryEvent {
  const LoadTicketCategoryList({this.activeOnly = true});

  final bool activeOnly;

  @override
  List<Object?> get props => [activeOnly];
}

class LoadTicketCategoryById extends TicketCategoryEvent {
  const LoadTicketCategoryById(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CreateTicketCategory extends TicketCategoryEvent {
  const CreateTicketCategory(this.dto);

  final CreateTicketCategoryDto dto;

  @override
  List<Object?> get props => [dto];
}

class UpdateTicketCategory extends TicketCategoryEvent {
  const UpdateTicketCategory(this.id, this.dto);

  final String id;
  final UpdateTicketCategoryDto dto;

  @override
  List<Object?> get props => [id, dto];
}

class DeleteTicketCategory extends TicketCategoryEvent {
  const DeleteTicketCategory(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ActivateTicketCategory extends TicketCategoryEvent {
  const ActivateTicketCategory(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class DeactivateTicketCategory extends TicketCategoryEvent {
  const DeactivateTicketCategory(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

