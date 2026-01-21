part of 'tenant_villa_cubit.dart';

enum TenantVillaStatus { initial, loading, success, failure }

class TenantVillaState extends Equatable {
  const TenantVillaState({
    required this.status,
    required this.villas,
    required this.activeVilla,
    this.errorMessage,
  });

  const TenantVillaState.initial()
      : status = TenantVillaStatus.initial,
        villas = const [],
        activeVilla = null,
        errorMessage = null;

  final TenantVillaStatus status;
  final List<VillaEntity> villas;
  final VillaEntity? activeVilla;
  final String? errorMessage;

  TenantVillaState copyWith({
    TenantVillaStatus? status,
    List<VillaEntity>? villas,
    VillaEntity? activeVilla,
    String? errorMessage,
  }) {
    return TenantVillaState(
      status: status ?? this.status,
      villas: villas ?? this.villas,
      activeVilla: activeVilla ?? this.activeVilla,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        villas,
        activeVilla,
        errorMessage,
      ];
}


