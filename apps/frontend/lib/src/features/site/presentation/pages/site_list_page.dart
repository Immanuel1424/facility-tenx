import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/pluto_grid_config.dart';
import '../../../../core/utils/permission_checker.dart';
import '../../data/repositories/site_repository.dart';
import '../../domain/entities/site_entity.dart';
import '../bloc/site_bloc.dart';
import '../bloc/site_event.dart';
import '../bloc/site_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../company/presentation/bloc/company_bloc.dart';
import '../../../company/presentation/bloc/company_event.dart';
import '../../../company/presentation/bloc/company_state.dart';
import '../../../company/data/repositories/company_repository.dart';
import 'site_create_page.dart';

class SiteListPage extends StatelessWidget {
  const SiteListPage({
    super.key,
    this.companyId,
  });

  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SiteBloc(
            repository: SiteRepository(
              apiClient: getIt<ApiClient>(),
            ),
          )..add(LoadSiteList(companyId: companyId)),
        ),
        BlocProvider(
          create: (context) => CompanyBloc(
            repository: CompanyRepository(
              apiClient: getIt<ApiClient>(),
            ),
          )..add(const LoadCompanyList()),
        ),
      ],
      child: _SiteListContent(companyId: companyId),
    );
  }
}

class _SiteListContent extends StatefulWidget {
  const _SiteListContent({
    this.companyId,
  });

  final String? companyId;

  @override
  State<_SiteListContent> createState() => _SiteListContentState();
}

class _SiteListContentState extends State<_SiteListContent> {
  PlutoGridStateManager? _stateManager;
  // Note: Business data comes from BLoC state, not local variables

  // Filter state (UI-only, for local filtering)
  final TextEditingController _searchController = TextEditingController();
  String? _selectedParentFilter;
  String? _selectedCompanyId;

  // Pagination state (UI-only)
  int _currentPage = 1;
  int _itemsPerPage = 20;
  static const List<int> _pageSizeOptions = [10, 20, 50, 100];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    // Use selectedCompanyId if SUPER_ADMIN, otherwise use widget.companyId
    final targetCompanyId = _selectedCompanyId ?? widget.companyId;
    context.read<SiteBloc>().add(
          LoadSiteList(companyId: targetCompanyId),
        );
  }

  List<SiteEntity> _getFilteredSites(List<SiteEntity> sites) {
    var filtered = List<SiteEntity>.from(sites);

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((site) {
        final code = site.code.toLowerCase();
        final name = site.name.toLowerCase();
        final description = (site.description ?? '').toLowerCase();
        return code.contains(query) ||
            name.contains(query) ||
            description.contains(query);
      }).toList();
    }

    if (_selectedParentFilter != null && _selectedParentFilter!.isNotEmpty) {
      filtered = filtered.where((site) {
        if (_selectedParentFilter == 'parent') {
          return site.isParent;
        }
        if (_selectedParentFilter == 'child') {
          return !site.isParent;
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  List<SiteEntity> _getPaginatedSites(List<SiteEntity> sites) {
    final filtered = _getFilteredSites(sites);
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

  int _getTotalPages(List<SiteEntity> sites) {
    final filtered = _getFilteredSites(sites);
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  String _getPaginationRangeText(List<SiteEntity> sites) {
    final filtered = _getFilteredSites(sites);
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

  void _updateGridRows(List<SiteEntity> sites) {
    if (_stateManager == null) return;
    final paginatedSites = _getPaginatedSites(sites);
    final rows = paginatedSites
        .map(
          (site) => PlutoRow(
            cells: <String, PlutoCell>{
              'actions': PlutoCell(value: site.id),
              'code': PlutoCell(value: site.code),
              'name': PlutoCell(value: site.name),
              'isParent': PlutoCell(value: site.isParent),
              'parentName': PlutoCell(value: ''),
              'isActive': PlutoCell(value: site.isActive),
              'createdAt': PlutoCell(value: site.createdAt),
            },
          ),
        )
        .toList();
    _stateManager!.removeAllRows();
    _stateManager!.appendRows(rows);
  }

  void _goToPage(int page, List<SiteEntity> sites) {
    final totalPages = _getTotalPages(sites);
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
      // Update grid rows when page changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateGridRows(sites);
        }
      });
    }
  }

  void _onPageSizeChanged(int? newSize) {
    if (newSize != null && newSize != _itemsPerPage) {
      setState(() {
        _itemsPerPage = newSize;
        _currentPage = 1; // Reset to first page when changing page size
      });
      // Get current sites from BLoC state to update grid
      final state = context.read<SiteBloc>().state;
      state.maybeWhen(
        listLoaded: (sites) {
          _updateGridRows(sites);
        },
        orElse: () {},
      );
    }
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final Map<String, double> minWidths = <String, double>{
      'code': 120,
      'name': 220,
      'isParent': 110,
      'parentName': 200,
      'isActive': 100,
      'createdAt': 180,
      'actions': 80,
    };

    final double totalMinWidth = minWidths.values.fold(
      0,
      (double sum, double width) => sum + width,
    );
    final double widthMultiplier =
        availableWidth < totalMinWidth ? 1.0 : (availableWidth / totalMinWidth);

    final theme = Theme.of(context);

    return <PlutoColumn>[
      PlutoColumn(
        title: 'Code',
        field: 'code',
        type: PlutoColumnType.text(),
        width: (minWidths['code']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  value.isNotEmpty ? value[0].toUpperCase() : '?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
        width: (minWidths['name']! * widthMultiplier)
            .clamp(220.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: 'Type',
        field: 'isParent',
        type: PlutoColumnType.text(),
        width: (minWidths['isParent']! * widthMultiplier)
            .clamp(110.0, double.infinity),
        enableSorting: true,
        renderer: (rendererContext) {
          final bool isParent = rendererContext.cell.value as bool;
          final label = isParent ? 'Parent' : 'Child';
          final color =
              isParent ? Colors.blue.shade700 : Colors.deepPurple.shade700;
          final bg = isParent ? Colors.blue.shade50 : Colors.deepPurple.shade50;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: context.cardBorderRadius,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Parent Site',
        field: 'parentName',
        type: PlutoColumnType.text(),
        width: (minWidths['parentName']! * widthMultiplier)
            .clamp(200.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'isActive',
        type: PlutoColumnType.text(),
        width: (minWidths['isActive']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final isActive = rendererContext.cell.value as bool;
          final color = isActive ? Colors.green.shade700 : Colors.red.shade700;
          final bg = isActive ? Colors.green.shade50 : Colors.red.shade50;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: context.cardBorderRadius,
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Created At',
        field: 'createdAt',
        type: PlutoColumnType.text(),
        width: (minWidths['createdAt']! * widthMultiplier)
            .clamp(180.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: minWidths['actions']!,
        enableSorting: false,
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        renderer: (rendererContext) {
          final id = rendererContext.cell.value.toString();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Colors.blue,
                ),
                tooltip: 'View Site Details',
                onPressed: () {
                  context.push('/sites/$id');
                },
              ),
            ],
          );
        },
      ),
    ];
  }

  Widget _buildPaginationControls(
    BuildContext context,
    List<SiteEntity> sites,
    int totalPages,
    int totalFiltered,
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
              sites,
              totalPages,
              totalFiltered,
            )
          : _buildDesktopPaginationControls(
              context,
              sites,
              totalPages,
              totalFiltered,
            ),
    );
  }

  Widget _buildMobilePaginationControls(
    BuildContext context,
    List<SiteEntity> sites,
    int totalPages,
    int totalFiltered,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Info and page size selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getPaginationRangeText(sites),
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
                onChanged: _onPageSizeChanged,
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
              onPressed: _currentPage > 1 ? () => _goToPage(1, sites) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, sites)
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
                  ? () => _goToPage(_currentPage + 1, sites)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, sites)
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
    List<SiteEntity> sites,
    int totalPages,
    int totalFiltered,
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
              _getPaginationRangeText(sites),
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
                    onChanged: _onPageSizeChanged,
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
              onPressed: _currentPage > 1 ? () => _goToPage(1, sites) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, sites)
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
                  onTap: () => _goToPage(page, sites),
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
                  ? () => _goToPage(_currentPage + 1, sites)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, sites)
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

  @override
  void initState() {
    super.initState();
    // Ensure sites are loaded when page is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _reload();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: BlocConsumer<SiteBloc, SiteState>(
        listener: (context, state) {
          state.maybeWhen(
            listLoaded: (sites) {
              // Update grid rows when data is loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _updateGridRows(sites);
                }
              });
            },
            created: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Site created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _reload();
            },
            updated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Site updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _reload();
            },
            deleted: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Site deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _reload();
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: CircularProgressIndicator(),
            ),
            loading: () {
              _stateManager?.setShowLoading(true);
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            listLoaded: (sites) {
              if (sites.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sites found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final isWeb = screenWidth >= 768;
                            final effectiveCompanyId = widget.companyId ?? '';
                            final shouldRefresh = isWeb
                                ? await SiteCreateDialog.show(
                                    context,
                                    companyId: effectiveCompanyId,
                                  )
                                : await context.push<bool>(
                                    '/companies/$effectiveCompanyId/sites/create',
                                  );
                            if (shouldRefresh == true && mounted) {
                              _reload();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Site'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: context.cardBorderRadius,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                hintText: 'Search sites...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          // Controller updates trigger rebuild automatically
                                        },
                                      )
                                    : null,
                                isDense: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                filled: false,
                              ),
                              onChanged: (_) {
                                // Reset to first page when search changes
                                setState(() {
                                  _currentPage = 1;
                                });
                                // Update grid with filtered/paginated data
                                final state = context.read<SiteBloc>().state;
                                state.maybeWhen(
                                  listLoaded: (sites) {
                                    _updateGridRows(sites);
                                  },
                                  orElse: () {},
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedParentFilter,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Type',
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
                                    'All Types',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'parent',
                                  child: Text(
                                    'Parent Sites',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'child',
                                  child: Text(
                                    'Child Sites',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedParentFilter = value;
                                  _currentPage = 1; // Reset to first page
                                });
                                // Update grid with filtered/paginated data
                                final state = context.read<SiteBloc>().state;
                                state.maybeWhen(
                                  listLoaded: (sites) {
                                    _updateGridRows(sites);
                                  },
                                  orElse: () {},
                                );
                              },
                            ),
                          ),
                          // Company dropdown (SUPER_ADMIN only)
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              final isSuperAdmin = authState.maybeWhen<bool>(
                                    authenticated: (UserEntity user) =>
                                        PermissionChecker.isSuperAdmin(user),
                                    orElse: () => false,
                                  ) ??
                                  false;

                              if (!isSuperAdmin) {
                                return const SizedBox.shrink();
                              }

                              return BlocBuilder<CompanyBloc, CompanyState>(
                                builder: (context, companyState) {
                                  if (companyState is CompanyListLoaded) {
                                    return Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCompanyId,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.normal,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Company',
                                          labelStyle: TextStyle(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          isDense: true,
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          filled: false,
                                        ),
                                        isExpanded: true,
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text(
                                              'All Companies',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          ...companyState.companies.map(
                                            (company) => DropdownMenuItem(
                                              value: company.id,
                                              child: Text(
                                                company.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (String? value) {
                                          _selectedCompanyId = value;
                                          _reload();
                                          // No setState needed - _reload triggers BLoC event
                                        },
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _reload,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                              ),
                              child: const Text('Refresh'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final screenWidth =
                                    MediaQuery.of(context).size.width;
                                final isWeb = screenWidth >= 768;
                                final effectiveCompanyId =
                                    widget.companyId ?? '';
                                final shouldRefresh = isWeb
                                    ? await SiteCreateDialog.show(
                                        context,
                                        companyId: effectiveCompanyId,
                                      )
                                    : await context.push<bool>(
                                        '/companies/$effectiveCompanyId/sites/create',
                                      );
                                if (shouldRefresh == true && mounted) {
                                  _reload();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                              ),
                              child: const Text('Create Site'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: context.cardBorderRadius,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
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
                          final paginatedSites = _getPaginatedSites(sites);
                          final rows = paginatedSites
                              .map(
                                (site) => PlutoRow(
                                  cells: <String, PlutoCell>{
                                    'actions': PlutoCell(value: site.id),
                                    'code': PlutoCell(value: site.code),
                                    'name': PlutoCell(value: site.name),
                                    'isParent': PlutoCell(value: site.isParent),
                                    'parentName': PlutoCell(value: ''),
                                    'isActive': PlutoCell(value: site.isActive),
                                    'createdAt':
                                        PlutoCell(value: site.createdAt),
                                  },
                                ),
                              )
                              .toList();

                          if (rows.isEmpty) {
                            final filtered = _getFilteredSites(sites);
                            if (filtered.isEmpty) {
                              return Center(
                                child: Text(
                                  'No sites match your filters',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              );
                            }
                            // Reset to first page if current page is out of bounds
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_currentPage > _getTotalPages(sites)) {
                                setState(() {
                                  _currentPage = 1;
                                });
                              }
                            });
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return Theme(
                            data: PlutoGridConfig.buildGridTheme(context),
                            child: PlutoGrid(
                              key: ValueKey(
                                  'sites_${_currentPage}_${_itemsPerPage}'),
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
                              configuration: PlutoGridConfig.buildConfiguration(
                                context,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Pagination Controls
                  Builder(
                    builder: (context) {
                      final filteredSites = _getFilteredSites(sites);
                      final totalPages = _getTotalPages(sites);
                      if (filteredSites.isEmpty || totalPages <= 1) {
                        return const SizedBox.shrink();
                      }
                      return _buildPaginationControls(
                        context,
                        sites,
                        totalPages,
                        filteredSites.length,
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
                      style: TextStyle(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
