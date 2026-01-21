import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/permission_checker.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/pluto_grid_config.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/announcement_entity.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import 'announcement_create_page.dart';

class AnnouncementListPage extends StatelessWidget {
  const AnnouncementListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
        final canCreate = user != null &&
            PermissionChecker.canPerform(user, 'announcement', 'create');
        final isAdmin = user != null &&
            PermissionChecker.canPerform(user, 'announcement', 'read');

        return BlocProvider(
          create: (context) => getIt<AnnouncementBloc>()
            ..add(isAdmin
                ? const LoadAnnouncementsForAdmin()
                : const LoadAnnouncements()),
          child: _AnnouncementListContent(
            canCreate: canCreate,
          ),
        );
      },
    );
  }
}

class _AnnouncementListContent extends StatefulWidget {
  const _AnnouncementListContent({required this.canCreate});

  final bool canCreate;

  @override
  State<_AnnouncementListContent> createState() =>
      _AnnouncementListContentState();
}

class _AnnouncementListContentState extends State<_AnnouncementListContent> {
  PlutoGridStateManager? _stateManager;

  // Filter state (UI-only, for local filtering)
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryFilter;
  String? _selectedPriorityFilter;
  String? _selectedStatusFilter;

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
    final authState = context.read<AuthBloc>().state;
    final user = authState.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
    final isAdmin = user != null &&
        PermissionChecker.canPerform(user, 'announcement', 'read');
    context.read<AnnouncementBloc>().add(
          isAdmin
              ? const LoadAnnouncementsForAdmin()
              : const LoadAnnouncements(),
        );
  }

  List<AnnouncementEntity> _getFilteredAnnouncements(
    List<AnnouncementEntity> announcements,
  ) {
    var filtered = List<AnnouncementEntity>.from(announcements);

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((announcement) {
        final title = announcement.title.toLowerCase();
        final message = announcement.message.toLowerCase();
        return title.contains(query) || message.contains(query);
      }).toList();
    }

    if (_selectedCategoryFilter != null &&
        _selectedCategoryFilter!.isNotEmpty) {
      filtered = filtered.where((announcement) {
        return announcement.category.name == _selectedCategoryFilter;
      }).toList();
    }

    if (_selectedPriorityFilter != null &&
        _selectedPriorityFilter!.isNotEmpty) {
      filtered = filtered.where((announcement) {
        return announcement.priority.name == _selectedPriorityFilter;
      }).toList();
    }

    if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
      filtered = filtered.where((announcement) {
        if (_selectedStatusFilter == 'published') {
          return announcement.isPublished;
        }
        if (_selectedStatusFilter == 'draft') {
          return !announcement.isPublished;
        }
        return true;
      }).toList();
    }

    return filtered;
  }

  List<AnnouncementEntity> _getPaginatedAnnouncements(
    List<AnnouncementEntity> announcements,
  ) {
    final filtered = _getFilteredAnnouncements(announcements);
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

  int _getTotalPages(List<AnnouncementEntity> announcements) {
    final filtered = _getFilteredAnnouncements(announcements);
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  String _getPaginationRangeText(List<AnnouncementEntity> announcements) {
    final filtered = _getFilteredAnnouncements(announcements);
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

  void _updateGridRows(List<AnnouncementEntity> announcements) {
    if (_stateManager == null) return;
    final paginatedAnnouncements = _getPaginatedAnnouncements(announcements);
    final rows = paginatedAnnouncements
        .map(
          (announcement) => PlutoRow(
            cells: <String, PlutoCell>{
              'actions': PlutoCell(value: announcement.id),
              'title': PlutoCell(value: announcement.title),
              'message': PlutoCell(value: announcement.message),
              'category': PlutoCell(value: announcement.category),
              'priority': PlutoCell(value: announcement.priority),
              'status': PlutoCell(value: announcement.isPublished),
              'targetAudience': PlutoCell(value: announcement.targetAudience),
              'createdAt': PlutoCell(value: announcement.createdAt),
            },
          ),
        )
        .toList();
    _stateManager!.removeAllRows();
    _stateManager!.appendRows(rows);
  }

  void _goToPage(int page, List<AnnouncementEntity> announcements) {
    final totalPages = _getTotalPages(announcements);
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
      // Update grid rows when page changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateGridRows(announcements);
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
      // Get current announcements from BLoC state to update grid
      final state = context.read<AnnouncementBloc>().state;
      if (state is AnnouncementListLoaded) {
        _updateGridRows(state.announcements);
      }
    }
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final Map<String, double> minWidths = <String, double>{
      'title': 200,
      'message': 300,
      'category': 120,
      'priority': 100,
      'status': 100,
      'targetAudience': 120,
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
        title: 'Title',
        field: 'title',
        type: PlutoColumnType.text(),
        width: (minWidths['title']! * widthMultiplier)
            .clamp(200.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      PlutoColumn(
        title: 'Message',
        field: 'message',
        type: PlutoColumnType.text(),
        width: (minWidths['message']! * widthMultiplier)
            .clamp(300.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          );
        },
      ),
      PlutoColumn(
        title: 'Category',
        field: 'category',
        type: PlutoColumnType.text(),
        width: (minWidths['category']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final category = rendererContext.cell.value as AnnouncementCategory;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: context.cardBorderRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 14,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  category.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Priority',
        field: 'priority',
        type: PlutoColumnType.text(),
        width: (minWidths['priority']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final priority = rendererContext.cell.value as AnnouncementPriority;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityBackgroundColor(context, priority),
              borderRadius: context.cardBorderRadius,
              border: Border.all(
                color: _getPriorityTextColor(context, priority)
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              priority.displayName.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getPriorityTextColor(context, priority),
                fontWeight: FontWeight.w600,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        width: (minWidths['status']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final isPublished = rendererContext.cell.value as bool;
          final color =
              isPublished ? Colors.green.shade700 : Colors.orange.shade700;
          final bg = isPublished ? Colors.green.shade50 : Colors.orange.shade50;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: context.cardBorderRadius,
            ),
            child: Text(
              isPublished ? 'Published' : 'Draft',
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
        title: 'Target',
        field: 'targetAudience',
        type: PlutoColumnType.text(),
        width: (minWidths['targetAudience']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final targetAudience =
              rendererContext.cell.value as AnnouncementTargetAudience;
          if (targetAudience == AnnouncementTargetAudience.roles) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: context.cardBorderRadius,
              ),
              child: Text(
                'ROLES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            );
          }
          return Text(
            'ALL',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10,
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
        renderer: (rendererContext) {
          final dateTime = rendererContext.cell.value as DateTime;
          return Text(
            DateFormat('MMM dd, yyyy HH:mm').format(dateTime),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        renderer: (rendererContext) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: Colors.blue,
                ),
                tooltip: 'View Announcement',
                onPressed: () {
                  // Navigate to detail page if needed
                  // final id = rendererContext.cell.value.toString();
                  // context.push('/announcements/$id');
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
    List<AnnouncementEntity> announcements,
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
              announcements,
              totalPages,
              totalFiltered,
            )
          : _buildDesktopPaginationControls(
              context,
              announcements,
              totalPages,
              totalFiltered,
            ),
    );
  }

  Widget _buildMobilePaginationControls(
    BuildContext context,
    List<AnnouncementEntity> announcements,
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
              _getPaginationRangeText(announcements),
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
                  _currentPage > 1 ? () => _goToPage(1, announcements) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () => _goToPage(_currentPage - 1, announcements)
                  : null,
              tooltip: 'Previous Page',
            ),
            Text(
              'Page $_currentPage of $totalPages',
              style: theme.textTheme.bodyMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(_currentPage + 1, announcements)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < totalPages
                  ? () => _goToPage(totalPages, announcements)
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
    List<AnnouncementEntity> announcements,
    int totalPages,
    int totalFiltered,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Info text
        Text(
          _getPaginationRangeText(announcements),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        // Right side: Page size selector and navigation
        Row(
          children: [
            // Page size selector
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
                    style: theme.textTheme.bodyMedium,
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
                        child: Text('$size'),
                      );
                    }).toList(),
                    onChanged: _onPageSizeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Page navigation buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: _currentPage > 1
                      ? () => _goToPage(1, announcements)
                      : null,
                  tooltip: 'First Page',
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () => _goToPage(_currentPage - 1, announcements)
                      : null,
                  tooltip: 'Previous Page',
                ),
                // Page numbers
                ..._buildPageNumbers(totalPages).map((pageNum) {
                  if (pageNum == -1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  final isActive = pageNum == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextButton(
                      onPressed: () => _goToPage(pageNum, announcements),
                      style: TextButton.styleFrom(
                        backgroundColor: isActive
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        foregroundColor: isActive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('$pageNum'),
                    ),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages
                      ? () => _goToPage(_currentPage + 1, announcements)
                      : null,
                  tooltip: 'Next Page',
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: _currentPage < totalPages
                      ? () => _goToPage(totalPages, announcements)
                      : null,
                  tooltip: 'Last Page',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<int> _buildPageNumbers(int totalPages) {
    if (totalPages <= 7) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final pages = <int>[];
    final currentPage = _currentPage;

    if (currentPage <= 3) {
      // Near the beginning
      pages.addAll([1, 2, 3, 4, -1, totalPages]);
    } else if (currentPage >= totalPages - 2) {
      // Near the end
      pages.addAll(
          [1, -1, totalPages - 3, totalPages - 2, totalPages - 1, totalPages]);
    } else {
      // In the middle
      pages.addAll([
        1,
        -1,
        currentPage - 1,
        currentPage,
        currentPage + 1,
        -1,
        totalPages
      ]);
    }

    return pages;
  }

  @override
  void initState() {
    super.initState();
    // Ensure announcements are loaded when page is first displayed
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
        title: const Text('Announcements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listener: (context, state) {
          if (state is AnnouncementListLoaded) {
            // Update grid rows when data is loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _updateGridRows(state.announcements);
              }
            });
          } else if (state is AnnouncementCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Announcement created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _reload();
          } else if (state is AnnouncementUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Announcement updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _reload();
          } else if (state is AnnouncementDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Announcement deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _reload();
          } else if (state is AnnouncementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnnouncementInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AnnouncementLoading) {
            _stateManager?.setShowLoading(true);
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AnnouncementListLoaded) {
            final announcements = state.announcements;
            if (announcements.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No announcements found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      if (widget.canCreate) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final created =
                                await AnnouncementCreateDialog.show(context);
                            if (created == true && context.mounted) {
                              _reload();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Announcement'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return ResponsiveLayout(
              mobileBreakpoint: 768,
              mobileBuilder: (context) => _buildMobileLayout(
                context,
                announcements,
                theme,
              ),
              desktopBuilder: (context) => _buildDesktopLayout(
                context,
                announcements,
                theme,
              ),
            );
          } else if (state is AnnouncementDetailLoaded ||
              state is AnnouncementCreated ||
              state is AnnouncementUpdated ||
              state is AnnouncementDeleted) {
            return const SizedBox.shrink();
          } else if (state is AnnouncementError) {
            return Center(
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
                      'Error: ${state.message}',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<AnnouncementEntity> announcements,
    ThemeData theme,
  ) {
    // For mobile, show a simplified list view
    final filtered = _getFilteredAnnouncements(announcements);
    return Column(
      children: [
        // Search and filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search announcements...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (_) {
                  setState(() {
                    _currentPage = 1;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reload,
                      child: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.canCreate
                          ? () async {
                              final shouldRefresh =
                                  await context.push<bool>(
                                '/announcements/create',
                              );
                              if (shouldRefresh == true && context.mounted) {
                                _reload();
                              }
                            }
                          : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Announcement'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // List view
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _reload();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final announcement = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!announcement.isPublished)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DRAFT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          announcement.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: context.cardBorderRadius,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getCategoryIcon(announcement.category),
                                    size: 14,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    announcement.category.displayName,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityBackgroundColor(
                                  context,
                                  announcement.priority,
                                ),
                                borderRadius: context.cardBorderRadius,
                                border: Border.all(
                                  color: _getPriorityTextColor(
                                    context,
                                    announcement.priority,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                announcement.priority.displayName.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getPriorityTextColor(
                                    context,
                                    announcement.priority,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(announcement.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to detail page if needed
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    List<AnnouncementEntity> announcements,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // Search and filters
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
                      hintText: 'Search announcements...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) {
                      setState(() {
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Category filter
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategoryFilter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: false,
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...AnnouncementCategory.values.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Text(category.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryFilter = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Priority filter
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriorityFilter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: false,
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Priorities'),
                      ),
                      ...AnnouncementPriority.values.map((priority) {
                        return DropdownMenuItem<String>(
                          value: priority.name,
                          child: Text(priority.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPriorityFilter = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Status filter
                Flexible(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatusFilter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: false,
                    ),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Status'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'published',
                        child: Text('Published'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'draft',
                        child: Text('Draft'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatusFilter = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Refresh Button
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
                // Create Announcement Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.canCreate
                        ? () async {
                            final screenWidth =
                                MediaQuery.of(context).size.width;
                            final isWeb = screenWidth >= 768;

                            if (isWeb) {
                              // Show dialog on web
                              final shouldRefresh =
                                  await AnnouncementCreateDialog.show(context);
                              if (shouldRefresh == true && context.mounted) {
                                _reload();
                              }
                            } else {
                              // Navigate to full page on mobile
                              final shouldRefresh =
                                  await context.push<bool>(
                                '/announcements/create',
                              );
                              if (shouldRefresh == true && context.mounted) {
                                _reload();
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                    child: const Text('Create Announcement'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Grid
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
                final paginatedAnnouncements =
                    _getPaginatedAnnouncements(announcements);
                final rows = paginatedAnnouncements
                    .map(
                      (announcement) => PlutoRow(
                        cells: <String, PlutoCell>{
                          'actions': PlutoCell(value: announcement.id),
                          'title': PlutoCell(value: announcement.title),
                          'message': PlutoCell(value: announcement.message),
                          'category': PlutoCell(value: announcement.category),
                          'priority': PlutoCell(value: announcement.priority),
                          'status': PlutoCell(value: announcement.isPublished),
                          'targetAudience':
                              PlutoCell(value: announcement.targetAudience),
                          'createdAt': PlutoCell(value: announcement.createdAt),
                        },
                      ),
                    )
                    .toList();

                if (rows.isEmpty) {
                  final filtered = _getFilteredAnnouncements(announcements);
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No announcements match your filters',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    );
                  }
                  // Reset to first page if current page is out of bounds
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_currentPage > _getTotalPages(announcements)) {
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
                        'announcements_${_currentPage}_${_itemsPerPage}'),
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        stateManager.scroll.horizontal?.jumpTo(0);
                      });
                    },
                    configuration: PlutoGridConfig.buildConfiguration(context),
                  ),
                );
              },
            ),
          ),
        ),
        // Pagination Controls
        Builder(
          builder: (context) {
            final filteredAnnouncements =
                _getFilteredAnnouncements(announcements);
            final totalPages = _getTotalPages(announcements);
            if (filteredAnnouncements.isEmpty || totalPages <= 1) {
              return const SizedBox.shrink();
            }
            return _buildPaginationControls(
              context,
              announcements,
              totalPages,
              filteredAnnouncements.length,
            );
          },
        ),
      ],
    );
  }

  static IconData _getCategoryIcon(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.maintenance:
        return Icons.build;
      case AnnouncementCategory.emergency:
        return Icons.warning;
      case AnnouncementCategory.general:
        return Icons.info;
      case AnnouncementCategory.info:
        return Icons.notifications;
    }
  }

  static Color _getPriorityBackgroundColor(
    BuildContext context,
    AnnouncementPriority priority,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case AnnouncementPriority.low:
        return isDark
            ? Colors.green.shade900.withValues(alpha: 0.3)
            : Colors.green.shade50;
      case AnnouncementPriority.medium:
        return isDark
            ? Colors.blue.shade900.withValues(alpha: 0.3)
            : Colors.blue.shade50;
      case AnnouncementPriority.high:
        return isDark
            ? Colors.orange.shade900.withValues(alpha: 0.3)
            : Colors.orange.shade50;
      case AnnouncementPriority.urgent:
        return isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50;
    }
  }

  static Color _getPriorityTextColor(
    BuildContext context,
    AnnouncementPriority priority,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case AnnouncementPriority.low:
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case AnnouncementPriority.medium:
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case AnnouncementPriority.high:
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case AnnouncementPriority.urgent:
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
    }
  }
}
