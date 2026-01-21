import 'package:dio/dio.dart';

/// Base exception class for application errors
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  final int? statusCode;

  factory NetworkException.fromDioException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(
            message: 'Connection timeout. Please check your internet connection and try again.',
            code: 'TIMEOUT',
          );
        case DioExceptionType.connectionError:
          return const NetworkException(
            message: 'No internet connection. Please check your network settings.',
            code: 'NO_CONNECTION',
          );
        case DioExceptionType.badResponse:
          return NetworkException(
            message: _extractErrorMessage(error.response?.data) ??
                'Server error. Please try again later.',
            code: 'BAD_RESPONSE',
            statusCode: error.response?.statusCode,
            details: error.response?.data as Map<String, dynamic>?,
          );
        case DioExceptionType.cancel:
          return const NetworkException(
            message: 'Request was cancelled.',
            code: 'CANCELLED',
          );
        default:
          return NetworkException(
            message: error.message ?? 'Network error occurred.',
            code: 'UNKNOWN',
          );
      }
    }
    return NetworkException(
      message: error.toString(),
      code: 'UNKNOWN',
    );
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

/// Authentication-related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthenticationException.unauthorized() {
    return const AuthenticationException(
      message: 'Your session has expired. Please login again.',
      code: 'UNAUTHORIZED',
    );
  }

  factory AuthenticationException.forbidden() {
    return const AuthenticationException(
      message: 'You do not have permission to perform this action.',
      code: 'FORBIDDEN',
    );
  }
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
    this.fieldErrors,
  });

  final Map<String, String>? fieldErrors;

  factory ValidationException.fromResponse(Map<String, dynamic> data) {
    final message = data['message'] as String? ?? 'Validation failed';
    final rawErrors = data['errors'];

    Map<String, String>? parsedFieldErrors;

    // Backend format 1: { errors: { field: [messages] } }
    if (rawErrors is Map<String, dynamic>) {
      parsedFieldErrors = {};
      rawErrors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          parsedFieldErrors![key] = value.first.toString();
        } else if (value is String) {
          parsedFieldErrors![key] = value;
        }
      });
    }

    // Backend format 2: { errors: [ { field: 'email', message: 'email must be an email' }, ... ] }
    if (rawErrors is List) {
      parsedFieldErrors = parsedFieldErrors ?? <String, String>{};
      for (final error in rawErrors) {
        if (error is Map<String, dynamic>) {
          final field = error['field']?.toString();
          final fieldMessage = error['message']?.toString();
          if (field != null && fieldMessage != null && field.isNotEmpty) {
            parsedFieldErrors[field] = fieldMessage;
          }
        }
      }
    }

    return ValidationException(
      message: message,
      code: 'VALIDATION_ERROR',
      fieldErrors: parsedFieldErrors,
      details: data,
    );
  }
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });

  final int? statusCode;

  factory ServerException.fromStatusCode(int statusCode, {String? message}) {
    switch (statusCode) {
      case 500:
        return ServerException(
          message: message ?? 'Internal server error. Please try again later.',
          code: 'INTERNAL_ERROR',
          statusCode: statusCode,
        );
      case 502:
        return const ServerException(
          message: 'Service temporarily unavailable. Please try again later.',
          code: 'BAD_GATEWAY',
          statusCode: 502,
        );
      case 503:
        return const ServerException(
          message: 'Service is currently under maintenance. Please try again later.',
          code: 'SERVICE_UNAVAILABLE',
          statusCode: 503,
        );
      default:
        return ServerException(
          message: message ?? 'Server error occurred.',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );
    }
  }
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.details,
  });

  factory PermissionException.insufficientPermissions() {
    return const PermissionException(
      message: 'You do not have sufficient permissions to perform this action.',
      code: 'INSUFFICIENT_PERMISSIONS',
    );
  }
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.details,
  });

  factory UnknownException.fromError(dynamic error) {
    return UnknownException(
      message: error.toString(),
      code: 'UNKNOWN',
      details: {'originalError': error.toString()},
    );
  }
}

