import 'package:equatable/equatable.dart';

class TicketCategoryEntity extends Equatable {
  const TicketCategoryEntity({
    required this.id,
    this.code,
    this.name,
    this.description,
    this.parentCategoryId,
    this.displayOrder = 0,
    this.isActive = true,
    this.icon,
    this.colorCode,
  });

  final String id;
  final String? code;
  final String? name;
  final String? description;
  final String? parentCategoryId;
  final int displayOrder;
  final bool isActive;
  final String? icon;
  final String? colorCode;

  /// Display name for UI
  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    if (code != null && code!.isNotEmpty) {
      return code!;
    }
    return 'Category $id';
  }

  /// Check if this is a root category (no parent)
  bool get isRoot => parentCategoryId == null || parentCategoryId!.isEmpty;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        parentCategoryId,
        displayOrder,
        isActive,
        icon,
        colorCode,
      ];
}

