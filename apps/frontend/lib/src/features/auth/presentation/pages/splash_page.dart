import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/company_id_storage.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  bool _authCheckComplete = false;
  bool _minDisplayTimeElapsed = false;
  Timer? _minDisplayTimer;
  Timer? _maxWaitTimer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Ensure splash screen shows for at least 2 seconds
    _minDisplayTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _minDisplayTimeElapsed = true;
        });
        _checkAndNavigate();
      }
    });

    // Maximum wait time: if auth check takes too long, navigate anyway
    // Reduced to 3 seconds for faster initial load
    _maxWaitTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Force navigation if auth check is taking too long
        // This ensures we never get stuck on splash screen
        setState(() {
          _authCheckComplete = true;
          _minDisplayTimeElapsed = true;
        });
        _checkAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    _maxWaitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    // Only navigate if both conditions are met:
    // 1. Minimum display time has elapsed
    // 2. Auth check has completed
    if (!_minDisplayTimeElapsed || !_authCheckComplete || !mounted) {
      return;
    }

    // Ensure we're on the next frame before checking SharedPreferences
    // This is especially important on web where localStorage might need initialization
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    await authState.when(
      initial: () async {
        // Still waiting for auth check - shouldn't happen at this point
        // But if it does, check company ID and navigate accordingly
        final hasCompanyId = await CompanyIdStorage.hasCompanyId();
        final companyId = await CompanyIdStorage.getCompanyId();
        print('🔍 Splash: initial state, hasCompanyId: $hasCompanyId');
        if (mounted) {
          if (hasCompanyId && companyId != null) {
            // Pass companyId as query parameter to login page
            context.go('/login?companyId=${Uri.encodeComponent(companyId)}');
          } else {
            context.go('/company-selection');
          }
        }
      },
      loading: () async {
        // Still loading - shouldn't happen at this point
        // But if it does, check company ID and navigate accordingly
        final hasCompanyId = await CompanyIdStorage.hasCompanyId();
        final companyId = await CompanyIdStorage.getCompanyId();
        print('🔍 Splash: loading state, hasCompanyId: $hasCompanyId');
        if (mounted) {
          if (hasCompanyId && companyId != null) {
            // Pass companyId as query parameter to login page
            context.go('/login?companyId=${Uri.encodeComponent(companyId)}');
          } else {
            context.go('/company-selection');
          }
        }
      },
      authenticated: (_) async {
        // Navigate to dashboard if authenticated
        print('🔍 Splash: authenticated, navigating to dashboard');
        if (mounted) {
          context.go('/dashboard');
        }
      },
      unauthenticated: () async {
        // Check if company ID exists - navigate to login if yes, company selection if no
        // Debug: Print all keys to help troubleshoot
        await CompanyIdStorage.debugPrintAllKeys();
        final hasCompanyId = await CompanyIdStorage.hasCompanyId();
        final companyId = await CompanyIdStorage.getCompanyId();
        print(
            '🔍 Splash: unauthenticated, hasCompanyId: $hasCompanyId, companyId: $companyId');
        if (mounted) {
          if (hasCompanyId && companyId != null) {
            // Pass companyId as query parameter to login page
            context.go('/login?companyId=${Uri.encodeComponent(companyId)}');
          } else {
            context.go('/company-selection');
          }
        }
      },
      error: (_) async {
        // Check if company ID exists - navigate to login if yes, company selection if no
        final hasCompanyId = await CompanyIdStorage.hasCompanyId();
        final companyId = await CompanyIdStorage.getCompanyId();
        print('🔍 Splash: error state, hasCompanyId: $hasCompanyId, companyId: $companyId');
        if (mounted) {
          if (hasCompanyId && companyId != null) {
            // Pass companyId as query parameter to login page
            context.go('/login?companyId=${Uri.encodeComponent(companyId)}');
          } else {
            context.go('/company-selection');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Mark auth check as complete when we get a definitive state
        // Also handle initial/loading states if they persist too long
        state.when(
          initial: () {
            // If we're still in initial state after minimum display time, mark as complete
            // This handles cases where auth check hasn't started yet
            if (_minDisplayTimeElapsed && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !_authCheckComplete) {
                  setState(() {
                    _authCheckComplete = true;
                  });
                  _checkAndNavigate();
                }
              });
            }
          },
          loading: () {
            // If we're still loading after minimum display time, mark as complete
            // This handles cases where auth check is taking too long
            if (_minDisplayTimeElapsed && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && !_authCheckComplete) {
                  setState(() {
                    _authCheckComplete = true;
                  });
                  _checkAndNavigate();
                }
              });
            }
          },
          authenticated: (_) {
            if (mounted) {
              setState(() {
                _authCheckComplete = true;
              });
              _checkAndNavigate();
            }
          },
          unauthenticated: () {
            if (mounted) {
              setState(() {
                _authCheckComplete = true;
              });
              _checkAndNavigate();
            }
          },
          error: (_) {
            if (mounted) {
              setState(() {
                _authCheckComplete = true;
              });
              _checkAndNavigate();
            }
          },
        );
      },
      child: Scaffold(
        body: Container(
          color: colorScheme.primary,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.business_center_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'TENX',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'YOUR PROPERTY OUR PRIORITY',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 64),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
