import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/pluto_grid_config.dart';
import '../../../../core/utils/permission_checker.dart';
import '../../data/dto/user_dto.dart';
import '../../data/repositories/iam_repository.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../bloc/role/role_bloc.dart';
import '../bloc/role/role_event.dart';
import '../bloc/role/role_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../company/presentation/bloc/company_bloc.dart';
import '../../../company/presentation/bloc/company_event.dart';
import '../../../company/presentation/bloc/company_state.dart';
import '../../../company/data/repositories/company_repository.dart';
import 'user_create_page.dart';

/// Formats role name from uppercase with underscores to readable format
/// Example: "ADMIN" -> "Admin", "SITE_COORDINATOR" -> "Site Coordinator"
String _formatRoleName(String roleName) {
  return roleName
      .split('_')
      .map((word) => word.isEmpty
          ? ''
          : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

/// Extracts unit name from villas array
String _getUnitNameFromVillas(List<Map<String, dynamic>>? villas) {
  if (villas == null || villas.isEmpty) return '';
  // Get the first villa's unitName or unit_name
  final firstVilla = villas.first;
  return firstVilla['unitName'] as String? ??
      firstVilla['unit_name'] as String? ??
      '';
}

/// Extracts building name from villas array
String _getBuildingNameFromVillas(List<Map<String, dynamic>>? villas) {
  if (villas == null || villas.isEmpty) return '';
  // Get the first villa's buildingName or building_name
  final firstVilla = villas.first;
  return firstVilla['buildingName'] as String? ??
      firstVilla['building_name'] as String? ??
      '';
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key, this.initialCompanyId});

  final String? initialCompanyId;

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  PlutoGridStateManager? _stateManager;
  final List<UserDto> _allUsers = [];

  // Filter state
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedRole;
  String? _selectedCompanyId;

  // Pagination state (UI-only)
  int _currentPage = 1;
  int _itemsPerPage = 20;
  static const List<int> _pageSizeOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    if (widget.initialCompanyId != null) {
      _selectedCompanyId = widget.initialCompanyId;
      // UserBloc is already initialized with companyId in build method
      // No need to dispatch again here
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  List<UserDto> _getFilteredUsers() {
    var filtered = List<UserDto>.from(_allUsers);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((user) {
        final email = user.email.toLowerCase();
        final firstName = user.firstName?.toLowerCase() ?? '';
        final lastName = user.lastName?.toLowerCase() ?? '';
        return email.contains(query) ||
            firstName.contains(query) ||
            lastName.contains(query);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered
          .where(
            (user) =>
                user.status.toLowerCase() == _selectedStatus!.toLowerCase(),
          )
          .toList();
    }

    // Filter by role
    if (_selectedRole != null && _selectedRole!.isNotEmpty) {
      filtered = filtered.where((user) {
        if (user.roles == null || user.roles!.isEmpty) return false;
        return user.roles!
            .any((r) => r.toLowerCase() == _selectedRole!.toLowerCase());
      }).toList();
    }

    // Filter by company (only if backend didn't already filter)
    // If backend filtered by company, all users in _allUsers already match that company
    // So we only need client-side filtering if we're showing "All Companies" but want to filter by a specific one
    // For now, we'll skip client-side company filtering since backend handles it
    // This prevents double-filtering which could cause issues

    return filtered;
  }

  List<UserDto> _getPaginatedUsers() {
    final filtered = _getFilteredUsers();
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

  int _getTotalPages() {
    final filtered = _getFilteredUsers();
    if (filtered.isEmpty) return 1;
    return (filtered.length / _itemsPerPage).ceil();
  }

  String _getPaginationRangeText() {
    final filtered = _getFilteredUsers();
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

  void _goToPage(int page) {
    final totalPages = _getTotalPages();
    if (page >= 1 && page <= totalPages) {
      setState(() {
        _currentPage = page;
      });
      _updateGridData();
    }
  }

  void _onPageSizeChanged(int? newSize) {
    if (newSize != null && newSize != _itemsPerPage) {
      setState(() {
        _itemsPerPage = newSize;
        _currentPage = 1; // Reset to first page when changing page size
      });
      _updateGridData();
    }
  }

  void _updateGridData() {
    if (_stateManager == null) return;

    final paginatedUsers = _getPaginatedUsers();
    final rows = paginatedUsers.map((user) {
      return PlutoRow(
        cells: {
          'actions': PlutoCell(value: user.id),
          'email': PlutoCell(value: user.email),
          'firstName': PlutoCell(value: user.firstName ?? ''),
          'lastName': PlutoCell(value: user.lastName ?? ''),
          'roles': PlutoCell(
            value: user.roles?.join(', ') ?? 'No role',
          ),
          'status': PlutoCell(
            value: user.status.toUpperCase(),
          ),
          'villaNumber': PlutoCell(
            value: user.villaNumber,
          ),
          'unitName': PlutoCell(
            value: _getUnitNameFromVillas(user.villas),
          ),
          'buildingName': PlutoCell(
            value: _getBuildingNameFromVillas(user.villas),
          ),
          'lastLoginAt': PlutoCell(
            value: user.lastLoginAt,
          ),
        },
      );
    }).toList();

    _stateManager!.removeAllRows();
    _stateManager!.appendRows(rows);
  }

  List<PlutoColumn> _buildColumns(double availableWidth) {
    final minWidths = {
      'email': 200.0,
      'firstName': 120.0,
      'lastName': 120.0,
      'roles': 150.0,
      'status': 100.0,
      'villaNumber': 100.0,
      'unitName': 120.0,
      'buildingName': 150.0,
      'lastLoginAt': 180.0,
      'actions': 80.0,
    };

    final totalMinWidth =
        minWidths.values.fold(0.0, (sum, width) => sum + width);
    final widthMultiplier =
        availableWidth < totalMinWidth ? 1.0 : (availableWidth / totalMinWidth);

    final theme = Theme.of(context);

    return [
      PlutoColumn(
        title: 'Email',
        field: 'email',
        type: PlutoColumnType.text(),
        width: (minWidths['email']! * widthMultiplier)
            .clamp(200.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        frozen: PlutoColumnFrozen.start,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  value.isNotEmpty ? value[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'First Name',
        field: 'firstName',
        type: PlutoColumnType.text(),
        width: (minWidths['firstName']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: 'Last Name',
        field: 'lastName',
        type: PlutoColumnType.text(),
        width: (minWidths['lastName']! * widthMultiplier)
            .clamp(120.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: 'Roles',
        field: 'roles',
        type: PlutoColumnType.text(),
        width: (minWidths['roles']! * widthMultiplier)
            .clamp(150.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final text = rendererContext.cell.value.toString();
          if (text == 'No role') return const Text('-');
          final roles = text.split(', ');
          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: roles.map((role) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: context.cardBorderRadius,
                ),
                child: Text(
                  role,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }).toList(),
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
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final status = rendererContext.cell.value.toString().toUpperCase();
          Color color;
          Color textColor;
          switch (status) {
            case 'ACTIVE':
              color = Colors.green.shade100;
              textColor = Colors.green.shade800;
              break;
            case 'INACTIVE':
              color = Colors.red.shade100;
              textColor = Colors.red.shade800;
              break;
            case 'SUSPENDED':
              color = Colors.orange.shade100;
              textColor = Colors.orange.shade800;
              break;
            default:
              color = Colors.grey.shade200;
              textColor = Colors.grey.shade800;
          }
          return UnconstrainedBox(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: context.cardBorderRadius,
              ),
              child: Text(
                status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Unit No',
        field: 'villaNumber',
        type: PlutoColumnType.text(),
        width: (minWidths['villaNumber']! * widthMultiplier)
            .clamp(100.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: 'Unit Name',
        field: 'unitName',
        type: PlutoColumnType.text(),
        width: (minWidths['unitName']! * widthMultiplier)
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
        field: 'buildingName',
        type: PlutoColumnType.text(),
        width: (minWidths['buildingName']! * widthMultiplier)
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
        title: 'Last Login',
        field: 'lastLoginAt',
        type: PlutoColumnType.text(),
        width: (minWidths['lastLoginAt']! * widthMultiplier)
            .clamp(180.0, double.infinity),
        enableSorting: true,
        enableColumnDrag: true,
        enableFilterMenuItem: true,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value;
          if (value == null) return const Text('-');
          if (value is DateTime) {
            return Text(DateFormat('MMM d, y, h:mm a').format(value));
          }
          return Text(value.toString());
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
          final userId = rendererContext.cell.value.toString();
          // Get companyId from the row's _companyId cell
          final companyIdCell = rendererContext.row.cells['_companyId'];
          final companyId = companyIdCell?.value as String?;
          return Center(
            child: IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                print(
                    '[UserListPage] Navigating to user detail: userId=$userId, companyId=$companyId');
                context.push(
                  '/iam/users/$userId',
                  extra: companyId != null ? {'companyId': companyId} : null,
                );
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserBloc(
            repository: getIt<IamRepository>(),
          )..add(LoadUserList(companyId: widget.initialCompanyId)),
        ),
        BlocProvider(
          create: (context) => RoleBloc(
            repository: getIt<IamRepository>(),
          )..add(const LoadRoleList()),
        ),
        BlocProvider(
          create: (context) => CompanyBloc(
            repository: CompanyRepository(
              apiClient: getIt(),
            ),
          )..add(const LoadCompanyList()),
        ),
      ],
      child: _UserListContent(
        allUsers: _allUsers,
        onUsersUpdated: (users) {
          setState(() {
            _allUsers.clear();
            _allUsers.addAll(users);
            // If grid is already loaded, update it; otherwise _updateGridData will be called by onLoaded
            if (_stateManager != null) {
              _updateGridData();
            }
          });
        },
        buildColumns: _buildColumns,
        stateManager: _stateManager,
        onStateManagerChanged: (manager) {
          setState(() {
            _stateManager = manager;
            _updateGridData();
          });
        },
        // Filter props
        searchController: _searchController,
        selectedStatus: _selectedStatus,
        selectedRole: _selectedRole,
        onStatusChanged: (status) {
          setState(() {
            _selectedStatus = status;
            _currentPage = 1; // Reset to first page
          });
          _updateGridData();
        },
        onRoleChanged: (role) {
          setState(() {
            _selectedRole = role;
            _currentPage = 1; // Reset to first page
          });
          _updateGridData();
        },
        onCompanyChanged: (String? companyId) {
          setState(() {
            _selectedCompanyId = companyId;
            _currentPage = 1; // Reset to first page when company changes
          });
        },
        selectedCompanyId: _selectedCompanyId,
        onSearchChanged: () {
          setState(() {
            _currentPage = 1; // Reset to first page on search
          });
          _updateGridData();
        },
        getFilteredUsers: _getFilteredUsers,
        // Pagination props
        currentPage: _currentPage,
        itemsPerPage: _itemsPerPage,
        pageSizeOptions: _pageSizeOptions,
        getTotalPages: _getTotalPages,
        getPaginationRangeText: _getPaginationRangeText,
        goToPage: _goToPage,
        onPageSizeChanged: _onPageSizeChanged,
      ),
    );
  }
}

class _UserListContent extends StatelessWidget {
  const _UserListContent({
    required this.allUsers,
    required this.onUsersUpdated,
    required this.buildColumns,
    required this.stateManager,
    required this.onStateManagerChanged,
    required this.searchController,
    required this.selectedStatus,
    required this.selectedRole,
    this.selectedCompanyId,
    required this.onStatusChanged,
    required this.onRoleChanged,
    this.onCompanyChanged,
    required this.onSearchChanged,
    required this.getFilteredUsers,
    // Pagination props
    required this.currentPage,
    required this.itemsPerPage,
    required this.pageSizeOptions,
    required this.getTotalPages,
    required this.getPaginationRangeText,
    required this.goToPage,
    required this.onPageSizeChanged,
  });

  final List<UserDto> allUsers;
  final ValueChanged<List<UserDto>> onUsersUpdated;
  final List<PlutoColumn> Function(double) buildColumns;
  final PlutoGridStateManager? stateManager;
  final ValueChanged<PlutoGridStateManager?> onStateManagerChanged;

  // Filter props
  final TextEditingController searchController;
  final String? selectedStatus;
  final String? selectedRole;
  final String? selectedCompanyId;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<String?>? onCompanyChanged;
  final VoidCallback onSearchChanged;
  final List<UserDto> Function() getFilteredUsers;
  // Pagination props
  final int currentPage;
  final int itemsPerPage;
  final List<int> pageSizeOptions;
  final int Function() getTotalPages;
  final String Function() getPaginationRangeText;
  final void Function(int) goToPage;
  final void Function(int?) onPageSizeChanged;

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
          title: const Text('Users'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
          actions: const [],
        ),
        body: BlocConsumer<UserBloc, UserState>(
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
              listLoaded: (users) {
                onUsersUpdated(users);
                // Ensure loading state is cleared
                onStateManagerChanged(stateManager);
              },
              created: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<UserBloc>().add(const LoadUserList());
              },
              updated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<UserBloc>().add(const LoadUserList());
              },
              activated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User activated'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<UserBloc>().add(const LoadUserList());
              },
              deactivated: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deactivated'),
                    backgroundColor: Colors.orange,
                  ),
                );
                context.read<UserBloc>().add(const LoadUserList());
              },
              passwordReset: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              deleted: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Force reload the list immediately to reflect deletion
                // Use a small delay to ensure navigation is complete
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) {
                    context.read<UserBloc>().add(const LoadUserList());
                  }
                });
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              listLoaded: (users) {
                // Data is synced via listener, just render UI
                if (users.isEmpty) {
                  // Fallback if list is legitimately empty
                }

                return Column(
                  children: [
                    // Filter Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                controller: searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  hintText: 'Search users...',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            searchController.clear();
                                            onSearchChanged();
                                          },
                                        )
                                      : null,
                                  isDense: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  // Remove background
                                  filled: false,
                                ),
                                onChanged: (_) => onSearchChanged(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedStatus,
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
                                  DropdownMenuItem(
                                    value: 'suspended',
                                    child: Text(
                                      'Suspended',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: onStatusChanged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: BlocBuilder<RoleBloc, RoleState>(
                                builder: (context, roleState) {
                                  if (roleState is RoleListLoaded) {
                                    return DropdownButtonFormField<String>(
                                      initialValue: roleState.roles.any(
                                        (r) => r.name == selectedRole,
                                      )
                                          ? selectedRole
                                          : null,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.normal,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Role',
                                        labelStyle: TextStyle(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        isDense: true,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        // Remove background
                                        filled: false,
                                      ),
                                      isExpanded: true,
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text(
                                            'All Roles',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        ...roleState.roles.map(
                                          (role) => DropdownMenuItem(
                                            value: role.name,
                                            child: Text(
                                              _formatRoleName(role.name),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: onRoleChanged,
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                          value: selectedCompanyId,
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
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: (String? companyId) {
                                            if (onCompanyChanged != null) {
                                              onCompanyChanged!(companyId);
                                            }
                                            // Access UserBloc from the correct context
                                            context.read<UserBloc>().add(
                                                  LoadUserList(
                                                      companyId: companyId),
                                                );
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
                            // Refresh Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<UserBloc>().add(
                                        LoadUserList(
                                            companyId: selectedCompanyId),
                                      );
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Refresh'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Create User Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final screenWidth =
                                      MediaQuery.of(context).size.width;
                                  final isWeb = screenWidth >= 768;

                                  if (isWeb) {
                                    // Show dialog on web
                                    final shouldRefresh =
                                        await UserCreateDialog.show(context);
                                    if (shouldRefresh == true &&
                                        context.mounted) {
                                      context.read<UserBloc>().add(
                                            const LoadUserList(),
                                          );
                                    }
                                  } else {
                                    // Navigate to full page on mobile
                                    final shouldRefresh =
                                        await context.push<bool>(
                                      '/iam/users/create',
                                    );
                                    if (shouldRefresh == true &&
                                        context.mounted) {
                                      context.read<UserBloc>().add(
                                            const LoadUserList(),
                                          );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 56),
                                ),
                                child: const Text('Create User'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grid
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth;
                          final columns = buildColumns(availableWidth);
                          final filteredUsers = getFilteredUsers();
                          final totalPages = getTotalPages();

                          // Reset to page 1 if current page exceeds total pages
                          if (totalPages > 0 && currentPage > totalPages) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              goToPage(1);
                            });
                          }

                          // Get paginated users
                          final startIndex = (currentPage - 1) * itemsPerPage;
                          final endIndex = startIndex + itemsPerPage;
                          final paginatedUsers =
                              startIndex >= filteredUsers.length
                                  ? <UserDto>[]
                                  : filteredUsers.sublist(
                                      startIndex,
                                      endIndex > filteredUsers.length
                                          ? filteredUsers.length
                                          : endIndex,
                                    );

                          final rows = paginatedUsers.map((user) {
                            return PlutoRow(
                              cells: {
                                'actions': PlutoCell(value: user.id),
                                'email': PlutoCell(value: user.email),
                                'firstName':
                                    PlutoCell(value: user.firstName ?? ''),
                                'lastName':
                                    PlutoCell(value: user.lastName ?? ''),
                                'roles': PlutoCell(
                                  value: user.roles?.join(', ') ?? 'No role',
                                ),
                                'status': PlutoCell(
                                  value: user.status.toUpperCase(),
                                ),
                                'villaNumber': PlutoCell(
                                  value: user.villaNumber,
                                ),
                                'unitName': PlutoCell(
                                  value: _getUnitNameFromVillas(user.villas),
                                ),
                                'buildingName': PlutoCell(
                                  value: _getBuildingNameFromVillas(user.villas),
                                ),
                                'lastLoginAt': PlutoCell(
                                  value: user.lastLoginAt,
                                ),
                                // Store companyId for use in renderer
                                '_companyId': PlutoCell(value: user.companyId),
                              },
                            );
                          }).toList();

                          // Show empty state when no users match filters
                          if (rows.isEmpty || filteredUsers.isEmpty) {
                            final hasFilters =
                                searchController.text.isNotEmpty ||
                                    selectedStatus != null ||
                                    selectedRole != null ||
                                    selectedCompanyId != null;

                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    hasFilters
                                        ? Icons.filter_alt_off_rounded
                                        : Icons.people_outline_rounded,
                                    size: 64,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    hasFilters
                                        ? 'No users found matching your filters'
                                        : 'No users found',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                  if (hasFilters) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        searchController.clear();
                                        onStatusChanged(null);
                                        onRoleChanged(null);
                                        onCompanyChanged?.call(null);
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
                                  'users_${currentPage}_$itemsPerPage'),
                              columns: columns,
                              rows: rows,
                              onLoaded: (PlutoGridOnLoadedEvent event) {
                                onStateManagerChanged(event.stateManager);
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
                        final filteredUsers = getFilteredUsers();
                        final totalPages = getTotalPages();
                        if (filteredUsers.isEmpty || totalPages <= 1) {
                          return const SizedBox.shrink();
                        }
                        return _buildPaginationControls(
                          context,
                          totalPages,
                          filteredUsers.length,
                        );
                      },
                    ),
                  ],
                );
              },
              detailLoaded: (_) => const SizedBox.shrink(),
              created: (_) => const SizedBox.shrink(),
              updated: (_) => const SizedBox.shrink(),
              activated: (_) => const SizedBox.shrink(),
              deactivated: (_) => const SizedBox.shrink(),
              passwordReset: () => const SizedBox.shrink(),
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
                          context.read<UserBloc>().add(const LoadUserList());
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
            )
          : _buildDesktopPaginationControls(
              context,
              totalPages,
              totalFiltered,
            ),
    );
  }

  Widget _buildMobilePaginationControls(
    BuildContext context,
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
              getPaginationRangeText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<int>(
                value: itemsPerPage,
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
                items: pageSizeOptions.map((size) {
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
                onChanged: onPageSizeChanged,
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
              onPressed: currentPage > 1 ? () => goToPage(1) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  currentPage > 1 ? () => goToPage(currentPage - 1) : null,
              tooltip: 'Previous Page',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Page $currentPage of $totalPages',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < totalPages
                  ? () => goToPage(currentPage + 1)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed:
                  currentPage < totalPages ? () => goToPage(totalPages) : null,
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
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate which page numbers to show
    final List<int> visiblePages = _getVisiblePageNumbers(
      currentPage,
      totalPages,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Info and page size selector
        Row(
          children: [
            Text(
              getPaginationRangeText(),
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
                    value: itemsPerPage,
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
                    items: pageSizeOptions.map((size) {
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
                    onChanged: onPageSizeChanged,
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
              onPressed: currentPage > 1 ? () => goToPage(1) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  currentPage > 1 ? () => goToPage(currentPage - 1) : null,
              tooltip: 'Previous Page',
            ),
            const SizedBox(width: 8),
            // Page numbers
            ...visiblePages.map((page) {
              final isCurrentPage = page == currentPage;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => goToPage(page),
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
              onPressed: currentPage < totalPages
                  ? () => goToPage(currentPage + 1)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed:
                  currentPage < totalPages ? () => goToPage(totalPages) : null,
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
