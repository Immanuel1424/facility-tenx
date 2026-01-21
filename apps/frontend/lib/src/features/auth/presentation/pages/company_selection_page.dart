import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:dio/dio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/standard_button.dart';
import '../../../../core/widgets/standard_text_field.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/company_id_storage.dart';
import '../../../maintenance_ticket/data/dto/maintenance_ticket_dto.dart';

class CompanySelectionPage extends StatefulWidget {
  const CompanySelectionPage({super.key});

  @override
  State<CompanySelectionPage> createState() => _CompanySelectionPageState();
}

class _CompanySelectionPageState extends State<CompanySelectionPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  int _currentSlideIndex = 0;
  late PageController _pageController;

  // New state for 2-step flow
  List<SiteDto> _availableSites = [];
  String? _resolvedCompanyId;
  String? _resolvedCompanyName;
  bool _isCompanyVerified = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Auto-advance slides every 4 seconds
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _pageController.hasClients) {
        _currentSlideIndex = (_currentSlideIndex + 1) % 3;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startAutoSlide();
      }
    });
  }

  void _resetVerification() {
    setState(() {
      _availableSites = [];
      _resolvedCompanyId = null;
      _resolvedCompanyName = null;
      _isCompanyVerified = false;
      _formKey.currentState?.fields['siteCode']?.didChange(null);
    });
  }

  Future<void> _handleAction() async {
    if (_isCompanyVerified && _availableSites.isNotEmpty) {
      await _completedSelection();
    } else {
      await _verifyCompany();
    }
  }

  Future<void> _verifyCompany() async {
    // Save the form to get current values
    _formKey.currentState?.save();

    // Validate only companyId field
    final companyField = _formKey.currentState?.fields['companyId'];
    if (companyField == null || !companyField.validate()) {
      return;
    }

    final rawCompanyCode = companyField.value as String? ?? '';
    final companyCodeInput = rawCompanyCode.trim();

    // Additional validation: reject UUID format
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (uuidPattern.hasMatch(companyCodeInput)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Invalid company code. Please check and try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = getIt<ApiClient>();

      // Special handling for SYSTEM company code
      if (companyCodeInput.toUpperCase() == 'SYSTEM' ||
          companyCodeInput.toUpperCase() == 'SUPER_ADMIN') {
        await CompanyIdStorage.saveCompanyId('SYSTEM');
        if (!mounted) return;
        context.go(
          '/login?companyId=SYSTEM&companyName=${Uri.encodeComponent("System Administration")}&siteId=&siteCode=SYSTEM',
        );
        return;
      }

      // 1. Resolve Company
      final companies = await apiClient.getPublicCompanies();
      final matchingCompany = companies.where(
        (CompanyDto c) {
          final code = c.code;
          if (code == null) {
            return false;
          }
          final normalizedCode = code.toLowerCase().trim();
          final normalizedInput = companyCodeInput.toLowerCase();
          return normalizedCode == normalizedInput;
        },
      );

      if (matchingCompany.isEmpty) {
        throw Exception('Invalid company code');
      }

      final company = matchingCompany.first;
      final resolvedCompanyUuid = company.id;

      if (resolvedCompanyUuid == null || resolvedCompanyUuid.isEmpty) {
        throw Exception('Resolved company ID is invalid');
      }

      // 2. Fetch Sites
      print('🔍 Fetching public sites for company: $resolvedCompanyUuid');
      final sites =
          await apiClient.getPublicSites(companyId: resolvedCompanyUuid);
      print('✅ Fetched ${sites.length} sites');

      if (sites.isEmpty) {
        throw Exception('No sites found for this company.');
      }

      setState(() {
        _resolvedCompanyId = resolvedCompanyUuid;
        _resolvedCompanyName = company.name;
        _availableSites = sites;
        _isCompanyVerified = true;
      });

      // Auto-select and navigate if only one site exists
      if (sites.length == 1) {
        final singleSite = sites.first;
        if (singleSite.id != null) {
          // Set the form field value for consistency
          _formKey.currentState?.fields['siteCode']?.didChange(singleSite.id);

          // Persist resolved company UUID
          await CompanyIdStorage.saveCompanyId(resolvedCompanyUuid);

          if (!mounted) return;

          print('🚀 Auto-selecting single site and navigating to login...');
          // Navigate directly to login
          context.go(
            '/login?companyId=${Uri.encodeComponent(resolvedCompanyUuid)}&companyName=${Uri.encodeComponent(company.name ?? "")}&siteId=${Uri.encodeComponent(singleSite.id ?? "")}&siteCode=${Uri.encodeComponent(singleSite.code ?? "")}',
          );
          return;
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      // Provide user-friendly error messages
      String errorMessage = 'An error occurred. Please try again.';
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = 'Connection timeout. Please check your internet connection and try again.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Unable to connect to server. Please ensure the backend is running and try again.';
        } else if (e.response != null) {
          errorMessage = e.response?.data?['message'] as String? ?? 
                        'Server error: ${e.response?.statusCode}';
        } else {
          errorMessage = 'Network error: ${e.message ?? "Unknown error"}';
        }
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
      _resetVerification();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completedSelection() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    final siteId = _formKey.currentState!.value['siteCode'] as String?;

    if (siteId == null || siteId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a site.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Determine selected site object
    final selectedSite = _availableSites.firstWhere(
      (s) => s.id == siteId,
      orElse: () => _availableSites.first,
    );

    // Persist resolved company UUID
    await CompanyIdStorage.saveCompanyId(_resolvedCompanyId!);

    if (!mounted) return;

    print('🚀 Navigating to login...');
    // Navigate to login
    context.go(
      '/login?companyId=${Uri.encodeComponent(_resolvedCompanyId ?? "")}&companyName=${Uri.encodeComponent(_resolvedCompanyName ?? "")}&siteId=${Uri.encodeComponent(selectedSite.id ?? "")}&siteCode=${Uri.encodeComponent(selectedSite.code ?? "")}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in Builder to ensure context is available
    // Add error boundary to catch any rendering issues
    return Builder(
      builder: (context) {
        try {
          return Scaffold(
            body: ResponsiveLayout(
              mobileBuilder: _buildMobileLayout,
              desktopBuilder: _buildDesktopLayout,
            ),
          );
        } catch (e, stackTrace) {
          // Log error for debugging
          print('❌ Error rendering CompanySelectionPage: $e');
          print('Stack trace: $stackTrace');
          
          // Return fallback UI
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading page',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please refresh the page',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Reload the page using GoRouter
                      context.go('/company-selection');
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        // Top Navigation Bar
        _buildTopNavBar(context),
        // Main Content - 3:1 Split Layout
        Expanded(
          child: Row(
            children: [
              // Left Side (3/4) - Visual Content
              Expanded(
                flex: 3,
                child: _buildLeftVisualContent(context),
              ),
              // Right Side (1/4) - Company Selection Form
              Expanded(
                flex: 1,
                child: _buildRightCompanyForm(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftVisualContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final slides = _getSiteSelectionSlides();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primaryContainer.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Slide Carousel
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSlideIndex = index;
                      });
                    },
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return _buildSlideItem(context, slide, index);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Slide Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => _buildSlideIndicator(
                      context,
                      index == _currentSlideIndex,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Welcome Text
                Text(
                  'TENX',
                  style: AppTypography.headline(context).copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 16),
                Text(
                  'Tenant Experience Layer for Residential Communities by HelixSense',
                  style: AppTypography.body(context).copyWith(
                    fontSize: 18,
                    color: colorScheme
                        .onSurfaceVariant, // Use theme color for dark mode visibility
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSiteSelectionSlides() {
    return [
      {
        'icon': Icons.location_city_rounded,
        'title': 'Multi-Site Access',
        'description': 'Manage multiple facilities from one platform',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Secure & Private',
        'description': 'Your data is protected with enterprise-grade security',
        'color': Colors.green,
      },
      {
        'icon': Icons.speed_rounded,
        'title': 'Fast & Reliable',
        'description': 'Lightning-fast performance for all your operations',
        'color': Colors.orange,
      },
    ];
  }

  Widget _buildSlideItem(
    BuildContext context,
    Map<String, dynamic> slide,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: (slide['color'] as Color).withOpacity(0.3),
                width: 3,
              ),
            ),
            child: Icon(
              slide['icon'] as IconData,
              size: 120,
              color: slide['color'] as Color,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: (index * 100).ms)
              .scale(delay: (index * 100).ms, duration: 600.ms),
          const SizedBox(height: 32),
          Text(
            slide['title'] as String,
            style: AppTypography.headline(context).copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: slide['color'] as Color,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: (index * 100 + 200).ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            slide['description'] as String,
            style: AppTypography.body(context).copyWith(
              fontSize: 18,
              color: colorScheme
                  .onSurfaceVariant, // Use theme color for dark mode visibility
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: (index * 100 + 400).ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildSlideIndicator(BuildContext context, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : colorScheme.onSurfaceVariant
                .withOpacity(0.3), // Use theme color for dark mode visibility
        borderRadius: BorderRadius.circular(4),
      ),
    ).animate(target: isActive ? 1 : 0).scale(duration: 300.ms);
  }

  Widget _buildRightCompanyForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surface, // Use theme color for dark mode support
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppLogo(context),
                const SizedBox(height: 32),
                _buildHeaderText(context),
                const SizedBox(height: 32),
                _buildCompanyCard(context),
                const SizedBox(height: 32),
                _buildPoweredBy(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Top Navigation Bar
        _buildTopNavBar(context),
        // Main Content
        Expanded(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(child: _buildLogo(context)),
                  const SizedBox(height: 24),
                  Center(child: _buildHeaderText(context)),
                  const SizedBox(height: 48),
                  _buildCompanyCard(context),
                  const SizedBox(height: 24),
                  _buildPoweredBy(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildLogo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.business_center_rounded,
        size: 48,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildAppLogo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.business_center_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'TENX',
          style: AppTypography.headline(context).copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tenant Experience Layer for Residential Communities by HelixSense',
          style: AppTypography.body(context).copyWith(
            fontSize: 12,
            color: colorScheme
                .onSurfaceVariant, // Use theme color for dark mode visibility
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHeaderText(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'Welcome',
          style: AppTypography.headline(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme
                .onSurface, // Use theme color for dark mode visibility
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter Your Company Code to Continue',
          style: AppTypography.body(context).copyWith(
            color: colorScheme
                .onSurfaceVariant, // Use theme color for dark mode visibility
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Company Code Row (Field + Edit Button)
              // Company Code Field
              // When verified, we show it as read-only with an edit icon
              StandardTextField(
                name: 'companyId',
                label: 'Company Code',
                icon: Icons.business,
                hintText: 'Enter company code (e.g., ALOS)',
                keyboardType: TextInputType.text,
                // If verified, it's read-only (not disabled) so suffix click works
                enabled: true,
                readOnly: _isCompanyVerified,
                suffixIcon: _isCompanyVerified
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Change Company',
                        onPressed: _resetVerification,
                      )
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  final trimmedValue = value.trim();
                  final uuidPattern = RegExp(
                    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                    caseSensitive: false,
                  );
                  if (uuidPattern.hasMatch(trimmedValue)) {
                    return 'Invalid format';
                  }
                  return null;
                },
              ),

              if (_isCompanyVerified) ...[
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Site',
                      style: AppTypography.label(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FormBuilderDropdown<String>(
                      name: 'siteCode',
                      decoration: InputDecoration(
                        hint: Transform.translate(
                          offset: const Offset(0, -5),
                          child: Text(
                            'Select a site',
                            style: AppTypography.body(context).copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: AppTypography.body(context).copyWith(
                        color: colorScheme.onSurface,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      items: _availableSites
                          .where((s) => s.id != null)
                          .map(
                            (site) => DropdownMenuItem(
                              value: site.id!,
                              child: Text(
                                '${site.name ?? "Unknown"} (${site.code ?? "N/A"})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
              StandardButton(
                label: _isCompanyVerified ? 'Continue' : 'Verify Company',
                onPressed: _isLoading ? null : _handleAction,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoweredBy(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        'Powered by Helixsense',
        style: AppTypography.body(context).copyWith(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant
              .withOpacity(0.7), // Use theme color for dark mode visibility
        ),
      ),
    );
  }
}
