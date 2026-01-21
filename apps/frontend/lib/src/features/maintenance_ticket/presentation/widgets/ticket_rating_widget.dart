import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/maintenance_ticket_bloc.dart';
import '../bloc/maintenance_ticket_event.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../../../core/theme/app_typography.dart';

class TicketRatingWidget extends StatefulWidget {
  const TicketRatingWidget({
    super.key,
    required this.ticket,
  });

  final MaintenanceTicketEntity ticket;

  @override
  State<TicketRatingWidget> createState() => _TicketRatingWidgetState();
}

class _TicketRatingWidgetState extends State<TicketRatingWidget> {
  int? _selectedRating;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TicketRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset form state when ticket is updated with rating
    if (oldWidget.ticket.rating == null && widget.ticket.rating != null) {
      _isSubmitting = false;
      _selectedRating = null;
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Only show if ticket is closed
    if (!widget.ticket.tenantConfirmed) {
      return const SizedBox.shrink();
    }

    // If already rated, show read-only display
    if (widget.ticket.rating != null) {
      return _buildReadOnlyRating(context, theme, colorScheme);
    }

    // Show rating form
    return _buildRatingForm(context, theme, colorScheme);
  }

  Widget _buildReadOnlyRating(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
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
            Row(
              children: [
                Icon(
                  Icons.star_rate_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Rating',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSizes.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStarDisplay(widget.ticket.rating!),
                const SizedBox(width: 12),
                if (widget.ticket.ratedAt != null)
                  Text(
                    'Rated on ${_formatDate(widget.ticket.ratedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
            if (widget.ticket.ratingComment != null &&
                widget.ticket.ratingComment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.ticket.ratingComment!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: AppFontSizes.bodyMedium,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingForm(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
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
            Row(
              children: [
                Icon(
                  Icons.star_rate_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rate This Ticket',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSizes.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'How would you rate the service provided?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            _buildStarSelector(colorScheme),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: 'Additional Comments (Optional)',
                hintText: 'Share your feedback about the service...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting || _selectedRating == null
                    ? null
                    : () => _submitRating(context),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarSelector(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final rating = index + 1;
        final isSelected = _selectedRating != null && rating <= _selectedRating!;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRating = rating;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: 40,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStarDisplay(int rating) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < rating;
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          size: 24,
          color: isFilled
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.3),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void _submitRating(BuildContext context) {
    if (_selectedRating == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    context.read<MaintenanceTicketBloc>().add(
          SubmitTicketRating(
            ticketId: widget.ticket.id,
            rating: _selectedRating!,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          ),
        );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Rating submitted successfully')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // Note: State will be updated when BLoC emits MaintenanceTicketDetailLoaded
    // with the updated ticket (now containing rating). The widget will rebuild
    // and show the read-only rating display.
  }
}

