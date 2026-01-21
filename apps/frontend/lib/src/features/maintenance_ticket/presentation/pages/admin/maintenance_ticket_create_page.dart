import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/utils/role_access_control.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/ticket_type_entity.dart';
import '../../../domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import '../../widgets/site_space_selector_widget.dart';

class MaintenanceTicketCreatePage extends StatelessWidget {
  const MaintenanceTicketCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaintenanceTicketBloc(
        repository: getIt<MaintenanceTicketRepositoryInterface>(),
      ),
      child: const _MaintenanceTicketCreateContent(),
    );
  }
}

class _MaintenanceTicketCreateContent extends StatefulWidget {
  const _MaintenanceTicketCreateContent();

  @override
  State<_MaintenanceTicketCreateContent> createState() =>
      _MaintenanceTicketCreateContentState();
}

class _MaintenanceTicketCreateContentState
    extends State<_MaintenanceTicketCreateContent> {
  final formKey = GlobalKey<FormBuilderState>();
  String? _selectedTicketType;
  String? _selectedSiteId;
  String? _selectedSpaceId;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    final isTenant = RoleAccessControl.isTenant(user);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final formState = formKey.currentState;
        final isDirty = formState?.isDirty ?? false;

        if (isDirty) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard Changes?'),
              content: const Text(
                'You have unsaved changes. Are you sure you want to leave?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );

          if (shouldPop == true && context.mounted) {
            context.pop();
          }
        } else {
          if (context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Ticket'),
          centerTitle: false,
        ),
        body: BlocConsumer<MaintenanceTicketBloc, MaintenanceTicketState>(
          listener: (context, state) {
            state.maybeWhen(
              created: (ticket) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pop();
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            final isLoading = state is MaintenanceTicketLoading;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FormBuilder(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Describe the Issue',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We will assign this to the maintenance team based on the selected location.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 32),

                          // Ticket Type (not for TENANT)
                          if (!isTenant) ...[
                            Text(
                              'Ticket Type',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            FormBuilderDropdown<String>(
                              name: 'ticket_type',
                              decoration: const InputDecoration(
                                labelText: 'Select Ticket Type',
                                border: OutlineInputBorder(),
                              ),
                              items: TicketType.values.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type.backendValue,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Color(type.colorValue),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(type.displayName),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTicketType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                          ],

                          FormBuilderTextField(
                            name: 'title',
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'e.g., Leaking Tap',
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              prefixIcon: const Icon(Icons.edit_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'description',
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText:
                                  'Please provide more details about the issue...',
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              prefixIcon: const Icon(Icons.notes),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 5,
                          ),
                          const SizedBox(height: 24),

                          // Location Selection
                          Text(
                            'Location',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SiteSpaceSelectorWidget(
                            selectedSiteId: _selectedSiteId,
                            selectedSpaceId: _selectedSpaceId,
                            onSiteChanged: (value) {
                              setState(() {
                                _selectedSiteId = value;
                              });
                            },
                            onSpaceChanged: (value) {
                              setState(() {
                                _selectedSpaceId = value;
                              });
                            },
                          ),
                          Text(
                            'Priority Level',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          FormBuilderChoiceChips<String>(
                            name: 'priority',
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            initialValue: 'MEDIUM',
                            alignment: WrapAlignment.start,
                            spacing: 12,
                            runSpacing: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            options: const [
                              FormBuilderChipOption(
                                value: 'LOW',
                                child: Text('Low'),
                              ),
                              FormBuilderChipOption(
                                value: 'MEDIUM',
                                child: Text('Medium'),
                              ),
                              FormBuilderChipOption(
                                value: 'HIGH',
                                child: Text('High'),
                              ),
                              FormBuilderChipOption(
                                value: 'URGENT',
                                child: Text('Urgent'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final formState = formKey.currentState;
                              if (formState != null) {
                                if (formState.saveAndValidate()) {
                                  final formData = formState.value;

                                  context.read<MaintenanceTicketBloc>().add(
                                        CreateMaintenanceTicket(
                                          title: formData['title'] as String,
                                          description: formData['description']
                                              as String?,
                                          ticketType: _selectedTicketType,
                                          siteId: _selectedSiteId,
                                          spaceId: _selectedSpaceId,
                                          priority: (formData['priority']
                                                  as String?) ??
                                              'MEDIUM',
                                        ),
                                      );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Request',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
