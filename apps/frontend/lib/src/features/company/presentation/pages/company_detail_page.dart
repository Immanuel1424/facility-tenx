import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../data/repositories/company_repository.dart';
import '../../domain/entities/company_entity.dart';
import '../bloc/company_bloc.dart';
import '../bloc/company_event.dart';
import '../bloc/company_state.dart';
import 'company_create_page.dart';

class CompanyDetailPage extends StatelessWidget {
  const CompanyDetailPage({
    super.key,
    required this.companyId,
  });

  final String companyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompanyBloc(
        repository: CompanyRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(LoadCompanyDetail(companyId)),
      child: const _CompanyDetailContent(),
    );
  }
}

class _CompanyDetailContent extends StatefulWidget {
  const _CompanyDetailContent();

  @override
  State<_CompanyDetailContent> createState() => _CompanyDetailContentState();
}

class _CompanyDetailContentState extends State<_CompanyDetailContent> {
  int? _sitesCount;
  int? _usersCount;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  Future<void> _loadStatistics() async {
    if (!mounted) return;

    final companyState = context.read<CompanyBloc>().state;
    final companyId = companyState.maybeWhen(
      detailLoaded: (c) => c.id,
      created: (c) => c.id,
      updated: (c) => c.id,
      orElse: () => null,
    );

    if (companyId == null) return;

    setState(() {
      _isLoadingStats = true;
    });

    try {
      final apiClient = getIt<ApiClient>();

      // Load sites
      final sites = await apiClient.getSitesForManagement(companyId: companyId);

      // Load users - pass companyId parameter
      // Backend will use it for SUPER_ADMIN, or ignore it for regular users (using their own companyId)
      final users = await apiClient.getUsers(companyId: companyId);

      if (mounted) {
        setState(() {
          _sitesCount = sites.length;
          _usersCount = users.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyBloc, CompanyState>(
      listener: (context, state) {
        state.maybeWhen(
          detailLoaded: (_) {
            _loadStatistics();
          },
          updated: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Company updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            final companyId = state.maybeWhen(
              updated: (c) => c.id,
              orElse: () => null,
            );
            if (companyId != null) {
              context.read<CompanyBloc>().add(LoadCompanyDetail(companyId));
              _loadStatistics();
            }
          },
          deleted: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Company deleted successfully'),
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
      child: BlocBuilder<CompanyBloc, CompanyState>(
        builder: (context, state) {
          final company = state.maybeWhen(
            detailLoaded: (c) => c,
            created: (c) => c,
            updated: (c) => c,
            orElse: () => null,
          );

          return Scaffold(
            appBar: AppBar(
              title: company != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          company.name,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    )
                  : const Text('Company Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    final state = context.read<CompanyBloc>().state;
                    final companyId = state.maybeWhen(
                      detailLoaded: (c) => c.id,
                      created: (c) => c.id,
                      updated: (c) => c.id,
                      orElse: () => null,
                    );
                    if (companyId != null) {
                      context
                          .read<CompanyBloc>()
                          .add(LoadCompanyDetail(companyId));
                      _loadStatistics();
                    }
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
            body: BlocBuilder<CompanyBloc, CompanyState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  detailLoaded: (company) =>
                      _buildResponsiveContent(context, company),
                  created: (company) =>
                      _buildResponsiveContent(context, company),
                  updated: (company) =>
                      _buildResponsiveContent(context, company),
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
                            context.read<CompanyBloc>().add(
                                  LoadCompanyDetail(
                                    (context.findAncestorWidgetOfExactType<
                                            CompanyDetailPage>())!
                                        .companyId,
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

  Widget _buildResponsiveContent(BuildContext context, CompanyEntity company) {
    return ResponsiveLayout(
      mobileBuilder: (context) => _buildMobileLayout(context, company),
      desktopBuilder: (context) => _buildDesktopLayout(context, company),
    );
  }

  Widget _buildMobileLayout(BuildContext context, CompanyEntity company) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, company),
          const SizedBox(height: 12),
          _BasicInfoSection(
            company: company,
            sitesCount: _sitesCount,
            usersCount: _usersCount,
            isLoading: _isLoadingStats,
          ),
          const SizedBox(height: 12),
          _SystemInfoSection(company: company),
          const SizedBox(height: 12),
          _buildActionButtonsCard(context, company),
          const SizedBox(height: 12),
          _RelatedEntitiesCard(
            company: company,
            sitesCount: _sitesCount,
            usersCount: _usersCount,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, CompanyEntity company) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(context, company),
                        const SizedBox(height: 16),
                        _BasicInfoSection(
                          company: company,
                          sitesCount: _sitesCount,
                          usersCount: _usersCount,
                          isLoading: _isLoadingStats,
                        ),
                        const SizedBox(height: 16),
                        _SystemInfoSection(company: company),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 320,
                    child: Column(
                      children: [
                        _buildActionButtonsCard(context, company),
                        const SizedBox(height: 16),
                        _RelatedEntitiesCard(
                          company: company,
                          sitesCount: _sitesCount,
                          usersCount: _usersCount,
                        ),
                      ],
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

  Widget _buildHeaderCard(BuildContext context, CompanyEntity company) {
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
            GestureDetector(
              onTap: company.logoUrl != null && company.logoUrl!.isNotEmpty
                  ? () => _showLogoFullScreen(context, company.logoUrl!)
                  : null,
              child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        company.logoUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar(
                            radius: 25,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              company.code.isNotEmpty
                                  ? company.code[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return CircleAvatar(
                            radius: 25,
                            backgroundColor: colorScheme.primaryContainer,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : CircleAvatar(
                      radius: 25,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        company.code.isNotEmpty
                            ? company.code[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company.code,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StatusBadge(isActive: company.isActive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoFullScreen(BuildContext context, String logoUrl) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(logoUrl),
        ),
      ),
    );
  }

  Widget _buildActionButtonsCard(BuildContext context, CompanyEntity company) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSystemCompany = company.code.toUpperCase() == 'SYSTEM';

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
            if (isSystemCompany) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: context.cardBorderRadius,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'This is the SYSTEM company. It cannot be edited or deleted from the UI.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ] else ...[
              BlocBuilder<CompanyBloc, CompanyState>(
                builder: (context, state) {
                  final currentCompany = state.maybeWhen(
                    detailLoaded: (c) => c,
                    created: (c) => c,
                    updated: (c) => c,
                    orElse: () => company,
                  );
                  return SwitchListTile(
                    title: const Text('Active Status'),
                    subtitle: Text(
                      currentCompany.isActive
                          ? 'Company is currently active and operational.'
                          : 'Company is currently inactive.',
                    ),
                    value: currentCompany.isActive,
                    onChanged: (value) {
                      final companyBloc = context.read<CompanyBloc>();
                      companyBloc.add(
                        UpdateCompany(
                          id: currentCompany.id,
                          code: currentCompany.code,
                          name: currentCompany.name,
                          description: currentCompany.description,
                          logoUrl: currentCompany.logoUrl,
                          timezone: currentCompany.timezone,
                          currency: currentCompany.currency,
                          isActive: !currentCompany.isActive,
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
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isWeb = screenWidth >= 768;

                  if (isWeb) {
                    final shouldRefresh = await CompanyCreateDialog.showForEdit(
                      context,
                      company.id,
                    );
                    if (shouldRefresh == true && context.mounted) {
                      context.read<CompanyBloc>().add(
                            LoadCompanyDetail(company.id),
                          );
                    }
                  } else {
                    final shouldRefresh = await context
                        .push<bool>('/companies/${company.id}/edit');
                    if (shouldRefresh == true && context.mounted) {
                      context.read<CompanyBloc>().add(
                            LoadCompanyDetail(company.id),
                          );
                    }
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Company'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    _showDeleteConfirmationDialog(context, company),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Company'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    CompanyEntity company,
  ) {
    final companyBloc = context.read<CompanyBloc>();
    final theme = Theme.of(context);

    CommonDialogs.showDeleteDialog(
      context: context,
      title: 'Delete Company',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Are you sure you want to delete this company?'),
          const SizedBox(height: 8),
          Text(
            'Name: ${company.name}',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Code: ${company.code}',
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
        companyBloc.add(DeleteCompany(company.id));
      },
    );
  }
}

class _RelatedEntitiesCard extends StatelessWidget {
  const _RelatedEntitiesCard({
    required this.company,
    required this.sitesCount,
    required this.usersCount,
  });

  final CompanyEntity company;
  final int? sitesCount;
  final int? usersCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  Icons.link,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Related Entities',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RelatedEntityItem(
              icon: Icons.domain,
              label: 'Sites',
              count: sitesCount,
              onTap: () {
                context.push('/companies/${company.id}/sites');
              },
            ),
            const SizedBox(height: 12),
            _RelatedEntityItem(
              icon: Icons.people,
              label: 'Users',
              count: usersCount,
              onTap: () {
                context.push(
                  '/iam/users',
                  extra: {'companyId': company.id},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RelatedEntityItem extends StatelessWidget {
  const _RelatedEntityItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// Section Widgets
class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({
    required this.company,
    this.sitesCount,
    this.usersCount,
    this.isLoading = false,
  });

  final CompanyEntity company;
  final int? sitesCount;
  final int? usersCount;
  final bool isLoading;

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
            _InfoRow(
              label: 'ID',
              value: company.id,
              canCopy: true,
            ),
            _InfoRow(
              label: 'Code',
              value: company.code,
              canCopy: true,
            ),
            _InfoRow(
              label: 'Name',
              value: company.name,
              canCopy: true,
            ),
            if (company.description != null && company.description!.isNotEmpty)
              _InfoRow(
                label: 'Description',
                value: company.description!,
                isMultiline: true,
              ),
            if (company.logoUrl != null && company.logoUrl!.isNotEmpty)
              _InfoRow(label: 'Logo URL', value: company.logoUrl!),
            if (company.timezone != null && company.timezone!.isNotEmpty)
              _InfoRow(
                label: 'Timezone',
                value: company.timezone!,
                showIcon: true,
                icon: Icons.access_time_outlined,
              ),
            if (company.currency != null && company.currency!.isNotEmpty)
              _InfoRow(
                label: 'Currency',
                value: company.currency!,
                showIcon: true,
                icon: Icons.attach_money_outlined,
              ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              _InfoRow(
                label: 'Sites',
                value: sitesCount?.toString() ?? '-',
                showIcon: true,
                icon: Icons.domain,
                onTap: () {
                  context.push('/companies/${company.id}/sites');
                },
              ),
              _InfoRow(
                label: 'Users',
                value: usersCount?.toString() ?? '-',
                showIcon: true,
                icon: Icons.people,
                onTap: () {
                  context.push(
                    '/iam/users',
                    extra: {'companyId': company.id},
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SystemInfoSection extends StatelessWidget {
  const _SystemInfoSection({required this.company});

  final CompanyEntity company;

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
              value: DateFormat('yyyy-MM-dd HH:mm').format(company.createdAt),
              showIcon: true,
              icon: Icons.add_circle_outline,
            ),
            _InfoRow(
              label: 'Updated At',
              value: DateFormat('yyyy-MM-dd HH:mm').format(company.updatedAt),
              showIcon: true,
              icon: Icons.update_outlined,
            ),
          ],
        ),
      ),
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
    this.onTap,
  });

  final String label;
  final String value;
  final bool isMultiline;
  final bool showIcon;
  final IconData? icon;
  final bool canCopy;
  final VoidCallback? onTap;

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

    final content = Padding(
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
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }

    return content;
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
