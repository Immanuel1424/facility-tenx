import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../announcement/presentation/bloc/announcement_bloc.dart';
import '../../../announcement/presentation/bloc/announcement_event.dart';
import '../../../announcement/presentation/bloc/announcement_state.dart';
import '../../../announcement/domain/entities/announcement_entity.dart';

class TenantAnnouncementsSection extends StatefulWidget {
  const TenantAnnouncementsSection({super.key});

  @override
  State<TenantAnnouncementsSection> createState() =>
      _TenantAnnouncementsSectionState();
}

class _TenantAnnouncementsSectionState
    extends State<TenantAnnouncementsSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        if (state is AnnouncementLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AnnouncementError) {
          return const SizedBox.shrink(); // Hide on error
        }

        if (state is AnnouncementListLoaded) {
          final announcements = state.announcements;

          if (announcements.isEmpty) {
            return const SizedBox.shrink();
          }

          final displayAnnouncements = announcements.length > 3
              ? announcements.take(3).toList()
              : announcements;

          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Announcements',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Important updates and announcements',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (announcements.length > 3)
                      TextButton(
                        onPressed: () {
                          context.push('/announcements');
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Horizontal Scrollable Announcements
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: displayAnnouncements.length,
                    itemBuilder: (context, index) {
                      final announcement = displayAnnouncements[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _AnnouncementCard(
                          announcement: announcement,
                          onTap: () {
                            // Mark as read and navigate to detail
                            context.read<AnnouncementBloc>().add(
                                  MarkAnnouncementAsRead(announcement.id),
                                );
                            // Navigate to detail page if available
                            // For now, show a dialog
                            _showAnnouncementDetail(context, announcement);
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Page Indicators
                if (displayAnnouncements.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        displayAnnouncements.length,
                        (index) => _PageIndicator(
                          isActive: index == _currentPage,
                          colorScheme: colorScheme,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showAnnouncementDetail(
    BuildContext context,
    AnnouncementEntity announcement,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: colorScheme.onSurface, // Use theme color for dark mode visibility
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category and Priority badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Emergency category badge - styled like urgent status
                        if (announcement.category ==
                            AnnouncementCategory.emergency) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(announcement.category)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              announcement.category.displayName,
                              style: TextStyle(
                                color: _getCategoryColor(announcement.category),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Regular category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(announcement.category)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getCategoryColor(announcement.category)
                                    .withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              announcement.category.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getCategoryColor(announcement.category),
                              ),
                            ),
                          ),
                        ],
                        // Priority badge - styled to match ticket list
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getPriorityColorForDetail(
                                  announcement.priority,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              announcement.priority.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant, // Use theme color for dark mode visibility
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      height: 1.6,
                      color: colorScheme.onSurface, // Use theme color for dark mode visibility
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Footer
                Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Published: ${DateFormat('MMM dd, yyyy HH:mm').format(announcement.publishedAt ?? announcement.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (announcement.expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expires: ${DateFormat('MMM dd, yyyy HH:mm').format(announcement.expiresAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(AnnouncementCategory category) {
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

  Color _getCategoryColor(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.maintenance:
        return Colors.blue;
      case AnnouncementCategory.emergency:
        return Colors.red;
      case AnnouncementCategory.general:
        return Colors.grey;
      case AnnouncementCategory.info:
        return Colors.blue;
    }
  }

  Color _getPriorityColorForDetail(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return const Color(0xFF10B981); // Green
      case AnnouncementPriority.medium:
        return const Color(0xFF3B82F6); // Blue
      case AnnouncementPriority.high:
        return const Color(0xFFF59E0B); // Orange
      case AnnouncementPriority.urgent:
        return const Color(0xFFEF4444); // Red
    }
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.onTap,
  });

  final AnnouncementEntity announcement;
  final VoidCallback onTap;

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return const Color(0xFF10B981); // Green
      case AnnouncementPriority.medium:
        return const Color(0xFF3B82F6); // Blue
      case AnnouncementPriority.high:
        return const Color(0xFFF59E0B); // Orange
      case AnnouncementPriority.urgent:
        return const Color(0xFFEF4444); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = _getCategoryColor(announcement.category);
    final priorityColor = _getPriorityColor(announcement.priority);
    final publishedDate = announcement.publishedAt ?? announcement.createdAt;
    final timeAgo = _getTimeAgo(publishedDate);
    final isUrgent = announcement.priority == AnnouncementPriority.urgent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface, // Use theme color for dark mode support
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUrgent
                  ? priorityColor.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.1),
              width: isUrgent ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isUrgent
                    ? priorityColor.withValues(alpha: 0.1)
                    : colorScheme.shadow.withValues(alpha: 0.03), // Use theme color for dark mode
                blurRadius: isUrgent ? 8 : 2,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Category Icon, Title, Priority Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getCategoryIcon(announcement.category),
                      color: categoryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title and Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with urgent badge inline
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                announcement.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface, // Use theme color for dark mode visibility
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isUrgent) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Category and Priority Chips
                        Row(
                          children: [
                            // Emergency category badge - styled like urgent priority
                            if (announcement.category ==
                                AnnouncementCategory.emergency) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  announcement.category.displayName,
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Regular category badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: categoryColor.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(announcement.category),
                                      size: 9,
                                      color: categoryColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      announcement.category.displayName,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (!isUrgent) ...[
                              const SizedBox(width: 8),
                              // Priority badge - styled to match ticket list
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: priorityColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    announcement.priority.displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Message Content
              Text(
                announcement.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Footer: Time and Read More Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Read more',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: colorScheme.primary,
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

  IconData _getCategoryIcon(AnnouncementCategory category) {
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

  Color _getCategoryColor(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.maintenance:
        return Colors.blue;
      case AnnouncementCategory.emergency:
        return Colors.red;
      case AnnouncementCategory.general:
        return Colors.grey;
      case AnnouncementCategory.info:
        return Colors.blue;
    }
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.isActive,
    required this.colorScheme,
  });

  final bool isActive;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
