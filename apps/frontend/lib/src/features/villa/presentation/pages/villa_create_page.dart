import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../data/repositories/villa_repository.dart';
import '../../data/dto/city_dto.dart';
import '../../data/dto/location_dto.dart';
import '../../data/dto/villa_type_config_dto.dart';
import '../../domain/entities/villa_entity.dart';
import '../bloc/villa_bloc.dart';
import '../bloc/villa_event.dart';
import '../bloc/villa_state.dart';

class VillaCreatePage extends StatelessWidget {
  const VillaCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VillaBloc(
        repository: VillaRepository(
          apiClient: getIt<ApiClient>(),
        ),
      ),
      child: const VillaCreateFormContent(),
    );
  }
}

/// Dialog version for web - shows as modal dialog
class VillaCreateDialog extends StatefulWidget {
  const VillaCreateDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider(
        create: (context) => VillaBloc(
          repository: VillaRepository(
            apiClient: getIt<ApiClient>(),
          ),
        ),
        child: const VillaCreateDialog(),
      ),
    );
  }

  @override
  State<VillaCreateDialog> createState() => _VillaCreateDialogState();
}

class _VillaCreateDialogState extends State<VillaCreateDialog> {
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
          maxWidth: isWeb ? 1200 : double.infinity,
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
                    Icons.home,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create Villa',
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
              child: BlocListener<VillaBloc, VillaState>(
                listener: (context, state) {
                  if (!mounted) return;

                  state.maybeWhen(
                    created: (_) {
                      if (mounted && Navigator.of(context).canPop()) {
                        // Capture root context before closing dialog
                        BuildContext? rootContext;
                        try {
                          rootContext =
                              Navigator.of(context, rootNavigator: true)
                                  .context;
                        } catch (e) {
                          // No root navigator available
                        }

                        // Close dialog first
                        Navigator.of(context).pop(true);

                        // Show snackbar on root Scaffold after dialog closes
                        if (rootContext != null) {
                          final safeContext = rootContext;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            try {
                              if (safeContext.mounted) {
                                ScaffoldMessenger.of(safeContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('Villa created successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Ignore - snackbar not critical
                            }
                          });
                        }
                      }
                    },
                    error: (message) {
                      if (mounted && Navigator.of(context).canPop()) {
                        // Capture root context before showing error
                        BuildContext? rootContext;
                        try {
                          rootContext =
                              Navigator.of(context, rootNavigator: true)
                                  .context;
                        } catch (e) {
                          // No root navigator available
                        }

                        // Show error snackbar on root Scaffold
                        if (rootContext != null) {
                          final safeContext = rootContext;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            try {
                              if (safeContext.mounted) {
                                ScaffoldMessenger.of(safeContext).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Ignore - snackbar not critical
                            }
                          });
                        }
                      }
                    },
                    orElse: () {},
                  );
                },
                child: const VillaCreateFormContent(isDialog: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable form content widget that can be used in both page and dialog
/// Can be used for both creating and editing villas
class VillaCreateFormContent extends StatefulWidget {
  const VillaCreateFormContent({
    super.key,
    this.isDialog = false,
    this.initialVilla,
    this.onSubmit,
  });

  final bool isDialog;
  final VillaEntity? initialVilla; // For editing mode
  final void Function(Map<String, dynamic> formData)?
      onSubmit; // Custom submit handler for edit mode

  @override
  State<VillaCreateFormContent> createState() => _VillaCreateFormContentState();
}

class _VillaCreateFormContentState extends State<VillaCreateFormContent> {
  final formKey = GlobalKey<FormBuilderState>();
  List<CityDto>? _cities;
  bool _isLoadingCities = true;
  List<LocationDto>? _locations;
  bool _isLoadingLocations = false;
  String? _selectedCityId;
  List<VillaTypeConfigDto>? _villaTypes;
  bool _isLoadingVillaTypes = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadVillaTypes();
    // If editing, load locations for the existing city
    if (widget.initialVilla != null && widget.initialVilla!.city != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Find city ID from city name
        _loadCitiesAndLocations();
      });
    }
  }

  Future<void> _loadVillaTypes() async {
    try {
      setState(() {
        _isLoadingVillaTypes = true;
      });
      final apiClient = getIt<ApiClient>();
      final villaTypes = await apiClient.getLookupVillaTypes();
      if (mounted) {
        setState(() {
          _villaTypes = villaTypes;
          _isLoadingVillaTypes = false;
        });
      }
    } catch (e) {
      print('Error loading villa types: $e');
      if (mounted) {
        setState(() {
          _isLoadingVillaTypes = false;
        });
      }
    }
  }

  Future<void> _loadCitiesAndLocations() async {
    if (widget.initialVilla != null) {
      final villa = widget.initialVilla!;

      // Set floor and bathroom count values after form is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final formState = formKey.currentState;
        if (formState != null) {
          if (villa.floor != null && villa.floor!.isNotEmpty) {
            formState.fields['floor']?.didChange(villa.floor);
          }
          if (villa.floorCount != null) {
            formState.fields['floor_count']
                ?.didChange(villa.floorCount.toString());
          }
          if (villa.bathroomCount != null) {
            formState.fields['bathroom_count']
                ?.didChange(villa.bathroomCount.toString());
          }
        }
      });

      // Load city and location if city exists
      if (villa.city != null) {
        await _loadCities();
        if (_cities != null && mounted) {
          // Find city by name
          try {
            final city = _cities!.firstWhere(
              (c) => c.name == villa.city,
            );
            // Update form with city ID
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final formState = formKey.currentState;
              if (formState != null) {
                formState.fields['city']?.didChange(city.id);
              }
            });
            await _loadLocations(city.id);
          } catch (e) {
            // City not found, that's okay
          }
        }
      }
    }
  }

  Future<void> _loadCities() async {
    try {
      final apiClient = getIt<ApiClient>();
      final cities = await apiClient.getLookupCities();
      print('✅ Loaded ${cities.length} cities from API');
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
        });
        print('⚠️ Error loading cities: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  Future<void> _loadLocations(String? cityId) async {
    if (cityId == null || cityId.isEmpty) {
      setState(() {
        _locations = null;
        _selectedCityId = null;
      });
      return;
    }

    setState(() {
      _isLoadingLocations = true;
      _selectedCityId = cityId;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final locations = await apiClient.getLookupLocations(cityId: cityId);
      print('✅ Loaded ${locations.length} locations for city $cityId');
      if (mounted) {
        setState(() {
          _locations = locations;
          _isLoadingLocations = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
        print('⚠️ Error loading locations: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  void _handleCityChange(String? cityId) {
    // Clear location when city changes
    final formState = formKey.currentState;
    if (formState != null) {
      formState.fields['location']?.didChange(null);
    }
    _loadLocations(cityId);
  }

  String? _getCityName(String? cityId) {
    if (cityId == null || cityId.isEmpty || _cities == null) {
      return null;
    }
    try {
      final city = _cities!.firstWhere((c) => c.id == cityId);
      return city.name;
    } catch (e) {
      print('⚠️ City not found for ID: $cityId');
      return null;
    }
  }

  String? _getLocationName(String? locationId) {
    if (locationId == null || locationId.isEmpty || _locations == null) {
      return null;
    }
    try {
      final location = _locations!.firstWhere((l) => l.id == locationId);
      return location.name;
    } catch (e) {
      print('⚠️ Location not found for ID: $locationId');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    // For dialog mode, just show the form content without Scaffold/AppBar
    // For page mode, wrap in Scaffold with AppBar
    final formContent = PopScope(
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
            context.pop(true);
          }
        } else {
          if (context.mounted) {
            context.pop(true);
          }
        }
      },
      child: BlocListener<VillaBloc, VillaState>(
        listener: (context, state) {
          if (!mounted) return;

          // When in dialog mode, the dialog's BlocListener handles SnackBars
          // So we skip showing them here to avoid context issues
          if (widget.isDialog) {
            // Only handle navigation for dialog mode
            state.maybeWhen(
              created: (_) {
                // Dialog's listener will handle SnackBar and closing
                // Nothing to do here
              },
              orElse: () {},
            );
            return;
          }

          // For page mode, show SnackBars normally
          state.maybeWhen(
            created: (_) {
              if (mounted && context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && context.mounted) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Villa created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Ignore if context is invalid
                      debugPrint('Error showing success SnackBar: $e');
                    }
                  }
                });
                // Navigate back after showing SnackBar
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && context.mounted) {
                    context.pop(true);
                  }
                });
              }
            },
            error: (message) {
              if (mounted && context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && context.mounted) {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (e) {
                      // Ignore if context is invalid
                      debugPrint('Error showing error SnackBar: $e');
                    }
                  }
                });
              }
            },
            orElse: () {},
          );
        },
        child: ResponsiveLayout(
          mobileBreakpoint: 768.0,
          mobileBuilder: (context) =>
              _buildForm(context, formKey, isMobile: true),
          desktopBuilder: (context) =>
              _buildForm(context, formKey, isMobile: false),
        ),
      ),
    );

    if (widget.isDialog) {
      // For dialog mode, just return the form content without Scaffold/AppBar
      // The ResponsiveLayout inside formContent already handles scrolling
      return formContent;
    }

    // For page mode, wrap in Scaffold with AppBar
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Villa'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
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

  Widget _buildForm(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey, {
    required bool isMobile,
  }) {
    // Build initial values map for editing
    final Map<String, dynamic> initialValues = {};
    if (widget.initialVilla != null) {
      final villa = widget.initialVilla!;
      initialValues['villa_type'] = villa.villaType;
      initialValues['unit_category'] = villa.unitCategory;
      initialValues['villa_number'] = villa.villaNumber;
      initialValues['block'] =
          villa.unitName; // unitName is stored in block field
      initialValues['building_name'] = villa.buildingName;
      initialValues['measure'] = villa.measure;
      initialValues['external_area'] = villa.externalArea;
      initialValues['villa_code'] = villa.villaCode;
      initialValues['owner_name'] = villa.ownerName;
      initialValues['tenant_name'] = villa.tenantName;
      initialValues['contact_phone'] = villa.contactPhone;
      initialValues['contact_email'] = villa.contactEmail;
      initialValues['floor'] = villa.floor;
      initialValues['floor_count'] = villa.floorCount?.toString();
      initialValues['bedroom_count'] = villa.bedroomCount?.toString();
      initialValues['bathroom_count'] = villa.bathroomCount?.toString();
      initialValues['primary_view'] = villa.primaryView;
      initialValues['open_from'] = villa
          .openFrom; // FormBuilderDateTimePicker expects DateTime?, not String
      initialValues['remarks'] = villa.remarks;
      // City and location will be set after cities are loaded
      // Note: We set these in _loadCitiesAndLocations after cities are loaded
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: FormBuilder(
        key: formKey,
        initialValue: initialValues,
        autovalidateMode: AutovalidateMode.disabled,
        child: isMobile
            ? _buildMobileForm(context, formKey)
            : _buildDesktopForm(context, formKey),
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

  /// Builds consistent dropdown decoration using theme
  InputDecoration _buildDropdownDecoration(
    BuildContext context, {
    required String hintText,
    String? helperText,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hintText,
      border: const OutlineInputBorder(),
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.hintColor,
      ),
      helperText: helperText,
      helperStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.hintColor,
      ),
    );
  }

  /// Builds consistent dropdown text style using theme
  TextStyle _buildDropdownTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium ?? const TextStyle();
  }

  Widget _buildMobileForm(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Villa Type - FIRST
        _buildFieldLabel('Villa Type', isRequired: true),
        _isLoadingVillaTypes
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : FormBuilderDropdown<String>(
                name: 'villa_type',
                decoration: _buildDropdownDecoration(
                  context,
                  hintText: 'Select villa type',
                ),
                style: _buildDropdownTextStyle(context),
                validator: FormBuilderValidators.required(
                  errorText: 'Villa type is required',
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Select Villa Type',
                      style: _buildDropdownTextStyle(context).copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  ...(_villaTypes ?? []).map((villaType) {
                    final displayText =
                        villaType.displayName ?? villaType.villaType;
                    return DropdownMenuItem<String>(
                      value: villaType.villaType,
                      child: Text(displayText),
                    );
                  }),
                ],
              ),
        const SizedBox(height: 24),
        _buildFieldLabel('Unit Category', isRequired: true),
        FormBuilderDropdown<String>(
          name: 'unit_category',
          decoration: _buildDropdownDecoration(
            context,
            hintText: 'Select unit category',
          ),
          style: _buildDropdownTextStyle(context),
          validator: FormBuilderValidators.required(
            errorText: 'Unit category is required',
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Select Unit Category',
                style: _buildDropdownTextStyle(context).copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Residential',
              child: Text('Residential'),
            ),
            DropdownMenuItem<String>(
              value: 'Commercial',
              child: Text('Commercial'),
            ),
            DropdownMenuItem<String>(
              value: 'Mixed Use',
              child: Text('Mixed Use'),
            ),
            DropdownMenuItem<String>(
              value: 'Retail',
              child: Text('Retail'),
            ),
            DropdownMenuItem<String>(
              value: 'Office',
              child: Text('Office'),
            ),
            DropdownMenuItem<String>(
              value: 'Industrial',
              child: Text('Industrial'),
            ),
            DropdownMenuItem<String>(
              value: 'Hospitality',
              child: Text('Hospitality'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Unit No (formerly Villa Number)
        _buildFieldLabel('Unit No', isRequired: true),
        FormBuilderTextField(
          name: 'villa_number',
          decoration: const InputDecoration(
            hintText: 'Enter unit number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Unit number is required',
            ),
            FormBuilderValidators.maxLength(
              50,
              errorText: 'Unit number must be 50 characters or less',
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('Unit Name', isRequired: true),
        FormBuilderTextField(
          name: 'block',
          decoration: const InputDecoration(
            hintText: 'Enter unit name',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Unit name is required',
            ),
            FormBuilderValidators.maxLength(
              50,
              errorText: 'Unit name must be 50 characters or less',
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('Building Name', isRequired: true),
        FormBuilderTextField(
          name: 'building_name',
          decoration: const InputDecoration(
            hintText: 'Enter building name',
            border: OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Building name is required',
            ),
            FormBuilderValidators.maxLength(
              100,
              errorText: 'Building name must be 100 characters or less',
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('Measure'),
        FormBuilderTextField(
          name: 'measure',
          decoration: const InputDecoration(
            hintText: 'Enter measure',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('External Area'),
        FormBuilderTextField(
          name: 'external_area',
          decoration: const InputDecoration(
            hintText: 'Enter external area',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Open From'),
        FormBuilderDateTimePicker(
          name: 'open_from',
          decoration: const InputDecoration(
            hintText: 'Select date',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          inputType: InputType.date,
          format: DateFormat('yyyy-MM-dd'),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Floor'),
        FormBuilderTextField(
          name: 'floor',
          decoration: const InputDecoration(
            hintText: 'Enter floor',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Bedroom Count', isRequired: true),
        FormBuilderTextField(
          name: 'bedroom_count',
          decoration: const InputDecoration(
            hintText: 'Enter bedroom count',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Bedroom count is required',
            ),
            FormBuilderValidators.integer(
              errorText: 'Bedroom count must be a valid number',
            ),
            FormBuilderValidators.min(
              0,
              errorText: 'Bedroom count cannot be negative',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Primary View', isRequired: true),
        FormBuilderDropdown<String>(
          name: 'primary_view',
          decoration: _buildDropdownDecoration(
            context,
            hintText: 'Select primary view',
          ),
          style: _buildDropdownTextStyle(context),
          validator: FormBuilderValidators.required(
            errorText: 'Primary view is required',
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Select Primary View',
                style: _buildDropdownTextStyle(context).copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Excellent',
              child: Text('Excellent'),
            ),
            DropdownMenuItem<String>(
              value: 'Good',
              child: Text('Good'),
            ),
            DropdownMenuItem<String>(
              value: 'Average',
              child: Text('Average'),
            ),
            DropdownMenuItem<String>(
              value: 'Fair',
              child: Text('Fair'),
            ),
            DropdownMenuItem<String>(
              value: 'Poor',
              child: Text('Poor'),
            ),
            DropdownMenuItem<String>(
              value: 'Sea View',
              child: Text('Sea View'),
            ),
            DropdownMenuItem<String>(
              value: 'City View',
              child: Text('City View'),
            ),
            DropdownMenuItem<String>(
              value: 'Garden View',
              child: Text('Garden View'),
            ),
            DropdownMenuItem<String>(
              value: 'Pool View',
              child: Text('Pool View'),
            ),
            DropdownMenuItem<String>(
              value: 'Mountain View',
              child: Text('Mountain View'),
            ),
            DropdownMenuItem<String>(
              value: 'Park View',
              child: Text('Park View'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('Floor Count', isRequired: true),
        FormBuilderTextField(
          name: 'floor_count',
          decoration: const InputDecoration(
            hintText: 'Enter floor count',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Floor count is required',
            ),
            FormBuilderValidators.integer(
              errorText: 'Floor count must be a valid number',
            ),
            FormBuilderValidators.min(
              0,
              errorText: 'Floor count cannot be negative',
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Bathroom Count', isRequired: true),
        FormBuilderTextField(
          name: 'bathroom_count',
          decoration: const InputDecoration(
            hintText: 'Enter bathroom count',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
              errorText: 'Bathroom count is required',
            ),
            FormBuilderValidators.integer(
              errorText: 'Bathroom count must be a valid number',
            ),
            FormBuilderValidators.min(
              0,
              errorText: 'Bathroom count cannot be negative',
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('City', isRequired: true),
        _isLoadingCities
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : FormBuilderDropdown<String>(
                name: 'city',
                decoration: _buildDropdownDecoration(
                  context,
                  hintText: 'Select city',
                ),
                style: _buildDropdownTextStyle(context),
                validator: FormBuilderValidators.required(
                  errorText: 'City is required',
                ),
                onChanged: (value) => _handleCityChange(value),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Select City',
                      style: _buildDropdownTextStyle(context).copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  if (_cities != null)
                    ..._cities!.map(
                      (city) => DropdownMenuItem<String>(
                        value: city.id,
                        child: Text(city.name),
                      ),
                    ),
                ],
              ),
        const SizedBox(height: 16),
        _buildFieldLabel('Location', isRequired: true),
        _isLoadingLocations
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : FormBuilderDropdown<String>(
                name: 'location',
                enabled: _selectedCityId != null,
                decoration: _buildDropdownDecoration(
                  context,
                  hintText: _selectedCityId == null
                      ? 'Select city first'
                      : 'Select location',
                ),
                style: _buildDropdownTextStyle(context),
                validator: FormBuilderValidators.required(
                  errorText: 'Location is required',
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      'Select Location',
                      style: _buildDropdownTextStyle(context).copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  if (_locations != null)
                    ..._locations!.map(
                      (location) => DropdownMenuItem<String>(
                        value: location.id,
                        child: Text(location.name),
                      ),
                    ),
                ],
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('Owner Name'),
        FormBuilderTextField(
          name: 'owner_name',
          decoration: const InputDecoration(
            hintText: 'Enter owner name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Contact Phone'),
        FormBuilderTextField(
          name: 'contact_phone',
          decoration: const InputDecoration(
            hintText: 'Enter contact phone',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Contact Email'),
        FormBuilderTextField(
          name: 'contact_email',
          decoration: const InputDecoration(
            hintText: 'Enter contact email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('Remarks'),
        FormBuilderTextField(
          name: 'remarks',
          decoration: const InputDecoration(
            hintText: 'Enter any additional remarks',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        // Submit Button
        BlocBuilder<VillaBloc, VillaState>(
          builder: (context, state) {
            final isLoading = state.maybeWhen<bool>(
                  loading: () => true,
                  orElse: () => false,
            );

            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final formState = formKey.currentState;
                      if (formState != null && formState.saveAndValidate()) {
                        final formData = formState.value;

                        // If custom submit handler provided (for edit mode), use it
                        if (widget.onSubmit != null) {
                          widget.onSubmit!(formData);
                          return;
                        }

                        // Otherwise, use create mode
                        context.read<VillaBloc>().add(
                              CreateVilla(
                                villaNumber: formData['villa_number'] as String,
                                ownerName: formData['owner_name']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['owner_name'] as String?,
                                contactPhone: formData['contact_phone']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['contact_phone'] as String?,
                                contactEmail: formData['contact_email']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['contact_email'] as String?,
                                city: _getCityName(formData['city'] as String?),
                                street: _getLocationName(
                                  formData['location'] as String?,
                                ),
                                block: null, // Block is now mapped to unitName
                                floorCount: formData['floor_count']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : int.tryParse(
                                        formData['floor_count'] as String,
                                      ),
                                bedroomCount: formData['bedroom_count']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : int.tryParse(
                                        formData['bedroom_count'] as String,
                                      ),
                                bathroomCount: formData['bathroom_count']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : int.tryParse(
                                        formData['bathroom_count'] as String,
                                      ),
                                villaType: formData['villa_type']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['villa_type'] as String?,
                                buildingName: formData['building_name']
                                                ?.toString()
                                                .trim()
                                                .isEmpty ==
                                            true
                                        ? null
                                    : formData['building_name'] as String?,
                                openFrom: formData['open_from'] != null
                                    ? DateTime.tryParse(
                                        formData['open_from'].toString(),
                                      )
                                    : null,
                                unitNo: formData['villa_number']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['villa_number'] as String?,
                                unitName: formData['block']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['block'] as String?,
                                primaryView: formData['primary_view']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['primary_view'] as String?,
                                unitCategory: formData['unit_category']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['unit_category'] as String?,
                                floor: formData['floor']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['floor'] as String?,
                                remarks: formData['remarks']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['remarks'] as String?,
                                measure: formData['measure']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['measure'] as String?,
                                externalArea: formData['external_area']
                                            ?.toString()
                                            .trim()
                                            .isEmpty ==
                                        true
                                    ? null
                                    : formData['external_area'] as String?,
                                isActive: true, // Always active by default
                                isOccupied: false,
                              ),
                            );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.initialVilla != null
                      ? 'Update Villa'
                      : 'Create Villa'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopForm(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Villa Type | Unit Category
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Villa Type', isRequired: true),
                  _isLoadingVillaTypes
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : FormBuilderDropdown<String>(
                          name: 'villa_type',
                          decoration: _buildDropdownDecoration(
                            context,
                            hintText: 'Select villa type',
                          ),
                          style: _buildDropdownTextStyle(context),
                          validator: FormBuilderValidators.required(
                            errorText: 'Villa type is required',
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Select Villa Type',
                                style: _buildDropdownTextStyle(context).copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                            ...(_villaTypes ?? []).map((villaType) {
                              final displayText =
                                  villaType.displayName ?? villaType.villaType;
                              return DropdownMenuItem<String>(
                                value: villaType.villaType,
                                child: Text(displayText),
                              );
                            }),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Unit Category', isRequired: true),
                  FormBuilderDropdown<String>(
                    name: 'unit_category',
                    decoration: _buildDropdownDecoration(
                      context,
                      hintText: 'Select unit category',
                    ),
                    style: _buildDropdownTextStyle(context),
                    validator: FormBuilderValidators.required(
                      errorText: 'Unit category is required',
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'Select Unit Category',
                          style: _buildDropdownTextStyle(context).copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Residential',
                        child: Text('Residential'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Commercial',
                        child: Text('Commercial'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Mixed Use',
                        child: Text('Mixed Use'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Retail',
                        child: Text('Retail'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Office',
                        child: Text('Office'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Industrial',
                        child: Text('Industrial'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Hospitality',
                        child: Text('Hospitality'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 2: Unit No | Unit Name
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Unit No', isRequired: true),
                  FormBuilderTextField(
                    name: 'villa_number',
                    decoration: const InputDecoration(
                      hintText: 'Enter unit number (e.g., 101, 101A, V-101)',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Unit number is required',
                      ),
                      FormBuilderValidators.maxLength(
                        50,
                        errorText: 'Unit number must be 50 characters or less',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Unit Name', isRequired: true),
                  FormBuilderTextField(
                    name: 'block',
                    decoration: const InputDecoration(
                      hintText: 'Enter unit name',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Unit name is required',
                      ),
                      FormBuilderValidators.maxLength(
                        50,
                        errorText: 'Unit name must be 50 characters or less',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 3: Building Name | Open From
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Building Name', isRequired: true),
                  FormBuilderTextField(
                    name: 'building_name',
                    decoration: const InputDecoration(
                      hintText: 'Enter building name',
                      border: OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Building name is required',
                      ),
                      FormBuilderValidators.maxLength(
                        100,
                        errorText: 'Building name must be 100 characters or less',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Open From'),
                  FormBuilderDateTimePicker(
                    name: 'open_from',
                          decoration: const InputDecoration(
                      hintText: 'Select date',
                            border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    inputType: InputType.date,
                    format: DateFormat('yyyy-MM-dd'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 4: Measure | External Area
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Measure'),
                  FormBuilderTextField(
                    name: 'measure',
                    decoration: const InputDecoration(
                      hintText: 'Enter measure',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('External Area'),
                  FormBuilderTextField(
                    name: 'external_area',
                    decoration: const InputDecoration(
                      hintText: 'Enter external area',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 5: Floor | Bedroom Count
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Floor'),
                  FormBuilderTextField(
                    name: 'floor',
                    decoration: const InputDecoration(
                      hintText: 'Enter floor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Bedroom Count', isRequired: true),
                  FormBuilderTextField(
                    name: 'bedroom_count',
                    decoration: const InputDecoration(
                      hintText: 'Enter bedroom count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Bedroom count is required',
                      ),
                      FormBuilderValidators.integer(
                        errorText: 'Bedroom count must be a valid number',
                      ),
                      FormBuilderValidators.min(
                        0,
                        errorText: 'Bedroom count cannot be negative',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 6: Primary View | Floor Count
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Primary View', isRequired: true),
                  FormBuilderDropdown<String>(
                    name: 'primary_view',
                    decoration: _buildDropdownDecoration(
                      context,
                      hintText: 'Select primary view',
                    ),
                    style: _buildDropdownTextStyle(context),
                    validator: FormBuilderValidators.required(
                      errorText: 'Primary view is required',
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'Select Primary View',
                          style: _buildDropdownTextStyle(context).copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Excellent',
                        child: Text('Excellent'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Good',
                        child: Text('Good'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Average',
                        child: Text('Average'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Fair',
                        child: Text('Fair'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Poor',
                        child: Text('Poor'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Sea View',
                        child: Text('Sea View'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'City View',
                        child: Text('City View'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Garden View',
                        child: Text('Garden View'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Pool View',
                        child: Text('Pool View'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Mountain View',
                        child: Text('Mountain View'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Park View',
                        child: Text('Park View'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Floor Count', isRequired: true),
                  FormBuilderTextField(
                    name: 'floor_count',
                    decoration: const InputDecoration(
                      hintText: 'Enter floor count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Floor count is required',
                      ),
                      FormBuilderValidators.integer(
                        errorText: 'Floor count must be a valid number',
                      ),
                      FormBuilderValidators.min(
                        0,
                        errorText: 'Floor count cannot be negative',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 7: Bathroom Count | (empty)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Bathroom Count', isRequired: true),
                  FormBuilderTextField(
                    name: 'bathroom_count',
                    decoration: const InputDecoration(
                      hintText: 'Enter bathroom count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'Bathroom count is required',
                      ),
                      FormBuilderValidators.integer(
                        errorText: 'Bathroom count must be a valid number',
                      ),
                      FormBuilderValidators.min(
                        0,
                        errorText: 'Bathroom count cannot be negative',
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 24),
        // Row 8: City | Location
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('City', isRequired: true),
                  _isLoadingCities
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : FormBuilderDropdown<String>(
                          name: 'city',
                          decoration: _buildDropdownDecoration(
                            context,
                            hintText: 'Select city',
                          ),
                          style: _buildDropdownTextStyle(context),
                          validator: FormBuilderValidators.required(
                            errorText: 'City is required',
                          ),
                          onChanged: (value) => _handleCityChange(value),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Select City',
                                style: _buildDropdownTextStyle(context).copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                            if (_cities != null)
                              ..._cities!.map(
                                (city) => DropdownMenuItem<String>(
                                  value: city.id,
                                  child: Text(city.name),
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Location', isRequired: true),
                  _isLoadingLocations
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : FormBuilderDropdown<String>(
                          name: 'location',
                          enabled: _selectedCityId != null,
                          decoration: _buildDropdownDecoration(
                            context,
                            hintText: _selectedCityId == null
                                ? 'Select city first'
                                : 'Select location',
                          ),
                          style: _buildDropdownTextStyle(context),
                          validator: FormBuilderValidators.required(
                            errorText: 'Location is required',
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Select Location',
                                style: _buildDropdownTextStyle(context).copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                            if (_locations != null)
                              ..._locations!.map(
                                (location) => DropdownMenuItem<String>(
                                  value: location.id,
                                  child: Text(location.name),
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 10: Owner Name | Contact Phone
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Owner Name'),
                  FormBuilderTextField(
                    name: 'owner_name',
                    decoration: const InputDecoration(
                      hintText: 'Enter owner name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Contact Phone'),
                  FormBuilderTextField(
                    name: 'contact_phone',
                    decoration: const InputDecoration(
                      hintText: 'Enter contact phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 11: Contact Email | (empty)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Contact Email'),
                  FormBuilderTextField(
                    name: 'contact_email',
                    decoration: const InputDecoration(
                      hintText: 'Enter contact email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('Remarks'),
        FormBuilderTextField(
          name: 'remarks',
          decoration: const InputDecoration(
            hintText: 'Enter any additional remarks',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        // Submit button
        BlocBuilder<VillaBloc, VillaState>(
          builder: (context, state) {
            final isLoading = state.maybeWhen<bool>(
                  loading: () => true,
                  orElse: () => false,
            );

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final formState = formKey.currentState;
                        if (formState != null && formState.saveAndValidate()) {
                          final formData = formState.value;

                          // If custom submit handler provided (for edit mode), use it
                          if (widget.onSubmit != null) {
                            widget.onSubmit!(formData);
                            return;
                          }

                          // Otherwise, use create mode
                          context.read<VillaBloc>().add(
                                CreateVilla(
                                  villaNumber:
                                      formData['villa_number'] as String,
                                  ownerName: formData['owner_name']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['owner_name'] as String?,
                                  contactPhone: formData['contact_phone']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['contact_phone'] as String?,
                                  contactEmail: formData['contact_email']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['contact_email'] as String?,
                                  city:
                                      _getCityName(formData['city'] as String?),
                                  street: _getLocationName(
                                    formData['location'] as String?,
                                  ),
                                  block:
                                      null, // Block is now mapped to unitName
                                  floorCount: formData['floor_count']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : int.tryParse(
                                          formData['floor_count'] as String,
                                        ),
                                  bedroomCount: formData['bedroom_count']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : int.tryParse(
                                          formData['bedroom_count'] as String,
                                        ),
                                  bathroomCount: formData['bathroom_count']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : int.tryParse(
                                          formData['bathroom_count'] as String,
                                        ),
                                  villaType: formData['villa_type']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['villa_type'] as String?,
                                  buildingName: formData['building_name']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['building_name'] as String?,
                                  openFrom: formData['open_from'] != null
                                      ? DateTime.tryParse(
                                          formData['open_from'].toString(),
                                        )
                                      : null,
                                  unitNo: formData['villa_number']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['villa_number'] as String?,
                                  unitName: formData['block']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['block'] as String?,
                                  primaryView: formData['primary_view']
                                                  ?.toString()
                                                  .trim()
                                                  .isEmpty ==
                                              true
                                          ? null
                                      : formData['primary_view'] as String?,
                                  unitCategory: formData['unit_category']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['unit_category'] as String?,
                                  floor: formData['floor']
                                                  ?.toString()
                                                  .trim()
                                                  .isEmpty ==
                                              true
                                          ? null
                                      : formData['floor'] as String?,
                                  remarks: formData['remarks']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['remarks'] as String?,
                                  measure: formData['measure']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['measure'] as String?,
                                  externalArea: formData['external_area']
                                              ?.toString()
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? null
                                      : formData['external_area'] as String?,
                                  isActive: true, // Always active by default
                                  isOccupied: false,
                                ),
                              );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.initialVilla != null
                        ? 'Update Villa'
                        : 'Create Villa'),
              ),
            );
          },
        ),
      ],
    );
  }
}
