import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../data/repositories/villa_repository.dart';
import '../../data/dto/city_dto.dart';
import '../../data/dto/location_dto.dart';
import '../../domain/entities/villa_entity.dart';
import '../bloc/villa_bloc.dart';
import '../bloc/villa_event.dart';
import '../bloc/villa_state.dart';
import 'villa_create_page.dart';

class VillaDetailPage extends StatelessWidget {
  const VillaDetailPage({
    super.key,
    required this.villaId,
  });

  final String villaId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VillaBloc(
        repository: VillaRepository(
          apiClient: getIt<ApiClient>(),
        ),
      )..add(LoadVillaDetail(villaId)),
      child: _VillaDetailContent(villaId: villaId),
    );
  }
}

class _VillaDetailContent extends StatefulWidget {
  const _VillaDetailContent({required this.villaId});

  final String villaId;

  @override
  State<_VillaDetailContent> createState() => _VillaDetailContentState();
}

class _VillaDetailContentState extends State<_VillaDetailContent> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Villa Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VillaBloc>().add(LoadVillaDetail(widget.villaId));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocListener<VillaBloc, VillaState>(
        listener: (context, state) {
          if (!mounted) return;

          state.maybeWhen(
            updated: (_) {
              if (mounted && context.mounted) {
                context.read<VillaBloc>().add(LoadVillaDetail(widget.villaId));
              }
            },
            activated: (_) {
              if (mounted && context.mounted) {
                context.read<VillaBloc>().add(LoadVillaDetail(widget.villaId));
              }
            },
            deactivated: (_) {
              if (mounted && context.mounted) {
                context.read<VillaBloc>().add(LoadVillaDetail(widget.villaId));
              }
            },
            deleted: () {
              if (mounted && context.mounted) {
                context.pop();
              }
            },
            error: (message) {
              // Error handling removed - no SnackBar
            },
            orElse: () {},
          );
        },
        child: BlocBuilder<VillaBloc, VillaState>(
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              detailLoaded: (villa) => _buildResponsiveContent(context, villa),
              updated: (villa) => _buildResponsiveContent(context, villa),
              activated: (villa) => _buildResponsiveContent(context, villa),
              deactivated: (villa) => _buildResponsiveContent(context, villa),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading villa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<VillaBloc>()
                            .add(LoadVillaDetail(widget.villaId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveContent(BuildContext context, VillaEntity villa) {
    return ResponsiveLayout(
      mobileBuilder: (context) => _buildMobileLayout(context, villa),
      desktopBuilder: (context) => _buildDesktopLayout(context, villa),
    );
  }

  Widget _buildMobileLayout(BuildContext context, VillaEntity villa) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context, villa),
          const SizedBox(height: 12),
          _VillaInfoSection(villa: villa),
          const SizedBox(height: 12),
          _PropertyFeaturesSection(villa: villa),
          const SizedBox(height: 12),
          _ContactDetailsSection(villa: villa),
          const SizedBox(height: 12),
          _SystemDetailsSection(villa: villa),
          const SizedBox(height: 12),
          _buildActionButtonsCard(context, villa),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, VillaEntity villa) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context, villa),
                    const SizedBox(height: 16),
                    _VillaInfoSection(villa: villa),
                    const SizedBox(height: 16),
                    _PropertyFeaturesSection(villa: villa),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Middle Column
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactDetailsSection(villa: villa),
                    const SizedBox(height: 16),
                    _SystemDetailsSection(villa: villa),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column (Sticky Actions)
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    _buildActionButtonsCard(context, villa),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, VillaEntity villa) {
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
              child: Icon(
                Icons.villa_rounded,
                size: 30,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    villa.villaCode ?? 'Villa ${villa.villaNumber}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unit No: ${villa.villaNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusChip(
                        label: villa.isActive ? 'ACTIVE' : 'INACTIVE',
                        color: villa.isActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: villa.isOccupied ? 'OCCUPIED' : 'VACANT',
                        color: villa.isOccupied ? Colors.blue : Colors.grey,
                      ),
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

  Widget _buildActionButtonsCard(BuildContext context, VillaEntity villa) {
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Villa Status'),
              subtitle: Text(
                villa.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: villa.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Switch(
                value: villa.isActive,
                onChanged: (value) {
                  _showStatusChangeDialog(
                    context,
                    widget.villaId,
                    villa.isActive,
                  );
                },
                activeThumbColor: Colors.green,
              ),
            ),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () => _showEditDialog(context, _formKey, villa),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Villa'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Villa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
    VillaEntity villa,
  ) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 768;

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<VillaBloc>()),
        ],
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isWeb ? 40 : 16,
            vertical: isWeb ? 40 : 24,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isWeb ? 1200 : double.infinity,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Villa',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onPrimary,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                // Dialog Body with form
                Expanded(
                  child: BlocListener<VillaBloc, VillaState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        updated: (_) {
                          Navigator.of(dialogContext).pop(true);
                        },
                        error: (message) {
                          // Error handling removed - no SnackBar
                        },
                        orElse: () {},
                      );
                    },
                    child: _VillaEditFormWrapper(
                      villa: villa,
                      villaId: widget.villaId,
                      onUpdate: (formData, cityName, locationName) {
                        final bloc = context.read<VillaBloc>();
                        bloc.add(
                          UpdateVilla(
                            id: widget.villaId,
                            villaNumber: formData['villa_number'] as String?,
                            villaType: formData['villa_type']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['villa_type'] as String?,
                            unitName:
                                formData['block']?.toString().trim().isEmpty ==
                                        true
                                    ? null
                                    : formData['block'] as String?,
                            buildingName: formData['building_name']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['building_name'] as String?,
                            villaCode: formData['villa_code']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['villa_code'] as String?,
                            ownerName: formData['owner_name']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['owner_name'] as String?,
                            tenantName: formData['tenant_name']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['tenant_name'] as String?,
                            contactPhone: formData['contact_phone']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['contact_phone'] as String?,
                            contactEmail: formData['contact_email']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['contact_email'] as String?,
                            city: cityName,
                            street: locationName,
                            isActive: formData['is_active'] as bool?,
                            isOccupied: formData['is_occupied'] as bool?,
                            openFrom: formData['open_from'] != null
                                ? DateTime.tryParse(
                                    formData['open_from'].toString(),
                                  )
                                : null,
                            unitNo: formData['villa_number']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['villa_number'] as String?,
                            primaryView: formData['primary_view']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['primary_view'] as String?,
                            unitCategory: formData['villa_type']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['villa_type'] as String?,
                            floor:
                                formData['floor']?.toString().trim().isEmpty ==
                                        true
                                    ? null
                                    : formData['floor'] as String?,
                            floorCount: formData['floor_count']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : int.tryParse(
                                    formData['floor_count'] as String,
                                  ),
                            bedroomCount: formData['bedroom_count']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : int.tryParse(
                                    formData['bedroom_count'] as String,
                                  ),
                            bathroomCount: formData['bathroom_count']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : int.tryParse(
                                    formData['bathroom_count'] as String,
                                  ),
                            remarks: formData['remarks']
                                        ?.toString()
                                        .trim()
                                        .isEmpty ==
                                    true
                                ? null
                                : formData['remarks'] as String?,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true && context.mounted) {
        context.read<VillaBloc>().add(LoadVillaDetail(widget.villaId));
      }
    });
  }

  void _showStatusChangeDialog(
    BuildContext context,
    String villaId,
    bool isActive,
  ) {
    final villaBloc = context.read<VillaBloc>();

    CommonDialogs.showConfirmationDialog(
      context: context,
      title: isActive ? 'Deactivate Villa' : 'Activate Villa',
      content: isActive
          ? 'Are you sure you want to deactivate this villa?'
          : 'Are you sure you want to activate this villa?',
      confirmText: isActive ? 'Deactivate' : 'Activate',
      onConfirm: () {
        if (isActive) {
          villaBloc.add(DeactivateVilla(villaId));
        } else {
          villaBloc.add(ActivateVilla(villaId));
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final villaBloc = context.read<VillaBloc>();

    CommonDialogs.showDeleteDialog(
      context: context,
      title: 'Delete Villa',
      content: const Text(
        'Are you sure you want to delete this villa? This action cannot be undone.',
      ),
      onDelete: () {
        villaBloc.add(DeleteVilla(widget.villaId));
      },
    );
  }
}

class _VillaInfoSection extends StatelessWidget {
  const _VillaInfoSection({required this.villa});

  final VillaEntity villa;

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
                Icon(Icons.villa_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Villa Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (villa.villaType != null)
              _InfoRow(
                label: 'Villa Type',
                value: villa.villaType!,
                showIcon: true,
                icon: Icons.category_outlined,
              ),
            _InfoRow(
              label: 'Unit No',
              value: villa.villaNumber,
              showIcon: true,
              icon: Icons.tag,
            ),
            if (villa.unitName != null)
              _InfoRow(
                label: 'Unit Name',
                value: villa.unitName!,
                showIcon: true,
                icon: Icons.home_outlined,
              ),
            if (villa.buildingName != null)
              _InfoRow(
                label: 'Building Name',
                value: villa.buildingName!,
                showIcon: true,
                icon: Icons.business_outlined,
              ),
            if (villa.villaCode != null)
              _InfoRow(
                label: 'Villa Code',
                value: villa.villaCode!,
                showIcon: true,
                icon: Icons.code,
              ),
          ],
        ),
      ),
    );
  }
}

class _PropertyFeaturesSection extends StatelessWidget {
  const _PropertyFeaturesSection({required this.villa});

  final VillaEntity villa;

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
                Icon(Icons.home_work_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Property Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (villa.street != null)
              _InfoRow(
                label: 'Street',
                value: villa.street!,
                showIcon: true,
                icon: Icons.location_on_outlined,
              ),
            if (villa.floor != null && villa.floor!.isNotEmpty)
              _InfoRow(
                label: 'Floor',
                value: villa.floor!,
                showIcon: true,
                icon: Icons.stairs_outlined,
              ),
            if (villa.floorCount != null)
              _InfoRow(
                label: 'Floor Count',
                value: villa.floorCount.toString(),
                showIcon: true,
                icon: Icons.layers_outlined,
              ),
            if (villa.bedroomCount != null)
              _InfoRow(
                label: 'Bedroom Count',
                value: villa.bedroomCount.toString(),
                showIcon: true,
                icon: Icons.bedroom_parent_outlined,
              ),
            if (villa.bathroomCount != null)
              _InfoRow(
                label: 'Bathroom Count',
                value: villa.bathroomCount.toString(),
                showIcon: true,
                icon: Icons.bathroom_outlined,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactDetailsSection extends StatelessWidget {
  const _ContactDetailsSection({required this.villa});

  final VillaEntity villa;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (villa.ownerName == null &&
        villa.tenantName == null &&
        villa.contactPhone == null &&
        villa.contactEmail == null) {
      return const SizedBox.shrink();
    }

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
                Icon(Icons.contact_phone_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Contact Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (villa.ownerName != null)
              _InfoRow(
                label: 'Owner Name',
                value: villa.ownerName!,
                showIcon: true,
                icon: Icons.person_outline,
              ),
            if (villa.tenantName != null)
              _InfoRow(
                label: 'Tenant Name',
                value: villa.tenantName!,
                showIcon: true,
                icon: Icons.person,
              ),
            if (villa.contactPhone != null)
              _InfoRow(
                label: 'Phone',
                value: villa.contactPhone!,
                showIcon: true,
                icon: Icons.phone_outlined,
              ),
            if (villa.contactEmail != null)
              _InfoRow(
                label: 'Email',
                value: villa.contactEmail!,
                showIcon: true,
                icon: Icons.email_outlined,
              ),
          ],
        ),
      ),
    );
  }
}

class _SystemDetailsSection extends StatelessWidget {
  const _SystemDetailsSection({required this.villa});

  final VillaEntity villa;

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
                Icon(Icons.settings_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'System Details',
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
              value: DateFormat('dd/MM/yyyy HH:mm').format(villa.createdAt),
              showIcon: true,
              icon: Icons.add_circle_outline,
            ),
            _InfoRow(
              label: 'Last Updated',
              value: DateFormat('dd/MM/yyyy HH:mm').format(villa.updatedAt),
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
    this.showIcon = false,
    this.icon,
  });

  final String label;
  final String value;
  final bool showIcon;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: context.cardBorderRadius,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Wrapper widget that handles city/location mapping for edit form
class _VillaEditFormWrapper extends StatefulWidget {
  const _VillaEditFormWrapper({
    required this.villa,
    required this.villaId,
    required this.onUpdate,
  });

  final VillaEntity villa;
  final String villaId;
  final void Function(
    Map<String, dynamic> formData,
    String? cityName,
    String? locationName,
  ) onUpdate;

  @override
  State<_VillaEditFormWrapper> createState() => _VillaEditFormWrapperState();
}

class _VillaEditFormWrapperState extends State<_VillaEditFormWrapper> {
  List<CityDto>? _cities;
  List<LocationDto>? _locations;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final apiClient = getIt<ApiClient>();
      final cities = await apiClient.getLookupCities();
      if (mounted) {
        setState(() {
          _cities = cities;
        });
        // Load locations if villa has a city
        if (widget.villa.city != null) {
          final city = cities.firstWhere(
            (c) => c.name == widget.villa.city,
            orElse: () => cities.first,
          );
          _loadLocations(city.id);
        }
      }
    } catch (e) {
      print('⚠️ Error loading cities: $e');
    }
  }

  Future<void> _loadLocations(String? cityId) async {
    if (cityId == null || cityId.isEmpty) {
      setState(() {
        _locations = null;
      });
      return;
    }

    try {
      final apiClient = getIt<ApiClient>();
      final locations = await apiClient.getLookupLocations(cityId: cityId);
      if (mounted) {
        setState(() {
          _locations = locations;
        });
      }
    } catch (e) {
      print('⚠️ Error loading locations: $e');
    }
  }

  String? _getCityName(String? cityId) {
    if (cityId == null || cityId.isEmpty || _cities == null) {
      return null;
    }
    try {
      final city = _cities!.firstWhere((c) => c.id == cityId);
      return city.name;
    } catch (e) {
      return null;
    }
  }

  String? _getLocationName(String? locationId) {
    if (locationId == null || locationId.isEmpty || _locations == null) {
      return null;
    }
    try {
      final location = _locations!.firstWhere((l) => l.id == locationId);
      return location.name;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VillaCreateFormContent(
      isDialog: true,
      initialVilla: widget.villa,
      onSubmit: (formData) {
        // Map city and location IDs to names
        final cityName = _getCityName(formData['city'] as String?);
        final locationName = _getLocationName(formData['location'] as String?);
        widget.onUpdate(formData, cityName, locationName);
      },
    );
  }
}
