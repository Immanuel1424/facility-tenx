import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/utils/theme_helpers.dart';
import '../../../../../core/theme/app_typography.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import '../../../domain/entities/maintenance_ticket_entity.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../widgets/status_timeline_widget.dart';
import '../../widgets/maintenance_ticket_status_chip.dart';
import '../../widgets/maintenance_ticket_priority_chip.dart';
import '../../widgets/comment_list_widget.dart';
import '../../widgets/location_display_widget.dart';
import '../../widgets/maintenance_ticket_action_buttons.dart';
import '../../widgets/attachment_gallery_widget.dart';
import '../../widgets/escalation_history_widget.dart';
import '../../widgets/ticket_link_widget.dart';
import '../../bloc/comment/comment_bloc.dart';
import '../../bloc/comment/comment_event.dart';
import '../../../domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../../domain/repositories/comment_repository_interface.dart';
import '../../../domain/repositories/attachment_repository_interface.dart';
import '../../../domain/entities/attachment_entity.dart';

class MaintenanceTicketDetailPageEnhanced extends StatelessWidget {
  const MaintenanceTicketDetailPageEnhanced({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MaintenanceTicketBloc(
            repository: getIt<MaintenanceTicketRepositoryInterface>(),
          )..add(LoadMaintenanceTicketDetail(ticketId)),
        ),
        BlocProvider(
          create: (context) => CommentBloc(
            repository: getIt<CommentRepositoryInterface>(),
          )..add(LoadComments(ticketId)),
        ),
      ],
      child: _AdminTicketDetailContent(ticketId: ticketId),
    );
  }
}

class _AdminTicketDetailContent extends StatefulWidget {
  const _AdminTicketDetailContent({required this.ticketId});

  final String ticketId;

  @override
  State<_AdminTicketDetailContent> createState() =>
      _AdminTicketDetailContentState();
}

class _AdminTicketDetailContentState extends State<_AdminTicketDetailContent>
    with WidgetsBindingObserver {
  List<AttachmentEntity> _attachments = [];
  bool _isLoadingAttachments = false;
  bool _hasLoadedOnce =
      false; // Track if attachments have been loaded at least once

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAttachments();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload attachments when the page becomes visible again
    // This handles cases where user navigates back from other pages
    if (ModalRoute.of(context)?.isCurrent == true && !_hasLoadedOnce) {
      _loadAttachments();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App resumed from background, force refresh
      _loadAttachments();
    }
  }

  Future<void> _loadAttachments() async {
    // Prevent multiple simultaneous loads
    if (_isLoadingAttachments) {
      debugPrint('⏳ Attachments already loading, skipping...');
      return;
    }

    setState(() {
      _isLoadingAttachments = true;
    });

    try {
      final repository = getIt<AttachmentRepositoryInterface>();
      debugPrint(
          '📥 [ADMIN] Loading attachments for ticket: ${widget.ticketId}');
      final result = await repository.getAttachments(widget.ticketId);
      result.fold(
        (error) {
          // Log error for debugging
          debugPrint(
              '❌ [ADMIN] Failed to load attachments for ticket ${widget.ticketId}: $error');
          if (mounted) {
            setState(() {
              _isLoadingAttachments = false;
            });
          }
        },
        (attachments) {
          debugPrint(
              '✅ [ADMIN] Loaded ${attachments.length} attachments for ticket ${widget.ticketId}');
          // Debug: Log attachment details
          for (final att in attachments) {
            debugPrint(
              '  - ${att.originalName}: type=${att.attachmentType}, mime=${att.mimeType}, isImage=${att.isImage}, isDeleted=${att.isDeleted}, storageUrl=${att.storageUrl}, ticketId=${att.ticketId}',
            );
          }
          if (mounted) {
            setState(() {
              _attachments = attachments;
              _isLoadingAttachments = false;
              _hasLoadedOnce = true;
            });
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [ADMIN] Exception loading attachments: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingAttachments = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          // Pop with result to trigger refresh in list page
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ticket Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Pop with result to trigger refresh in list page
              context.pop(true);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context
                    .read<MaintenanceTicketBloc>()
                    .add(LoadMaintenanceTicketDetail(widget.ticketId));
                context.read<CommentBloc>().add(LoadComments(widget.ticketId));
                _loadAttachments();
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: BlocConsumer<MaintenanceTicketBloc, MaintenanceTicketState>(
          listener: (context, state) {
            if (state is MaintenanceTicketError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is MaintenanceTicketStatusChanged) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh ticket detail
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
              _loadAttachments();
            } else if (state is MaintenanceTicketNotesAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notes added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh ticket detail
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
              _loadAttachments();
            } else if (state is MaintenanceTicketTeamAssigned) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team assigned successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh ticket detail
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
              _loadAttachments();
            } else if (state is MaintenanceTicketAssigned) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Technician assigned successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh ticket detail
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
              _loadAttachments();
            } else if (state is MaintenanceTicketCancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket cancelled'),
                  backgroundColor: Colors.orange,
                ),
              );
              // Refresh ticket detail
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
              _loadAttachments();
            } else if (state is MaintenanceTicketCompletionConfirmed) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Completion confirmed'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh ticket detail
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
              _loadAttachments();
            } else if (state is MaintenanceTicketAcknowledged) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket acknowledged'),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh ticket detail
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
              _loadAttachments();
            }
          },
          builder: (context, state) {
            if (state is MaintenanceTicketLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MaintenanceTicketDetailLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<MaintenanceTicketBloc>()
                      .add(LoadMaintenanceTicketDetail(widget.ticketId));
                  context
                      .read<CommentBloc>()
                      .add(LoadComments(widget.ticketId));
                  await _loadAttachments();
                },
                child: ResponsiveLayout(
                  mobileBuilder: (context) => _buildTicketDetails(
                    context,
                    state.ticket,
                    isMobile: true,
                  ),
                  desktopBuilder: (context) => _buildTicketDetails(
                    context,
                    state.ticket,
                    isMobile: false,
                  ),
                ),
              );
            } else if (state is MaintenanceTicketError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context
                            .read<MaintenanceTicketBloc>()
                            .add(LoadMaintenanceTicketDetail(widget.ticketId));
                        _loadAttachments();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTicketDetails(
    BuildContext context,
    MaintenanceTicketEntity ticket, {
    required bool isMobile,
  }) {
    if (isMobile) {
      return _buildMobileLayout(context, ticket);
    } else {
      return _buildDesktopLayout(context, ticket);
    }
  }

  Widget _buildMobileLayout(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Status & Priority
          _buildHeaderCard(context, ticket),
          const SizedBox(height: 12),

          // Essential Information Card
          _buildInfoCard(context, ticket),
          const SizedBox(height: 12),

          // Location & Assignment Card
          _buildLocationAssignmentCard(context, ticket),
          const SizedBox(height: 12),

          // Creator & Tenant Information Card (Admin-specific)
          _buildCreatorTenantCard(context, ticket),
          const SizedBox(height: 12),

          // Escalation & Relationships Card (Admin-specific)
          if (ticket.isEscalated || ticket.hasParent())
            _buildEscalationRelationsCard(context, ticket),
          if (ticket.isEscalated || ticket.hasParent())
            const SizedBox(height: 12),

          // Child Tickets Card (if this is a parent ticket)
          if (!ticket.hasParent()) TicketLinkWidget(ticket: ticket),
          if (!ticket.hasParent()) const SizedBox(height: 12),

          // Technician Notes Card (if exists)
          if (ticket.technicianNotes != null &&
              ticket.technicianNotes!.isNotEmpty)
            _buildTechnicianNotesCard(context, ticket.technicianNotes!),
          if (ticket.technicianNotes != null &&
              ticket.technicianNotes!.isNotEmpty)
            const SizedBox(height: 12),

          // Resolution Notes Card (if exists)
          if (ticket.resolutionNotes != null &&
              ticket.resolutionNotes!.isNotEmpty)
            _buildResolutionNotesCard(
              context,
              ticket.resolutionNotes!,
            ),
          if (ticket.resolutionNotes != null &&
              ticket.resolutionNotes!.isNotEmpty)
            const SizedBox(height: 12),

          // Tenant Rating Card (if ticket is completed and has rating)
          if (ticket.status == TicketStatus.completed && ticket.rating != null)
            _buildTenantRatingCard(context, ticket),
          if (ticket.status == TicketStatus.completed && ticket.rating != null)
            const SizedBox(height: 12),

          // SLA Information Card (if SLA data is available)
          if (ticket.slaDueAt != null)
            _buildSlaInformationCard(context, ticket),
          if (ticket.slaDueAt != null) const SizedBox(height: 12),

          // Status Timeline Card
          _buildTimelineCard(context, ticket),
          const SizedBox(height: 12),

          // Attachments Card
          _buildAttachmentsCard(context),
          const SizedBox(height: 12),

          // Comments Card (Admin can see internal notes)
          _buildCommentsCard(context, widget.ticketId, ticket),
          const SizedBox(height: 12),

          // Action Buttons Card
          _buildActionButtonsCard(context, ticket),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Header and Action Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Ticket Details
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card with Status & Priority
                        _buildHeaderCard(context, ticket),
                        const SizedBox(height: 16),

                        // Essential Information Card
                        _buildInfoCard(context, ticket),
                        const SizedBox(height: 16),

                        // Location & Assignment Card
                        _buildLocationAssignmentCard(context, ticket),
                        const SizedBox(height: 16),

                        // Creator & Tenant Information Card
                        _buildCreatorTenantCard(context, ticket),
                        const SizedBox(height: 16),

                        // Escalation & Relationships Card
                        if (ticket.isEscalated || ticket.hasParent())
                          _buildEscalationRelationsCard(context, ticket),
                        if (ticket.isEscalated || ticket.hasParent())
                          const SizedBox(height: 16),

                        // Technician Notes Card
                        if (ticket.technicianNotes != null &&
                            ticket.technicianNotes!.isNotEmpty) ...[
                          _buildTechnicianNotesCard(
                            context,
                            ticket.technicianNotes!,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Resolution Notes Card
                        if (ticket.resolutionNotes != null &&
                            ticket.resolutionNotes!.isNotEmpty) ...[
                          _buildResolutionNotesCard(
                            context,
                            ticket.resolutionNotes!,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Tenant Rating Card (if ticket is completed and has rating)
                        if (ticket.status == TicketStatus.completed &&
                            ticket.rating != null) ...[
                          _buildTenantRatingCard(context, ticket),
                          const SizedBox(height: 16),
                        ],

                        // SLA Information Card (if SLA data is available)
                        if (ticket.slaDueAt != null) ...[
                          _buildSlaInformationCard(context, ticket),
                          const SizedBox(height: 16),
                        ],

                        // Attachments Card
                        _buildAttachmentsCard(context),
                        const SizedBox(height: 16),

                        // Status Timeline Card
                        _buildTimelineCard(context, ticket),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Middle Column: Comments ONLY
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Comments Card
                        _buildCommentsCard(context, widget.ticketId, ticket),
                      ],
                    ),
                  ),

                  // Right Column: Action Buttons (Sticky)
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 320,
                    child: Column(
                      children: [
                        _buildActionButtonsCard(context, ticket),
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

  Widget _buildHeaderCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: context.cardBorderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                ticket.title.isNotEmpty ? ticket.title : 'No Title',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Ticket ID, Status, and Priority - Horizontal Layout
              Wrap(
                spacing: 24,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Ticket ID
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ticket ID:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.tag_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ticket.ticketNumber.isNotEmpty
                            ? ticket.ticketNumber
                            : 'N/A',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Status:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MaintenanceTicketStatusChip(status: ticket.status),
                    ],
                  ),
                  // Priority
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Priority:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MaintenanceTicketPriorityChip(
                        priority: ticket.priority,
                        priorityDetails: ticket.priorityDetails,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.info_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ticket Information',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (ticket.description != null &&
                  ticket.description!.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  'Description',
                  ticket.description!,
                  isMultiline: true,
                ),
                const SizedBox(height: 12),
              ],
              if (ticket.category != null) ...[
                _buildInfoRow(
                    context, 'Category', ticket.category!.displayName),
                const SizedBox(height: 12),
              ],
              if (ticket.ticketType != null) ...[
                _buildInfoRow(
                  context,
                  'Ticket Type',
                  ticket.ticketTypeDisplay,
                ),
                const SizedBox(height: 12),
              ],
              if (ticket.villaNumber != null)
                _buildInfoRow(context, 'Villa', 'Villa ${ticket.villaNumber}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAssignmentCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasAssignmentInfo = ticket.assignedTechnicianName != null ||
        ticket.assignedSupervisorName != null ||
        ticket.assignedTeam != null ||
        ticket.departmentName != null ||
        ticket.scheduledAt != null ||
        ticket.assigner != null ||
        ticket.supervisorAssignedAt != null;

    if (!hasAssignmentInfo && ticket.locationDisplay.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.location_on_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Location & Assignment',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (ticket.locationDisplay.isNotEmpty) ...[
                LocationDisplayWidget(ticket: ticket),
                if (hasAssignmentInfo || ticket.locationDetail != null)
                  const SizedBox(height: 16),
              ],
              // Location Detail (specific location within villa/space)
              if (ticket.locationDetail != null &&
                  ticket.locationDetail!.isNotEmpty) ...[
                _buildInfoRow(
                  context,
                  'Location Detail',
                  ticket.locationDetail!,
                  showIcon: true,
                  icon: Icons.location_on_outlined,
                ),
                if (hasAssignmentInfo) const SizedBox(height: 16),
              ],
              if (ticket.departmentName != null)
                _buildInfoRow(context, 'Department', ticket.departmentName!),
              if (ticket.assignedTeam != null) ...[
                if (ticket.departmentName != null) const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Assigned Team',
                  ticket.assignedTeam!.displayName,
                  showIcon: true,
                  icon: Icons.group_outlined,
                ),
              ],
              if (ticket.assignedSupervisorName != null) ...[
                if (ticket.assignedSupervisorName != null ||
                    ticket.departmentName != null ||
                    ticket.assignedTeam != null)
                  const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Supervisor',
                  ticket.assignedSupervisorName!,
                ),
                if (ticket.supervisorAssignedAt != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      'Assigned on ${_formatDateTime(ticket.supervisorAssignedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
              if (ticket.assignedTechnicianName != null) ...[
                if (ticket.assignedSupervisorName != null ||
                    ticket.departmentName != null ||
                    ticket.assignedTeam != null)
                  const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Assigned To',
                  ticket.assignedTechnicianName!,
                ),
              ],
              if (ticket.assigner != null) ...[
                if (ticket.assignedTechnicianName != null ||
                    ticket.assignedSupervisorName != null ||
                    ticket.departmentName != null ||
                    ticket.assignedTeam != null)
                  const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Assigned By',
                  _getUserNameFromAssigner(ticket.assigner!),
                  showIcon: true,
                  icon: Icons.person_add_outlined,
                ),
                if (ticket.assignedAt != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      'On ${_formatDateTime(ticket.assignedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
              if (ticket.scheduledAt != null) ...[
                if (ticket.assignedTechnicianName != null ||
                    ticket.assignedSupervisorName != null ||
                    ticket.departmentName != null ||
                    ticket.assignedTeam != null ||
                    ticket.assigner != null)
                  const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Scheduled',
                  _formatDateTime(ticket.scheduledAt!),
                  showIcon: true,
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorTenantCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.person_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Creator & Tenant Information',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (ticket.creatorDisplayName != null) ...[
                _buildInfoRow(
                  context,
                  'Created By',
                  ticket.creatorDisplayName!,
                ),
              ],
              // Contact Information
              if (ticket.contactNumber != null ||
                  ticket.alternateContact != null ||
                  ticket.preferredTime != null) ...[
                if (ticket.creatorDisplayName != null)
                  const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'Contact Information',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                if (ticket.contactNumber != null) ...[
                  _buildInfoRow(
                    context,
                    'Contact Number',
                    ticket.contactNumber!,
                    showIcon: true,
                    icon: Icons.phone_outlined,
                  ),
                ],
                if (ticket.alternateContact != null) ...[
                  if (ticket.contactNumber != null) const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'Alternate Contact',
                    ticket.alternateContact!,
                    showIcon: true,
                    icon: Icons.phone_android_outlined,
                  ),
                ],
                if (ticket.preferredTime != null) ...[
                  if (ticket.contactNumber != null ||
                      ticket.alternateContact != null)
                    const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'Preferred Time',
                    ticket.preferredTime!,
                    showIcon: true,
                    icon: Icons.access_time_outlined,
                  ),
                ],
              ],
              // Tenant Confirmation Status
              if (ticket.status == TicketStatus.completed) ...[
                if (ticket.creatorDisplayName != null ||
                    ticket.contactNumber != null ||
                    ticket.alternateContact != null ||
                    ticket.preferredTime != null)
                  const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      ticket.tenantConfirmed
                          ? Icons.check_circle_outline
                          : Icons.pending_outlined,
                      size: 18,
                      color: ticket.tenantConfirmed
                          ? Colors.green
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tenant Confirmation:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ticket.tenantConfirmed
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticket.tenantConfirmed ? 'Confirmed' : 'Pending',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ticket.tenantConfirmed
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEscalationRelationsCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.trending_up_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Escalation & Relationships',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (ticket.isEscalated) ...[
                _buildInfoRow(
                  context,
                  'Escalation Status',
                  'Escalated (Level ${ticket.escalationLevel})',
                ),
                if (ticket.escalatedAt != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'Escalated At',
                    _formatDateTime(ticket.escalatedAt!),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Escalation History',
                  style: _getLabelStyle(context),
                ),
                const SizedBox(height: 8),
                EscalationHistoryWidget(ticketId: ticket.id),
              ],
              if (ticket.hasParent()) ...[
                if (ticket.isEscalated) const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Parent Ticket',
                  ticket.parentTicketId ?? 'N/A',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianNotesCard(BuildContext context, String notes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.note_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Technician Notes',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: context.cardBorderRadius,
                ),
                child: Text(
                  notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResolutionNotesCard(BuildContext context, String notes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.check_circle_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Resolution Notes',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: context.cardBorderRadius,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTenantRatingCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.star_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tenant Rating & Feedback',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Rating Display
              Row(
                children: [
                  Text(
                    'Rating:',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Star Rating Display
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (ticket.rating ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${ticket.rating}/5',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              // Rating Comment (if exists)
              if (ticket.ratingComment != null &&
                  ticket.ratingComment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: context.cardBorderRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comment:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.ratingComment!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Rating Timestamp (if available)
              if (ticket.ratedAt != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Rated on ${_formatDateTime(ticket.ratedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.timeline_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status Timeline',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StatusTimelineWidget(ticket: ticket),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Key Timestamps
              _buildInfoRow(
                context,
                'Created',
                _formatDateTime(ticket.createdAt),
                showIcon: true,
                icon: Icons.add_circle_outline,
              ),
              if (ticket.acknowledgedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Acknowledged',
                  _formatDateTime(ticket.acknowledgedAt!),
                  showIcon: true,
                  icon: Icons.check_circle_outline,
                ),
              ],
              if (ticket.assignedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Assigned',
                  _formatDateTime(ticket.assignedAt!),
                  showIcon: true,
                  icon: Icons.person_outline,
                ),
              ],
              if (ticket.completedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Completed',
                  _formatDateTime(ticket.completedAt!),
                  showIcon: true,
                  icon: Icons.check_circle_outline,
                ),
              ],
              if (ticket.closedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Closed',
                  _formatDateTime(ticket.closedAt!),
                  showIcon: true,
                  icon: Icons.lock_outline,
                ),
              ],
              if (ticket.autoCloseAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Auto-Close Scheduled',
                  _formatDateTime(ticket.autoCloseAt!),
                  showIcon: true,
                  icon: Icons.schedule_outlined,
                ),
              ],
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Last Updated',
                _formatDateTime(ticket.updatedAt),
                showIcon: true,
                icon: Icons.update_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _getLabelStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ) ??
        TextStyle(
          fontSize: AppFontSizes.labelMedium,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isMultiline = false,
    bool showIcon = false,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isMultiline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: context.cardBorderRadius,
            ),
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showIcon && icon != null) ...[
          Icon(
            icon,
            size: 16,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: showIcon ? 130 : 140,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getUserNameFromAssigner(UserEntity user) {
    final firstName = user.firstName;
    final lastName = user.lastName;
    if (firstName != null && lastName != null) {
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }
    return user.email;
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormatter.formatDateTime(dateTime);
  }

  Widget _buildSlaInformationCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (ticket.slaDueAt == null) {
      return const SizedBox.shrink();
    }

    final isCompleted = ticket.status == TicketStatus.completed;
    final now = DateTime.now();
    final slaDueAt = ticket.slaDueAt!;
    final timeRemaining = slaDueAt.difference(now);
    final isBreached = timeRemaining.isNegative;
    final isAtRisk = !isBreached && timeRemaining.inHours < 24;
    final slaStatus = ticket.slaStatus?.toUpperCase() ?? 'UNKNOWN';

    // Calculate time metrics
    String timeRemainingText;
    Color statusColor;
    IconData statusIcon;

    if (isCompleted) {
      // For completed tickets, show final SLA outcome
      if (slaStatus == 'MET') {
        timeRemainingText = 'SLA was met successfully';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      } else if (slaStatus == 'BREACHED') {
        final breachTime = ticket.completedAt != null
            ? ticket.completedAt!.difference(slaDueAt)
            : timeRemaining.abs();
        timeRemainingText =
            'SLA was breached by ${_formatDuration(breachTime)}';
        statusColor = Colors.red;
        statusIcon = Icons.error;
      } else {
        // Fallback for other statuses
        timeRemainingText = 'Final Status: ${_formatSlaStatus(slaStatus)}';
        statusColor = slaStatus == 'BREACHED' ? Colors.red : Colors.orange;
        statusIcon = slaStatus == 'BREACHED' ? Icons.error : Icons.warning;
      }
    } else {
      // For active tickets, show time remaining
      if (isBreached) {
        timeRemainingText =
            'Breached (${_formatDuration(timeRemaining.abs())} ago)';
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
      } else if (isAtRisk) {
        timeRemainingText = '${_formatDuration(timeRemaining)} remaining';
        statusColor = Colors.orange;
        statusIcon = Icons.warning_outlined;
      } else {
        timeRemainingText = '${_formatDuration(timeRemaining)} remaining';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
      }
    }

    // Calculate response time if ticket was acknowledged
    String? responseTimeText;
    if (ticket.acknowledgedAt != null) {
      final responseTime = ticket.acknowledgedAt!.difference(ticket.createdAt);
      responseTimeText = 'Response Time: ${_formatDuration(responseTime)}';
    }

    // Calculate resolution time if ticket was completed
    String? resolutionTimeText;
    if (ticket.completedAt != null) {
      final resolutionTime = ticket.completedAt!.difference(ticket.createdAt);
      resolutionTimeText =
          'Resolution Time: ${_formatDuration(resolutionTime)}';
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    isCompleted
                        ? Icons.history_outlined
                        : Icons.schedule_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted
                        ? 'SLA Performance (Historical)'
                        : 'SLA & Performance',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // SLA Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: context.cardBorderRadius,
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SLA Status: ${_formatSlaStatus(slaStatus)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeRemainingText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // SLA Due Date
              _buildInfoRow(
                context,
                isCompleted ? 'SLA Deadline' : 'SLA Due Date',
                _formatDateTime(slaDueAt),
                showIcon: true,
                icon: Icons.event_outlined,
              ),
              // For completed tickets, show completion date
              if (isCompleted && ticket.completedAt != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Completed On',
                  _formatDateTime(ticket.completedAt!),
                  showIcon: true,
                  icon: Icons.check_circle_outline,
                ),
              ],
              // Response Time
              if (responseTimeText != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Response Time',
                  responseTimeText.replaceFirst('Response Time: ', ''),
                  showIcon: true,
                  icon: Icons.access_time_outlined,
                ),
              ],
              // Resolution Time
              if (resolutionTimeText != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Resolution Time',
                  resolutionTimeText.replaceFirst('Resolution Time: ', ''),
                  showIcon: true,
                  icon: Icons.timer_outlined,
                ),
                // Show SLA compliance for completed tickets
                if (isCompleted && ticket.completedAt != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    'SLA Compliance',
                    slaStatus == 'MET'
                        ? '✅ Met SLA deadline'
                        : '❌ Breached SLA deadline',
                    showIcon: true,
                    icon:
                        slaStatus == 'MET' ? Icons.thumb_up : Icons.thumb_down,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatSlaStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ON_TRACK':
        return 'On Track';
      case 'AT_RISK':
        return 'At Risk';
      case 'BREACHED':
        return 'Breached';
      case 'PAUSED':
        return 'Paused';
      case 'MET':
        return 'Met';
      default:
        return status;
    }
  }

  Widget _buildAttachmentsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter to only images (not deleted)
    final imageAttachments =
        _attachments.where((att) => att.isImage && !att.isDeleted).toList();

    debugPrint(
      '📸 [ADMIN] Attachments card: total=${_attachments.length}, images=${imageAttachments.length}, loading=$_isLoadingAttachments',
    );

    // Hide card if no attachments and loading is complete
    if (imageAttachments.isEmpty && !_isLoadingAttachments) {
      return const SizedBox.shrink();
    }

    // Show loading only if still loading
    if (_isLoadingAttachments) {
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
                    Icons.photo_library_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Attachments',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.photo_library_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Attachments',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoadingAttachments)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                AttachmentGalleryWidget(
                  attachments: imageAttachments,
                  onImageTap: (attachment, index) {
                    showDialog<void>(
                      context: context,
                      barrierColor: Colors.black87,
                      builder: (dialogContext) => ImagePreviewDialog(
                        attachments: imageAttachments,
                        initialIndex: index,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsCard(
    BuildContext context,
    String ticketId,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    Icons.comment_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Comments & Notes',
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CommentListWidget(
                ticketId: ticketId,
                ticketStatus: ticket.status,
                showInternalNotes: true, // Admin can see internal notes
                showInput: true, // Enable comment input
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
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
                    style: _getLabelStyle(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MaintenanceTicketActionButtons(ticket: ticket),
            ],
          ),
        ),
      ),
    );
  }
}
