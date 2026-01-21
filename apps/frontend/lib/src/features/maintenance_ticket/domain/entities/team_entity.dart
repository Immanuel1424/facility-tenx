import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  const TeamEntity({
    required this.id,
    this.name,
    this.description,
    this.departmentId,
    this.leadUserId,
    this.isActive = true,
    this.colorCode,
  });

  final String id;
  final String? name;
  final String? description;
  final String? departmentId;
  final String? leadUserId;
  final bool isActive;
  final String? colorCode;

  /// Display name for UI
  String get displayName => name ?? 'Team $id';

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        departmentId,
        leadUserId,
        isActive,
        colorCode,
      ];
}

