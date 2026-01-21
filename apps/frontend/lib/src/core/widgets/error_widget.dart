import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../errors/error_handler.dart';

/// Reusable error widget for displaying errors
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
  });

  final dynamic error;
  final VoidCallback? onRetry;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final exception = ErrorHandler.handleError(error);
    final isRecoverable = ErrorHandler.isRecoverable(exception);
    final message = ErrorHandler.getUserFriendlyMessage(exception);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(exception),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorTitle(exception),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (showDetails && exception.details != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Error Details'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      exception.details.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (isRecoverable && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(AppException exception) {
    if (exception is NetworkException) {
      if (exception.code == 'NO_CONNECTION') {
        return Icons.wifi_off;
      }
      return Icons.cloud_off;
    }
    if (exception is AuthenticationException) {
      return Icons.lock_outline;
    }
    if (exception is ValidationException) {
      return Icons.error_outline;
    }
    if (exception is PermissionException) {
      return Icons.block;
    }
    return Icons.error_outline;
  }

  String _getErrorTitle(AppException exception) {
    if (exception is NetworkException) {
      if (exception.code == 'NO_CONNECTION') {
        return 'No Internet Connection';
      }
      return 'Network Error';
    }
    if (exception is AuthenticationException) {
      return 'Authentication Error';
    }
    if (exception is ValidationException) {
      return 'Validation Error';
    }
    if (exception is PermissionException) {
      return 'Permission Denied';
    }
    if (exception is ServerException) {
      return 'Server Error';
    }
    return 'Error';
  }
}

/// Error snackbar helper
class ErrorSnackBar {
  static void show(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final exception = ErrorHandler.handleError(error);
    final message = ErrorHandler.getUserFriendlyMessage(exception);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(exception),
              color: Theme.of(context).colorScheme.onError, // Use theme color for dark mode
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.onError), // Use theme color for dark mode
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: ErrorHandler.isRecoverable(exception)
            ? SnackBarAction(
                label: 'Retry',
                textColor: Theme.of(context).colorScheme.onError, // Use theme color for dark mode
                onPressed: () {
                  // Retry logic should be handled by the caller
                },
              )
            : null,
      ),
    );
  }

  static IconData _getErrorIcon(AppException exception) {
    if (exception is NetworkException) {
      return Icons.wifi_off;
    }
    if (exception is AuthenticationException) {
      return Icons.lock_outline;
    }
    return Icons.error_outline;
  }
}

