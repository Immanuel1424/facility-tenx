import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/pluto_grid_config.dart';
import '../../data/repositories/company_repository.dart';
import '../../domain/entities/company_entity.dart';
import '../bloc/company_bloc.dart';
import '../bloc/company_event.dart';
import '../bloc/company_state.dart';
import 'company_create_page.dart';

class CompanyListPage extends StatelessWidget {
  const CompanyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompanyBloc(
        repository: CompanyRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(const LoadCompanyList()),
      child: const _CompanyListContent(),
    );
  }
}

class _CompanyListContent extends StatefulWidget {
  const _CompanyListContent();

  @override
  State<_CompanyListContent> createState() => _CompanyListContentState();
}

class _CompanyListContentState extends State<_CompanyListContent> {
  // Note: Business data comes from BLoC state, not local variables

  // Filter state (UI-only, for local filtering)
  final _searchController = TextEditingController();
  String? _selectedStatus;

  // Pagination state (UI-only)
  int _currentPage = 1;
  int _itemsPerPage = 20;
  static const List<int> _pageSizeOptions = [10, 20, 50, 100];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCompanies() {
    if (mounted) {
      context.read<CompanyBloc>().add(const LoadCompanyList());
    }
  }

  List<CompanyEntity> _getFilteredCompanies(List<CompanyEntity> companies) {
    var filtered = List<CompanyEntity>.from(companies);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((company) {
        final code = company.code.toLowerCase();
        final name = company.name.toLowerCase();
        final description = (company.description ?? '').toLowerCase();
        return code.contains(query) ||
            name.contains(query) ||
            description.contains(query);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((company) {
        switch (_selectedStatus!.toLowerCase()) {
          case 'active':
            return company.isActive == true;
          case 'inactive':
            return company.isActive == false;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  List<CompanyEntity> _getPaginatedCompanies(List<CompanyEntity> companies) {
    final filtered = _getFilteredCompanies(companies);
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

  int _getTotalPages(List<CompanyEntity> companies) {
    final filtered = _getFilteredCompanies(companies);
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  String _getPaginationRangeText(List<CompanyEntity> companies) {
    final filtered = _getFilteredCompanies(companies);
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

  void _goToPage(int page, List<CompanyEntity> companies) {
    final totalPages = _getTotalPages(companies);
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _onPageSizeChanged(int? newSize) {
    if (newSize != null && newSize != _itemsPerPage) {
      setState(() {
        _itemsPerPage = newSize;
        _currentPage = 1; // Reset to first page when changing page size
      });
    }
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final minWidths = {
      'code': 120.0,
      'name': 200.0,
      'description': 250.0,
      'timezone': 150.0,
      'currency': 100.0,
      'isActive': 100.0,
      'createdAt': 180.0,
      'actions': 80.0,
    };

    final totalMinWidth =
        minWidths.values.fold(0.0, (sum, width) => sum + width);
    final widthMultiplier =
        availableWidth < totalMinWidth ? 1.0 : (availableWidth / totalMinWidth);

    final theme = Theme.of(context);

    return [
      PlutoColumn(
        title: 'Code',
        field: 'code',
        type: PlutoColumnType.text(),
        width: (minWidths['code']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        minWidth: 100,
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
            .clamp(200.0, double.infinity),
        minWidth: 150,
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
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
            .clamp(250.0, double.infinity),
        minWidth: 200,
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
        title: 'Timezone',
        field: 'timezone',
        type: PlutoColumnType.text(),
        width: (minWidths['timezone']! * widthMultiplier)
            .clamp(150.0, double.infinity),
        minWidth: 120,
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
        title: 'Currency',
        field: 'currency',
        type: PlutoColumnType.text(),
        width: (minWidths['currency']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        minWidth: 80,
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
        title: 'Status',
        field: 'isActive',
        type: PlutoColumnType.text(),
        width: (minWidths['isActive']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        minWidth: 100,
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final isActive = rendererContext.cell.value as bool;
          return UnconstrainedBox(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: context.cardBorderRadius,
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                ),
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
        minWidth: 150,
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          if (value is DateTime) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                DateFormat('MMM d, y').format(value),
                style: const TextStyle(fontSize: 13),
              ),
            );
          }
          return const Text('—');
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
          final companyId = rendererContext.cell.value.toString();
          return Center(
            child: IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              padding: EdgeInsets.zero,
              onPressed: () {
                context.push('/companies/$companyId');
              },
              tooltip: 'View Details',
            ),
          );
        },
      ),
    ];
  }

  Widget _buildPaginationControls(
    BuildContext context,
    List<CompanyEntity> companies,
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
              companies,
              totalPages,
              totalFiltered,
            )
          : _buildDesktopPaginationControls(
              context,
              companies,
              totalPages,
              totalFiltered,
            ),
    );
  }

  Widget _buildMobilePaginationControls(
    BuildContext context,
    List<CompanyEntity> companies,
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
              _getPaginationRangeText(companies),
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
              onPressed:
                  _currentPage > 1 ? () => _goToPage(1, companies) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, companies)
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
                  ? () => _goToPage(_currentPage + 1, companies)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, companies)
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
    List<CompanyEntity> companies,
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
              _getPaginationRangeText(companies),
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
              onPressed:
                  _currentPage > 1 ? () => _goToPage(1, companies) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, companies)
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
                  onTap: () => _goToPage(page, companies),
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
                  ? () => _goToPage(_currentPage + 1, companies)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, companies)
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
          title: const Text('Companies'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: BlocConsumer<CompanyBloc, CompanyState>(
          listener: (context, state) {
            state.maybeWhen(
              created: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Company created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<CompanyBloc>().add(const LoadCompanyList());
              },
              updated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Company updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<CompanyBloc>().add(const LoadCompanyList());
              },
              deleted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Company deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<CompanyBloc>().add(const LoadCompanyList());
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
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              listLoaded: (companies) {
                // Read directly from BLoC state - no local duplication needed
                if (companies.isEmpty) {
                  return Center(
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
                          'No companies found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final isWeb = screenWidth >= 768;
                            if (isWeb) {
                              final shouldRefresh =
                                  await CompanyCreateDialog.show(context);
                              if (shouldRefresh == true) {
                                _loadCompanies();
                              }
                            } else {
                              final shouldRefresh =
                                  await context.push<bool>('/companies/create');
                              if (shouldRefresh == true) {
                                _loadCompanies();
                              }
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Company'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Filter Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
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
                                  hintText: 'Search companies...',
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
                                  setState(() {
                                    _currentPage =
                                        1; // Reset to first page on search
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
                                    _currentPage =
                                        1; // Reset to first page on filter change
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentPage = 1;
                                    _searchController.clear();
                                    _selectedStatus = null;
                                  });
                                  context.read<CompanyBloc>().add(
                                        const LoadCompanyList(),
                                      );
                                },
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
                                  if (isWeb) {
                                    final shouldRefresh =
                                        await CompanyCreateDialog.show(context);
                                    if (shouldRefresh == true) {
                                      _loadCompanies();
                                    }
                                  } else {
                                    final shouldRefresh = await context
                                        .push<bool>('/companies/create');
                                    if (shouldRefresh == true) {
                                      _loadCompanies();
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Create Company'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Pluto Grid
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final columns = _buildColumns(availableWidth);
                          final filteredCompanies =
                              _getFilteredCompanies(companies);
                          final totalPages = _getTotalPages(companies);

                          // Reset to page 1 if current page exceeds total pages
                          if (totalPages > 0 && _currentPage > totalPages) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _currentPage = 1;
                                });
                              }
                            });
                          }

                          final paginatedCompanies =
                              _getPaginatedCompanies(companies);
                          final rows = paginatedCompanies.map((company) {
                            return PlutoRow(
                              cells: {
                                'actions': PlutoCell(value: company.id),
                                'code': PlutoCell(value: company.code),
                                'name': PlutoCell(value: company.name),
                                'description':
                                    PlutoCell(value: company.description ?? ''),
                                'timezone':
                                    PlutoCell(value: company.timezone ?? ''),
                                'currency':
                                    PlutoCell(value: company.currency ?? ''),
                                'isActive': PlutoCell(value: company.isActive),
                                'createdAt':
                                    PlutoCell(value: company.createdAt),
                              },
                            );
                          }).toList();

                          if (filteredCompanies.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 64,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No companies found',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Theme(
                            data: PlutoGridConfig.buildGridTheme(context),
                            child: PlutoGrid(
                              key: ValueKey(
                                'companies_${_currentPage}_${_itemsPerPage}',
                              ),
                              columns: columns,
                              rows: rows,
                              onLoaded: (PlutoGridOnLoadedEvent event) {
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

                    // Pagination Controls
                    Builder(
                      builder: (context) {
                        final filteredCompanies =
                            _getFilteredCompanies(companies);
                        final totalPages = _getTotalPages(companies);
                        if (filteredCompanies.isEmpty || totalPages <= 1) {
                          return const SizedBox.shrink();
                        }
                        return _buildPaginationControls(
                          context,
                          companies,
                          totalPages,
                          filteredCompanies.length,
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
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<CompanyBloc>()
                              .add(const LoadCompanyList());
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
}
