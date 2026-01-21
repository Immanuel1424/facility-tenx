import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../utils/permission_checker.dart';

/// Guard that checks if user has required permission before accessing route
class PermissionGuard {
  final String resource;
  final String action;

  const PermissionGuard({
    required this.resource,
    required this.action,
  });

  /// Check if user has permission to access the route
  static bool canAccess(
    BuildContext context,
    String resource,
    String action,
  ) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    return authState.maybeWhen(
      authenticated: (user) {
        return PermissionChecker.canPerform(user, resource, action);
      },
      orElse: () => false,
    ) ?? false;
  }

  /// Redirect function for GoRouter
  static String? redirect(
    BuildContext context,
    GoRouterState state,
    String resource,
    String action,
  ) {
    if (!canAccess(context, resource, action)) {
      // Redirect to unauthorized page or dashboard
      return '/dashboard';
    }
    return null;
  }
}

