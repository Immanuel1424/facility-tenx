import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/theme_helpers.dart';
import '../../data/repositories/notification_repository.dart';
import '../bloc/template/template_bloc.dart';
import '../bloc/template/template_event.dart';
import '../bloc/template/template_state.dart';

class EmailTemplatesListPage extends StatelessWidget {
  const EmailTemplatesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) => TemplateBloc(
        repository: NotificationRepository(
          apiClient: getIt(),
        ),
      )..add(const LoadEmailTemplates()),
      child: Builder(
        builder: (blocContext) => Scaffold(
          appBar: AppBar(
            title: const Text('Email Templates'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/settings'),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  blocContext.read<TemplateBloc>().add(const SeedEmailTemplates());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Seed Templates'),
              ),
            ],
          ),
          body: BlocConsumer<TemplateBloc, TemplateState>(
            listener: (blocContext, state) {
            state.maybeWhen(
              orElse: () {},
              error: (message) {
                ScaffoldMessenger.of(blocContext).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: colorScheme.error,
                  ),
                );
              },
              updated: (template) {
                ScaffoldMessenger.of(blocContext).showSnackBar(
                  SnackBar(
                    content: Text('Template "${template.code}" updated successfully'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
              listLoaded: (templates) {
                // Show success message after seeding if templates were just created
                if (templates.isNotEmpty) {
                  ScaffoldMessenger.of(blocContext).showSnackBar(
                    SnackBar(
                      content: Text('${templates.length} email template(s) loaded'),
                      backgroundColor: colorScheme.primary,
                    ),
                  );
                }
              },
            );
          },
            builder: (blocContext, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              listLoaded: (templates) {
                if (templates.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No email templates found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No email templates have been created yet. Email templates are used for sending email notifications to users.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Note: Templates need to be created via the API or database. Contact your system administrator to add email templates.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: context.cardBorderRadius,
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            color: colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          template.code.replaceAll('_', ' ').toUpperCase(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (template.subject != null)
                              Text(
                                'Subject: ${template.subject}',
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Body: ${template.body.substring(0, template.body.length > 50 ? 50 : template.body.length)}...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          blocContext.push(
                            '/settings/email-templates/${template.id}',
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loaded: (template) => const SizedBox.shrink(),
              updated: (template) => const SizedBox.shrink(),
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
                        'Error loading templates',
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
                        onPressed: () {
                          blocContext.read<TemplateBloc>().add(const LoadEmailTemplates());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }
}

