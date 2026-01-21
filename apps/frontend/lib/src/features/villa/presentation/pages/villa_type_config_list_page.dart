import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/pluto_grid_config.dart';
import '../../data/repositories/villa_type_config_repository.dart';
import '../../domain/entities/villa_type_config_entity.dart';
import '../bloc/villa_type_config/villa_type_config_bloc.dart';
import '../bloc/villa_type_config/villa_type_config_event.dart';
import '../bloc/villa_type_config/villa_type_config_state.dart';
import 'villa_type_config_create_page.dart';

class VillaTypeConfigListPage extends StatelessWidget {
  const VillaTypeConfigListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VillaTypeConfigBloc(
        repository: VillaTypeConfigRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(const LoadVillaTypeConfigList()),
      child: const _VillaTypeConfigListContent(),
    );
  }
}

class _VillaTypeConfigListContent extends StatefulWidget {
  const _VillaTypeConfigListContent();

  @override
  State<_VillaTypeConfigListContent> createState() =>
      _VillaTypeConfigListContentState();
}

class _VillaTypeConfigListContentState
    extends State<_VillaTypeConfigListContent> {
  PlutoGridStateManager? _stateManager;

  // Filter state (UI-only, for local filtering)
  final _searchController = TextEditingController();
  String? _selectedStatus = 'active';

  // Pagination state (UI-only)
  int _currentPage = 1;
  int _itemsPerPage = 20;
  static const List<int> _pageSizeOptions = [10, 20, 50, 100];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VillaTypeConfigEntity> _getFilteredConfigs(
    List<VillaTypeConfigEntity> configs,
  ) {
    var filtered = List<VillaTypeConfigEntity>.from(configs);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((config) {
        final villaType = config.villaType.toLowerCase();
        final displayName = (config.displayName ?? '').toLowerCase();
        return villaType.contains(query) || displayName.contains(query);
      }).toList();
    }

    // Filter by status (Active/Inactive)
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((config) {
        if (_selectedStatus == 'active') {
          return config.isActive;
        } else if (_selectedStatus == 'inactive') {
          return !config.isActive;
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  List<VillaTypeConfigEntity> _getPaginatedConfigs(
    List<VillaTypeConfigEntity> configs,
  ) {
    final filtered = _getFilteredConfigs(configs);
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

  int _getTotalPages(List<VillaTypeConfigEntity> configs) {
    final filtered = _getFilteredConfigs(configs);
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  String _getPaginationRangeText(List<VillaTypeConfigEntity> configs) {
    final filtered = _getFilteredConfigs(configs);
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

  void _goToPage(int page, List<VillaTypeConfigEntity> configs) {
    final totalPages = _getTotalPages(configs);
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
      _updateGridData(configs);
    }
  }

  void _onPageSizeChanged(int? newSize, List<VillaTypeConfigEntity> configs) {
    if (newSize != null && newSize != _itemsPerPage) {
      setState(() {
        _itemsPerPage = newSize;
        _currentPage = 1; // Reset to first page when changing page size
      });
      _updateGridData(configs);
    }
  }

  void _updateGridData(List<VillaTypeConfigEntity> configs) {
    if (_stateManager == null) return;

    final paginatedConfigs = _getPaginatedConfigs(configs);
    final rows = _buildRows(paginatedConfigs);

    _stateManager!.removeAllRows();
    _stateManager!.appendRows(rows);
  }

  List<PlutoRow> _buildRows(List<VillaTypeConfigEntity> configs) {
    return configs.map((config) {
      return PlutoRow(
        cells: {
          'actions': PlutoCell(value: config.id),
          'villa_type': PlutoCell(value: config.villaType),
          'display_name': PlutoCell(value: config.displayName ?? ''),
          'bedroom_count': PlutoCell(value: config.defaultBedroomCount),
          'floor_count': PlutoCell(value: config.defaultFloorCount),
          'area_sqm': PlutoCell(value: config.defaultAreaSqm),
          'is_active': PlutoCell(value: config.isActive),
          'created_at': PlutoCell(value: config.createdAt),
        },
      );
    }).toList();
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final minWidths = {
      'villa_type': 150.0,
      'display_name': 180.0,
      'bedroom_count': 120.0,
      'floor_count': 120.0,
      'area_sqm': 120.0,
      'is_active': 110.0,
      'created_at': 160.0,
      'actions': 100.0,
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
            .clamp(150.0, double.infinity),
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
        title: 'Display Name',
        field: 'display_name',
        type: PlutoColumnType.text(),
        width: (minWidths['display_name']! * widthMultiplier)
            .clamp(180.0, double.infinity),
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
        title: 'Bedrooms',
        field: 'bedroom_count',
        type: PlutoColumnType.number(),
        width: (minWidths['bedroom_count']! * widthMultiplier)
            .clamp(120.0, double.infinity),
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
            .clamp(120.0, double.infinity),
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
        title: 'Area (sqm)',
        field: 'area_sqm',
        type: PlutoColumnType.number(),
        width: (minWidths['area_sqm']! * widthMultiplier)
            .clamp(120.0, double.infinity),
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
          final configId = rendererContext.cell.value.toString();
          return Center(
            child: IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                context.push('/villa-types/$configId');
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
          title: const Text('Villa Types'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          actions: const [],
        ),
        body: BlocConsumer<VillaTypeConfigBloc, VillaTypeConfigState>(
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
              listLoaded: (configs) {
                // Update grid directly from BLoC state
                if (_stateManager != null) {
                  _updateGridData(configs);
                }
              },
              created: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa type created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaTypeConfigBloc>().add(
                      const LoadVillaTypeConfigList(),
                    );
              },
              updated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa type updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaTypeConfigBloc>().add(
                      const LoadVillaTypeConfigList(),
                    );
              },
              deleted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa type deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    context.read<VillaTypeConfigBloc>().add(
                          const LoadVillaTypeConfigList(),
                        );
                  }
                });
              },
              activated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa type activated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaTypeConfigBloc>().add(
                      const LoadVillaTypeConfigList(),
                    );
              },
              deactivated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Villa type deactivated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<VillaTypeConfigBloc>().add(
                      const LoadVillaTypeConfigList(),
                    );
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
              listLoaded: (configs) {
                // Calculate stats from BLoC state
                final totalConfigs = configs.length;
                final activeConfigs =
                    configs.where((c) => c.isActive).length;
                final inactiveConfigs = totalConfigs - activeConfigs;

                return Column(
                  children: [
                    // 1. Statistics Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          _buildStatCard(
                            context,
                            'Total Types',
                            totalConfigs.toString(),
                            Icons.category_outlined,
                            theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Active',
                            activeConfigs.toString(),
                            Icons.check_circle_outline,
                            Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            'Inactive',
                            inactiveConfigs.toString(),
                            Icons.cancel_outlined,
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
                                  hintText: 'Search by type or name...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _currentPage = 1;
                                            });
                                          },
                                        )
                                      : null,
                                  isDense: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  filled: false,
                                ),
                                onChanged: (_) {
                                  setState(() {
                                    _currentPage = 1; // Reset to first page on search
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedStatus,
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
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Create Villa Type Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final created = await VillaTypeConfigCreateDialog.show(context);
                                  if (created == true && context.mounted) {
                                    // Refresh the villa type list
                                    context.read<VillaTypeConfigBloc>().add(
                                          const LoadVillaTypeConfigList(),
                                        );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Create Villa Type'),
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
                            final filteredConfigs = _getFilteredConfigs(configs);
                            final totalPages = _getTotalPages(configs);

                            // Reset to page 1 if current page exceeds total pages
                            if (totalPages > 0 && _currentPage > totalPages) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _goToPage(1, configs);
                              });
                            }

                            // Get paginated configs
                            final paginatedConfigs = _getPaginatedConfigs(configs);
                            final rows = _buildRows(paginatedConfigs);

                            // Show empty state when no configs match filters
                            if (rows.isEmpty || filteredConfigs.isEmpty) {
                              final hasFilters =
                                  _searchController.text.isNotEmpty ||
                                      _selectedStatus != null;

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
                                        hasFilters
                                            ? Icons.filter_alt_off_rounded
                                            : Icons.category_outlined,
                                        size: 64,
                                        color: theme
                                            .colorScheme.onSurfaceVariant
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      hasFilters
                                          ? 'No villa types found matching your filters'
                                          : 'No villa types found',
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
                                    'villa_types_${_currentPage}_$_itemsPerPage'),
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
                                  String? lastSelectedConfigId;
                                  DateTime? lastSelectionTime;
                                  bool isNavigating = false;

                                  stateManager.addListener(() {
                                    if (isNavigating) return;

                                    final currentRows =
                                        stateManager.currentSelectingRows;
                                    if (currentRows.isNotEmpty) {
                                      final row = currentRows.first;
                                      final configId = row.cells['actions']
                                          ?.value as String?;

                                      if (configId != null &&
                                          configId != lastSelectedConfigId) {
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
                                          lastSelectedConfigId = configId;
                                          lastSelectionTime = now;
                                          isNavigating = true;

                                          Future.delayed(
                                              const Duration(milliseconds: 250),
                                              () {
                                            if (!isNavigating) return;

                                            if (stateManager
                                                .currentSelectingRows
                                                .isNotEmpty) {
                                              final currentConfigId =
                                                  stateManager
                                                      .currentSelectingRows
                                                      .first
                                                      .cells['actions']
                                                      ?.value as String?;
                                              if (currentConfigId == configId) {
                                                context.push(
                                                  '/villa-types/$configId',
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
                                  final configId = event.row.cells['actions']
                                      ?.value as String?;

                                  if (configId != null) {
                                    context.push('/villa-types/$configId');
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
                        final filteredConfigs = _getFilteredConfigs(configs);
                        final totalPages = _getTotalPages(configs);
                        if (filteredConfigs.isEmpty || totalPages <= 1) {
                          return const SizedBox.shrink();
                        }
                        return _buildPaginationControls(
                          context,
                          totalPages,
                          filteredConfigs.length,
                          configs,
                        );
                      },
                    ),
                  ],
                );
              },
              loaded: (_) => const SizedBox.shrink(),
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
                          context.read<VillaTypeConfigBloc>().add(
                                const LoadVillaTypeConfigList(),
                              );
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
    List<VillaTypeConfigEntity> configs,
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
              configs,
            )
          : _buildDesktopPaginationControls(
              context,
              totalPages,
              totalFiltered,
              configs,
            ),
    );
  }

  Widget _buildMobilePaginationControls(
    BuildContext context,
    int totalPages,
    int totalFiltered,
    List<VillaTypeConfigEntity> configs,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Info and page size selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getPaginationRangeText(configs),
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
                onChanged: (value) => _onPageSizeChanged(value, configs),
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
              onPressed: _currentPage > 1 ? () => _goToPage(1, configs) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, configs)
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
                  ? () => _goToPage(_currentPage + 1, configs)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, configs)
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
    List<VillaTypeConfigEntity> configs,
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
              _getPaginationRangeText(configs),
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
                    onChanged: (value) => _onPageSizeChanged(value, configs),
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
              onPressed: _currentPage > 1 ? () => _goToPage(1, configs) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, configs)
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
                  onTap: () => _goToPage(page, configs),
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
                  ? () => _goToPage(_currentPage + 1, configs)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, configs)
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
