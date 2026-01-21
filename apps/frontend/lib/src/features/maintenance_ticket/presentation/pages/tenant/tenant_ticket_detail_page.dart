import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/service_locator.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import '../../../domain/entities/maintenance_ticket_entity.dart';

import '../../widgets/status_timeline_widget.dart';
import '../../widgets/maintenance_ticket_status_chip.dart';
import '../../widgets/maintenance_ticket_priority_chip.dart';
import '../../widgets/comment_list_widget.dart';
import '../../widgets/comment_input_widget.dart';
import '../../widgets/attachment_gallery_widget.dart';
import '../../widgets/ticket_rating_widget.dart';
import '../../bloc/comment/comment_bloc.dart';
import '../../bloc/comment/comment_event.dart';
import '../../bloc/comment/comment_state.dart';
import '../../../domain/entities/comment_entity.dart' as domain;
import '../../../domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../../domain/repositories/comment_repository_interface.dart';
import '../../../domain/repositories/attachment_repository_interface.dart';
import '../../../domain/entities/attachment_entity.dart';
import '../../../../../core/widgets/header_widgets.dart';
import '../../../../../core/theme/app_typography.dart';

class TenantTicketDetailPage extends StatelessWidget {
  const TenantTicketDetailPage({
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
      child: _TenantTicketDetailContent(ticketId: ticketId),
    );
  }
}

class _TenantTicketDetailContent extends StatefulWidget {
  const _TenantTicketDetailContent({required this.ticketId});

  final String ticketId;

  @override
  State<_TenantTicketDetailContent> createState() =>
      _TenantTicketDetailContentState();
}

class _TenantTicketDetailContentState
    extends State<_TenantTicketDetailContent> {
  List<AttachmentEntity> _attachments = [];
  bool _isLoadingAttachments = false;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  // Track if this is the first build to avoid double-loading
  bool _hasLoadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload if we've already loaded once (to catch updates after returning from create page)
    if (_hasLoadedOnce && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadAttachments();
        }
      });
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
      debugPrint('📥 Loading attachments for ticket: ${widget.ticketId}');
      final result = await repository.getAttachments(widget.ticketId);
      result.fold(
        (error) {
          // Log error for debugging
          debugPrint(
              '❌ Failed to load attachments for ticket ${widget.ticketId}: $error');
          if (mounted) {
            setState(() {
              _isLoadingAttachments = false;
            });
          }
        },
        (attachments) {
          debugPrint(
              '✅ Loaded ${attachments.length} attachments for ticket ${widget.ticketId}');
          // Debug: Log attachment details
          for (final att in attachments) {
            debugPrint(
              '  - ${att.originalName}: type=${att.attachmentType}, mime=${att.mimeType}, isImage=${att.isImage}, isDeleted=${att.isDeleted}, storageUrl=${att.storageUrl}',
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
      debugPrint('❌ Exception loading attachments: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
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
          state.maybeWhen(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            completionConfirmed: (ticket) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Completion confirmed. Ticket closed.'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            ratingSubmitted: (ticket) {
              // Rating success is already shown in the widget
              // This listener is here for potential future use
            },
            cancelled: (ticket) {
              final bloc = context.read<MaintenanceTicketBloc>();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ticket cancelled. If this was a mistake, contact site coordinator.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: Colors.white,
                    onPressed: () {
                      // Best-effort optimistic undo: try to move ticket back to NEW.
                      // Backend will enforce role permissions.
                      bloc.add(
                        ChangeMaintenanceTicketStatus(
                          id: ticket.id,
                          status: TicketStatus.new_.toBackendValue,
                          notes: 'Tenant requested undo of cancellation.',
                        ),
                      );
                    },
                  ),
                ),
              );
              // Reload ticket detail to reflect cancelled status
              bloc.add(LoadMaintenanceTicketDetail(widget.ticketId));
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          if (state is MaintenanceTicketLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MaintenanceTicketDetailLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                // Reload ticket details, comments, and attachments
                context
                    .read<MaintenanceTicketBloc>()
                    .add(LoadMaintenanceTicketDetail(widget.ticketId));
                context.read<CommentBloc>().add(LoadComments(widget.ticketId));
                await _loadAttachments();
                // Small delay to ensure all data is loaded
                await Future<void>.delayed(const Duration(milliseconds: 300));
              },
              child: _buildTicketDetails(context, state.ticket),
            );
          } else if (state is MaintenanceTicketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context
                          .read<MaintenanceTicketBloc>()
                          .add(LoadMaintenanceTicketDetail(widget.ticketId));
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
    );
  }

  Widget _buildTicketDetails(
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

          // Status Timeline Card
          _buildTimelineCard(context, ticket),
          const SizedBox(height: 12),

          // Attachments Card
          _buildAttachmentsCard(context),
          const SizedBox(height: 12),

          // Comments Card (only if comments are enabled and not empty)
          if (_areCommentsEnabled(ticket))
            _buildCommentsCard(context, widget.ticketId, ticket),
          if (_areCommentsEnabled(ticket)) const SizedBox(height: 12),

          // Comment Input (only if comments are enabled)
          if (_areCommentsEnabled(ticket))
            _buildCommentInput(context, widget.ticketId, ticket),
          if (_areCommentsEnabled(ticket)) const SizedBox(height: 12),

          // Action Buttons at the end of scroll
          _QuickActionSection(ticket: ticket),
          const SizedBox(height: 12),

          // Rating Card (if ticket is closed) - moved to bottom
          if (ticket.tenantConfirmed) ...[
            TicketRatingWidget(ticket: ticket),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              ticket.title.isNotEmpty ? ticket.title : 'No Title',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: AppFontSizes.titleExtraSmall,
              ),
            ),
            const SizedBox(height: 12),
            // Ticket Number with Icon
            Row(
              children: [
                Icon(
                  Icons.tag_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  ticket.ticketNumber.isNotEmpty ? ticket.ticketNumber : 'N/A',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Status & Priority Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MaintenanceTicketStatusChip(status: ticket.status),
                MaintenanceTicketPriorityChip(
                  priority: ticket.priority,
                  priorityDetails: ticket.priorityDetails,
                  showIcon: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(
              'Ticket Information',
              icon: Icons.info_outline,
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
              _buildInfoRow(context, 'Category', ticket.category!.displayName),
              const SizedBox(height: 12),
            ],
            if (ticket.villaNumber != null)
              _buildInfoRow(context, 'Villa', 'Villa ${ticket.villaNumber}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAssignmentCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    final hasAssignmentInfo = ticket.assignedTechnicianName != null ||
        ticket.departmentName != null ||
        ticket.scheduledAt != null;

    if (!hasAssignmentInfo && ticket.locationDisplay.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(
              'Location & Assignment',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            if (ticket.locationDisplay.isNotEmpty) ...[
              _buildInfoRow(context, 'Location', ticket.locationDisplay),
              if (hasAssignmentInfo) const SizedBox(height: 12),
            ],
            if (ticket.departmentName != null)
              _buildInfoRow(context, 'Department', ticket.departmentName!),
            if (ticket.assignedTechnicianName != null) ...[
              if (ticket.departmentName != null) const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Assigned To',
                ticket.assignedTechnicianName!,
              ),
            ],
            if (ticket.scheduledAt != null) ...[
              if (ticket.assignedTechnicianName != null ||
                  ticket.departmentName != null)
                const SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Scheduled',
                _formatDateTime(ticket.scheduledAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianNotesCard(BuildContext context, String notes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(
              'Technician Notes',
              icon: Icons.note_outlined,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionNotesCard(BuildContext context, String notes) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resolution Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSizes.titleSmall,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                notes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    MaintenanceTicketEntity ticket,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(
              'Status Timeline',
              icon: Icons.timeline_outlined,
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
    if (isMultiline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.labelMedium,
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
              style: const TextStyle(
                fontSize: AppFontSizes.bodyMedium,
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
          width: showIcon ? 90 : 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.labelMedium,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppFontSizes.bodyMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }

  bool _areCommentsEnabled(MaintenanceTicketEntity ticket) {
    // Comments are disabled for completed or cancelled tickets
    return ticket.status != TicketStatus.completed &&
        ticket.status != TicketStatus.cancelled;
  }

  Widget _buildAttachmentsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter to only images (not deleted)
    final imageAttachments =
        _attachments.where((att) => att.isImage && !att.isDeleted).toList();

    debugPrint(
      '📸 Attachments card: total=${_attachments.length}, images=${imageAttachments.length}, loading=$_isLoadingAttachments',
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
          borderRadius: BorderRadius.circular(12),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.titleSmall,
                    ),
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

    // Show attachments if available
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(
              'Attachments',
              icon: Icons.photo_library_outlined,
            ),
            const SizedBox(height: 16),
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
    );
  }

  Widget _buildCommentsCard(
    BuildContext context,
    String ticketId,
    MaintenanceTicketEntity ticket,
  ) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        // Hide card if no comments
        if (state is CommentsLoaded) {
          final comments = state.comments
              .where(
                (comment) =>
                    !comment.isDeleted &&
                    comment.commentType != domain.CommentType.internal,
              )
              .toList();
          if (comments.isEmpty) {
            return const SizedBox.shrink();
          }
        }

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardHeader(
                  'Comments',
                  icon: Icons.comment_outlined,
                ),
                const SizedBox(height: 12),
                CommentListWidget(
                  ticketId: ticketId,
                  ticketStatus: ticket.status,
                  showInternalNotes: false,
                  showInput: false, // Input is now outside the card
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    String ticketId,
    MaintenanceTicketEntity ticket,
  ) {
    // Use the same CommentBloc from the parent (provided in TenantTicketDetailPage)
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CardHeader(
              'Add Comment',
              icon: Icons.edit_note,
            ),
          ),
          CommentInputWidget(
            ticketId: ticketId,
            ticketStatus: ticket.status,
            onCommentCreated: () {
              // Reload comments after creation - this will update both the list and input
              context.read<CommentBloc>().add(LoadComments(ticketId));
            },
          ),
        ],
      ),
    );
  }
}

/// Quick Action Section for Tenant - Confirm/Cancel actions
class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection({required this.ticket});

  final MaintenanceTicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    // Hide "Confirm Resolution" button for tenants - removed per requirement
    const canConfirm = false;
    // Allow cancellation for all statuses except completed and already cancelled
    final canCancel = ticket.status != TicketStatus.completed &&
        ticket.status != TicketStatus.cancelled;
    final isWorkInProgress = ticket.status == TicketStatus.inProgress ||
        ticket.status == TicketStatus.assigned;

    if (!canConfirm && !canCancel) {
      return const SizedBox.shrink();
    }

    return _buildActionButtons(
      context,
      ticket,
      canConfirm,
      canCancel,
      isWorkInProgress,
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    MaintenanceTicketEntity ticket,
    bool canConfirm,
    bool canCancel,
    bool isWorkInProgress,
  ) {
    // Primary action row (Confirm / Cancel)
    if (canConfirm && canCancel) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showCancelConfirmation(context, ticket, isWorkInProgress),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Ticket'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                context.read<MaintenanceTicketBloc>().add(
                      ConfirmMaintenanceTicketCompletion(ticket.id),
                    );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm Resolution'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (canConfirm) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            context.read<MaintenanceTicketBloc>().add(
                  ConfirmMaintenanceTicketCompletion(ticket.id),
                );
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm Resolution'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () =>
              _showCancelConfirmation(context, ticket, isWorkInProgress),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Ticket'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            backgroundColor: Colors.orange,
          ),
        ),
      );
    }
  }

  void _showCancelConfirmation(
    BuildContext context,
    MaintenanceTicketEntity ticket,
    bool isWorkInProgress,
  ) {
    // Capture BLoC reference before showing dialog
    final bloc = context.read<MaintenanceTicketBloc>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          isWorkInProgress ? Icons.warning_amber_rounded : Icons.info_outline,
          color: isWorkInProgress ? Colors.orange : null,
          size: 48,
        ),
        title: Text(
          isWorkInProgress ? 'Cancel In-Progress Ticket?' : 'Cancel Ticket',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWorkInProgress) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.build_circle,
                      size: 20,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A technician is currently working on this ticket.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              isWorkInProgress
                  ? 'Are you sure you want to cancel ticket ${ticket.ticketNumber}? The technician will be notified and work will stop immediately. This action cannot be undone.'
                  : 'Are you sure you want to cancel ticket ${ticket.ticketNumber}? This action cannot be undone.',
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(
                CancelMaintenanceTicket(ticket.id),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
