import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/standard_button.dart';
import '../../../../core/widgets/standard_text_field.dart';
import '../../../../core/storage/company_id_storage.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.companyId,
    this.companyName,
    this.siteCode,
    this.siteId,
  });

  final String? companyId;
  final String? companyName;
  final String? siteCode;
  final String? siteId;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  int _currentSlideIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
    _checkContext();
  }

  void _checkContext() async {
    // If we don't have companyId or siteCode, redirect to company selection
    // Use addPostFrameCallback to ensure context is available for navigation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? companyId = widget.companyId;
      
      // If companyId is missing from query params, try to get it from storage
      if (companyId == null || companyId.isEmpty) {
        final storedCompanyId = await CompanyIdStorage.getCompanyId();
        if (storedCompanyId != null && storedCompanyId.isNotEmpty) {
          companyId = storedCompanyId;
          // Update the URL to include companyId for consistency
          if (mounted) {
            context.go('/login?companyId=${Uri.encodeComponent(companyId)}');
            return;
          }
        } else {
          // No companyId anywhere - redirect to company selection
          if (mounted) {
            context.go('/company-selection');
          }
          return;
        }
      }
      
      // For non-SYSTEM companies, siteCode is required
      // If missing, redirect to company-selection to allow site selection
      if (companyId != 'SYSTEM' && 
          (widget.siteCode == null || widget.siteCode!.isEmpty)) {
        // Redirect to company-selection with companyId preserved
        // This allows user to select site while preserving companyId
        if (mounted) {
          context.go('/company-selection?companyId=${Uri.encodeComponent(companyId)}');
        }
      }
    });
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = (_formKey.currentState!.value['email'] as String).trim();
      final password = _formKey.currentState!.value['password'] as String;

      // Use context from widget arguments
      // Default to 'SYSTEM' site code if logging in as SYSTEM company
      final siteCode =
          widget.siteCode ?? (widget.companyId == 'SYSTEM' ? 'SYSTEM' : '');

      if (siteCode.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Invalid session. Please select company again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior
                .floating, // Lint fix: ensure behavior is named parameter if required? No, it's valid.
          ),
        );
        context.go('/company-selection');
        return;
      }

      context.read<AuthBloc>().add(
            LoginEvent(
              siteCode: siteCode,
              email: email,
              password: password,
              companyId: widget.companyId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          authenticated: (user) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/dashboard');
              }
            });
          },
          unauthenticated: () {},
          error: (message) {
            final colorScheme = Theme.of(context).colorScheme;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: colorScheme.errorContainer,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        );
      },
      child: Scaffold(
        body: ResponsiveLayout(
          mobileBuilder: _buildMobileLayout,
          desktopBuilder: _buildDesktopLayout,
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Side (3/4) - Visual Content
        Expanded(
          flex: 3,
          child: _buildLeftVisualContent(context),
        ),
        // Right Side (1/4) - Login Form
        Expanded(
          flex: 1,
          child: _buildRightLoginForm(context),
        ),
      ],
    );
  }

  Widget _buildLeftVisualContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final slides = _getHelpdeskSlides();

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
                  'Welcome to',
                  style: AppTypography.headline(context).copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: colorScheme.onSurface.withOpacity(
                      0.9,
                    ), // Use theme color for dark mode visibility
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  'TENX',
                  style: AppTypography.headline(context).copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
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
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getHelpdeskSlides() {
    return [
      {
        'icon': Icons.support_agent_rounded,
        'title': '24/7 Support',
        'description': 'Get instant help with your maintenance requests',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.assignment_turned_in_rounded,
        'title': 'Track Tickets',
        'description': 'Monitor your maintenance tickets in real-time',
        'color': Colors.green,
      },
      {
        'icon': Icons.engineering_rounded,
        'title': 'Expert Technicians',
        'description': 'Professional technicians at your service',
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

  Widget _buildRightLoginForm(BuildContext context) {
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
                _buildMainHeading(context),
                const SizedBox(height: 32),
                _buildLoginCard(context),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildAppLogo(context),
            const SizedBox(height: 24),
            _buildMainHeading(context),
            const SizedBox(height: 24),
            _buildLoginCard(context),
            const SizedBox(height: 24),
            _buildPoweredBy(context),
            const SizedBox(height: 24),
          ],
        ),
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
            Icons.home_work_rounded,
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

  Widget _buildMainHeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome Back',
          style: AppTypography.headline(context).copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme
                .onSurface, // Use theme color for dark mode visibility
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to access your account',
          style: AppTypography.body(context).copyWith(
            color: colorScheme
                .onSurface, // Use onSurface (white) for better visibility in dark mode
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Login Header
            Text(
              'Login',
              style: AppTypography.headline(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme
                    .onSurface, // Use theme color for dark mode visibility
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Use your username and password.',
              style: AppTypography.body(context).copyWith(
                color: colorScheme
                    .onSurface, // Use onSurface (white) for better visibility in dark mode
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 24,
              child: widget.companyName != null
                  ? Text(
                      'Signing in to: ${widget.companyName}',
                      style: AppTypography.body(context).copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // Form
            _buildForm(context),
            const SizedBox(height: 24),
            // Bottom Links
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Forgot password will need siteCode from form
                  // For now, navigate without it - the forgot password page can handle it
                  if (mounted) {
                    context.push('/forgot-password');
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot password?',
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/company-selection'),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Switch Site'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StandardTextField(
            name: 'email',
            label: 'Username / Email',
            icon: Icons.person,
            hintText: 'Enter username or email',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username or email is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          StandardTextField(
            name: 'password',
            label: 'Password',
            icon: Icons.lock,
            hintText: 'Enter password',
            obscureText: _obscurePassword,
            onTogglePassword: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            onSubmitted: (_) {
              _handleLogin();
            },
            autofillHints: const [AutofillHints.password],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  ) ??
                  false;

              return StandardButton(
                label: 'Login',
                onPressed: isLoading ? null : _handleLogin,
                isLoading: isLoading,
              );
            },
          ),
        ],
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
