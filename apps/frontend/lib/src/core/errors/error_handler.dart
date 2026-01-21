import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'app_exception.dart';

/// Centralized error handler for the application
class ErrorHandler {
  ErrorHandler._();

  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Handle and convert any error to AppException
  static AppException handleError(dynamic error) {
    // Log the error
    _logError(error);

    // Convert to AppException
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      // If we have an HTTP response, map by status code + body (handles validation errors)
      if (error.response != null) {
        return handleApiError(error.response);
      }
      // Fallback to generic network mapping
      return NetworkException.fromDioException(error);
    }

    if (error is Exception) {
      return UnknownException.fromError(error);
    }

    return UnknownException.fromError(error);
  }

  /// Extract user-friendly error message
  static String getUserFriendlyMessage(AppException exception) {
    return exception.message;
  }

  /// Check if error is recoverable (can retry)
  static bool isRecoverable(AppException exception) {
    if (exception is NetworkException) {
      return exception.code == 'TIMEOUT' ||
          exception.code == 'NO_CONNECTION' ||
          exception.code == 'BAD_RESPONSE';
    }
    if (exception is ServerException) {
      return exception.statusCode != null &&
          exception.statusCode! >= 500 &&
          exception.statusCode! < 600;
    }
    return false;
  }

  /// Check if error requires authentication
  static bool requiresAuthentication(AppException exception) {
    if (exception is AuthenticationException) {
      return exception.code == 'UNAUTHORIZED';
    }
    if (exception is NetworkException) {
      return exception.statusCode == 401;
    }
    return false;
  }

  /// Check if error is a permission issue
  static bool isPermissionError(AppException exception) {
    return exception is PermissionException ||
        exception is AuthenticationException && exception.code == 'FORBIDDEN' ||
        (exception is NetworkException && exception.statusCode == 403);
  }

  /// Log error with appropriate level
  static void _logError(dynamic error) {
    if (error is AppException) {
      if (error is NetworkException && error.statusCode != null) {
        _logger.e(
          'Network Error: ${error.message}',
          error: error,
          stackTrace: StackTrace.current,
        );
      } else if (error is AuthenticationException) {
        _logger.w(
          'Authentication Error: ${error.message}',
          error: error,
        );
      } else if (error is ValidationException) {
        _logger.w(
          'Validation Error: ${error.message}',
          error: error.fieldErrors,
        );
      } else {
        _logger.e(
          'Error: ${error.message}',
          error: error,
          stackTrace: StackTrace.current,
        );
      }
    } else {
      _logger.e(
        'Unknown Error',
        error: error,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Log info message
  static void logInfo(String message, {dynamic error}) {
    _logger.i(message, error: error);
  }

  /// Log warning message
  static void logWarning(String message, {dynamic error}) {
    _logger.w(message, error: error);
  }

  /// Log debug message
  static void logDebug(String message, {dynamic error}) {
    if (kDebugMode) {
      _logger.d(message, error: error);
    }
  }

  /// Handle API response errors
  static AppException handleApiError(Response<dynamic>? response) {
    if (response == null) {
      return const NetworkException(
        message: 'No response from server',
        code: 'NO_RESPONSE',
      );
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Handle specific status codes
    switch (statusCode) {
      case 400:
        if (data is Map<String, dynamic>) {
          return ValidationException.fromResponse(data);
        }
        return const ValidationException(
          message: 'Invalid request. Please check your input.',
          code: 'BAD_REQUEST',
        );
      case 401:
        // Extract error message from response (especially for login failures)
        final errorMessage = _extractErrorMessage(data);
        if (errorMessage != null) {
          // Use the actual error message from API response
          // This will show "Invalid credentials" for login failures
          return AuthenticationException(
            message: errorMessage,
            code: 'UNAUTHORIZED',
          );
        }
        // Fallback to default unauthorized message for session expiry
        return AuthenticationException.unauthorized();
      case 403:
        return AuthenticationException.forbidden();
      case 404:
        return const NetworkException(
          message: 'Resource not found.',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      case 422:
        if (data is Map<String, dynamic>) {
          return ValidationException.fromResponse(data);
        }
        return const ValidationException(
          message: 'Validation failed.',
          code: 'VALIDATION_ERROR',
        );
      case >= 500 && < 600:
        return ServerException.fromStatusCode(statusCode);
      default:
        return NetworkException(
          message: _extractErrorMessage(data) ??
              'An error occurred. Please try again.',
          code: 'API_ERROR',
          statusCode: statusCode,
          details: data is Map<String, dynamic> ? data : null,
        );
    }
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    if (data is String) {
      return data;
    }
    return null;
  }
}

