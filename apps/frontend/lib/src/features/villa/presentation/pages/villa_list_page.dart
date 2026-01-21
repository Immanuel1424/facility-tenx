import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/pluto_grid_config.dart';
import '../../data/repositories/villa_repository.dart';
import '../../domain/entities/villa_entity.dart';
import '../bloc/villa_bloc.dart';
import '../bloc/villa_event.dart';
import '../bloc/villa_state.dart';
import 'villa_create_page.dart';

class VillaListPage extends StatelessWidget {
  const VillaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VillaBloc(
        repository: VillaRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(const LoadVillaList()),
      child: const _VillaListContent(),
    );
  }
}

class _VillaListContent extends StatefulWidget {
  const _VillaListContent();

  @override
  State<_VillaListContent> createState() => _VillaListContentState();
}

class _VillaListContentState extends State<_VillaListContent> {
  PlutoGridStateManager? _stateManager;
  // Note: Business data comes from BLoC state, not local variables

  // Filter state (UI-only, for local filtering)
  final _searchController = TextEditingController();
  String? _selectedStatus = 'active';
  String? _selectedOccupancy;
  bool _hasInitialBuild = false;

  // Pagination state (UI-only)
  int _currentPage = 1;
  int _itemsPerPage = 20;
  static const List<int> _pageSizeOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-refresh removed
    if (!_hasInitialBuild) {
      _hasInitialBuild = true;
    }
  }

  List<VillaEntity> _getFilteredVillas(List<VillaEntity> villas) {
    var filtered = List<VillaEntity>.from(villas);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((villa) {
        final villaNumber = villa.villaNumber.toString();
        final tenantName = (villa.tenantName ?? '').toLowerCase();
        final unitName = (villa.unitName ?? '').toLowerCase();
        final buildingName = (villa.buildingName ?? '').toLowerCase();
        return villaNumber.contains(query) ||
            tenantName.contains(query) ||
            unitName.contains(query) ||
            buildingName.contains(query);
      }).toList();
    }

    // Filter by status (Active/Inactive)
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((villa) {
        if (_selectedStatus == 'active') {
          return villa.isActive;
        } else if (_selectedStatus == 'inactive') {
          return !villa.isActive;
        }
        return true;
      }).toList();
    }

    // Filter by occupancy
    if (_selectedOccupancy != null && _selectedOccupancy!.isNotEmpty) {
      filtered = filtered.where((villa) {
        if (_selectedOccupancy == 'occupied') {
          return villa.isOccupied;
        } else if (_selectedOccupancy == 'vacant') {
          return !villa.isOccupied;
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  List<VillaEntity> _getPaginatedVillas(List<VillaEntity> villas) {
    final filtered = _getFilteredVillas(villas);
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= filtered.length) {
      return [];
    }
    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  int _getTotalPages(List<VillaEntity> villas) {
    final filtered = _getFilteredVillas(villas);
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  String _getPaginationRangeText(List<VillaEntity> villas) {
    final filtered = _getFilteredVillas(villas);
    if (filtered.isEmpty) {
      return '0';
    }
    final startIndex = ((_currentPage - 1) * _itemsPerPage) + 1;
    final endIndex = (_currentPage * _itemsPerPage) < filtered.length
        ? (_currentPage * _itemsPerPage)
        : filtered.length;

    if (startIndex == endIndex) {
      return '$startIndex of ${filtered.length}';
    }
    return '$startIndex-$endIndex of ${filtered.length}';
  }

  void _goToPage(int page, List<VillaEntity> villas) {
    final totalPages = _getTotalPages(villas);
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
      _updateGridData(villas);
    }
  }

  void _onPageSizeChanged(int? newSize, List<VillaEntity> villas) {
    if (newSize != null && newSize != _itemsPerPage) {
      setState(() {
        _itemsPerPage = newSize;
        _currentPage = 1; // Reset to first page when changing page size
      });
      _updateGridData(villas);
    }
  }

  void _updateGridData(List<VillaEntity> villas) {
    if (_stateManager == null) return;

    final paginatedVillas = _getPaginatedVillas(villas);
    final rows = _buildRows(paginatedVillas);

    _stateManager!.removeAllRows();
    _stateManager!.appendRows(rows);
  }

  List<PlutoRow> _buildRows(List<VillaEntity> villas) {
    return villas.map((villa) {
      return PlutoRow(
        cells: {
          'actions': PlutoCell(value: villa.id),
          'villa_type': PlutoCell(value: villa.villaType ?? ''),
          'villa_number': PlutoCell(value: villa.villaNumber),
          'unit_name': PlutoCell(value: villa.unitName ?? ''),
          'building_name': PlutoCell(value: villa.buildingName ?? ''),
          'tenant_name': PlutoCell(value: villa.tenantName ?? ''),
          'contact_phone': PlutoCell(value: villa.contactPhone ?? ''),
          'contact_email': PlutoCell(value: villa.contactEmail ?? ''),
          'is_active': PlutoCell(value: villa.isActive),
          'is_occupied': PlutoCell(value: villa.isOccupied),
          'bedroom_count': PlutoCell(value: villa.bedroomCount),
          'bathroom_count': PlutoCell(value: villa.bathroomCount),
          'floor_count': PlutoCell(value: villa.floorCount),
          'measure': PlutoCell(value: villa.measure ?? ''),
          'external_area': PlutoCell(value: villa.externalArea ?? ''),
          'primary_view': PlutoCell(value: villa.primaryView ?? ''),
          'city': PlutoCell(value: villa.city ?? ''),
          'open_from': PlutoCell(value: villa.openFrom),
          'created_at': PlutoCell(value: villa.createdAt),
        },
      );
    }).toList();
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final minWidths = {
      'villa_type': 120.0,
      'villa_number': 110.0,
      'unit_name': 120.0,
      'building_name': 150.0,
      'tenant_name': 160.0,
      'contact_phone': 140.0,
      'contact_email': 200.0,
      'is_active': 110.0,
      'is_occupied': 110.0,
      'bedroom_count': 110.0,
      'bathroom_count': 110.0,
      'floor_count': 110.0,
      'measure': 120.0,
      'external_area': 120.0,
      'primary_view': 120.0,
      'city': 120.0,
      'open_from': 120.0,
      'created_at': 160.0,
      'actions': 80.0,
    };

    final totalMinWidth =
        minWidths.values.fold(0.0, (sum, width) => sum + width);
    final widthMultiplier =
        availableWidth < totalMinWidth ? 1.0 : (availableWidth / totalMinWidth);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return [
      PlutoColumn(
        title: 'Villa Type',
        field: 'villa_type',
        type: PlutoColumnType.text(),
        width: (minWidths['villa_type']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Unit No',
        field: 'villa_number',
        type: PlutoColumnType.text(),
        width: (minWidths['villa_number']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Unit Name',
        field: 'unit_name',
        type: PlutoColumnType.text(),
        width: (minWidths['unit_name']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Building Name',
        field: 'building_name',
        type: PlutoColumnType.text(),
        width: (minWidths['building_name']! * widthMultiplier)
            .clamp(150.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Tenant',
        field: 'tenant_name',
        type: PlutoColumnType.text(),
        width: (minWidths['tenant_name']! * widthMultiplier)
            .clamp(160.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Contact Phone',
        field: 'contact_phone',
        type: PlutoColumnType.text(),
        width: (minWidths['contact_phone']! * widthMultiplier)
            .clamp(140.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Contact Email',
        field: 'contact_email',
        type: PlutoColumnType.text(),
        width: (minWidths['contact_email']! * widthMultiplier)
            .clamp(200.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Active',
        field: 'is_active',
        type: PlutoColumnType.text(),
        width: (minWidths['is_active']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final isActive = rendererContext.cell.value as bool;
          final status = isActive ? 'ACTIVE' : 'INACTIVE';
          final bgColor = isActive
              ? (isDark
                  ? Colors.green.shade900.withOpacity(0.3)
                  : Colors.green.shade50)
              : (isDark
                  ? Colors.red.shade900.withOpacity(0.3)
                  : Colors.red.shade50);
          final textColor = isActive
              ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
              : (isDark ? Colors.red.shade300 : Colors.red.shade700);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                  minHeight: 0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: context.cardBorderRadius,
                  border: Border.all(
                    color: textColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Occupied',
        field: 'is_occupied',
        type: PlutoColumnType.text(),
        width: (minWidths['is_occupied']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final isOccupied = rendererContext.cell.value as bool;
          final status = isOccupied ? 'OCCUPIED' : 'VACANT';
          final bgColor = isOccupied
              ? (isDark
                  ? Colors.blue.shade900.withOpacity(0.3)
                  : Colors.blue.shade50)
              : (isDark
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade100);
          final textColor = isOccupied
              ? (isDark ? Colors.blue.shade300 : Colors.blue.shade700)
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade700);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                  minHeight: 0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: context.cardBorderRadius,
                  border: Border.all(
                    color: textColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Bedrooms',
        field: 'bedroom_count',
        type: PlutoColumnType.number(),
        width: (minWidths['bedroom_count']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value?.toString() ?? '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Bathrooms',
        field: 'bathroom_count',
        type: PlutoColumnType.number(),
        width: (minWidths['bathroom_count']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value?.toString() ?? '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Floors',
        field: 'floor_count',
        type: PlutoColumnType.number(),
        width: (minWidths['floor_count']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value?.toString() ?? '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Measure',
        field: 'measure',
        type: PlutoColumnType.text(),
        width: (minWidths['measure']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'External Area',
        field: 'external_area',
        type: PlutoColumnType.text(),
        width: (minWidths['external_area']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Primary View',
        field: 'primary_view',
        type: PlutoColumnType.text(),
        width: (minWidths['primary_view']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'City',
        field: 'city',
        type: PlutoColumnType.text(),
        width: (minWidths['city']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Open From',
        field: 'open_from',
        type: PlutoColumnType.date(),
        width: (minWidths['open_from']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          if (value == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '—',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          final date = value is DateTime ? value : DateTime.tryParse(value.toString());
          if (date == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '—',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Created At',
        field: 'created_at',
        type: PlutoColumnType.date(),
        width: (minWidths['created_at']! * widthMultiplier)
            .clamp(160.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value?.toString() ?? '—',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: minWidths['actions']!,
        enableSorting: false,
        enableColumnDrag: false,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          final villaId = rendererContext.cell.value.toString();
          return Center(
            child: IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                context.push('/villas/$villaId');
              },
              tooltip: 'View Details',
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Note: Stats will be calculated from BLoC state in builder
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Villas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          actions: const [],
        ),
        body: BlocConsumer<VillaBloc, VillaState>(
          listener: (context, state) {
            state.maybeWhen(
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              listLoaded: (villas) {
                // Update grid directly from BLoC state - no local duplication needed
                if (_stateManager != null) {
                  _updateGridData(villas);
                }
              },
              created: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaBloc>().add(const LoadVillaList());
              },
              updated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaBloc>().add(const LoadVillaList());
              },
              deleted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    context.read<VillaBloc>().add(const LoadVillaList());
                  }
                });
              },
              activated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa activated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaBloc>().add(const LoadVillaList());
              },
              deactivated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa deactivated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaBloc>().add(const LoadVillaList());
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () {
                _stateManager?.setShowLoading(true);
                return const Center(child: CircularProgressIndicator());
              },
              listLoaded: (villas) {
                // Calculate stats from BLoC state
                final totalVillas = villas.length;
                final activeVillas = villas.where((v) => v.isActive).length;
                final occupiedVillas = villas.where((v) => v.isOccupied).length;
                final vacantVillas = totalVillas - occupiedVillas;
                
                return Column(
                  children: [
                    // 1. Statistics Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          _buildStatCard(
                            context,
                            'Total Villas',
                            totalVillas.toString(),
                            Icons.home_outlined,
                            theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Active',
                            activeVillas.toString(),
                            Icons.check_circle_outline,
                            Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Occupied',
                            occupiedVillas.toString(),
                            Icons.people_outline,
                            Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Vacant',
                            vacantVillas.toString(),
                            Icons.home_work_outlined,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    // 2. Modern Filter Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: context.cardBorderRadius,
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  hintText:
                                      'Search by unit no, tenant, unit name, building...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _currentPage = 1;
                                            });
                                            // Update grid with filtered data
                                            final state = context.read<VillaBloc>().state;
                                            state.maybeWhen(
                                              listLoaded: (villas) {
                                                _updateGridData(villas);
                                              },
                                              orElse: () {},
                                            );
                                          },
                                        )
                                      : null,
                                  isDense: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  // Remove background
                                  filled: false,
                                ),
                                onChanged: (_) {
                                  setState(() {
                                    _currentPage = 1; // Reset to first page on search
                                  });
                                  // Update grid with filtered data
                                  final state = context.read<VillaBloc>().state;
                                  state.maybeWhen(
                                    listLoaded: (villas) {
                                      _updateGridData(villas);
                                    },
                                    orElse: () {},
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Status',
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  isDense: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  // Remove background
                                  filled: false,
                                ),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'All Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Text(
                                      'Active',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'inactive',
                                    child: Text(
                                      'Inactive',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value;
                                    _currentPage = 1; // Reset to first page
                                  });
                                  // Update grid with filtered data
                                  final state = context.read<VillaBloc>().state;
                                  state.maybeWhen(
                                    listLoaded: (villas) {
                                      _updateGridData(villas);
                                    },
                                    orElse: () {},
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedOccupancy,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Occupancy',
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  isDense: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  // Remove background
                                  filled: false,
                                ),
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'All',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'occupied',
                                    child: Text(
                                      'Occupied',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'vacant',
                                    child: Text(
                                      'Vacant',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOccupancy = value;
                                    _currentPage = 1; // Reset to first page
                                  });
                                  // Update grid with filtered data
                                  final state = context.read<VillaBloc>().state;
                                  state.maybeWhen(
                                    listLoaded: (villas) {
                                      _updateGridData(villas);
                                    },
                                    orElse: () {},
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Refresh Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<VillaBloc>().add(
                                        const LoadVillaList(),
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Refresh'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Create Villa Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final shouldRefresh =
                                      await VillaCreateDialog.show(context);

                                  if (shouldRefresh == true &&
                                      context.mounted) {
                                    context.read<VillaBloc>().add(
                                          const LoadVillaList(),
                                        );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Create Villa'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Clean Grid
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: context.cardBorderRadius,
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            final columns = _buildColumns(availableWidth);
                            final filteredVillas = _getFilteredVillas(villas);
                            final totalPages = _getTotalPages(villas);

                            // Reset to page 1 if current page exceeds total pages
                            if (totalPages > 0 && _currentPage > totalPages) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _goToPage(1, villas);
                              });
                            }

                            // Get paginated villas
                            final paginatedVillas = _getPaginatedVillas(villas);
                            final rows = _buildRows(paginatedVillas);

                            // Show empty state when no villas match filters
                            if (rows.isEmpty || filteredVillas.isEmpty) {
                              final hasFilters =
                                  _searchController.text.isNotEmpty ||
                                      _selectedStatus != null ||
                                      _selectedOccupancy != null;
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.surfaceContainerHighest
                                            .withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.search_off_rounded,
                                        size: 64,
                                        color: theme
                                            .colorScheme.onSurfaceVariant
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      hasFilters
                                          ? 'No villas found matching your filters'
                                          : 'No villas found',
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (hasFilters) ...[
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _selectedStatus = 'active';
                                            _selectedOccupancy = null;
                                            _currentPage = 1;
                                          });
                                        },
                                        child: const Text('Clear all filters'),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }

                            return Theme(
                              data: PlutoGridConfig.buildGridTheme(context),
                              child: PlutoGrid(
                                key: ValueKey(
                                    'villas_${_currentPage}_$_itemsPerPage'),
                                columns: columns,
                                rows: rows,
                                onLoaded: (PlutoGridOnLoadedEvent event) {
                                  setState(() {
                                    _stateManager = event.stateManager;
                                  });
                                  final stateManager = event.stateManager;

                                  // Disable editing mode - set to row selection mode only
                                  stateManager.setSelectingMode(
                                    PlutoGridSelectingMode.row,
                                  );
                                  stateManager.setShowColumnFilter(true);

                                  // Reset horizontal scroll to start (leftmost position)
                                  // This ensures frozen columns are properly visible
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    stateManager.scroll.horizontal?.jumpTo(0);
                                  });

                                  // Handle single click navigation
                                  String? lastSelectedVillaNumber;
                                  DateTime? lastSelectionTime;
                                  bool isNavigating = false;

                                  stateManager.addListener(() {
                                    if (isNavigating) return;

                                    final currentRows =
                                        stateManager.currentSelectingRows;
                                    if (currentRows.isNotEmpty) {
                                      final row = currentRows.first;
                                      final villaNumber = row
                                          .cells['villa_number']
                                          ?.value as String?;

                                      if (villaNumber != null &&
                                          villaNumber !=
                                              lastSelectedVillaNumber) {
                                        final now = DateTime.now();
                                        final timeSinceLastSelection =
                                            lastSelectionTime != null
                                                ? now
                                                    .difference(
                                                      lastSelectionTime!,
                                                    )
                                                    .inMilliseconds
                                                : 500;

                                        if (timeSinceLastSelection > 250) {
                                          lastSelectedVillaNumber = villaNumber;
                                          lastSelectionTime = now;
                                          isNavigating = true;

                                          Future.delayed(
                                              const Duration(milliseconds: 250),
                                              () {
                                            if (!isNavigating) return;

                                            if (stateManager
                                                .currentSelectingRows
                                                .isNotEmpty) {
                                              final currentVillaNumber =
                                                  stateManager
                                                      .currentSelectingRows
                                                      .first
                                                      .cells['villa_number']
                                                      ?.value as String?;
                                              if (currentVillaNumber ==
                                                  villaNumber) {
                                                final villa = filteredVillas.firstWhere(
                                                  (VillaEntity v) =>
                                                      v.villaNumber.toString() ==
                                                      villaNumber,
                                                  orElse: () => filteredVillas.isNotEmpty ? filteredVillas.first : villas.first,
                                                );
                                                context.push(
                                                  '/villas/${villa.id}',
                                                );
                                              }
                                            }
                                            isNavigating = false;
                                          });
                                        }
                                      }
                                    }
                                  });
                                },
                                onRowDoubleTap: (event) {
                                  final villaNumber = event.row
                                      .cells['villa_number']?.value as String?;

                                  if (villaNumber != null) {
                                    final villa = filteredVillas.firstWhere(
                                      (VillaEntity v) => v.villaNumber.toString() == villaNumber,
                                      orElse: () => filteredVillas.isNotEmpty ? filteredVillas.first : villas.first,
                                    );
                                    context.push('/villas/${villa.id}');
                                  }
                                },
                                configuration:
                                    PlutoGridConfig.buildConfiguration(context),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Pagination Controls
                    Builder(
                      builder: (context) {
                        final filteredVillas = _getFilteredVillas(villas);
                        final totalPages = _getTotalPages(villas);
                        if (filteredVillas.isEmpty || totalPages <= 1) {
                          return const SizedBox.shrink();
                        }
                        return _buildPaginationControls(
                          context,
                          totalPages,
                          filteredVillas.length,
                          villas,
                        );
                      },
                    ),
                  ],
                );
              },
              detailLoaded: (_) => const SizedBox.shrink(),
              created: (_) => const SizedBox.shrink(),
              updated: (_) => const SizedBox.shrink(),
              deleted: () => const SizedBox.shrink(),
              activated: (_) => const SizedBox.shrink(),
              deactivated: (_) => const SizedBox.shrink(),
              error: (message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $message',
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<VillaBloc>().add(const LoadVillaList());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: context.cardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(
            bottom: BorderSide(
              color: color,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.0,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(
    BuildContext context,
    int totalPages,
    int totalFiltered,
    List<VillaEntity> villas,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: isMobile
          ? _buildMobilePaginationControls(
              context,
              totalPages,
              totalFiltered,
              villas,
            )
          : _buildDesktopPaginationControls(
              context,
              totalPages,
              totalFiltered,
              villas,
            ),
    );
  }

  Widget _buildMobilePaginationControls(
    BuildContext context,
    int totalPages,
    int totalFiltered,
    List<VillaEntity> villas,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Info and page size selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getPaginationRangeText(villas),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<int>(
                value: _itemsPerPage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _pageSizeOptions.map((size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Text(
                      '$size',
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) => _onPageSizeChanged(value, villas),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Navigation buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: _currentPage > 1 ? () => _goToPage(1, villas) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, villas)
                  : null,
              tooltip: 'Previous Page',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Page $_currentPage of $totalPages',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(_currentPage + 1, villas)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, villas)
                  : null,
              tooltip: 'Last Page',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopPaginationControls(
    BuildContext context,
    int totalPages,
    int totalFiltered,
    List<VillaEntity> villas,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate which page numbers to show
    final List<int> visiblePages = _getVisiblePageNumbers(
      _currentPage,
      totalPages,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Info and page size selector
        Row(
          children: [
            Text(
              _getPaginationRangeText(villas),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Text(
                  'Items per page:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: DropdownButtonFormField<int>(
                    value: _itemsPerPage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _pageSizeOptions.map((size) {
                      return DropdownMenuItem<int>(
                        value: size,
                        child: Text(
                          '$size',
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => _onPageSizeChanged(value, villas),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Center: Page navigation
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: _currentPage > 1 ? () => _goToPage(1, villas) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, villas)
                  : null,
              tooltip: 'Previous Page',
            ),
            const SizedBox(width: 8),
            // Page numbers
            ...visiblePages.map((page) {
              final isCurrentPage = page == _currentPage;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => _goToPage(page, villas),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrentPage
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrentPage
                          ? Border.all(
                              color: colorScheme.primary,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      page == -1 ? '...' : '$page',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isCurrentPage
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight:
                            isCurrentPage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(_currentPage + 1, villas)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, villas)
                  : null,
              tooltip: 'Last Page',
            ),
          ],
        ),
        // Right: Total pages info
        Text(
          'Total: $totalFiltered',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<int> _getVisiblePageNumbers(int currentPage, int totalPages) {
    const int maxVisible = 7; // Show max 7 page numbers
    final List<int> pages = [];

    if (totalPages <= maxVisible) {
      // Show all pages if total is less than max visible
      for (int i = 1; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      // Always show first page
      pages.add(1);

      int startPage;
      int endPage;

      if (currentPage <= 3) {
        // Near the beginning
        startPage = 2;
        endPage = 5;
      } else if (currentPage >= totalPages - 2) {
        // Near the end
        startPage = totalPages - 4;
        endPage = totalPages - 1;
      } else {
        // In the middle
        startPage = currentPage - 1;
        endPage = currentPage + 1;
      }

      // Add ellipsis if needed
      if (startPage > 2) {
        pages.add(-1); // -1 represents ellipsis
      }

      // Add middle pages
      for (int i = startPage; i <= endPage; i++) {
        pages.add(i);
      }

      // Add ellipsis if needed
      if (endPage < totalPages - 1) {
        pages.add(-1); // -1 represents ellipsis
      }

      // Always show last page
      pages.add(totalPages);
    }

    return pages;
  }
}
