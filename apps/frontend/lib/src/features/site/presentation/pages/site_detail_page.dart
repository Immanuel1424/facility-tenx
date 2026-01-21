import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../data/repositories/site_repository.dart';
import '../../domain/entities/site_entity.dart';
import '../bloc/site_bloc.dart';
import '../bloc/site_event.dart';
import '../bloc/site_state.dart';
import 'site_create_page.dart';
import '../../../iam/data/dto/user_dto.dart' as iam_dto;

class SiteDetailPage extends StatelessWidget {
  const SiteDetailPage({
    super.key,
    required this.siteId,
  });

  final String siteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SiteBloc(
        repository: SiteRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(LoadSiteDetail(siteId)),
      child: const _SiteDetailContent(),
    );
  }
}

class _SiteDetailContent extends StatefulWidget {
  const _SiteDetailContent();

  @override
  State<_SiteDetailContent> createState() => _SiteDetailContentState();
}

class _SiteDetailContentState extends State<_SiteDetailContent> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SiteBloc, SiteState>(
      listener: (context, state) {
        state.maybeWhen(
          updated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Site updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            final siteId = state.maybeWhen(
              updated: (s) => s.id,
              orElse: () => null,
            );
            if (siteId != null) {
              context.read<SiteBloc>().add(LoadSiteDetail(siteId));
            }
          },
          deleted: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Site deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<SiteBloc, SiteState>(
        builder: (context, state) {
          final site = state.maybeWhen(
            detailLoaded: (s) => s,
            created: (s) => s,
            updated: (s) => s,
            orElse: () => null,
          );

          return Scaffold(
            appBar: AppBar(
              title: site != null
                  ? Text(
                      site.name,
                      style: const TextStyle(fontSize: 18),
                    )
                  : const Text('Site Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    final state = context.read<SiteBloc>().state;
                    final siteId = state.maybeWhen(
                      detailLoaded: (s) => s.id,
                      created: (s) => s.id,
                      updated: (s) => s.id,
                      orElse: () => null,
                    );
                    if (siteId != null) {
                      context.read<SiteBloc>().add(LoadSiteDetail(siteId));
                    }
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
            body: site != null
                ? _buildResponsiveContent(context, site)
                : BlocBuilder<SiteBloc, SiteState>(
                    builder: (context, state) {
                      return state.maybeWhen(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        detailLoaded: (site) =>
                            _buildResponsiveContent(context, site),
                        created: (site) =>
                            _buildResponsiveContent(context, site),
                        updated: (site) =>
                            _buildResponsiveContent(context, site),
                        error: (message) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text('Error: $message'),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () {
                                  context.read<SiteBloc>().add(
                                        LoadSiteDetail(
                                          (context.findAncestorWidgetOfExactType<
                                                  SiteDetailPage>())!
                                              .siteId,
                                        ),
                                      );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                        orElse: () =>
                            const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context, SiteEntity site) {
    return ResponsiveLayout(
      mobileBuilder: (context) => _buildMobileLayout(context, site),
      desktopBuilder: (context) => _buildDesktopLayout(context, site),
    );
  }

  Widget _buildMobileLayout(BuildContext context, SiteEntity site) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, site),
          const SizedBox(height: 12),
          _BasicInfoSection(site: site),
          const SizedBox(height: 12),
          _SystemInfoSection(site: site),
          const SizedBox(height: 12),
          _UsersSection(siteId: site.id),
          const SizedBox(height: 12),
          _buildActionButtonsCard(context, site),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, SiteEntity site) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context, site),
                    const SizedBox(height: 16),
                    _BasicInfoSection(site: site),
                    const SizedBox(height: 16),
                    _SystemInfoSection(site: site),
                    const SizedBox(height: 16),
                    _UsersSection(siteId: site.id),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    _buildActionButtonsCard(context, site),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, SiteEntity site) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                site.code.isNotEmpty ? site.code[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    site.code,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusBadge(isActive: site.isActive),
                      const SizedBox(width: 8),
                      _TypeBadge(isParent: site.isParent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsCard(BuildContext context, SiteEntity site) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<SiteBloc, SiteState>(
              builder: (context, state) {
                final currentSite = state.maybeWhen(
                  detailLoaded: (s) => s,
                  created: (s) => s,
                  updated: (s) => s,
                  orElse: () => site,
                );
                return SwitchListTile(
                  title: const Text('Active Status'),
                  subtitle: Text(
                    currentSite.isActive
                        ? 'Site is currently active and operational.'
                        : 'Site is currently inactive.',
                  ),
                  value: currentSite.isActive,
                  onChanged: (value) {
                    final siteBloc = context.read<SiteBloc>();
                    siteBloc.add(
                      UpdateSite(
                        id: currentSite.id,
                        code: currentSite.code,
                        name: currentSite.name,
                        description: currentSite.description,
                        address: currentSite.address,
                        city: currentSite.city,
                        country: currentSite.country,
                        isParent: currentSite.isParent,
                        isActive: !currentSite.isActive,
                        parentSiteId: currentSite.parentSiteId,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final shouldRefresh = await SiteCreateDialog.showForEdit(
                  context,
                  site.id,
                );
                if (shouldRefresh == true && context.mounted) {
                  context.read<SiteBloc>().add(LoadSiteDetail(site.id));
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Site'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmationDialog(context, site),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Site'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    SiteEntity site,
  ) {
    final siteBloc = context.read<SiteBloc>();
    final theme = Theme.of(context);

    CommonDialogs.showDeleteDialog(
      context: context,
      title: 'Delete Site',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to delete this site?'),
          const SizedBox(height: 8),
          Text(
            'Name: ${site.name}',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Code: ${site.code}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'This action cannot be undone. All associated data will be removed.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
      onDelete: () {
        siteBloc.add(DeleteSite(site.id));
      },
    );
  }
}

// Section Widgets
class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({required this.site});

  final SiteEntity site;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Code', value: site.code, canCopy: true),
            _InfoRow(label: 'Name', value: site.name),
            if (site.description != null && site.description!.isNotEmpty)
              _InfoRow(
                label: 'Description',
                value: site.description!,
                isMultiline: true,
              ),
            if (site.address != null && site.address!.isNotEmpty)
              _InfoRow(
                label: 'Address',
                value: site.address!,
                showIcon: true,
                icon: Icons.location_on_outlined,
              ),
            if (site.city != null && site.city!.isNotEmpty)
              _InfoRow(
                label: 'City',
                value: site.city!,
                showIcon: true,
                icon: Icons.location_city_outlined,
              ),
            if (site.country != null && site.country!.isNotEmpty)
              _InfoRow(
                label: 'Country',
                value: site.country!,
                showIcon: true,
                icon: Icons.public_outlined,
              ),
            _InfoRow(
              label: 'Type',
              value: site.isParent ? 'Parent Site' : 'Child Site',
              showIcon: true,
              icon: site.isParent
                  ? Icons.business_outlined
                  : Icons.business_center_outlined,
            ),
            if (site.parentSiteId != null)
              _InfoRow(
                label: 'Parent Site ID',
                value: site.parentSiteId!,
                showIcon: true,
                icon: Icons.account_tree_outlined,
              ),
            if (site.companyId != null)
              _InfoRow(
                label: 'Company ID',
                value: site.companyId!,
                showIcon: true,
                icon: Icons.corporate_fare_outlined,
              ),
          ],
        ),
      ),
    );
  }
}

class _SystemInfoSection extends StatelessWidget {
  const _SystemInfoSection({required this.site});

  final SiteEntity site;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.computer_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Created At',
              value: DateFormat('yyyy-MM-dd HH:mm').format(site.createdAt),
              showIcon: true,
              icon: Icons.add_circle_outline,
            ),
            _InfoRow(
              label: 'Updated At',
              value: DateFormat('yyyy-MM-dd HH:mm').format(site.updatedAt),
              showIcon: true,
              icon: Icons.update_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersSection extends StatefulWidget {
  const _UsersSection({required this.siteId});

  final String siteId;

  @override
  State<_UsersSection> createState() => _UsersSectionState();
}

class _UsersSectionState extends State<_UsersSection> {
  List<iam_dto.UserDto> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final users = await apiClient.getSiteUsers(widget.siteId);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _assignUser() async {
    try {
      // Get all users in the company
      final apiClient = getIt<ApiClient>();
      final allUsers = await apiClient.getUsers();

      // Filter out users already assigned
      final assignedUserIds = _users.map((u) => u.id).toSet();
      final availableUsers =
          allUsers.where((u) => !assignedUserIds.contains(u.id)).toList();

      if (availableUsers.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No available users to assign'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show user selection dialog
      final selectedUser = await showDialog<iam_dto.UserDto>(
        context: context,
        builder: (context) => _UserSelectionDialog(users: availableUsers),
      );

      if (selectedUser != null && mounted) {
        await apiClient.assignUserToSite(widget.siteId, selectedUser.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User assigned to site successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: const Text(
          'Are you sure you want to remove this user from the site?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final apiClient = getIt<ApiClient>();
        await apiClient.removeUserFromSite(widget.siteId, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User removed from site successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing user: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: context.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assigned Users',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _assignUser,
                  tooltip: 'Assign User',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUsers,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Error loading users: $_error',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _loadUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_users.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No users assigned to this site',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _assignUser,
                        icon: const Icon(Icons.add),
                        label: const Text('Assign User'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        (user.firstName?.isNotEmpty == true
                                ? user.firstName![0]
                                : user.email[0])
                            .toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim()
                              .isEmpty
                          ? user.email
                          : '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        if (user.roles != null && user.roles!.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: user.roles!.map((role) {
                              return Chip(
                                label: Text(
                                  role,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: colorScheme.error,
                      onPressed: () => _removeUser(user.id),
                      tooltip: 'Remove from site',
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _UserSelectionDialog extends StatelessWidget {
  const _UserSelectionDialog({required this.users});

  final List<iam_dto.UserDto> users;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Select User to Assign'),
      content: SizedBox(
        width: double.maxFinite,
        child: users.isEmpty
            ? const Text('No available users')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        (user.firstName?.isNotEmpty == true
                                ? user.firstName![0]
                                : user.email[0])
                            .toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim()
                              .isEmpty
                          ? user.email
                          : '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim(),
                    ),
                    subtitle: Text(user.email),
                    onTap: () => Navigator.of(context).pop(user),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.showIcon = false,
    this.icon,
    this.canCopy = false,
  });

  final String label;
  final String value;
  final bool isMultiline;
  final bool showIcon;
  final IconData? icon;
  final bool canCopy;

  @override
  Widget build(BuildContext context) {
    if (isMultiline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon && icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: showIcon ? 130 : 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (canCopy)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied to clipboard'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: 'Copy $label',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green.shade50 : Colors.red.shade50;
    final textColor = isActive ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: context.cardBorderRadius,
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isParent});

  final bool isParent;

  @override
  Widget build(BuildContext context) {
    final color = isParent ? Colors.blue.shade50 : Colors.deepPurple.shade50;
    final textColor =
        isParent ? Colors.blue.shade700 : Colors.deepPurple.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: context.cardBorderRadius,
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        isParent ? 'PARENT' : 'CHILD',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
