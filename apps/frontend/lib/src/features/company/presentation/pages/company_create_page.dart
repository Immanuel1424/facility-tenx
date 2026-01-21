import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/utils/timezone_currency_data.dart';
import '../../data/repositories/company_repository.dart';
import '../bloc/company_bloc.dart';
import '../bloc/company_event.dart';
import '../bloc/company_state.dart';

class CompanyCreatePage extends StatelessWidget {
  const CompanyCreatePage({super.key, this.companyId});

  final String? companyId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = CompanyBloc(
          repository: CompanyRepository(
            apiClient: getIt<ApiClient>(),
          ),
        );

        if (companyId != null) {
          bloc.add(LoadCompanyDetail(companyId!));
        }

        return bloc;
      },
      child: CompanyCreateFormContent(
        useScaffold: true,
        companyId: companyId,
      ),
    );
  }
}

/// Dialog version for web - shows as modal dialog
class CompanyCreateDialog extends StatelessWidget {
  const CompanyCreateDialog({
    super.key,
    this.companyId,
  });

  final String? companyId;

  /// Create mode
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => CompanyBloc(
          repository: CompanyRepository(
            apiClient: getIt<ApiClient>(),
          ),
        ),
        child: const CompanyCreateDialog(),
      ),
    );
  }

  /// Edit mode
  static Future<bool?> showForEdit(
    BuildContext context,
    String companyId,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) {
          final bloc = CompanyBloc(
            repository: CompanyRepository(
              apiClient: getIt<ApiClient>(),
            ),
          );
          bloc.add(LoadCompanyDetail(companyId));
          return bloc;
        },
        child: CompanyCreateDialog(companyId: companyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 768;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40 : 16,
        vertical: isWeb ? 40 : 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 800 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.business,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      companyId == null ? 'Create Company' : 'Edit Company',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Dialog Body with form
            Expanded(
              child: BlocListener<CompanyBloc, CompanyState>(
                listener: (context, state) {
                  state.maybeWhen(
                    created: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Company created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    },
                    updated: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Company updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    },
                    error: (message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $message'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    orElse: () {},
                  );
                },
                child: CompanyCreateFormContent(
                  useScaffold: false,
                  companyId: companyId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable form content widget that can be used in both page and dialog
class CompanyCreateFormContent extends StatefulWidget {
  const CompanyCreateFormContent({
    super.key,
    this.useScaffold = true,
    this.companyId,
  });

  /// When true, wraps the form in a Scaffold with an AppBar.
  /// When false (dialog usage), returns only the form content (Dialog provides Material).
  final bool useScaffold;

   /// If provided, the form works in edit mode and will load existing company data.
   final String? companyId;

  @override
  State<CompanyCreateFormContent> createState() =>
      _CompanyCreateFormContentState();
}

class _CompanyCreateFormContentState extends State<CompanyCreateFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _currencyController = TextEditingController();
  bool _isDirty = false;
  bool _existingIsActive = true; // Store existing isActive for edit mode

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    _timezoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final bloc = context.read<CompanyBloc>();
      final code = _codeController.text.trim();
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final logoUrl = _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim();
      final timezone = _timezoneController.text.trim().isEmpty
          ? null
          : _timezoneController.text.trim();
      final currency = _currencyController.text.trim().isEmpty
          ? null
          : _currencyController.text.trim();

      if (widget.companyId != null) {
        // Edit mode - preserve existing isActive value
        bloc.add(
          UpdateCompany(
            id: widget.companyId!,
            code: code,
            name: name,
            description: description,
            logoUrl: logoUrl,
            timezone: timezone,
            currency: currency,
            isActive: _existingIsActive,
          ),
        );
      } else {
        // Create mode - always set to active
        bloc.add(
          CreateCompany(
            code: code,
            name: name,
            description: description,
            logoUrl: logoUrl,
            timezone: timezone,
            currency: currency,
            isActive: true,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final useScaffold = widget.useScaffold;

    // For full page (mobile), wrap in Scaffold with AppBar
    // For dialog (web), just show the form content
    final formContent = PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final isDirty = _isDirty;

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
            context.pop(true);
          }
        } else {
          if (context.mounted) {
            context.pop(true);
          }
        }
      },
      child: BlocListener<CompanyBloc, CompanyState>(
        listener: (context, state) {
          state.maybeWhen(
            created: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Company created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              if (useScaffold && context.mounted) {
                context.pop(true);
              }
            },
            updated: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Company updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              if (useScaffold && context.mounted) {
                context.pop(true);
              }
            },
            detailLoaded: (company) {
              // Populate form fields when editing
              _codeController.text = company.code;
              _nameController.text = company.name;
              _descriptionController.text = company.description ?? '';
              _logoUrlController.text = company.logoUrl ?? '';
              _timezoneController.text = company.timezone ?? '';
              _currencyController.text = company.currency ?? '';
              _existingIsActive = company.isActive;
              _isDirty = false;
              // Trigger rebuild to update dropdowns with selected values
              if (mounted) {
                setState(() {});
              }
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            orElse: () {},
          );
        },
        child: ResponsiveLayout(
          mobileBreakpoint: 768.0,
          mobileBuilder: (context) => _buildForm(context, isMobile: true),
          desktopBuilder: (context) => _buildForm(context, isMobile: false),
        ),
      ),
    );

    // When used inside a dialog, the Dialog already provides a Material ancestor.
    if (!useScaffold) {
      return formContent;
    }

    // Full-page usage (mobile or desktop route): wrap in Scaffold with AppBar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Company'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final isDirty = _isDirty;

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
                context.pop(true);
              }
            } else {
              if (context.mounted) {
                context.pop(true);
              }
            }
          },
        ),
      ),
      body: formContent,
    );
  }

  Widget _buildForm(BuildContext context, {required bool isMobile}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: isMobile
            ? _buildMobileForm(context)
            : _buildDesktopForm(context),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFieldLabel('Company Code', isRequired: true),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            hintText: 'e.g., TENX, ALOS',
            helperText: 'Unique code for the company (max 100 characters)',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => _isDirty = true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Company code is required';
            }
            if (value.trim().length > 100) {
              return 'Company code must be 100 characters or less';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Company Name', isRequired: true),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g., TenX Facilities',
            helperText: 'Full name of the company (max 255 characters)',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _isDirty = true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Company name is required';
            }
            if (value.trim().length > 255) {
              return 'Company name must be 255 characters or less';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Description'),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Optional description of the company',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Logo URL'),
        TextFormField(
          controller: _logoUrlController,
          decoration: const InputDecoration(
            hintText: 'https://example.com/logo.png',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => _isDirty = true,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Timezone'),
        DropdownButtonFormField<String>(
          value: _timezoneController.text.isEmpty ? null : _timezoneController.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: 'Select timezone',
            border: const OutlineInputBorder(),
            isDense: true,
            filled: false,
          ),
          isExpanded: true,
          selectedItemBuilder: (context) {
            return [
              const Text('None'),
              ...TimezoneData.timezones.map((tz) {
                return Text(
                  tz['value']!,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ];
          },
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('None'),
            ),
            ...TimezoneData.timezones.map((tz) {
              return DropdownMenuItem<String>(
                value: tz['value'],
                child: Text(
                  tz['label']!,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (value) {
            _timezoneController.text = value ?? '';
            _isDirty = true;
            // TextEditingController automatically triggers rebuild
          },
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Currency'),
        DropdownButtonFormField<String>(
          value: _currencyController.text.isEmpty ? null : _currencyController.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: 'Select currency',
            border: const OutlineInputBorder(),
            isDense: true,
            filled: false,
          ),
          isExpanded: true,
          selectedItemBuilder: (context) {
            return [
              const Text('None'),
              ...CurrencyData.currencies.map((curr) {
                return Text(
                  curr['value']!,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ];
          },
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('None'),
            ),
            ...CurrencyData.currencies.map((curr) {
              return DropdownMenuItem<String>(
                value: curr['value'],
                child: Text(
                  curr['label']!,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (value) {
            _currencyController.text = value ?? '';
            _isDirty = true;
            // TextEditingController automatically triggers rebuild
          },
        ),
        const SizedBox(height: 24),
        BlocBuilder<CompanyBloc, CompanyState>(
          builder: (context, state) {
            final isLoading = state is CompanyLoading;
            return ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.companyId == null
                          ? 'Create Company'
                          : 'Update Company',
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Code and Name
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Company Code', isRequired: true),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., TENX, ALOS',
                      helperText: 'Unique code (max 100 characters)',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => _isDirty = true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Company code is required';
                      }
                      if (value.trim().length > 100) {
                        return 'Company code must be 100 characters or less';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Company Name', isRequired: true),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., TenX Facilities',
                      helperText: 'Full name (max 255 characters)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _isDirty = true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Company name is required';
                      }
                      if (value.trim().length > 255) {
                        return 'Company name must be 255 characters or less';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 2: Description (full width)
        _buildFieldLabel('Description'),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Optional description of the company',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        // Row 3: Logo URL, Timezone, Currency
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Logo URL'),
                  TextFormField(
                    controller: _logoUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/logo.png',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    onChanged: (_) => _isDirty = true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Timezone'),
                  DropdownButtonFormField<String>(
                    value: _timezoneController.text.isEmpty ? null : _timezoneController.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Select timezone',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      filled: false,
                    ),
                    isExpanded: true,
                    selectedItemBuilder: (context) {
                      return [
                        const Text('None'),
                        ...TimezoneData.timezones.map((tz) {
                          return Text(
                            tz['value']!,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ];
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...TimezoneData.timezones.map((tz) {
                        return DropdownMenuItem<String>(
                          value: tz['value'],
                          child: Text(
                            tz['label']!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      // TextEditingController updates automatically trigger rebuild
                      // No setState needed
                      _timezoneController.text = value ?? '';
                      _isDirty = true;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Currency'),
                  DropdownButtonFormField<String>(
                    value: _currencyController.text.isEmpty ? null : _currencyController.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Select currency',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      filled: false,
                    ),
                    isExpanded: true,
                    selectedItemBuilder: (context) {
                      return [
                        const Text('None'),
                        ...CurrencyData.currencies.map((curr) {
                          return Text(
                            curr['value']!,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ];
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...CurrencyData.currencies.map((curr) {
                        return DropdownMenuItem<String>(
                          value: curr['value'],
                          child: Text(
                            curr['label']!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      // TextEditingController updates automatically trigger rebuild
                      // No setState needed
                      _currencyController.text = value ?? '';
                      _isDirty = true;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Submit button
        BlocBuilder<CompanyBloc, CompanyState>(
          builder: (context, state) {
            final isLoading = state is CompanyLoading;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.companyId == null
                            ? 'Create Company'
                            : 'Update Company',
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}

