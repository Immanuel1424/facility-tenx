import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/permission_checker.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../company/data/repositories/company_repository.dart';
import '../../../company/domain/entities/company_entity.dart';
import '../../data/repositories/site_repository.dart';
import '../bloc/site_bloc.dart';
import '../bloc/site_event.dart';
import '../bloc/site_state.dart';

class SiteCreatePage extends StatelessWidget {
  const SiteCreatePage({
    super.key,
    required this.companyId,
    this.siteId,
  });

  final String companyId;
  final String? siteId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = SiteBloc(
          repository: SiteRepository(
            apiClient: getIt<ApiClient>(),
          ),
        );
        if (siteId != null) {
          bloc.add(LoadSiteDetail(siteId!));
        }
        return bloc;
      },
      child: SiteCreateFormContent(
        companyId: companyId,
        siteId: siteId,
        useScaffold: true,
      ),
    );
  }
}

class SiteCreateDialog extends StatelessWidget {
  const SiteCreateDialog({
    super.key,
    required this.companyId,
    this.siteId,
  });

  final String companyId;
  final String? siteId;

  static Future<bool?> show(
    BuildContext context, {
    required String companyId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => SiteBloc(
          repository: SiteRepository(
            apiClient: getIt<ApiClient>(),
          ),
        ),
        child: SiteCreateDialog(companyId: companyId),
      ),
    );
  }

  static Future<bool?> showForEdit(
    BuildContext context,
    String siteId,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) {
          final bloc = SiteBloc(
            repository: SiteRepository(
              apiClient: getIt<ApiClient>(),
            ),
          );
          bloc.add(LoadSiteDetail(siteId));
          return bloc;
        },
        child: SiteCreateDialog(
          companyId: '',
          siteId: siteId,
        ),
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
          maxWidth: isWeb ? 900 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    Icons.domain,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      siteId == null ? 'Create Site' : 'Edit Site',
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
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocListener<SiteBloc, SiteState>(
                listener: (context, state) {
                  state.maybeWhen(
                    created: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(true);
                    },
                    updated: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Site updated successfully'),
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
                child: SiteCreateFormContent(
                  companyId: companyId,
                  siteId: siteId,
                  useScaffold: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SiteCreateFormContent extends StatefulWidget {
  const SiteCreateFormContent({
    super.key,
    required this.companyId,
    this.siteId,
    required this.useScaffold,
  });

  final String companyId;
  final String? siteId;
  final bool useScaffold;

  @override
  State<SiteCreateFormContent> createState() =>
      _SiteCreateFormContentState();
}

class _SiteCreateFormContentState extends State<SiteCreateFormContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  bool _isParent = true;
  String? _parentSiteId;

  bool _createAdmin = false;
  final TextEditingController _adminEmailController =
      TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();
  final TextEditingController _adminFirstNameController =
      TextEditingController();
  final TextEditingController _adminLastNameController =
      TextEditingController();

  // Company context
  final List<CompanyEntity> _companies = <CompanyEntity>[];
  bool _isLoadingCompanies = false;
  String? _selectedCompanyId;

  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _initCompanyContext();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    super.dispose();
  }

  Future<void> _initCompanyContext() async {
    final authState = context.read<AuthBloc>().state;

    await authState.maybeWhen(
      authenticated: (user) async {
        final bool isSuperAdmin = PermissionChecker.isSuperAdmin(user);

        // Non-super-admin: force company from user context
        if (!isSuperAdmin) {
          setState(() {
            _selectedCompanyId = user.companyId;
          });
          return;
        }

        // Super admin with explicit company in route/dialog
        if (widget.companyId.isNotEmpty) {
          setState(() {
            _selectedCompanyId = widget.companyId;
          });
          return;
        }

        // Super admin without explicit company: load all companies for dropdown
        setState(() {
          _isLoadingCompanies = true;
        });

        final repository = CompanyRepository(
          apiClient: getIt<ApiClient>(),
        );
        final result = await repository.getCompanies();

        if (!mounted) return;

        result.fold(
          (error) {
            setState(() {
              _isLoadingCompanies = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load companies: $error',
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          (companies) {
            setState(() {
              _companies
                ..clear()
                ..addAll(companies);
              _isLoadingCompanies = false;
            });
          },
        );
      },
      orElse: () async {},
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

     // Ensure a company is selected when creating a new site
    if (widget.siteId == null &&
        (_selectedCompanyId == null || _selectedCompanyId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a company for this site.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final code = _codeController.text.trim().isEmpty
        ? null
        : _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    final createAdmin = _createAdmin;
    final adminEmail = _adminEmailController.text.trim().isEmpty
        ? null
        : _adminEmailController.text.trim();
    final adminPassword = _adminPasswordController.text.trim().isEmpty
        ? null
        : _adminPasswordController.text.trim();
    final adminFirstName =
        _adminFirstNameController.text.trim().isEmpty
            ? null
            : _adminFirstNameController.text.trim();
    final adminLastName = _adminLastNameController.text.trim().isEmpty
        ? null
        : _adminLastNameController.text.trim();

    final bloc = context.read<SiteBloc>();

    if (widget.siteId != null) {
      bloc.add(
        UpdateSite(
          id: widget.siteId!,
          code: code,
          name: name,
          description: description,
          isParent: _isParent,
          parentSiteId: _isParent ? null : _parentSiteId,
        ),
      );
    } else {
      bloc.add(
        CreateSite(
          code: code,
          name: name,
          isParent: _isParent,
          parentSiteId: _isParent ? null : _parentSiteId,
          createAdmin: createAdmin,
          adminEmail: adminEmail,
          adminPassword: adminPassword,
          adminFirstName: adminFirstName,
          adminLastName: adminLastName,
          companyId: _selectedCompanyId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formContent = PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic _) async {
        if (didPop) return;
        if (!_isDirty) {
          if (context.mounted) {
            context.pop(false);
          }
          return;
        }

        final shouldDiscard = await showDialog<bool>(
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

        if (shouldDiscard == true && context.mounted) {
          context.pop(false);
        }
      },
      child: BlocListener<SiteBloc, SiteState>(
        listener: (context, state) {
          state.maybeWhen(
            detailLoaded: (site) {
              _codeController.text = site.code;
              _nameController.text = site.name;
              _descriptionController.text = site.description ?? '';
              _isParent = site.isParent;
              _parentSiteId = site.parentSiteId;
              _isDirty = false;
              // No setState needed - controller updates trigger rebuilds automatically
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
          mobileBreakpoint: 768,
          mobileBuilder: (context) => _buildForm(context, isMobile: true),
          desktopBuilder: (context) => _buildForm(context, isMobile: false),
        ),
      ),
    );

    if (!widget.useScaffold) {
      return formContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.siteId == null ? 'Create Site' : 'Edit Site'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (!_isDirty) {
              if (context.mounted) {
                context.pop(false);
              }
              return;
            }

            final shouldDiscard = await showDialog<bool>(
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

            if (shouldDiscard == true && context.mounted) {
              context.pop(false);
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Company selection / context
        _buildFieldLabel('Company', isRequired: true),
        _buildCompanySelector(isMobile: true),
        const SizedBox(height: 16),
        _buildFieldLabel('Site Code'),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            hintText: 'Optional, auto-generated if empty',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => _isDirty = true,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Site Name', isRequired: true),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter site name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _isDirty = true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Site name is required';
            }
            if (value.trim().length > 255) {
              return 'Site name must be 255 characters or less';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Description'),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Optional description of the site',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (_) => _isDirty = true,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Is Parent Site'),
          subtitle: const Text(
            'Parent sites can have child sites. Child sites must specify a parent.',
          ),
          value: _isParent,
          onChanged: (value) {
            setState(() {
              _isParent = value;
              _isDirty = true;
            });
          },
        ),
        if (!_isParent)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildFieldLabel('Parent Site (optional for now)'),
          ),
        if (!_isParent)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Parent site selection can be wired to existing sites later. '
              'For now, backend validation ensures correct hierarchy.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        const Divider(height: 32),
        SwitchListTile(
          title: const Text('Create Admin User for Site'),
          subtitle: const Text(
            'Creates a site admin user with ADMIN role and links them to this site.',
          ),
          value: _createAdmin,
          onChanged: (value) {
            setState(() {
              _createAdmin = value;
              _isDirty = true;
            });
          },
        ),
        if (_createAdmin) ...[
          const SizedBox(height: 12),
          _buildFieldLabel('Admin Email', isRequired: true),
          TextFormField(
            controller: _adminEmailController,
            decoration: const InputDecoration(
              hintText: 'admin@example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _isDirty = true,
            validator: (value) {
              if (!_createAdmin) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Admin email is required';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Admin Password', isRequired: true),
          TextFormField(
            controller: _adminPasswordController,
            decoration: const InputDecoration(
              hintText: 'At least 8 characters',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            onChanged: (_) => _isDirty = true,
            validator: (value) {
              if (!_createAdmin) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Admin password is required';
              }
              if (value.trim().length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Admin First Name'),
          TextFormField(
            controller: _adminFirstNameController,
            decoration: const InputDecoration(
              hintText: 'First name (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _isDirty = true,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Admin Last Name'),
          TextFormField(
            controller: _adminLastNameController,
            decoration: const InputDecoration(
              hintText: 'Last name (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _isDirty = true,
          ),
        ],
        const SizedBox(height: 24),
        BlocBuilder<SiteBloc, SiteState>(
          builder: (context, state) {
            final bool isLoading = state is SiteLoading;
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
                  : Text(widget.siteId == null ? 'Create Site' : 'Save'),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Note: Site will be created under the current company context.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopForm(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Company', isRequired: true),
                  _buildCompanySelector(isMobile: false),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Site Code'),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'Optional, auto-generated if empty',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
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
                  _buildFieldLabel('Site Name', isRequired: true),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter site name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _isDirty = true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Site name is required';
                      }
                      if (value.trim().length > 255) {
                        return 'Site name must be 255 characters or less';
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
        _buildFieldLabel('Description'),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'Optional description of the site',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (_) => _isDirty = true,
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Is Parent Site'),
          subtitle: const Text(
            'Parent sites can have child sites. Child sites must specify a parent.',
          ),
          value: _isParent,
          onChanged: (value) {
            setState(() {
              _isParent = value;
              _isDirty = true;
            });
          },
        ),
        if (!_isParent)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              'Parent site selection will be enhanced later. For now, child sites '
              'can be created and linked programmatically.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        const Divider(height: 32),
        SwitchListTile(
          title: const Text('Create Admin User for Site'),
          subtitle: const Text(
            'Creates a site admin user with ADMIN role and links them to this site.',
          ),
          value: _createAdmin,
          onChanged: (value) {
            setState(() {
              _createAdmin = value;
              _isDirty = true;
            });
          },
        ),
        if (_createAdmin) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFieldLabel('Admin Email', isRequired: true),
                    TextFormField(
                      controller: _adminEmailController,
                      decoration: const InputDecoration(
                        hintText: 'admin@example.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => _isDirty = true,
                      validator: (value) {
                        if (!_createAdmin) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Admin email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
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
                    _buildFieldLabel('Admin Password', isRequired: true),
                    TextFormField(
                      controller: _adminPasswordController,
                      decoration: const InputDecoration(
                        hintText: 'At least 8 characters',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onChanged: (_) => _isDirty = true,
                      validator: (value) {
                        if (!_createAdmin) return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'Admin password is required';
                        }
                        if (value.trim().length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFieldLabel('Admin First Name'),
                    TextFormField(
                      controller: _adminFirstNameController,
                      decoration: const InputDecoration(
                        hintText: 'First name (optional)',
                        border: OutlineInputBorder(),
                      ),
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
                    _buildFieldLabel('Admin Last Name'),
                    TextFormField(
                      controller: _adminLastNameController,
                      decoration: const InputDecoration(
                        hintText: 'Last name (optional)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _isDirty = true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        BlocBuilder<SiteBloc, SiteState>(
          builder: (context, state) {
            final bool isLoading = state is SiteLoading;
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
                    : Text(widget.siteId == null ? 'Create Site' : 'Save'),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Note: Site will be created under the current company context.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySelector({required bool isMobile}) {
    final authState = context.watch<AuthBloc>().state;
    bool isSuperAdmin = false;
    authState.maybeWhen(
      authenticated: (user) {
        isSuperAdmin = PermissionChecker.isSuperAdmin(user);
      },
      orElse: () {},
    );

    // Non-super-admin: show read-only context
    if (!isSuperAdmin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.business, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Current company context',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    // Super admin: dropdown of companies
    if (_isLoadingCompanies && _companies.isEmpty) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCompanyId?.isEmpty == true ? null : _selectedCompanyId,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Select company',
      ),
      items: _companies
          .map(
            (company) => DropdownMenuItem<String>(
              value: company.id,
              child: Text('${company.code} — ${company.name}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCompanyId = value;
          _isDirty = true;
        });
      },
    );
  }
}


