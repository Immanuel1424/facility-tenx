import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../bloc/maintenance_ticket_state.dart';
import '../../domain/entities/site_entity.dart';
import '../../domain/entities/space_entity.dart';

class SiteSpaceSelectorWidget extends StatefulWidget {
  const SiteSpaceSelectorWidget({
    super.key,
    this.selectedSiteId,
    this.selectedSpaceId,
    this.onSiteChanged,
    this.onSpaceChanged,
    this.enabled = true,
  });

  final String? selectedSiteId;
  final String? selectedSpaceId;
  final ValueChanged<String?>? onSiteChanged;
  final ValueChanged<String?>? onSpaceChanged;
  final bool enabled;

  @override
  State<SiteSpaceSelectorWidget> createState() =>
      _SiteSpaceSelectorWidgetState();
}

class _SiteSpaceSelectorWidgetState extends State<SiteSpaceSelectorWidget> {
  // Track which sites we've already attempted to load spaces for
  final Set<String> _attemptedSpaceLoads = {};

  @override
  void initState() {
    super.initState();
    // Load sites when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceTicketBloc>().add(const LoadSites());
    });
  }

  void _loadSpaces(String siteId) {
    // Only load if we haven't already attempted for this site
    if (!_attemptedSpaceLoads.contains(siteId)) {
      _attemptedSpaceLoads.add(siteId);
      context.read<MaintenanceTicketBloc>().add(LoadSpaces(siteId: siteId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        final bloc = context.read<MaintenanceTicketBloc>();
        // Use cached sites and spaces if available, otherwise use state
        List<SiteEntity> sites = bloc.cachedSites;
        List<SpaceEntity> spaces = widget.selectedSiteId != null
            ? bloc.getCachedSpaces(widget.selectedSiteId!)
            : [];
        bool isLoadingSites = false;
        bool isLoadingSpaces = false;

        if (state is MaintenanceTicketLoading) {
          // Determine what's loading based on current selections
          if (widget.selectedSiteId == null) {
            isLoadingSites = true;
          } else {
            isLoadingSpaces = true;
          }
        } else if (state is SitesLoaded) {
          sites = state.sites;
        } else if (state is SpacesLoaded) {
          spaces = state.spaces;
        }

        // Load spaces when site is selected (only if not already attempted)
        if (widget.selectedSiteId != null &&
            spaces.isEmpty &&
            !isLoadingSpaces &&
            !_attemptedSpaceLoads.contains(widget.selectedSiteId!)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadSpaces(widget.selectedSiteId!);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String?>(
              value: widget.selectedSiteId,
              decoration: InputDecoration(
                labelText: 'Select Site',
                border: const OutlineInputBorder(),
                suffixIcon: isLoadingSites
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              items: [
                ...sites.map((SiteEntity site) {
                  return DropdownMenuItem<String?>(
                    value: site.id,
                    child: Text(site.displayName),
                  );
                }),
              ],
              onChanged: widget.enabled && !isLoadingSites
                  ? (String? value) {
                      widget.onSiteChanged?.call(value);
                      // Clear space selection when site changes
                      widget.onSpaceChanged?.call(null);
                      // Reset attempted loads for the new site
                      if (value != null) {
                        _attemptedSpaceLoads.remove(value);
                        _loadSpaces(value);
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: widget.selectedSpaceId,
              decoration: InputDecoration(
                labelText: 'Select Space',
                border: const OutlineInputBorder(),
                suffixIcon: isLoadingSpaces
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              items: [
                ...spaces.map((SpaceEntity space) {
                  return DropdownMenuItem<String?>(
                    value: space.id,
                    child: Text(space.displayName),
                  );
                }),
              ],
              onChanged: widget.enabled &&
                      widget.selectedSiteId != null &&
                      !isLoadingSpaces
                  ? (String? value) {
                      widget.onSpaceChanged?.call(value);
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }
}

