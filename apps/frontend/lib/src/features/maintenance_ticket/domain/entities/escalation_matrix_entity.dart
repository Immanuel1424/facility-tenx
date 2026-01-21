import 'package:equatable/equatable.dart';

class EscalationMatrixEntity extends Equatable {
  const EscalationMatrixEntity({
    required this.priority,
    this.level1Minutes,
    this.level2Minutes,
    this.level3Minutes,
  });

  final String priority;
  final int? level1Minutes;
  final int? level2Minutes;
  final int? level3Minutes;

  String get level1Display {
    if (level1Minutes == null) return 'Not configured';
    final hours = level1Minutes! ~/ 60;
    final minutes = level1Minutes! % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String get level2Display {
    if (level2Minutes == null) return 'Not configured';
    final hours = level2Minutes! ~/ 60;
    final minutes = level2Minutes! % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String get level3Display {
    if (level3Minutes == null) return 'Not configured';
    final hours = level3Minutes! ~/ 60;
    final minutes = level3Minutes! % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  List<Object?> get props => [
        priority,
        level1Minutes,
        level2Minutes,
        level3Minutes,
      ];
}
