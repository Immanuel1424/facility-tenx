import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'token_refresh_manager.dart';

Dio createDioClient(FlutterSecureStorage storage, String baseUrl) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Create token refresh manager (needs Dio instance)
  final tokenRefreshManager = TokenRefreshManager(
    storage: storage,
    dio: dio,
  );

  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(storage, tokenRefreshManager, dio),
    RetryInterceptor(),
    ErrorInterceptor(),
  ]);

  return dio;
}

