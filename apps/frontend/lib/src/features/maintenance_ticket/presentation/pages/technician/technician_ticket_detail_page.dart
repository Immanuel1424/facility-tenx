import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../domain/entities/maintenance_ticket_entity.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import '../../bloc/comment/comment_bloc.dart';
import '../../bloc/comment/comment_event.dart';
import '../../widgets/maintenance_ticket_status_chip.dart';
import '../../widgets/maintenance_ticket_priority_chip.dart';
import '../../widgets/location_display_widget.dart';
import '../../widgets/status_timeline_widget.dart';
import '../../widgets/comment_list_widget.dart';
import '../../widgets/attachment_gallery_widget.dart';
import '../../../domain/repositories/attachment_repository_interface.dart';
import '../../../domain/entities/attachment_entity.dart';

/// Action-oriented ticket detail page specifically designed for technicians.
/// Mobile-first, focused on quick actions: Start, Add Notes, Complete.
class TechnicianTicketDetailPage extends StatelessWidget {
  const TechnicianTicketDetailPage({
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
            repository: getIt(),
          )..add(LoadMaintenanceTicketDetail(ticketId)),
        ),
        BlocProvider(
          create: (context) => CommentBloc(
            repository: getIt(),
          )..add(LoadComments(ticketId)),
        ),
      ],
      child: _TechnicianTicketDetailContent(ticketId: ticketId),
    );
  }
}

class _TechnicianTicketDetailContent extends StatefulWidget {
  const _TechnicianTicketDetailContent({required this.ticketId});

  final String ticketId;

  @override
  State<_TechnicianTicketDetailContent> createState() =>
      _TechnicianTicketDetailContentState();
}

class _TechnicianTicketDetailContentState
    extends State<_TechnicianTicketDetailContent> {
  List<AttachmentEntity> _attachments = [];
  bool _isLoadingAttachments = false;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    setState(() {
      _isLoadingAttachments = true;
    });

    try {
      final repository = getIt<AttachmentRepositoryInterface>();
      final result = await repository.getAttachments(widget.ticketId);
      result.fold(
        (error) {
          // Silently handle errors - attachments are optional
          debugPrint('Failed to load attachments: $error');
        },
        (attachments) {
          if (mounted) {
            setState(() {
              _attachments = attachments;
              _isLoadingAttachments = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Error loading attachments: $e');
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
              context.read<MaintenanceTicketBloc>().add(
                    LoadMaintenanceTicketDetail(widget.ticketId),
                  );
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
            statusChanged: (ticket) {
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
            },
            notesAdded: (ticket) {
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
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          if (state is MaintenanceTicketLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MaintenanceTicketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MaintenanceTicketBloc>().add(
                            LoadMaintenanceTicketDetail(widget.ticketId),
                          );
                      _loadAttachments();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MaintenanceTicketDetailLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Action Buttons (Sticky at top)
                  _QuickActionSection(ticket: state.ticket),
                  const SizedBox(height: 16),

                  // Header Card with Status & Priority
                  _buildHeaderCard(context, state.ticket),
                  const SizedBox(height: 12),

                  // Essential Information Card
                  _buildInfoCard(context, state.ticket),
                  const SizedBox(height: 12),

                  // Location & Assignment Card
                  _buildLocationAssignmentCard(context, state.ticket),
                  const SizedBox(height: 12),

                  // Work Notes Card (if exists)
                  if (state.ticket.technicianNotes != null &&
                      state.ticket.technicianNotes!.isNotEmpty)
                    _buildWorkNotesCard(context, state.ticket.technicianNotes!),
                  if (state.ticket.technicianNotes != null &&
                      state.ticket.technicianNotes!.isNotEmpty)
                    const SizedBox(height: 12),

                  // Resolution Notes Card (if exists)
                  if (state.ticket.resolutionNotes != null &&
                      state.ticket.resolutionNotes!.isNotEmpty)
                    _buildResolutionNotesCard(
                      context,
                      state.ticket.resolutionNotes!,
                    ),
                  if (state.ticket.resolutionNotes != null &&
                      state.ticket.resolutionNotes!.isNotEmpty)
                    const SizedBox(height: 12),

                  // Status Timeline Card
                  _buildTimelineCard(context, state.ticket),
                  const SizedBox(height: 12),

                  // Attachments Card
                  _buildAttachmentsCard(context),
                  const SizedBox(height: 12),

                  // Comments Card
                  _buildCommentsCard(context, widget.ticketId, state.ticket),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
                fontSize: 18,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
              _buildInfoRow(context, 'Category', ticket.category!.displayName),
            ],
          ],
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ticket.locationDisplay.isNotEmpty) ...[
              LocationDisplayWidget(ticket: ticket),
              if (hasAssignmentInfo) const SizedBox(height: 16),
            ],
            if (ticket.departmentName != null)
              _buildInfoRow(context, 'Department', ticket.departmentName!),
            if (ticket.assignedTechnicianName != null) ...[
              if (ticket.departmentName != null) const SizedBox(height: 8),
              _buildInfoRow(
                  context, 'Assigned To', ticket.assignedTechnicianName!,),
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

  Widget _buildWorkNotesCard(BuildContext context, String notes) {
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
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Work Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
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
                    fontSize: 16,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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

  Widget _buildAttachmentsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter to only images
    final imageAttachments =
        _attachments.where((att) => att.isImage && !att.isDeleted).toList();

    if (imageAttachments.isEmpty && !_isLoadingAttachments) {
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
                    fontSize: 16,
                  ),
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
    );
  }

  Widget _buildCommentsCard(
    BuildContext context,
    String ticketId,
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
            Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Comments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CommentListWidget(
              ticketId: ticketId,
              ticketStatus: ticket.status,
              showInternalNotes: false,
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
              fontSize: 13,
              color: Colors.grey,
            ),
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
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }
}

/// Quick Action Section - Clean, modern design
class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection({required this.ticket});

  final MaintenanceTicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    return _buildActionButtons(context);
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show Start button for assigned/acknowledged tickets
    if (ticket.status == TicketStatus.assigned ||
        ticket.status == TicketStatus.acknowledged) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _startWork(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, size: 24),
              const SizedBox(width: 8),
              Text(
                'Start Work',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show Notes and Complete buttons for in-progress tickets
    if (ticket.status == TicketStatus.inProgress) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _addNotes(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: colorScheme.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 24, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Add Notes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeTicket(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Complete Ticket',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // For completed tickets, show success badge
    if (ticket.status == TicketStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 12),
            Text(
              'Ticket Completed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // For other statuses, show minimal status indicator
    return const SizedBox.shrink();
  }

  void _startWork(BuildContext context) {
    final bloc = context.read<MaintenanceTicketBloc>();
    bloc.add(
      ChangeMaintenanceTicketStatus(
        id: ticket.id,
        status: TicketStatus.inProgress.toBackendValue,
        notes: null,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Starting work on ${ticket.ticketNumber}...'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNotes(BuildContext context) {
    final bloc = context.read<MaintenanceTicketBloc>();
    final notesController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => isMobile
          ? Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 32,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Work Notes',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your work notes...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 6,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (notesController.text.trim().isNotEmpty) {
                            bloc.add(
                              AddTechnicianNotes(
                                id: ticket.id,
                                notes: notesController.text.trim(),
                              ),
                            );
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please enter notes before saving'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              title: const Text('Add Work Notes'),
              content: SizedBox(
                width: 400,
                child: TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your work notes...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 5,
                  autofocus: true,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (notesController.text.trim().isNotEmpty) {
                      bloc.add(
                        AddTechnicianNotes(
                          id: ticket.id,
                          notes: notesController.text.trim(),
                        ),
                      );
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter notes before saving'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }

  void _completeTicket(BuildContext context) {
    final bloc = context.read<MaintenanceTicketBloc>();
    final notesController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => isMobile
          ? Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 32,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Ticket',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    const Text('Add resolution notes (optional):'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Describe what was done...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 5,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          bloc.add(
                            ChangeMaintenanceTicketStatus(
                              id: ticket.id,
                              status: TicketStatus.completed.toBackendValue,
                              notes: notesController.text.trim().isEmpty
                                  ? null
                                  : notesController.text.trim(),
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Complete'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              title: const Text('Complete Ticket'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add resolution notes (optional):'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        hintText: 'Describe what was done...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 4,
                      autofocus: true,
                      textInputAction: TextInputAction.newline,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(
                      ChangeMaintenanceTicketStatus(
                        id: ticket.id,
                        status: TicketStatus.completed.toBackendValue,
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      ),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Complete'),
                ),
              ],
            ),
    );
  }
}
