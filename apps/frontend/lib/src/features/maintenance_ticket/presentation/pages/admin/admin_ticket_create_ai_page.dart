import 'dart:async';
import 'dart:io' show File;
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional import for web camera support
import '../shared/camera_web_stub.dart'
    if (dart.library.html) '../shared/camera_web.dart' as camera_web;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../../bloc/maintenance_ticket_bloc.dart';
import '../../bloc/maintenance_ticket_event.dart';
import '../../bloc/maintenance_ticket_state.dart';
import '../../../domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../../domain/services/ai_ticket_service_interface.dart';
import '../../widgets/category_selector_widget.dart';
import '../../../domain/entities/villa_entity.dart';
import '../../../domain/entities/site_entity.dart';
import '../../../data/services/file_upload_service.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/data/mappers/user_mapper.dart';

class AdminTicketCreateAiPage extends StatelessWidget {
  const AdminTicketCreateAiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MaintenanceTicketBloc>(
          create: (context) {
            AiTicketServiceInterface? aiService;
            try {
              if (getIt.isRegistered<AiTicketServiceInterface>()) {
                aiService = getIt<AiTicketServiceInterface>();
              } else {
                debugPrint('⚠️ AI service not registered in GetIt');
              }
            } catch (e) {
              debugPrint('⚠️ AI service not available: $e');
              aiService = null;
            }

            return MaintenanceTicketBloc(
              repository: getIt<MaintenanceTicketRepositoryInterface>(),
              aiService: aiService,
            );
          },
        ),
      ],
      child: const _AdminTicketCreateAiContent(),
    );
  }
}

/// Dialog version - shows as modal dialog
class AdminTicketCreateAiDialog extends StatelessWidget {
  const AdminTicketCreateAiDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<MaintenanceTicketBloc>(
            create: (context) {
              AiTicketServiceInterface? aiService;
              try {
                if (getIt.isRegistered<AiTicketServiceInterface>()) {
                  aiService = getIt<AiTicketServiceInterface>();
                } else {
                  debugPrint('⚠️ AI service not registered in GetIt');
                }
              } catch (e) {
                debugPrint('⚠️ AI service not available: $e');
                aiService = null;
              }

              return MaintenanceTicketBloc(
                repository: getIt<MaintenanceTicketRepositoryInterface>(),
                aiService: aiService,
              );
            },
          ),
        ],
        child: const AdminTicketCreateAiDialog(),
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
      child: ConstrainedBox(
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
                    Icons.auto_awesome,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create New Ticket',
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
              child: const _AdminTicketCreateAiContent(isDialog: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTicketCreateAiContent extends StatefulWidget {
  const _AdminTicketCreateAiContent({
    this.isDialog = false,
  });

  final bool isDialog;

  @override
  State<_AdminTicketCreateAiContent> createState() =>
      _AdminTicketCreateAiContentState();
}

class _AdminTicketCreateAiContentState
    extends State<_AdminTicketCreateAiContent>
    with SingleTickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<PlatformFile> _selectedImages = [];

  // Form controllers (unified - no separate review form)
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  String? _selectedCategoryId;
  String _selectedPriority = 'MEDIUM';
  DateTime? _preferredDate;
  TimeOfDay? _preferredStartTime;
  TimeOfDay? _preferredEndTime;
  bool _isAiAnalyzing = false;

  // Admin-specific fields
  String? _selectedTenantId; // Selected tenant user ID
  String? _selectedVillaNumber;
  String? _selectedSiteId;

  // Tenant list state
  List<UserEntity> _tenants = [];
  bool _isLoadingTenants = false;
  String? _tenantsError;

  // Form validation state - track if form has been submitted or villa field touched
  bool _hasAttemptedSubmit = false;
  bool _villaFieldTouched = false;

  // Track villa loading to prevent infinite loops
  bool _hasAttemptedVillaLoad = false;
  String? _lastVillaLoadSiteId;

  @override
  void initState() {
    super.initState();
    // Voice feature initialization removed - feature is hidden

    // Categories are loaded automatically by CategorySelectorWidget
    // No need to load them here to avoid duplicate calls

    // Load tenants on page load
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    if (_isLoadingTenants) return;

    setState(() {
      _isLoadingTenants = true;
      _tenantsError = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final userDtos = await apiClient.getUsers(role: 'TENANT');
      final tenants = userDtos
          .map((dto) {
            // Convert UserDto to Map for UserMapper
            // UserMapper expects camelCase keys, so we need to convert from DTO format
            final json = <String, dynamic>{
              'id': dto.id,
              'email': dto.email,
              'companyId': dto.companyId,
              'siteId': '', // Default empty, will be populated if available
              'siteCode': '', // Default empty
              'firstName': dto.firstName,
              'lastName': dto.lastName,
              'villaNumber': dto.villaNumber,
              'phoneNumber': dto.phoneNumber,
              'villas': dto.villas ?? <Map<String, dynamic>>[],
              'roles': dto.roles ?? <String>[],
              'permissions': <String>[], // Permissions not in UserDto
            };
            return UserMapper.fromJson(json);
          })
          .where((user) => user.roles.contains('TENANT'))
          .toList();

      if (mounted) {
        setState(() {
          _tenants = tenants;
          _isLoadingTenants = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading tenants: $e');
      if (mounted) {
        setState(() {
          _tenantsError = e.toString();
          _isLoadingTenants = false;
        });
      }
    }
  }

  // Error state for manual display to avoid layout shift
  String? _descriptionError;

  Future<void> _pickImagesFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (kIsWeb) {
        final platformFile = await camera_web.pickImageFromCamera();
        if (platformFile != null && mounted) {
          setState(() {
            _selectedImages.add(platformFile);
          });
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(result.files);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: colorScheme.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: colorScheme.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _alternatePhoneController.dispose();

    super.dispose();
  }

  void _submitComplaint() {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? villaNumber = _selectedVillaNumber;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim().isEmpty
        ? null
        : _locationController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your problem'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedVillaNumber == null || _selectedVillaNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a villa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Format preferred time range (optional field)
    String? preferredTimeStr;
    if (_preferredDate != null &&
        _preferredStartTime != null &&
        _preferredEndTime != null) {
      // Validate time range before formatting
      final startDouble =
          _preferredStartTime!.hour + _preferredStartTime!.minute / 60.0;
      final endDouble =
          _preferredEndTime!.hour + _preferredEndTime!.minute / 60.0;

      // Only format if time range is valid (end > start)
      if (endDouble > startDouble) {
        final startDateTime = DateTime(
          _preferredDate!.year,
          _preferredDate!.month,
          _preferredDate!.day,
          _preferredStartTime!.hour,
          _preferredStartTime!.minute,
        );
        final endDateTime = DateTime(
          _preferredDate!.year,
          _preferredDate!.month,
          _preferredDate!.day,
          _preferredEndTime!.hour,
          _preferredEndTime!.minute,
        );
        // Format as ISO8601 range: "start/end"
        preferredTimeStr =
            '${startDateTime.toIso8601String()}/${endDateTime.toIso8601String()}';
      }
      // If invalid time range, skip preferred time (optional field)
    } else if (_preferredDate != null && _preferredStartTime != null) {
      // If only date and start time are selected, use start time as single point
      final startDateTime = DateTime(
        _preferredDate!.year,
        _preferredDate!.month,
        _preferredDate!.day,
        _preferredStartTime!.hour,
        _preferredStartTime!.minute,
      );
      preferredTimeStr = startDateTime.toIso8601String();
    }
    // If no date/time selected, preferredTimeStr remains null (optional)

    context.read<MaintenanceTicketBloc>().add(
          CreateMaintenanceTicket(
            title: title,
            description: description,
            categoryId: _selectedCategoryId,
            category: _selectedCategoryId == null ? 'MISCELLANEOUS' : null,
            priority: _selectedPriority,
            villaNumber: villaNumber,
            siteId: _selectedSiteId,
            contactNumber: _alternatePhoneController.text.trim().isEmpty
                ? null
                : _alternatePhoneController.text.trim(),
            preferredTime: preferredTimeStr,
            location: location,
          ),
        );
  }

  Future<void> _triggerAiAnalysis() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAiAnalyzing = true;
    });

    context.read<MaintenanceTicketBloc>().add(
          CreateMaintenanceTicketWithAi(
            description: description,
            villaNumber: _selectedVillaNumber,
            contactNumber: null, // Using alternate phone field instead
          ),
        );
  }

  /// Upload images after ticket creation
  Future<void> _uploadImages(String ticketId, BuildContext context) async {
    if (_selectedImages.isEmpty) return;

    final uploadService = getIt<FileUploadService>();
    final colorScheme = Theme.of(context).colorScheme;

    // Show uploading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Uploading images...'),
          ],
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 30), // Long duration for uploads
      ),
    );

    try {
      final results = await uploadService.uploadMultipleImages(
        ticketId,
        _selectedImages,
      );

      // Count successes and failures
      final successCount = results.where((r) => r.success).length;
      final failureCount = results.length - successCount;

      if (!context.mounted) return;

      // Hide uploading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show result
      if (failureCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $successCount image(s) uploaded successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ $successCount uploaded, $failureCount failed',
              maxLines: 2,
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload images: $e'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaintenanceTicketBloc, MaintenanceTicketState>(
      listener: (context, state) {
        // Handle AI analysis - populate fields directly
        if (state is MaintenanceTicketAiAnalysisReady) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final bloc = context.read<MaintenanceTicketBloc>();
            final categories = bloc.cachedCategories;

            // Find matching category by code or name (case-insensitive)
            String? matchedCategoryId;
            if (state.analysis.category.isNotEmpty && categories.isNotEmpty) {
              final categoryFromAi = state.analysis.category.toUpperCase();
              try {
                final matchedCategory = categories.firstWhere(
                  (cat) {
                    final codeMatch = cat.code?.toUpperCase() == categoryFromAi;
                    final nameMatch = cat.name?.toUpperCase() == categoryFromAi;
                    return codeMatch || nameMatch;
                  },
                );
                matchedCategoryId = matchedCategory.id;
              } catch (e) {
                // No matching category found, leave it null
                debugPrint(
                  '⚠️ No matching category found for: ${state.analysis.category}',
                );
              }
            }

            setState(() {
              _titleController.text = state.analysis.title;
              // Update description with AI response if available, otherwise keep original
              if (state.analysis.description != null &&
                  state.analysis.description!.isNotEmpty) {
                _descriptionController.text = state.analysis.description!;
              }
              // AI-detected location (e.g., Kitchen, Hall)
              if (state.analysis.location != null &&
                  state.analysis.location!.isNotEmpty) {
                _locationController.text = state.analysis.location!;
              }
              _selectedPriority = state.analysis.priority;
              if (matchedCategoryId != null) {
                _selectedCategoryId = matchedCategoryId;
              }
              if (state.analysis.contactNumber != null &&
                  state.analysis.contactNumber!.isNotEmpty) {
                _alternatePhoneController.text = state.analysis.contactNumber!;
              }
              // Parse preferred time if available (legacy support for single datetime)
              if (state.analysis.preferredTime != null) {
                try {
                  final parsedDateTime =
                      DateTime.tryParse(state.analysis.preferredTime!);
                  if (parsedDateTime != null) {
                    setState(() {
                      _preferredDate = DateTime(
                        parsedDateTime.year,
                        parsedDateTime.month,
                        parsedDateTime.day,
                      );
                      _preferredStartTime =
                          TimeOfDay.fromDateTime(parsedDateTime);
                      // Default end time to 1 hour after start
                      _preferredEndTime = TimeOfDay(
                        hour: (parsedDateTime.hour + 1) % 24,
                        minute: parsedDateTime.minute,
                      );
                    });
                  }
                } catch (e) {
                  // If parsing fails, leave it null
                }
              }
              _isAiAnalyzing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ AI analysis complete! Fields auto-filled.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          });
        }
        state.maybeWhen(
          created: (ticket) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!context.mounted) return;
              try {
                // Upload images if any
                if (_selectedImages.isNotEmpty) {
                  await _uploadImages(ticket.id, context);
                }

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ticket #${ticket.ticketNumber} created successfully',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } catch (e) {
                debugPrint('⚠️ Ignored UI update on deactivated widget: $e');
              } finally {
                if (context.mounted) {
                  if (widget.isDialog) {
                    // For dialog mode, close the dialog
                    Navigator.of(context).pop(true);
                  } else {
                    // For page mode, pop the route
                    context.pop();
                  }
                }
              }
            });
          },
          error: (message) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Reset AI analyzing state on error
                if (mounted) {
                  setState(() {
                    _isAiAnalyzing = false;
                  });
                }
              } catch (e) {
                debugPrint('⚠️ Ignored UI update on deactivated widget: $e');
              }
            });
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        final content = ResponsiveLayout(
          mobileBuilder: (context) => _buildMobileLayout(context, state),
          desktopBuilder: (context) => _buildDesktopLayout(context, state),
        );

        if (widget.isDialog) {
          // For dialog mode, just return the content without Scaffold/AppBar
          // The ResponsiveLayout already handles scrolling
          return content;
        }

        // For page mode, wrap in Scaffold with AppBar
        return Scaffold(
          // Use standard scaffold background from app theme (no custom gradient)
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            // Default Material 3 AppBar color from theme
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/dashboard'),
            ),
            title: const Text(
              'Create New Ticket',
            ),
          ),
          body: content,
        );
      },
    );
  }

  // --- Layout Builders ---

  Widget _buildDesktopLayout(
    BuildContext context,
    MaintenanceTicketState state,
  ) {
    final isLoading = state is MaintenanceTicketLoading;

    if (widget.isDialog) {
      // For dialog mode, just show the content without the card wrapper
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildContent(context, isLoading, isMobile: false),
      );
    }

    // For page mode, use the card wrapper
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _buildContent(context, isLoading, isMobile: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    MaintenanceTicketState state,
  ) {
    final isLoading = state is MaintenanceTicketLoading;

    if (widget.isDialog) {
      // For dialog mode, just show the content without SafeArea
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: _buildContent(context, isLoading, isMobile: true),
      );
    }

    // For page mode, use SafeArea
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: _buildContent(context, isLoading, isMobile: true),
      ),
    );
  }

  // --- Content & Components ---

  Widget _buildContent(
    BuildContext context,
    bool isLoading, {
    required bool isMobile,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          // Site Selector (Admin only) - MUST BE FIRST
          _buildSiteSelector(context, isMobile: isMobile),
          const SizedBox(height: 20),
          // Tenant Selector (Admin can select tenant to filter villas)
          _buildTenantSelector(context, isMobile: isMobile),
          const SizedBox(height: 20),
          // Villa selector (Admin can select any villa - loads after site/tenant selection)
          _buildVillaSelector(context, isMobile: isMobile),
          const SizedBox(height: 20),

          // Description Field with AI Button (FIRST)
          _buildDescriptionWithAiButton(context, isMobile: isMobile),
          const SizedBox(height: 20),

          // Title Field
          _buildFormField(
            context,
            label: 'Title',
            controller: _titleController,
            icon: Icons.title,
            hint: 'Brief title for the issue',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
            isMobile: isMobile,
            maxLength: 100,
            showCounter: false, // Hide explicit counter like Location
          ),
          const SizedBox(height: 20),

          // Location Field (e.g., Kitchen, Hall, Balcony)
          _buildFormField(
            context,
            label: 'Location (e.g., Kitchen, Hall, Balcony)',
            controller: _locationController,
            icon: Icons.place_outlined,
            hint: 'Where is the issue located inside your villa?',
            // Optional field, but restrict to max 2 words to keep it short
            isOptional: true,
            validator: (value) {
              if (value == null) return null;
              final trimmed = value.trim();
              if (trimmed.isEmpty) {
                return null;
              }
              final words = trimmed.split(RegExp(r'\s+'));
              if (words.length > 2) {
                return 'Please keep the location short (max 2 words)';
              }
              return null;
            },
            isMobile: isMobile,
            // Short label, 2-word max – 40 chars is enough
            maxLength: 40,
            showCounter: false,
          ),
          const SizedBox(height: 20),

          // Category Selector (Priority is auto-selected as MEDIUM, hidden from UI)
          _buildCategorySelector(context, isMobile: isMobile),
          const SizedBox(height: 24),

          // Alternate Phone Number (Optional)
          _buildFormField(
            context,
            label: 'Alternate Phone Number',
            controller: _alternatePhoneController,
            icon: Icons.phone_android,
            hint: 'Alternative contact number',
            keyboardType: TextInputType.phone,
            isMobile: isMobile,
            isOptional: true,
          ),
          const SizedBox(height: 20),

          // Preferred Date & Time
          _buildPreferredDateTimePicker(context, isMobile: isMobile),
          const SizedBox(height: 24),

          // Attachments Section
          _buildAttachmentsSection(context),

          const SizedBox(height: 32),

          // Action Button
          _buildSubmitButton(context, isLoading),
        ],
      ),
    );
  }

  Widget _buildVillaSelector(
    BuildContext context, {
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        final bloc = context.read<MaintenanceTicketBloc>();
        // Use state villas if available (most recent), otherwise use cached
        List<VillaEntity> villas = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is MaintenanceTicketLoading) {
          isLoading = true;
          // Keep showing cached villas while loading, but filter by current site
          villas = bloc.cachedVillas;
        } else if (state is VillasLoaded) {
          // Use the newly loaded villas from state (already filtered by siteId in API)
          villas = state.villas;
        } else if (state is MaintenanceTicketError) {
          errorMessage = state.message;
          // Keep showing cached villas on error, but filter by current site
          villas = bloc.cachedVillas;
        } else {
          // Initial state - use cached if available
          villas = bloc.cachedVillas;
        }

        // Filter villas by selected siteId on frontend
        // Note: API already filters, but cached villas might have all villas
        // So we filter again to ensure we only show villas for selected site
        if (_selectedSiteId != null && _selectedSiteId!.isNotEmpty) {
          final beforeFilter = villas.length;
          if (beforeFilter > 0) {
            // Debug: Log sample villa siteIds before filtering
            final sampleVilla = villas.first;
            debugPrint(
                '🏠 [Villa Filter] Before filter - Sample villa siteId: ${sampleVilla.siteId}, Selected siteId: $_selectedSiteId');
            final uniqueSiteIds =
                villas.map((v) => v.siteId).whereType<String>().toSet();
            debugPrint(
                '🏠 [Villa Filter] Unique siteIds in villas list: $uniqueSiteIds');

            // Check if all villas have null siteId
            final villasWithNullSiteId = villas
                .where((v) => v.siteId == null || v.siteId!.isEmpty)
                .length;

            // If all villas have null siteId, don't filter (show all villas)
            // This handles cases where backend data is incomplete but admin still needs to work
            if (villasWithNullSiteId == beforeFilter) {
              debugPrint(
                  '⚠️ [Villa Filter] All villas have null siteId - showing all ${beforeFilter} villas (data may be incomplete)');
              // Don't filter - show all villas
            } else {
              // Filter normally
              villas = villas
                  .where((villa) => villa.siteId == _selectedSiteId)
                  .toList();
              debugPrint(
                '🏠 [Villa Filter] Filtered ${beforeFilter} villas by siteId $_selectedSiteId -> ${villas.length} villas',
              );
              if (villas.isEmpty && beforeFilter > 0) {
                debugPrint(
                    '⚠️ [Villa Filter] No villas matched siteId $_selectedSiteId after filtering');
              }
            }
          }
        }

        // Auto-load villas if empty and not loading
        // Only load once per site selection to prevent infinite loops
        // Don't retry if there's an error (let user manually retry)
        final shouldLoad = villas.isEmpty &&
            !isLoading &&
            errorMessage == null &&
            (!_hasAttemptedVillaLoad ||
                _lastVillaLoadSiteId != _selectedSiteId);
        if (shouldLoad) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasAttemptedVillaLoad = true;
                _lastVillaLoadSiteId = _selectedSiteId;
              });
              bloc.add(LoadVillas(siteId: _selectedSiteId));
            }
          });
        }

        // Filter villas by selected tenant's villa number if tenant is selected
        // This is a convenience filter - if no matches, show all villas (admin can still assign)
        // Note: We only filter if villas are already loaded (not empty)
        if (_selectedTenantId != null &&
            _tenants.isNotEmpty &&
            villas.isNotEmpty &&
            !isLoading) {
          final selectedTenant = _tenants.firstWhere(
            (t) => t.id == _selectedTenantId,
            orElse: () => _tenants.first,
          );

          debugPrint('🏠 [Villa Filter] Tenant: ${selectedTenant.email}');
          debugPrint(
              '🏠 [Villa Filter] Tenant villaNumber: ${selectedTenant.villaNumber}');
          debugPrint(
              '🏠 [Villa Filter] Tenant villas count: ${selectedTenant.villas.length}');
          debugPrint(
              '🏠 [Villa Filter] Available villas before filter: ${villas.length}');

          // Check both villaNumber and villas array
          final Set<String> tenantVillaNumbers = <String>{};

          // Add single villaNumber if present
          if (selectedTenant.villaNumber != null &&
              selectedTenant.villaNumber!.isNotEmpty) {
            tenantVillaNumbers.add(selectedTenant.villaNumber!);
            debugPrint(
                '🏠 [Villa Filter] Added villaNumber: ${selectedTenant.villaNumber}');
          }

          // Add villas from villas array
          for (final villa in selectedTenant.villas) {
            if (villa.villaNumber.isNotEmpty) {
              tenantVillaNumbers.add(villa.villaNumber);
              debugPrint(
                  '🏠 [Villa Filter] Added villa from array: ${villa.villaNumber}');
            }
          }

          if (tenantVillaNumbers.isNotEmpty) {
            // Store original villas list before filtering (for fallback)
            final originalVillas = List<VillaEntity>.from(villas);

            // Filter villas by tenant's villa numbers
            // Match on both villaNumber and villaCode (some villas use code instead)
            final originalCount = villas.length;
            final matchedVillas = villas.where((villa) {
              // Try matching on villaNumber (exact match, case-insensitive)
              bool matchesNumber = false;
              if (villa.villaNumber != null && villa.villaNumber!.isNotEmpty) {
                final villaNum = villa.villaNumber!.trim();
                matchesNumber = tenantVillaNumbers.any((tenantVilla) {
                  final normalizedTenant = tenantVilla.trim();
                  final normalizedVilla = villaNum;
                  // Exact match
                  if (normalizedVilla == normalizedTenant) return true;
                  // Case-insensitive match
                  if (normalizedVilla.toLowerCase() ==
                      normalizedTenant.toLowerCase()) return true;
                  // Remove common prefixes/suffixes and compare
                  final cleanVilla = normalizedVilla
                      .replaceAll(RegExp(r'^[Vv]illa\s*'), '')
                      .trim();
                  final cleanTenant = normalizedTenant
                      .replaceAll(RegExp(r'^[Vv]illa\s*'), '')
                      .trim();
                  if (cleanVilla == cleanTenant) return true;
                  return false;
                });
              }

              // Try matching on villaCode (normalize by removing "Villa " prefix if present)
              bool matchesCode = false;
              if (!matchesNumber &&
                  villa.villaCode != null &&
                  villa.villaCode!.isNotEmpty) {
                final normalizedCode = villa.villaCode!
                    .replaceAll(RegExp(r'^Villa\s+', caseSensitive: false), '')
                    .trim();
                matchesCode = tenantVillaNumbers.any((tenantVilla) {
                  final normalizedTenant = tenantVilla.trim();
                  // Exact match
                  if (normalizedCode == normalizedTenant) return true;
                  // Case-insensitive match
                  if (normalizedCode.toLowerCase() ==
                      normalizedTenant.toLowerCase()) return true;
                  // Contains match
                  if (normalizedCode.contains(normalizedTenant) ||
                      normalizedTenant.contains(normalizedCode)) return true;
                  return false;
                });
              }

              // Also try reverse matching: check if tenant villa number is in villa code
              bool matchesReverse = false;
              if (!matchesNumber &&
                  !matchesCode &&
                  villa.villaCode != null &&
                  villa.villaCode!.isNotEmpty) {
                matchesReverse = tenantVillaNumbers.any((tenantVilla) {
                  // Remove "V-" prefix for comparison
                  final normalizedTenant = tenantVilla
                      .replaceAll(RegExp(r'^V-?', caseSensitive: false), '')
                      .trim();
                  final normalizedCode = villa.villaCode!.toLowerCase().trim();
                  return normalizedCode
                          .contains(normalizedTenant.toLowerCase()) ||
                      normalizedTenant.toLowerCase().contains(normalizedCode);
                });
              }

              final matches = matchesNumber || matchesCode || matchesReverse;
              if (matches) {
                debugPrint(
                    '🏠 [Villa Filter] ✅ Matched villa: ${villa.displayName} (villaNumber=${villa.villaNumber}, villaCode=${villa.villaCode})');
              }
              return matches;
            }).toList();

            debugPrint(
                '🏠 [Villa Filter] Filtered from $originalCount to ${matchedVillas.length} villas');
            debugPrint(
                '🏠 [Villa Filter] Tenant villa numbers: $tenantVillaNumbers');

            // If we found matches, use them; otherwise show all villas (admin can still assign)
            if (matchedVillas.isNotEmpty) {
              villas = matchedVillas;
              debugPrint(
                  '🏠 [Villa Filter] Matched villa numbers: ${villas.map((v) => v.villaNumber).toList()}');
              debugPrint(
                  '🏠 [Villa Filter] Matched villa codes: ${villas.map((v) => v.villaCode).toList()}');

              // Auto-select if only one villa matches
              if (villas.length == 1) {
                final matchedVilla = villas.first;
                if (_selectedVillaNumber != matchedVilla.villaNumber) {
                  debugPrint(
                      '🏠 [Villa Filter] Auto-selecting villa: ${matchedVilla.villaNumber}');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedVillaNumber = matchedVilla.villaNumber;
                      });
                    }
                  });
                }
              }
            } else {
              // No matches found - show all villas so admin can still assign
              // This is better than showing "No villas assigned" which blocks the admin
              debugPrint(
                  '⚠️ [Villa Filter] No villas matched tenant villa numbers - showing all villas');
              debugPrint('⚠️ [Villa Filter] Tenant has: $tenantVillaNumbers');
              // Keep villas as originalVillas (already filtered by site if site is selected)
              villas = originalVillas;
            }
          }
          // If tenant has no villa numbers, show all villas (admin can assign)
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Villa',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedVillaNumber,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: villas.isEmpty
                    ? isLoading
                        ? 'Loading villas...'
                        : _selectedSiteId != null && _selectedSiteId!.isNotEmpty
                            ? 'No villas available for this site'
                            : 'No villas available'
                    : 'Select Villa',
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : villas.isEmpty
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              bloc.add(LoadVillas(siteId: _selectedSiteId));
                            },
                            tooltip: 'Load villas',
                          )
                        : null,
              ),
              items: villas.isEmpty
                  ? [
                      DropdownMenuItem<String>(
                        value: null,
                        enabled: false,
                        child: Text(
                          isLoading
                              ? 'Loading villas...'
                              : _selectedSiteId != null &&
                                      _selectedSiteId!.isNotEmpty
                                  ? 'No villas available for this site'
                                  : 'No villas available',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ]
                  : villas
                      .map(
                        (villa) => DropdownMenuItem<String>(
                          value: villa.villaNumber ?? '',
                          child: Text(
                            villa.displayName,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      )
                      .toList(),
              onChanged: villas.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _villaFieldTouched = true;
                        if (value != null) {
                          _selectedVillaNumber = value;
                        }
                      });
                    },
            ),
            // Only show error if form has been submitted or field has been touched
            if (_selectedVillaNumber == null &&
                (_hasAttemptedSubmit || _villaFieldTouched))
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 14,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Villa is required',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSiteSelector(
    BuildContext context, {
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<MaintenanceTicketBloc, MaintenanceTicketState>(
      builder: (context, state) {
        final bloc = context.read<MaintenanceTicketBloc>();
        List<SiteEntity> sites = bloc.cachedSites;
        bool isLoading = false;

        if (state is MaintenanceTicketLoading) {
          isLoading = true;
        } else if (state is SitesLoaded) {
          sites = state.sites;
        }

        // Auto-load sites if empty
        if (sites.isEmpty && !isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (bloc.cachedSites.isEmpty) {
              bloc.add(const LoadSites());
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Site',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(Optional)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSiteId,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Select Site',
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : sites.isEmpty
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              bloc.add(const LoadSites());
                            },
                            tooltip: 'Load sites',
                          )
                        : null,
              ),
              items: sites.isEmpty
                  ? [
                      DropdownMenuItem<String>(
                        value: null,
                        enabled: false,
                        child: Text(
                          'No sites available',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ]
                  : [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'None (All Sites)',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...sites.map(
                        (site) => DropdownMenuItem<String>(
                          value: site.id,
                          child: Text(
                            site.displayName,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
              onChanged: sites.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _selectedSiteId = value;
                        // Reset villa load tracking when site changes to force reload
                        _hasAttemptedVillaLoad = false;
                        _lastVillaLoadSiteId = null;
                        // Clear villa selection when site changes to avoid mismatched villa/site
                        _selectedVillaNumber = null;
                      });
                      // Immediately reload villas when site changes
                      // This ensures we get fresh data for the new site
                      debugPrint(
                          '🏠 [Site Change] Loading villas for siteId: $value');
                      context.read<MaintenanceTicketBloc>().add(
                            LoadVillas(siteId: value),
                          );
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTenantSelector(
    BuildContext context, {
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Tenant',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoadingTenants)
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading tenants...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          )
        else if (_tenantsError != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tenantsError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadTenants,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedTenantId,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Select Tenant (Optional)',
              suffixIcon: _tenants.isEmpty
                  ? IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadTenants,
                      tooltip: 'Load tenants',
                    )
                  : null,
            ),
            items: _tenants.isEmpty
                ? [
                    DropdownMenuItem<String>(
                      value: null,
                      enabled: false,
                      child: Text(
                        'No tenants available',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ]
                : [
                    // Add "None" option to clear selection
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'None (All Villas)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ..._tenants.map(
                      (tenant) => DropdownMenuItem<String>(
                        value: tenant.id,
                        child: Text(
                          _getTenantDisplayName(tenant),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
            onChanged: (value) {
              setState(() {
                _selectedTenantId = value;
                // Clear villa selection when tenant changes
                _selectedVillaNumber = null;
                // Reset villa load tracking when tenant changes (to allow re-filtering)
                _hasAttemptedVillaLoad = false;
                _lastVillaLoadSiteId = null;
              });
              // Reload villas when tenant changes to ensure we have fresh data
              // The tenant filtering will happen on the frontend after villas are loaded
              final bloc = context.read<MaintenanceTicketBloc>();
              // Only reload if villas haven't been loaded yet, or if site changed
              if (bloc.cachedVillas.isEmpty ||
                  _lastVillaLoadSiteId != _selectedSiteId) {
                bloc.add(LoadVillas(siteId: _selectedSiteId));
              }
            },
          ),
      ],
    );
  }

  String _getTenantDisplayName(UserEntity tenant) {
    final nameParts = <String>[];
    if (tenant.firstName != null && tenant.firstName!.isNotEmpty) {
      nameParts.add(tenant.firstName!);
    }
    if (tenant.lastName != null && tenant.lastName!.isNotEmpty) {
      nameParts.add(tenant.lastName!);
    }
    final name = nameParts.isNotEmpty ? nameParts.join(' ') : tenant.email;
    if (tenant.villaNumber != null && tenant.villaNumber!.isNotEmpty) {
      // Extract just the number part, removing prefixes like "V-", "Villa ", etc.
      final numberMatch = RegExp(r'\d+').firstMatch(tenant.villaNumber!);
      final villaNumber =
          numberMatch != null ? numberMatch.group(0)! : tenant.villaNumber!;
      return '$name ($villaNumber)';
    }
    return name;
  }

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    required bool isMobile,
    int? maxLength,
    bool showCounter = false,
    bool isOptional = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Text(
                '(Optional)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          buildCounter: showCounter
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$currentLength / $maxLength characters',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
              : null,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDescriptionWithAiButton(
    BuildContext context, {
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAiServiceAvailable = getIt.isRegistered<AiTicketServiceInterface>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the card (optional, or part of the card? Design shows it inside)
        // Design has "DESCRIPTION" small header outside, but the card starts with "What needs maintenance?"
        Text(
          'DESCRIPTION',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),

        // MAIN CARD CONTAINER - Enhanced Design
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TEXT FIELD - Enhanced styling
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 8,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe the issue in your own words...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    height: 1.5,
                  ),
                  filled: true,
                  fillColor:
                      colorScheme.surfaceContainerLow.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // update counter
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the issue';
                  } else if (value.trim().length < 10) {
                    return 'Please provide more details (min 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // FOOTER: Actions + Counter - Enhanced layout
              Row(
                children: [
                  // AI Fill Button - Enhanced styling
                  if (isAiServiceAvailable)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isAiAnalyzing ? null : _triggerAiAnalysis,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _isAiAnalyzing
                                ? colorScheme.primaryContainer
                                    .withValues(alpha: 0.5)
                                : colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isAiAnalyzing)
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                )
                              else ...[
                                Icon(
                                  Icons.auto_fix_high,
                                  size: 16,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Fill',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Voice Button - Hidden

                  const Spacer(),

                  // Character Counter - Enhanced styling
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_descriptionController.text.length} / 500',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // HELPER TEXT & ERROR MESSAGE
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_descriptionError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _descriptionError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'AI can help expand short notes into clear maintenance requests.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(
    BuildContext context, {
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Category',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CategorySelectorWidget(
          selectedCategoryId: _selectedCategoryId,
          onChanged: (categoryId) {
            setState(() {
              _selectedCategoryId = categoryId;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreferredDateTimePicker(
    BuildContext context, {
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time_filled,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Preferred Visit Schedule',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Let us know when you are available for the technician to visit.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Date Picker
        _buildDatePicker(context),
        const SizedBox(height: 16),

        // Time Range Pickers
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTimePickerField(
                context,
                label: 'From',
                time: _preferredStartTime,
                onTap: () => _pickTime(context, isStartTime: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimePickerField(
                context,
                label: 'To',
                time: _preferredEndTime,
                onTap: () => _pickTime(context, isStartTime: false),
              ),
            ),
          ],
        ),
        if (_preferredStartTime != null && _preferredEndTime != null) ...[
          const SizedBox(height: 8),
          // Validation error or confirmation
          Builder(
            builder: (context) {
              final startDouble = _preferredStartTime!.hour +
                  _preferredStartTime!.minute / 60.0;
              final endDouble =
                  _preferredEndTime!.hour + _preferredEndTime!.minute / 60.0;

              if (endDouble <= startDouble) {
                return Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'End time must be after start time',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateText = _preferredDate != null
        ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
        : 'Select Date';

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _preferredDate ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: colorScheme.copyWith(
                  primary: colorScheme.primary, // Header background color
                  onPrimary: colorScheme.onPrimary, // Header text color
                  surface: colorScheme.surface, // Background color
                  onSurface: colorScheme.onSurface, // Text color
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _preferredDate = picked;
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _preferredDate != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
    BuildContext context, {
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time != null ? time.format(context) : 'Select',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: time != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context, {
    required bool isStartTime,
  }) async {
    final now = TimeOfDay.now();
    final initial = isStartTime
        ? (_preferredStartTime ?? now)
        : (_preferredEndTime ??
            (_preferredStartTime != null
                ? TimeOfDay(
                    hour: (_preferredStartTime!.hour + 1) % 24,
                    minute: _preferredStartTime!.minute,
                  )
                : now));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: colorScheme.surface,
              dialHandColor: colorScheme.primary,
              dialBackgroundColor: colorScheme.surfaceContainerHighest,
              hourMinuteTextColor: colorScheme.onSurface,
              dayPeriodTextColor: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _preferredStartTime = picked;
          // Auto-adjust end time if it becomes invalid or unset
          _preferredEndTime ??=
              TimeOfDay(hour: (picked.hour + 1) % 24, minute: picked.minute);
        } else {
          _preferredEndTime = picked;
        }
      });
    }
  }

  Widget _buildAttachmentsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ATTACHMENTS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: FontWeight.normal,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Photos',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImages.isNotEmpty)
                    Text(
                      '${_selectedImages.length} selected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 130, // Increased height
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  // Removed clipBehavior: Clip.none to prevent horizontal bleeding
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
                  itemCount: _selectedImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildAddImageButton(context);
                    }
                    final file = _selectedImages[index - 1];
                    return _buildImageThumbnail(context, file, index - 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showImageSourceDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surfaceContainerLow,
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Photo',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(
    BuildContext context,
    PlatformFile file,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showImagePreview(context, index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              ),
              image: DecorationImage(
                image: kIsWeb
                    ? MemoryImage(file.bytes!)
                    : FileImage(File(file.path!)) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: InkWell(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, int initialIndex) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => _ImagePreviewDialog(
        images: _selectedImages,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: isLoading ? () {} : _submitComplaint,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 22),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.onPrimary,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome),
                SizedBox(width: 10),
                Text(
                  'Create Ticket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
    );
  }
}

// Image Preview Dialog with Zoom and Carousel
class _ImagePreviewDialog extends StatefulWidget {
  final List<PlatformFile> images;
  final int initialIndex;

  const _ImagePreviewDialog({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Image viewer with zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _resetZoom();
              });
            },
            itemBuilder: (context, index) {
              final file = widget.images[index];
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: kIsWeb
                      ? Image.memory(
                          file.bytes!,
                          fit: BoxFit.contain,
                        )
                      : Image.file(
                          File(file.path!),
                          fit: BoxFit.contain,
                        ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Image counter
          if (widget.images.length > 1)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

          // Navigation arrows (only if more than 1 image)
          if (widget.images.length > 1) ...[
            // Left arrow
            if (_currentIndex > 0)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // Right arrow
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
