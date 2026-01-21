import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_formatter.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/maintenance_ticket_entity.dart';
import '../../domain/entities/comment_entity.dart' as domain;
import '../bloc/comment/comment_bloc.dart';
import '../bloc/comment/comment_event.dart';
import '../bloc/comment/comment_state.dart';
import 'comment_input_widget.dart';

class CommentListWidget extends StatelessWidget {
  const CommentListWidget({
    super.key,
    required this.ticketId,
    required this.ticketStatus,
    this.showInternalNotes = false,
    this.showInput = true,
  });

  final String ticketId;
  final TicketStatus ticketStatus;
  final bool showInternalNotes;
  final bool showInput;

  @override
  Widget build(BuildContext context) {
    // Check if CommentBloc already exists in the widget tree
    final existingBloc = _findCommentBloc(context);
    if (existingBloc != null) {
      // If it exists, use it without creating a new provider
      return BlocProvider.value(
        value: existingBloc,
        child: _CommentListContent(
          ticketId: ticketId,
          ticketStatus: ticketStatus,
          showInternalNotes: showInternalNotes,
          showInput: showInput,
        ),
      );
    }
    // If it doesn't exist, create a new one
    return BlocProvider(
      create: (context) => CommentBloc(
        repository: getIt(),
      )..add(LoadComments(ticketId)),
      child: _CommentListContent(
        ticketId: ticketId,
        ticketStatus: ticketStatus,
        showInternalNotes: showInternalNotes,
        showInput: showInput,
      ),
    );
  }

  CommentBloc? _findCommentBloc(BuildContext context) {
    try {
      return context.read<CommentBloc>();
    } catch (_) {
      return null;
    }
  }
}

class _CommentListContent extends StatelessWidget {
  const _CommentListContent({
    required this.ticketId,
    required this.ticketStatus,
    required this.showInternalNotes,
    required this.showInput,
  });

  final String ticketId;
  final TicketStatus ticketStatus;
  final bool showInternalNotes;
  final bool showInput;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.maybeWhen(
      authenticated: (user) => user,
      orElse: () => null,
    );
    final isTenant = user?.roles.contains('TENANT') ?? false;

    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is CommentError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.read<CommentBloc>().add(LoadComments(ticketId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CommentsLoaded) {
          final comments = <domain.CommentEntity>[
            for (final comment in state.comments)
              if (!comment.isDeleted &&
                  !(isTenant &&
                      (comment.commentType == domain.CommentType.internal ||
                          comment.commentType ==
                              domain.CommentType.workNote)) &&
                  (showInternalNotes ||
                      (comment.commentType != domain.CommentType.internal &&
                          comment.commentType != domain.CommentType.workNote)))
                comment,
          ];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (comments.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No comments yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _CommentItem(comment: comments[index]);
                  },
                ),
              if (showInput)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CommentInputWidget(
                    ticketId: ticketId,
                    ticketStatus: ticketStatus,
                    onCommentCreated: () {
                      // Reload comments after creation
                      context.read<CommentBloc>().add(LoadComments(ticketId));
                    },
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({required this.comment});

  final domain.CommentEntity comment;

  @override
  Widget build(BuildContext context) {
    final isInternal = comment.commentType == domain.CommentType.internal;
    final isWorkNote = comment.commentType == domain.CommentType.workNote;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isInternal
          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
          : isWorkNote
              ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    comment.createdBy ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isInternal || isWorkNote)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      comment.commentType.displayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(comment.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              comment.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (comment.isEdited) ...[
              const SizedBox(height: 4),
              Text(
                'Edited',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
