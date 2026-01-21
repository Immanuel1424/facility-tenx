import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';
import '../../domain/entities/villa_entity.dart';

class VillaSelectorWidget extends StatefulWidget {
  const VillaSelectorWidget({
    super.key,
    this.selectedVillaId,
    this.siteId,
    this.onChanged,
    this.enabled = true,
  });

  final String? selectedVillaId;
  final String? siteId;
  final ValueChanged<String?>? onChanged;
  final bool enabled;

  @override
  State<VillaSelectorWidget> createState() => _VillaSelectorWidgetState();
}

class _VillaSelectorWidgetState extends State<VillaSelectorWidget> {
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    // Load villas when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceTicketBloc>().add(
            LoadVillas(siteId: widget.siteId),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        List<VillaEntity> villas = [];
        bool isLoading = false;

        if (state is MaintenanceTicketLoading) {
          isLoading = true;
        } else if (state is VillasLoaded) {
          villas = state.villas;
        }

        // Filter villas by search query
        if (_searchQuery != null && _searchQuery!.isNotEmpty) {
          villas = villas.where((villa) {
            final query = _searchQuery!.toLowerCase();
            return villa.displayName.toLowerCase().contains(query) ||
                (villa.tenantName?.toLowerCase().contains(query) ?? false) ||
                (villa.villaNumber?.toString().contains(query) ?? false);
          }).toList();
        }

        if (isLoading) {
          return DropdownButtonFormField<String>(
            items: const [],
            onChanged: null,
            decoration: const InputDecoration(
              labelText: 'Loading villas...',
              suffixIcon: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              enabled: widget.enabled,
              decoration: InputDecoration(
                labelText: 'Search Villa',
                hintText: 'Type to search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: widget.enabled
                  ? (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: widget.selectedVillaId,
              decoration: const InputDecoration(
                labelText: 'Select Villa',
                border: OutlineInputBorder(),
              ),
              items: [
                ...villas.map((VillaEntity villa) {
                  return DropdownMenuItem<String?>(
                    value: villa.id,
                    child: Text(villa.fullDisplayName),
                  );
                }),
              ],
              onChanged: widget.enabled
                  ? (String? value) {
                      widget.onChanged?.call(value);
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }
}

