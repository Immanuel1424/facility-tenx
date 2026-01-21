import 'package:equatable/equatable.dart';

class PermissionEntity extends Equatable {
  const PermissionEntity({
    required this.id,
    required this.companyId,
    required this.resource,
    required this.action,
    this.description,
  });

  final String id;
  final String companyId;
  final String resource;
  final String action;
  final String? description;

  /// Get permission string in format "resource:action"
  String get permissionString => '$resource:$action';

  @override
  List<Object?> get props => [
        id,
        companyId,
        resource,
        action,
        description,
      ];
}

