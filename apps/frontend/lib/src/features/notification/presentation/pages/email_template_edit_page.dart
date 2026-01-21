import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../../../core/widgets/common_dialogs.dart';
import '../../data/dto/notification_template_dto.dart';
import '../../data/repositories/notification_repository.dart';
import '../bloc/template/template_bloc.dart';
import '../bloc/template/template_event.dart';
import '../bloc/template/template_state.dart';

class EmailTemplateEditPage extends StatefulWidget {
  const EmailTemplateEditPage({
    super.key,
    required this.templateId,
  });

  final String templateId;

  @override
  State<EmailTemplateEditPage> createState() => _EmailTemplateEditPageState();
}

class _EmailTemplateEditPageState extends State<EmailTemplateEditPage> {
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  NotificationTemplateDto? _template;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _bodyController = TextEditingController();
    _subjectController.addListener(() => setState(() => _isDirty = true));
    _bodyController.addListener(() => setState(() => _isDirty = true));
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _loadTemplate() {
    context.read<TemplateBloc>().add(LoadTemplate(widget.templateId));
  }

  void _updateTemplate() {
    if (_template == null) return;

    final updatedTemplate = NotificationTemplateDto(
      id: _template!.id,
      code: _template!.code,
      channel: _template!.channel,
      subject: _subjectController.text.isEmpty ? null : _subjectController.text,
      body: _bodyController.text,
      defaultVariables: _template!.defaultVariables,
      createdAt: _template!.createdAt,
      updatedAt: _template!.updatedAt,
    );

    context.read<TemplateBloc>().add(UpdateTemplate(
          id: widget.templateId,
          template: updatedTemplate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) => TemplateBloc(
        repository: NotificationRepository(
          apiClient: getIt(),
        ),
      )..add(LoadTemplate(widget.templateId)),
      child: BlocListener<TemplateBloc, TemplateState>(
        listener: (context, state) {
          state.maybeWhen(
            orElse: () {},
            loaded: (template) {
              if (_template == null) {
                setState(() {
                  _template = template;
                  _subjectController.text = template.subject ?? '';
                  _bodyController.text = template.body;
                  _isDirty = false;
                });
              }
            },
            updated: (template) {
              setState(() {
                _template = template;
                _isDirty = false;
              });
              context.pop(true);
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: colorScheme.error,
                ),
              );
            },
          );
        },
        child: BlocBuilder<TemplateBloc, TemplateState>(
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return PopScope(
              canPop: !_isDirty,
              onPopInvoked: (didPop) {
                if (!didPop && _isDirty) {
                  _showUnsavedChangesDialog(context);
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    _template?.code.replaceAll('_', ' ').toUpperCase() ?? 'Edit Template',
                  ),
                  actions: [
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _isDirty ? _updateTemplate : null,
                        child: const Text('Save'),
                      ),
                  ],
                ),
                body: state.when(
                  initial: () => const Center(child: CircularProgressIndicator()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (template) => _buildEditForm(context, template),
                  listLoaded: (_) => const SizedBox.shrink(),
                  updated: (_) => const SizedBox.shrink(),
                  error: (message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading template',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTemplate,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, NotificationTemplateDto template) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Extract available variables from defaultVariables or body
    final variables = <String>{};
    if (template.defaultVariables != null) {
      variables.addAll(template.defaultVariables!.keys);
    }
    // Also extract from body using regex
    final regex = RegExp(r'\{\{\s*([\w.]+)\s*\}\}');
    final matches = regex.allMatches(template.body);
    for (final match in matches) {
      variables.add(match.group(1) ?? '');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Template Information',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Code',
                    value: template.code,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Channel',
                    value: template.channel.toUpperCase(),
                  ),
                  if (variables.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Available Variables:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: variables.map((variable) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: context.cardBorderRadius,
                          ),
                          child: Text(
                            '{{$variable}}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use these variables in your template. They will be replaced with actual values when the email is sent.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subject Field
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'Email Subject',
              hintText: 'Enter email subject (optional)',
              helperText: 'Leave empty if not applicable',
              border: OutlineInputBorder(
                borderRadius: context.cardBorderRadius,
              ),
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 24),

          // Body Field
          TextField(
            controller: _bodyController,
            decoration: InputDecoration(
              labelText: 'Email Body',
              hintText: 'Enter email body template',
              helperText: 'Use {{variableName}} for dynamic content',
              border: OutlineInputBorder(
                borderRadius: context.cardBorderRadius,
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 15,
            minLines: 10,
          ),

          const SizedBox(height: 24),

          // Preview Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.preview_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Preview',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: context.cardBorderRadius,
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_subjectController.text.isNotEmpty) ...[
                          Text(
                            'Subject: ${_subjectController.text}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          _bodyController.text.isEmpty
                              ? 'Enter template body to see preview...'
                              : _bodyController.text,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    CommonDialogs.showConfirmationDialog(
      context: context,
      title: 'Unsaved Changes',
      content: const Text(
        'You have unsaved changes. Are you sure you want to leave?',
      ),
      confirmText: 'Leave',
      cancelText: 'Cancel',
      onConfirm: () => context.pop(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

