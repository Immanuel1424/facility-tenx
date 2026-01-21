import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/maintenance_ticket_entity.dart';
import '../bloc/comment/comment_bloc.dart';
import '../bloc/comment/comment_event.dart';
import '../bloc/comment/comment_state.dart';

class CommentInputWidget extends StatefulWidget {
  const CommentInputWidget({
    super.key,
    required this.ticketId,
    required this.ticketStatus,
    this.commentType,
    this.onCommentCreated,
  });

  final String ticketId;
  final TicketStatus ticketStatus;
  final String? commentType; // Optional override (for admin INTERNAL notes)
  final VoidCallback? onCommentCreated;

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  bool get _canComment =>
      widget.ticketStatus != TicketStatus.completed &&
      widget.ticketStatus != TicketStatus.cancelled;

  bool get _isValid => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (!_isValid || !_canComment || _isSubmitting) return;

    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    context.read<CommentBloc>().add(
          CreateComment(
            ticketId: widget.ticketId,
            content: content,
            commentType: widget.commentType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentCreated) {
          setState(() {
            _isSubmitting = false;
          });
          _controller.clear();
          _focusNode.unfocus();
          widget.onCommentCreated?.call();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Comment added successfully'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CommentError) {
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_canComment) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Comments are disabled for closed tickets',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface, // Use theme color for dark mode support
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2), // Use theme color for dark mode
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: _canComment && !_isSubmitting,
                      maxLines: 5,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: _canComment
                            ? 'Add a comment...'
                            : 'Comments disabled',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: false,
                      ),
                      // Trigger rebuild when text changes to update button state
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ),
                  if (_isSubmitting)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _isValid && _canComment && !_isSubmitting
                          ? _submitComment
                          : null,
                      icon: Icon(
                        Icons.send_rounded,
                        color: _isValid && _canComment && !_isSubmitting
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.38),
                      ),
                      tooltip: 'Send comment',
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
