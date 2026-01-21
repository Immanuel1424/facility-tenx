import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/theme_helpers.dart';
import '../../../../../core/widgets/pluto_grid_config.dart';
import '../../../data/dto/update_ticket_category_dto.dart';
import '../../../data/repositories/ticket_category_repository.dart';
import '../../../domain/entities/ticket_category_entity.dart';
import '../../bloc/ticket_category/ticket_category_bloc.dart';
import '../../bloc/ticket_category/ticket_category_event.dart';
import '../../bloc/ticket_category/ticket_category_state.dart';
import 'ticket_category_create_page.dart';

class TicketCategoryListPage extends StatelessWidget {
  const TicketCategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TicketCategoryBloc(
        repository: TicketCategoryRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(const LoadTicketCategoryList()),
      child: const _TicketCategoryListContent(),
    );
  }
}

class _TicketCategoryListContent extends StatefulWidget {
  const _TicketCategoryListContent();

  @override
  State<_TicketCategoryListContent> createState() =>
      _TicketCategoryListContentState();
}

class _TicketCategoryListContentState
    extends State<_TicketCategoryListContent> with WidgetsBindingObserver {
  PlutoGridStateManager? _stateManager;
  bool _hasInitialBuild = false;

  // Filter state (UI-only, for local filtering)
  final _searchController = TextEditingController();
  String? _selectedStatus = 'active';

  // Pagination state (UI-only)
  int _currentPage = 1;
  int _itemsPerPage = 20;
  static const List<int> _pageSizeOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload list when app comes back to foreground
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TicketCategoryBloc>().add(
                const LoadTicketCategoryList(),
              );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when navigating to this page (including back navigation)
    // Skip on initial build since BlocProvider already loads on creation
    if (_hasInitialBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TicketCategoryBloc>().add(
                const LoadTicketCategoryList(),
              );
        }
      });
    } else {
      _hasInitialBuild = true;
    }
  }

  List<TicketCategoryEntity> _getFilteredCategories(
    List<TicketCategoryEntity> categories,
  ) {
    var filtered = List<TicketCategoryEntity>.from(categories);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((category) {
        final name = category.displayName.toLowerCase();
        final code = (category.code ?? '').toLowerCase();
        final description = (category.description ?? '').toLowerCase();
        return name.contains(query) ||
            code.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Filter by status (Active/Inactive)
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((category) {
        if (_selectedStatus == 'active') {
          return category.isActive;
        } else if (_selectedStatus == 'inactive') {
          return !category.isActive;
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  List<TicketCategoryEntity> _getPaginatedCategories(
    List<TicketCategoryEntity> categories,
  ) {
    final filtered = _getFilteredCategories(categories);
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

  int _getTotalPages(List<TicketCategoryEntity> categories) {
    final filtered = _getFilteredCategories(categories);
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  String _getPaginationRangeText(List<TicketCategoryEntity> categories) {
    final filtered = _getFilteredCategories(categories);
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

  void _goToPage(int page, List<TicketCategoryEntity> categories) {
    final totalPages = _getTotalPages(categories);
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
      _updateGridData(categories);
    }
  }

  void _onPageSizeChanged(
    int? newSize,
    List<TicketCategoryEntity> categories,
  ) {
    if (newSize != null && newSize != _itemsPerPage) {
      setState(() {
        _itemsPerPage = newSize;
        _currentPage = 1; // Reset to first page when changing page size
      });
      _updateGridData(categories);
    }
  }

  void _updateGridData(List<TicketCategoryEntity> categories) {
    if (_stateManager == null) return;

    final paginatedCategories = _getPaginatedCategories(categories);
    final rows = _buildRows(paginatedCategories);

    _stateManager!.removeAllRows();
    _stateManager!.appendRows(rows);
  }

  void _showEditDialog(BuildContext context, TicketCategoryEntity category) {
    final nameController = TextEditingController(text: category.displayName);
    final descriptionController = TextEditingController(text: category.description ?? '');
    final bloc = context.read<TicketCategoryBloc>();

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                descriptionController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category name is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final dto = UpdateTicketCategoryDto(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );

                bloc.add(
                  UpdateTicketCategory(category.id, dto),
                );

                nameController.dispose();
                descriptionController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<PlutoRow> _buildRows(List<TicketCategoryEntity> categories) {
    return categories.map((category) {
      return PlutoRow(
        cells: {
          'actions': PlutoCell(value: category),
          'display_name': PlutoCell(value: category.displayName),
          'code': PlutoCell(value: category.code ?? ''),
          'description': PlutoCell(value: category.description ?? ''),
          'is_active': PlutoCell(value: category.isActive),
        },
      );
    }).toList();
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final minWidths = {
      'display_name': 180.0,
      'code': 120.0,
      'description': 200.0,
      'is_active': 110.0,
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
        title: 'Category Name',
        field: 'display_name',
        type: PlutoColumnType.text(),
        width: (minWidths['display_name']! * widthMultiplier)
            .clamp(180.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final displayName = rendererContext.cell.value.toString();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              displayName,
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
        title: 'Code',
        field: 'code',
        type: PlutoColumnType.text(),
        width: (minWidths['code']! * widthMultiplier)
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
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
        width: (minWidths['description']! * widthMultiplier)
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
                    : theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
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
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: minWidths['actions']!,
        enableSorting: false,
        enableColumnDrag: false,
        enableFilterMenuItem: false,
        renderer: (rendererContext) {
          final category = rendererContext.cell.value as TicketCategoryEntity;
          return Center(
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showEditDialog(context, category),
              tooltip: 'Edit Category',
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
          title: const Text('Ticket Categories'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          actions: const [],
        ),
        body: BlocConsumer<TicketCategoryBloc, TicketCategoryState>(
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
              listLoaded: (categories) {
                // Update grid directly from BLoC state
                if (_stateManager != null) {
                  _updateGridData(categories);
                }
              },
              created: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<TicketCategoryBloc>().add(
                      const LoadTicketCategoryList(),
                    );
              },
              updated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<TicketCategoryBloc>().add(
                      const LoadTicketCategoryList(),
                    );
              },
              deleted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    context.read<TicketCategoryBloc>().add(
                          const LoadTicketCategoryList(),
                        );
                  }
                });
              },
              activated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category activated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<TicketCategoryBloc>().add(
                      const LoadTicketCategoryList(),
                    );
              },
              deactivated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deactivated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<TicketCategoryBloc>().add(
                      const LoadTicketCategoryList(),
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
              listLoaded: (categories) {
                return Column(
                  children: [
                    // 1. Modern Filter Bar
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
                                  hintText: 'Search by name, code, or description...',
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
                            // Refresh Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<TicketCategoryBloc>().add(
                                        const LoadTicketCategoryList(),
                                      );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Refresh'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Create Category Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final created = await TicketCategoryCreateDialog.show(context);
                                  if (created == true && context.mounted) {
                                    // Refresh the category list
                                    context.read<TicketCategoryBloc>().add(
                                          const LoadTicketCategoryList(),
                                        );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Create Category'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. Clean Grid
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
                            final filteredCategories =
                                _getFilteredCategories(categories);
                            final totalPages = _getTotalPages(categories);

                            // Reset to page 1 if current page exceeds total pages
                            if (totalPages > 0 && _currentPage > totalPages) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _goToPage(1, categories);
                              });
                            }

                            // Get paginated categories
                            final paginatedCategories =
                                _getPaginatedCategories(categories);
                            final rows = _buildRows(paginatedCategories);

                            // Show empty state when no categories match filters
                            if (rows.isEmpty || filteredCategories.isEmpty) {
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
                                          ? 'No categories found matching your filters'
                                          : 'No categories found',
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
                                    'categories_${_currentPage}_$_itemsPerPage'),
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
                        final filteredCategories =
                            _getFilteredCategories(categories);
                        final totalPages = _getTotalPages(categories);
                        if (filteredCategories.isEmpty || totalPages <= 1) {
                          return const SizedBox.shrink();
                        }
                        return _buildPaginationControls(
                          context,
                          totalPages,
                          filteredCategories.length,
                          categories,
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
                          context.read<TicketCategoryBloc>().add(
                                const LoadTicketCategoryList(),
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

  Widget _buildPaginationControls(
    BuildContext context,
    int totalPages,
    int totalFiltered,
    List<TicketCategoryEntity> categories,
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
              categories,
            )
          : _buildDesktopPaginationControls(
              context,
              totalPages,
              totalFiltered,
              categories,
            ),
    );
  }

  Widget _buildMobilePaginationControls(
    BuildContext context,
    int totalPages,
    int totalFiltered,
    List<TicketCategoryEntity> categories,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Info and page size selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getPaginationRangeText(categories),
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
                onChanged: (value) => _onPageSizeChanged(value, categories),
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
              onPressed: _currentPage > 1 ? () => _goToPage(1, categories) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, categories)
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
                  ? () => _goToPage(_currentPage + 1, categories)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, categories)
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
    List<TicketCategoryEntity> categories,
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
              _getPaginationRangeText(categories),
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
                    onChanged: (value) => _onPageSizeChanged(value, categories),
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
              onPressed: _currentPage > 1 ? () => _goToPage(1, categories) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, categories)
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
                  onTap: () => _goToPage(page, categories),
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
                  ? () => _goToPage(_currentPage + 1, categories)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, categories)
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
