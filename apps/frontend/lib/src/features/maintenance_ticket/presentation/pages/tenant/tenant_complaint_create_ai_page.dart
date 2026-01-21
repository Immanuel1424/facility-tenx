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
import '../../bloc/tenant_villa_cubit.dart';
import '../../../domain/repositories/maintenance_ticket_repository_interface.dart';
import '../../../domain/services/ai_ticket_service_interface.dart';
import '../../widgets/category_selector_widget.dart';
import '../../../data/services/s3_upload_service.dart';
import '../../../../../core/utils/image_validation.dart';
import '../../../../../core/utils/image_compression.dart';

class TenantComplaintCreateAiPage extends StatelessWidget {
  const TenantComplaintCreateAiPage({super.key});

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
        BlocProvider<TenantVillaCubit>(
          create: (context) {
            final cubit = TenantVillaCubit(
              ticketRepository: getIt<MaintenanceTicketRepositoryInterface>(),
            );
            cubit.loadVillas();
            return cubit;
          },
        ),
      ],
      child: const _TenantComplaintCreateAiContent(),
    );
  }
}

class _TenantComplaintCreateAiContent extends StatefulWidget {
  const _TenantComplaintCreateAiContent();

  @override
  State<_TenantComplaintCreateAiContent> createState() =>
      _TenantComplaintCreateAiContentState();
}

class _TenantComplaintCreateAiContentState
    extends State<_TenantComplaintCreateAiContent>
    with SingleTickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<PlatformFile> _selectedImages = [];

  // Per-image upload progress tracking
  final Map<int, ImageUploadProgress> _uploadProgress = {};

  // Image validation errors
  final Map<int, String> _imageValidationErrors = {};

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

  @override
  void initState() {
    super.initState();
    // Voice feature initialization removed - feature is hidden

    // Load categories on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MaintenanceTicketBloc>().add(const LoadCategories());
      }
    });
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
        // Validate images before adding
        final validFiles = <PlatformFile>[];
        final validationErrors = <String>[];

        for (final file in result.files) {
          // Quick validation (fast check)
          final quickValidation = ImageValidation.quickValidate(file);
          if (!quickValidation.isValid) {
            validationErrors.add('${file.name}: ${quickValidation.error}');
            continue;
          }

          // Full validation (async, checks dimensions)
          final fullValidation = await ImageValidation.validateImage(file);
          if (!fullValidation.isValid) {
            validationErrors.add('${file.name}: ${fullValidation.error}');
            continue;
          }

          validFiles.add(file);
        }

        setState(() {
          _selectedImages.addAll(validFiles);
          // Clear validation errors for new images
          _imageValidationErrors.clear();
        });

        // Show validation errors if any
        if (validationErrors.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Some images were rejected:\n${validationErrors.join('\n')}',
                maxLines: 5,
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }

        // Show success message if valid images were added
        if (validFiles.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${validFiles.length} image(s) added successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
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
      PlatformFile? platformFile;

      if (kIsWeb) {
        platformFile = await camera_web.pickImageFromCamera();
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        platformFile = result?.files.firstOrNull;
      }

      if (platformFile != null && mounted) {
        // Validate image before adding
        final validation = await ImageValidation.validateImage(platformFile);
        if (!validation.isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid image: ${validation.error}'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        setState(() {
          _selectedImages.add(platformFile!);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
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
      _uploadProgress.remove(index);
      _imageValidationErrors.remove(index);
      // Reindex progress map
      final newProgress = <int, ImageUploadProgress>{};
      _uploadProgress.forEach((key, value) {
        if (key < index) {
          newProgress[key] = value;
        } else if (key > index) {
          newProgress[key - 1] = value;
        }
      });
      _uploadProgress.clear();
      _uploadProgress.addAll(newProgress);
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tenantVillaState = context.read<TenantVillaCubit>().state;
    final String? villaNumber = tenantVillaState.activeVilla?.villaNumber;

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
          ConfirmAiAnalysisTicket(
            title: title,
            description: description,
            categoryId: _selectedCategoryId,
            category: _selectedCategoryId == null
                ? 'MISCELLANEOUS'
                : null, // Will be resolved by backend if categoryId provided
            priority: _selectedPriority,
            // Use active villa from multi-villa selector
            villaNumber: villaNumber,
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
            // Use active villa for AI-based quick creation as well.
            villaNumber:
                context.read<TenantVillaCubit>().state.activeVilla?.villaNumber,
            contactNumber: null, // Using alternate phone field instead
          ),
        );
  }

  /// Retry uploading a single image
  Future<void> _retryImageUpload(BuildContext context, int index) async {
    if (index >= _selectedImages.length) return;

    final ticketId = _currentTicketId;
    if (ticketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket ID not available. Please create ticket first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if S3UploadService is registered
    if (!getIt.isRegistered<S3UploadService>()) {
      debugPrint('❌ S3UploadService is not registered in GetIt');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Upload service not available. Please restart the app.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final file = _selectedImages[index];
    final s3UploadService = getIt<S3UploadService>();

    setState(() {
      _uploadProgress[index] = const ImageUploadProgress(
        status: ImageUploadStatus.retrying,
        retryCount: 1,
      );
    });

    try {
      final result = await s3UploadService.uploadImageToS3(
        ticketId,
        file,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              _uploadProgress[index] = ImageUploadProgress(
                status: ImageUploadStatus.uploading,
                progress: sent / total,
              );
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          if (result.success) {
            _uploadProgress[index] = ImageUploadProgress(
              status: ImageUploadStatus.success,
              progress: 1.0,
              attachmentId: result.attachmentId,
            );
          } else {
            final currentProgress = _uploadProgress[index];
            _uploadProgress[index] = ImageUploadProgress(
              status: ImageUploadStatus.failed,
              error: result.error,
              retryCount: (currentProgress?.retryCount ?? 0) + 1,
            );
          }
        });

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${result.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final currentProgress = _uploadProgress[index];
          _uploadProgress[index] = ImageUploadProgress(
            status: ImageUploadStatus.failed,
            error: e.toString(),
            retryCount: (currentProgress?.retryCount ?? 0) + 1,
          );
        });
      }
    }
  }

  String? _currentTicketId;

  /// Upload images after ticket creation using S3 direct upload
  Future<void> _uploadImages(String ticketId, BuildContext context) async {
    _currentTicketId = ticketId;
    if (_selectedImages.isEmpty) return;

    // Check if S3UploadService is registered
    if (!getIt.isRegistered<S3UploadService>()) {
      debugPrint('❌ S3UploadService is not registered in GetIt');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Upload service not available. Please restart the app.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final s3UploadService = getIt<S3UploadService>();
    final colorScheme = Theme.of(context).colorScheme;

    // Initialize progress tracking
    setState(() {
      for (var i = 0; i < _selectedImages.length; i++) {
        _uploadProgress[i] = const ImageUploadProgress(
          status: ImageUploadStatus.pending,
        );
      }
    });

    try {
      final results = await s3UploadService.uploadMultipleImagesWithRetry(
        ticketId,
        _selectedImages,
        onProgress: (index, progress) {
          if (mounted) {
            setState(() {
              _uploadProgress[index] = progress;
            });
          }
        },
        compressionConfig: const ImageCompressionConfig(
          maxWidth: 1920,
          maxHeight: 1920,
          quality: 85,
          maxFileSizeKB: 2048,
        ),
        validationConfig: const ImageValidationConfig(
          maxFileSizeMB: 10,
          maxWidth: 4096,
          maxHeight: 4096,
        ),
      );

      // Count successes and failures
      final successCount = results.where((r) => r.success).length;
      final failureCount = results.length - successCount;

      if (!context.mounted) return;

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
        // Show detailed error for failed uploads
        final failedFiles = <String>[];
        for (var i = 0; i < results.length; i++) {
          if (!results[i].success) {
            failedFiles.add(
              '${_selectedImages[i].name}: ${results[i].error ?? 'Unknown error'}',
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ $successCount uploaded, $failureCount failed',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (failedFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...failedFiles.take(3).map(
                        (error) => Text(
                          '• $error',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  if (failedFiles.length > 3)
                    Text(
                      '... and ${failedFiles.length - 3} more',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
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
                  debugPrint(
                      '📤 Starting image upload for ticket ${ticket.id}...');
                  await _uploadImages(ticket.id, context);
                  debugPrint(
                      '✅ Image upload completed for ticket ${ticket.id}');
                } else {
                  debugPrint('ℹ️ No images to upload for ticket ${ticket.id}');
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
                debugPrint('⚠️ Error during ticket creation flow: $e');
              } finally {
                // Small delay to ensure uploads complete before navigation
                if (_selectedImages.isNotEmpty) {
                  await Future<void>.delayed(const Duration(milliseconds: 500));
                }
                if (context.mounted) {
                  context.pop();
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
        return Scaffold(
          // Use standard scaffold background from app theme (no custom gradient)
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            // Default Material 3 AppBar color from theme
            elevation: 0,
            leading: BackButton(
              color: Colors.white,
            ),
            title: const Text(
              'Create New Ticket',
            ),
          ),
          body: ResponsiveLayout(
            mobileBuilder: (context) => _buildMobileLayout(context, state),
            desktopBuilder: (context) => _buildDesktopLayout(context, state),
          ),
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

    // Simple centered card using default scaffold background (no custom gradient/orbs)
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

    // Use default scaffold background; just layout content with SafeArea
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
          // Villa selector (multi-villa aware tenants)
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

    return BlocBuilder<TenantVillaCubit, TenantVillaState>(
      builder: (context, state) {
        // Show loading state
        if (state.status == TenantVillaStatus.loading && state.villas.isEmpty) {
          return Row(
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
                'Loading your villas...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }

        // Show error state with retry option
        if (state.status == TenantVillaStatus.failure && state.villas.isEmpty) {
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
                    'Select Villa',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to load villas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        context.read<TenantVillaCubit>().loadVillas();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Hide if initial state (before first load attempt)
        if (state.status == TenantVillaStatus.initial) {
          return const SizedBox.shrink();
        }

        final villas = state.villas;
        final activeVilla =
            state.activeVilla ?? (villas.isNotEmpty ? villas.first : null);

        // If we have villas but no active villa, use first one
        if (activeVilla == null && villas.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<TenantVillaCubit>().selectVilla(villas.first);
          });
          return const SizedBox.shrink();
        }

        // If no villas after successful load, hide selector
        if (villas.isEmpty && state.status == TenantVillaStatus.success) {
          return const SizedBox.shrink();
        }

        // If no active villa and no villas, hide
        if (activeVilla == null) {
          return const SizedBox.shrink();
        }

        final hasMultiple = villas.length > 1;

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
                  hasMultiple ? 'Select Villa' : 'Villa',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!hasMultiple)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Villa ${activeVilla.villaNumber}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: activeVilla.villaNumber,
                decoration: InputDecoration(
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: villas
                    .map(
                      (villa) => DropdownMenuItem<String>(
                        value: villa.villaNumber,
                        child: Text(
                          'Villa ${villa.villaNumber}',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  final selected = villas.firstWhere(
                    (villa) => villa.villaNumber == value,
                    orElse: () => activeVilla,
                  );
                  context.read<TenantVillaCubit>().selectVilla(selected);
                },
              ),
          ],
        );
      },
    );
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
    final progress = _uploadProgress[index];
    final hasProgress = progress != null;

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
                color:
                    hasProgress && progress.status == ImageUploadStatus.failed
                        ? colorScheme.error
                        : hasProgress &&
                                progress.status == ImageUploadStatus.success
                            ? Colors.green
                            : colorScheme.outline,
                width: hasProgress &&
                        (progress.status == ImageUploadStatus.failed ||
                            progress.status == ImageUploadStatus.success)
                    ? 2
                    : 1,
              ),
              image: DecorationImage(
                image: kIsWeb
                    ? MemoryImage(file.bytes!)
                    : FileImage(File(file.path!)) as ImageProvider,
                fit: BoxFit.cover,
                colorFilter: hasProgress &&
                        progress.status == ImageUploadStatus.uploading
                    ? ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.3),
                        BlendMode.darken,
                      )
                    : null,
              ),
            ),
            // Upload progress overlay
            child: hasProgress &&
                    (progress.status == ImageUploadStatus.uploading ||
                        progress.status == ImageUploadStatus.retrying)
                ? Stack(
                    children: [
                      // Progress bar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: LinearProgressIndicator(
                            value: progress.progress,
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress.status == ImageUploadStatus.retrying
                                  ? Colors.orange
                                  : colorScheme.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      // Status indicator
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: progress.status == ImageUploadStatus.retrying
                              ? Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: Colors.orange,
                                )
                              : SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          // Success indicator
          if (hasProgress && progress.status == ImageUploadStatus.success)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          // Error indicator with retry
          if (hasProgress && progress.status == ImageUploadStatus.failed)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Failed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (progress.retryCount < S3UploadService.maxRetries) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => _retryImageUpload(context, index),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: colorScheme.primary,
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
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
