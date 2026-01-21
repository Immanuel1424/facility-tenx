import 'package:dio/dio.dart';

import '../../errors/error_handler.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Use centralized error handler
    final exception = ErrorHandler.handleError(err);
    final message = ErrorHandler.getUserFriendlyMessage(exception);

    handler.next(err.copyWith(message: message));
  }
}

