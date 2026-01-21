import 'dart:async';

import '../errors/app_exception.dart';
import '../errors/error_handler.dart';

/// Timeout exception for error recovery
class TimeoutException implements Exception {
  const TimeoutException(this.message, this.timeout);

  final String message;
  final Duration timeout;

  @override
  String toString() => message;
}

/// Error recovery utility for handling retries and recovery
class ErrorRecovery {
  ErrorRecovery._();

  /// Retry a function with exponential backoff
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(AppException)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempt++;
        final exception = ErrorHandler.handleError(error);

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(exception)) {
          rethrow;
        }

        // Don't retry if not recoverable
        if (!ErrorHandler.isRecoverable(exception)) {
          rethrow;
        }

        // If this was the last attempt, rethrow
        if (attempt >= maxRetries) {
          rethrow;
        }

        // Wait before retrying
        await Future<void>.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );

        ErrorHandler.logInfo(
          'Retrying operation (attempt $attempt/$maxRetries)',
        );
      }
    }

    throw Exception('Max retries exceeded');
  }

  /// Execute operation with timeout
  static Future<T> withTimeout<T>({
    required Future<T> Function() operation,
    Duration timeout = const Duration(seconds: 30),
    String? timeoutMessage,
  }) async {
    try {
      return await operation().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            timeoutMessage ?? 'Operation timed out after ${timeout.inSeconds} seconds',
            timeout,
          );
        },
      );
    } on TimeoutException catch (e) {
      throw NetworkException(
        message: e.message,
        code: 'TIMEOUT',
      );
    }
  }

  /// Execute operation with error handling wrapper
  static Future<T> execute<T>({
    required Future<T> Function() operation,
    T Function(AppException)? onError,
    void Function(AppException)? onErrorLog,
  }) async {
    try {
      return await operation();
    } catch (error) {
      final exception = ErrorHandler.handleError(error);

      // Log error if handler provided, otherwise use default logging
      if (onErrorLog != null) {
        onErrorLog(exception);
      }
      // Always log warnings for debugging
      ErrorHandler.logWarning(
        'Operation failed: ${exception.message}',
        error: exception,
      );

      // Handle error if handler provided
      if (onError != null) {
        return onError(exception);
      }

      // Otherwise rethrow
      rethrow;
    }
  }
}

