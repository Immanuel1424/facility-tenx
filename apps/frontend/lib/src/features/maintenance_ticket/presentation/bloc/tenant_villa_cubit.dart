import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/villa_entity.dart';
import '../../domain/repositories/maintenance_ticket_repository_interface.dart';

part 'tenant_villa_state.dart';

/// Simple BLoC to manage the current tenant's villas and the
/// selected (active) villa. This is intentionally thin and focused,
/// so it can be reused across tenant dashboard and complaint flows.
class TenantVillaCubit extends Cubit<TenantVillaState> {
  TenantVillaCubit({
    required MaintenanceTicketRepositoryInterface ticketRepository,
  })  : _ticketRepository = ticketRepository,
        super(const TenantVillaState.initial());

  final MaintenanceTicketRepositoryInterface _ticketRepository;

  Future<void> loadVillas() async {
    emit(state.copyWith(status: TenantVillaStatus.loading));

    final result = await _ticketRepository.getTenantVillasForCurrentUser();

    result.match(
      (String error) => emit(
        state.copyWith(
          status: TenantVillaStatus.failure,
          errorMessage: error,
        ),
      ),
      (List<VillaEntity> villas) {
        VillaEntity? active = state.activeVilla;
        if (active == null && villas.isNotEmpty) {
          active = villas.first;
        }
        emit(
          state.copyWith(
            status: TenantVillaStatus.success,
            villas: villas,
            activeVilla: active,
          ),
        );
      },
    );
  }

  void selectVilla(VillaEntity villa) {
    emit(state.copyWith(activeVilla: villa));
  }
}
