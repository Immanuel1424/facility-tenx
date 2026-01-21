import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../features/auth/data/dto/login_dto.dart';
import '../../features/auth/data/dto/token_response_dto.dart';
import '../../features/iam/data/dto/role_dto.dart';
import '../../features/iam/data/dto/permission_dto.dart';
import '../../features/iam/data/dto/user_dto.dart' as iam_dto;
import '../../features/notification/data/dto/notification_dto.dart';
import '../../features/notification/data/dto/notification_template_dto.dart';
import '../../features/dashboard/data/dto/dashboard_stats_dto.dart';
import '../../features/dashboard/data/dto/dashboard_analytics_dto.dart';
import '../../features/maintenance_ticket/data/dto/maintenance_ticket_dto.dart'
    show
        MaintenanceTicketDto,
        EscalateTicketDto,
        EscalationHistoryDto,
        EscalationMatrixDto,
        VillaDto,
        TeamDto,
        SiteDto,
        SpaceDto,
        TicketCategoryDto,
        CompanyDto,
        CreateTicketDto,
        UpdateTicketDto,
        ChangeStatusDto,
        AddNotesDto,
        LinkTicketDto;
import '../../features/maintenance_ticket/data/dto/sla_configuration_dto.dart';
import '../../features/maintenance_ticket/data/dto/maintenance_ticket_response_dto.dart';
import '../../features/maintenance_ticket/data/dto/comment_dto.dart';
import '../../features/maintenance_ticket/data/dto/attachment_dto.dart'
    show
        AttachmentDto,
        CreateAttachmentDto,
        AttachmentContext,
        PresignedUploadUrlDto;
import '../../features/maintenance_ticket/data/dto/ai_ticket_analysis_dto.dart';
import '../../features/department/data/dto/department_dto.dart' as dept_dto;
import '../../features/villa/data/dto/villa_dto.dart' as villa_dto;
import '../../features/villa/data/dto/villa_type_config_dto.dart';
import '../../features/villa/data/dto/create_villa_type_config_dto.dart';
import '../../features/villa/data/dto/update_villa_type_config_dto.dart';
import '../../features/villa/data/dto/city_dto.dart';
import '../../features/villa/data/dto/location_dto.dart';
import '../../features/announcement/data/dto/announcement_dto.dart';
import '../../features/announcement/data/dto/create_announcement_dto.dart';
import '../../features/company/data/dto/company_dto.dart' as company_dto;
import '../../features/site/data/dto/site_dto.dart' as site_dto;

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// Helper method to unwrap standard API response format
  /// Handles both wrapped {success: true, data: [...]} and direct array responses
  List<T> _unwrapListResponse<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // Handle wrapped response: {success: true, data: [...]}
    dynamic data = responseData;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    // Ensure data is a list
    if (data is! List) {
      return [];
    }

    return data.map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  // Authentication
  Future<TokenResponseDto> login(LoginDto loginDto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: loginDto.toJson(),
      );

      // Debug: Log the actual response
      print('🔍 Login response status: ${response.statusCode}');
      print('🔍 Login response data: ${response.data}');
      print('🔍 Login response data type: ${response.data.runtimeType}');

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Login response is null',
        );
      }

      // Handle nested response (e.g., { success: true, data: { accessToken: ... } })
      dynamic data = response.data;
      if (data is Map<String, dynamic>) {
        // Check if response is wrapped in standard API format: { success: true, data: {...} }
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          data = data['data'];
          print('🔍 Found wrapped response, extracting data property: $data');
        } else if (data.containsKey('success') && data.containsKey('data')) {
          // Double check for standard API response format
          final wrappedData = data['data'];
          if (wrappedData is Map<String, dynamic>) {
            data = wrappedData;
            print(
              '🔍 Found standard API response format, extracting data: $data',
            );
          }
        }

        // Log all available keys
        print('🔍 Available keys in response: ${data.keys.toList()}');

        // Handle both camelCase and snake_case response formats
        final normalizedData = <String, dynamic>{
          'accessToken':
              data['accessToken'] ?? data['access_token'] ?? data['token'],
          'refreshToken': data['refreshToken'] ?? data['refresh_token'],
          'expiresIn': data['expiresIn'] ?? data['expires_in'] ?? 900,
          'tokenType': data['tokenType'] ?? data['token_type'] ?? 'Bearer',
        };

        // Log normalized data
        print('🔍 Normalized data: $normalizedData');

        // Validate required fields
        if (normalizedData['accessToken'] == null) {
          print('❌ Missing accessToken. Available keys: ${data.keys.toList()}');
          throw DioException(
            requestOptions: response.requestOptions,
            error:
                'Missing accessToken in login response. Available keys: ${data.keys.toList()}',
          );
        }
        if (normalizedData['refreshToken'] == null) {
          print(
            '❌ Missing refreshToken. Available keys: ${data.keys.toList()}',
          );
          throw DioException(
            requestOptions: response.requestOptions,
            error:
                'Missing refreshToken in login response. Available keys: ${data.keys.toList()}',
          );
        }

        return TokenResponseDto.fromJson(normalizedData);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Unexpected response format: ${data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      // Provide more context for 403 errors
      if (e.response?.statusCode == 403) {
        final errorData = e.response?.data;
        final errorMessage = errorData is Map<String, dynamic>
            ? errorData['message'] as String? ?? errorData['error'] as String?
            : null;
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: errorMessage ??
              'Access denied. Please check your credentials and company ID.',
        );
      }
      rethrow;
    }
  }

  Future<TokenResponseDto> refreshToken(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: body,
    );
    return TokenResponseDto.fromJson(response.data!);
  }

  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  // IAM - Users
  Future<List<iam_dto.UserDto>> getUsers({
    String? companyId,
    String? role,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (companyId != null && companyId.isNotEmpty) {
      queryParameters['companyId'] = companyId;
    }
    if (role != null && role.isNotEmpty) {
      queryParameters['role'] = role;
    }
    final response = await _dio.get<dynamic>(
      '/users',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    return _unwrapListResponse(
      response.data,
      (json) => iam_dto.UserDto.fromJson(json),
    );
  }

  /// Get list of technicians for assignment
  /// Technicians are independent - returns all active technicians with technician/maintenance/staff roles
  Future<List<iam_dto.UserDto>> getTechnicians() async {
    final response = await _dio.get<dynamic>(
      '/users/technicians',
    );
    print('🔍 getTechnicians raw response: ${response.data}');
    print('🔍 getTechnicians response type: ${response.data.runtimeType}');

    final technicians = _unwrapListResponse(
      response.data,
      (json) {
        print('🔍 Mapping technician JSON: $json');
        final dto = iam_dto.UserDto.fromJson(json);
        print(
          '🔍 Mapped technician DTO: ${dto.id} - ${dto.email} - roles: ${dto.roles}',
        );
        return dto;
      },
    );

    print('🔍 Total technicians after unwrap: ${technicians.length}');
    return technicians;
  }

  // Lookup endpoints for dropdowns (deprecated - use getVillas with parameters)
  @Deprecated('Use getVillas with parameters instead')
  Future<List<VillaDto>> getVillasLegacy() async {
    final response = await _dio.get<List<dynamic>>('/lookup/villas');
    return (response.data ?? [])
        .map((json) => VillaDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<iam_dto.UserDto>> getLookupTechnicians({
    String? siteId,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (siteId != null) {
      queryParameters['siteId'] = siteId;
    }
    final response = await _dio.get<List<dynamic>>(
      '/lookup/technicians',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    return (response.data ?? [])
        .map((json) => iam_dto.UserDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<VillaTypeConfigDto>> getLookupVillaTypes() async {
    final response = await _dio.get<dynamic>('/lookup/villa-types');
    print('🔍 Villa types API response: ${response.data}');
    // Handle wrapped response: {success: true, data: [...]}
    final result = _unwrapListResponse<VillaTypeConfigDto>(
      response.data,
      (json) => VillaTypeConfigDto.fromJson(json),
    );
    print('✅ Parsed ${result.length} villa types');
    return result;
  }

  Future<List<CityDto>> getLookupCities() async {
    final response = await _dio.get<dynamic>('/lookup/cities');
    final result = _unwrapListResponse<CityDto>(
      response.data,
      (json) => CityDto.fromJson(json),
    );
    return result;
  }

  Future<List<LocationDto>> getLookupLocations({String? cityId}) async {
    final queryParams = cityId != null ? {'cityId': cityId} : null;
    final response = await _dio.get<dynamic>(
      '/lookup/locations',
      queryParameters: queryParams,
    );
    final result = _unwrapListResponse<LocationDto>(
      response.data,
      (json) => LocationDto.fromJson(json),
    );
    return result;
  }

  Future<iam_dto.UserDto> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/users/me');
      print('✅ /users/me response: ${response.data}');

      // Handle wrapped response format: { success: true, data: { ...user } }
      dynamic responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        responseData = responseData['data'];
        print('📦 Unwrapped /users/me data: $responseData');
      }

      return iam_dto.UserDto.fromJson(
        responseData as Map<String, dynamic>,
      );
    } catch (e, stackTrace) {
      print('❌ Error calling /users/me: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<iam_dto.UserDto> getUser(String id, {String? companyId}) async {
    final Map<String, dynamic> headers = {};
    if (companyId != null && companyId.isNotEmpty) {
      headers['x-company-id'] = companyId;
      print(
          '[ApiClient.getUser] Sending x-company-id header: $companyId for userId: $id');
    } else {
      print('[ApiClient.getUser] No companyId provided for userId: $id');
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/$id',
      options: Options(headers: headers.isNotEmpty ? headers : null),
    );

    // Handle wrapped response format: { success: true, data: { ...user } }
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data') &&
        responseData['data'] is Map<String, dynamic>) {
      responseData = responseData['data'];
    }

    // At this point we expect a single user object (camelCase or snake_case),
    // but UserDto.fromJson already normalizes keys and handles missing fields.
    if (responseData is! Map<String, dynamic>) {
      // Fallback: log and throw a descriptive error rather than a generic one
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Unexpected user response format: ${responseData.runtimeType}',
      );
    }

    return iam_dto.UserDto.fromJson(responseData);
  }

  Future<iam_dto.UserDto> createUser(iam_dto.CreateUserDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: dto.toJson(),
    );

    // Handle wrapped response format: { success: true, data: {...} }
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        responseData = responseData['data'];
      }
    }

    return iam_dto.UserDto.fromJson(responseData as Map<String, dynamic>);
  }

  Future<iam_dto.UserDto> updateUser(
    String id,
    iam_dto.UpdateUserDto dto,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/users/$id',
      data: dto.toJson(),
    );

    // Handle wrapped response format: { success: true, data: {...} }
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return iam_dto.UserDto.fromJson(responseData as Map<String, dynamic>);
  }

  Future<iam_dto.UserDto> activateUser(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id/activate',
    );

    // Handle wrapped response format: { success: true, data: { ...user } }
    dynamic responseData = response.data;
    if (responseData != null &&
        responseData is Map<String, dynamic> &&
        responseData.containsKey('data') &&
        responseData['data'] is Map<String, dynamic>) {
      responseData = responseData['data'];
    }

    if (responseData == null || responseData is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Invalid response format: expected user data. Received: ${response.data?.runtimeType}',
      );
    }

    return iam_dto.UserDto.fromJson(responseData);
  }

  Future<iam_dto.UserDto> deactivateUser(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id/deactivate',
    );

    // Handle wrapped response format: { success: true, data: { ...user } }
    dynamic responseData = response.data;
    if (responseData != null &&
        responseData is Map<String, dynamic> &&
        responseData.containsKey('data') &&
        responseData['data'] is Map<String, dynamic>) {
      responseData = responseData['data'];
    }

    if (responseData == null || responseData is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Invalid response format: expected user data. Received: ${response.data?.runtimeType}',
      );
    }

    return iam_dto.UserDto.fromJson(responseData);
  }

  Future<void> deleteUser(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/users/$id',
    );

    // Delete endpoint returns success response, no need to parse user data
    // Just verify the request was successful
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return;
    }

    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Failed to delete user',
    );
  }

  Future<void> resetUserPassword(
    String id,
    iam_dto.ResetPasswordDto dto,
  ) async {
    await _dio.post<void>(
      '/users/$id/reset-password',
      data: dto.toJson(),
    );
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _dio.post<void>(
      '/users/me/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> forgotPassword(String email) async {
    print('🔵 ApiClient: forgotPassword called');
    print('📧 Email: $email');
    print('🌐 Making POST request to /auth/forgot-password');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email},
      );
      print('✅ Forgot password API response: ${response.statusCode}');
      print('📦 Response data: ${response.data}');
      // Response contains message, but we don't need to return it
    } catch (e) {
      print('❌ Error in forgotPassword API call: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {
        'email': email,
        'otp': otp,
      },
    );
    // Handle wrapped response
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }
    return responseData as Map<String, dynamic>;
  }

  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    await _dio.post<Map<String, dynamic>>(
      '/auth/reset-password',
      data: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      },
    );
    // Response contains message, but we don't need to return it
  }

  Future<void> assignRoleToUser(
    String userId,
    iam_dto.AssignRoleDto dto,
  ) async {
    await _dio.post<void>(
      '/users/$userId/roles',
      data: dto.toJson(),
    );
  }

  Future<void> removeRoleFromUser(String userId, String roleId) async {
    await _dio.delete<void>('/users/$userId/roles/$roleId');
  }

  // IAM - Roles
  Future<List<RoleDto>> getRoles({String? companyId}) async {
    final queryParameters = <String, dynamic>{};
    if (companyId != null && companyId.isNotEmpty) {
      queryParameters['companyId'] = companyId;
    }
    final response = await _dio.get<dynamic>(
      '/iam/roles',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    return _unwrapListResponse(
      response.data,
      (json) => RoleDto.fromJson(json),
    );
  }

  Future<RoleDto> getRole(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/iam/roles/$id');
    return RoleDto.fromJson(response.data!);
  }

  Future<RoleDto> createRole(CreateRoleDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/iam/roles',
      data: dto.toJson(),
    );
    return RoleDto.fromJson(response.data!);
  }

  Future<RoleDto> updateRole(
    String id,
    UpdateRoleDto dto,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/iam/roles/$id',
      data: dto.toJson(),
    );
    return RoleDto.fromJson(response.data!);
  }

  Future<void> deleteRole(String id) async {
    await _dio.delete<void>('/iam/roles/$id');
  }

  Future<void> assignPermissionToRole(
    String roleId,
    AssignPermissionDto dto,
  ) async {
    await _dio.post<void>(
      '/iam/roles/$roleId/permissions',
      data: dto.toJson(),
    );
  }

  Future<Map<String, dynamic>> bulkAssignPermissionsToRole(
    String roleId,
    BulkAssignPermissionsDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/iam/roles/$roleId/permissions/bulk',
      data: dto.toJson(),
    );
    return response.data!;
  }

  Future<void> removePermissionFromRole(
    String roleId,
    String permissionId,
  ) async {
    await _dio.delete<void>(
      '/iam/roles/$roleId/permissions/$permissionId',
    );
  }

  Future<Map<String, dynamic>> bulkRemovePermissionsFromRole(
    String roleId,
    BulkRemovePermissionsDto dto,
  ) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/iam/roles/$roleId/permissions/bulk',
      data: dto.toJson(),
    );
    return response.data!;
  }

  // IAM - Permissions
  Future<List<PermissionDto>> getPermissions() async {
    final response = await _dio.get<List<dynamic>>('/iam/permissions');
    return (response.data ?? [])
        .map((json) => PermissionDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<RoleDto>> getRolePermissions(String roleId) async {
    final response = await _dio.get<List<dynamic>>(
      '/iam/roles/$roleId/permissions',
    );
    return (response.data ?? [])
        .map((json) => RoleDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PermissionDto> getPermission(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/iam/permissions/$id',
    );
    return PermissionDto.fromJson(response.data!);
  }

  Future<PermissionDto> createPermission(CreatePermissionDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/iam/permissions',
      data: dto.toJson(),
    );
    return PermissionDto.fromJson(response.data!);
  }

  Future<PermissionDto> updatePermission(
    String id,
    UpdatePermissionDto dto,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/iam/permissions/$id',
      data: dto.toJson(),
    );
    return PermissionDto.fromJson(response.data!);
  }

  Future<void> deletePermission(String id) async {
    await _dio.delete<void>('/iam/permissions/$id');
  }

  Future<List<PermissionDto>> getPermissionsByResource(String resource) async {
    final response = await _dio.get<List<dynamic>>(
      '/iam/permissions/by-resource/$resource',
    );
    return (response.data ?? [])
        .map((json) => PermissionDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<PermissionDto>> getPermissionsByAction(String action) async {
    final response = await _dio.get<List<dynamic>>(
      '/iam/permissions/by-action/$action',
    );
    return (response.data ?? [])
        .map((json) => PermissionDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<RoleDto>> getPermissionUsage(String permissionId) async {
    final response = await _dio.get<List<dynamic>>(
      '/iam/permissions/$permissionId/usage',
    );
    return (response.data ?? [])
        .map((json) => RoleDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Notifications
  Future<List<NotificationDto>> getNotifications() async {
    // Backend returns wrapped response:
    // { success: true, data: [ {..notification..}, ... ], message, timestamp }
    final response = await _dio.get<Map<String, dynamic>>('/notifications');

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    final list = responseData as List<dynamic>? ?? <dynamic>[];

    return list
        .map(
          (json) => NotificationDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<NotificationDto> markNotificationAsRead(String id) async {
    // This endpoint may also be wrapped in { success, data, ... }
    final response = await _dio.patch<Map<String, dynamic>>(
      '/notifications/$id/read',
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return NotificationDto.fromJson(responseData as Map<String, dynamic>);
  }

  Future<void> markAllNotificationsAsRead() async {
    await _dio.patch<void>('/notifications/read-all');
  }

  // Push Notification Device Registration
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    Map<String, dynamic>? deviceInfo,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '/notifications/devices/register',
      data: {
        'fcmToken': fcmToken,
        'platform': platform,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
      },
    );
  }

  Future<void> unregisterDevice({required String fcmToken}) async {
    await _dio.delete<Map<String, dynamic>>(
      '/notifications/devices/unregister',
      data: {
        'fcmToken': fcmToken,
      },
    );
  }

  // Dashboard
  Future<DashboardStatsDto> getDashboardStats({
    String? companyId,
    String? role,
  }) async {
    // Note: companyId is not sent as query parameter
    // Backend extracts companyId from JWT token automatically
    // For SUPER_ADMIN/SYSTEM role, companyId can be passed via x-company-id header if needed
    final queryParameters = <String, dynamic>{};
    if (role != null) {
      queryParameters['role'] = role;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/dashboard/stats',
      queryParameters: queryParameters,
    );

    if (response.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Dashboard stats response is null',
      );
    }

    // Handle wrapped response format: { success: true, data: {...} }
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    if (responseData == null || responseData is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Invalid dashboard stats response format',
      );
    }

    return DashboardStatsDto.fromJson(responseData);
  }

  Future<DashboardAnalyticsDto> getDashboardAnalytics({
    String? companyId,
    String? role,
    String period = 'weekly',
  }) async {
    // Note: companyId is not sent as query parameter
    // Backend extracts companyId from JWT token automatically
    // For SUPER_ADMIN/SYSTEM role, companyId can be passed via x-company-id header if needed
    final queryParameters = <String, dynamic>{
      'period': period,
    };
    if (role != null) {
      queryParameters['role'] = role;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/dashboard/analytics',
      queryParameters: queryParameters,
    );

    // Handle wrapped response format: { success: true, data: {...} }
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return DashboardAnalyticsDto.fromJson(responseData as Map<String, dynamic>);
  }

  // Maintenance Tickets
  Future<MaintenanceTicketsResponseDto> getMaintenanceTickets({
    String? status,
    String? priority,
    List<String>? villaNumbers,
    String? departmentId,
    String? assignedTechnicianId,
    String? search,
    String? ticketType,
    String? siteId,
    String? teamId,
    bool? isEscalated,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParameters['status'] = status;
    if (priority != null) queryParameters['priority'] = priority;
    if (villaNumbers != null && villaNumbers.isNotEmpty) {
      queryParameters['villa_numbers[]'] = villaNumbers;
    }
    if (departmentId != null) queryParameters['department_id'] = departmentId;
    if (assignedTechnicianId != null) {
      queryParameters['assigned_technician_id'] = assignedTechnicianId;
    }
    if (search != null) queryParameters['search'] = search;
    if (ticketType != null) queryParameters['ticket_type'] = ticketType;
    if (siteId != null) queryParameters['site_id'] = siteId;
    if (teamId != null) queryParameters['team_id'] = teamId;
    if (isEscalated != null) queryParameters['is_escalated'] = isEscalated;
    if (sortBy != null) queryParameters['sort_by'] = sortBy;
    if (sortOrder != null) queryParameters['sort_order'] = sortOrder;

    print('🌐 API Call: GET /maintenance-tickets');
    print('📤 Query params: $queryParameters');

    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets',
      queryParameters: queryParameters,
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response data type: ${response.data.runtimeType}');
    print('📥 Response data keys: ${response.data?.keys.toList()}');

    // Handle wrapped response format: { success: true, data: {...} }
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      // Check if data itself contains tickets/total (nested structure)
      if (dataValue is Map<String, dynamic> &&
          (dataValue.containsKey('tickets') ||
              dataValue.containsKey('total'))) {
        responseData = dataValue;
        print('📦 Unwrapped response data (nested structure)');
      } else {
        responseData = dataValue;
        print('📦 Unwrapped response data');
      }
    }

    // Ensure responseData is a Map before parsing
    if (responseData is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response format: expected Map, got ${responseData.runtimeType}',
      );
    }

    // Backend returns { tickets: [], total: number }
    try {
      final dto = MaintenanceTicketsResponseDto.fromJson(responseData);
      print(
        '✅ Parsed response - tickets: ${dto.tickets.length}, total: ${dto.total}',
      );
      return dto;
    } catch (e, stackTrace) {
      print('❌ Error parsing MaintenanceTicketsResponseDto: $e');
      print('Response data type: ${responseData.runtimeType}');
      print('Response data: $responseData');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<MaintenanceTicketDto> getMaintenanceTicket(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets/$id',
    );
    final body = response.data;
    if (body == null) {
      throw Exception('Empty response from GET /maintenance-tickets/$id');
    }

    // Unwrap standard API format: { success, data, message, ... }
    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<AiTicketAnalysisDto> analyzeTicketDescription(
    String description,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/analyze-description',
      data: {'description': description},
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/analyze-description',
      );
    }

    // Backend wraps response in standard API format: {success: true, data: {...}}
    // Unwrap the data field
    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return AiTicketAnalysisDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> createMaintenanceTicket(
    CreateTicketDto dto,
  ) async {
    final requestData = dto.toJson();
    print('📤 Creating ticket with payload: $requestData');
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets',
      data: requestData,
    );
    final body = response.data;
    if (body == null) {
      throw Exception('Empty response from POST /maintenance-tickets');
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> updateMaintenanceTicket(
    String id,
    UpdateTicketDto dto,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/maintenance-tickets/$id',
      data: dto.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw Exception('Empty response from PUT /maintenance-tickets/$id');
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> changeMaintenanceTicketStatus(
    String id,
    ChangeStatusDto dto,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/maintenance-tickets/$id/status',
      data: dto.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from PATCH /maintenance-tickets/$id/status',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> assignTechnicianToMaintenanceTicket(
    String id,
    String technicianId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/assign-technician',
      data: {'technician_id': technicianId},
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/assign-technician',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> acknowledgeMaintenanceTicket(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/acknowledge',
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/acknowledge',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> cancelMaintenanceTicket(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/cancel',
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/cancel',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> addMaintenanceTicketTechnicianNotes(
    String id,
    AddNotesDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/technician-notes',
      data: dto.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/technician-notes',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> addMaintenanceTicketResolutionNotes(
    String id,
    AddNotesDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/resolution-notes',
      data: dto.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/resolution-notes',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> confirmMaintenanceTicketCompletion(
    String id,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/confirm-completion',
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/confirm-completion',
      );
    }

    // This endpoint already wraps using ApiResponseUtil.success
    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> submitTicketRating(
    String ticketId,
    int rating,
    String? comment,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/rating',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$ticketId/rating',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  // New Maintenance Ticket Operations
  Future<EscalationHistoryDto> escalateMaintenanceTicket(
    String id,
    EscalateTicketDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/escalate',
      data: dto.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/escalate',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return EscalationHistoryDto.fromJson(data);
  }

  Future<MaintenanceTicketsResponseDto> getEscalatedTickets({
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets/escalated',
      queryParameters: queryParams,
    );

    // Handle wrapped response format: { success: true, data: {...} }
    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      final dataValue = responseData['data'];
      if (dataValue is Map<String, dynamic> &&
          (dataValue.containsKey('tickets') ||
              dataValue.containsKey('total'))) {
        responseData = dataValue;
      } else {
        responseData = dataValue;
      }
    }

    if (responseData is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response format: expected Map, got ${responseData.runtimeType}',
      );
    }

    return MaintenanceTicketsResponseDto.fromJson(responseData);
  }

  Future<List<EscalationHistoryDto>> getEscalationHistory(
    String ticketId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/escalation-history',
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from GET /maintenance-tickets/$ticketId/escalation-history',
      );
    }

    final data = body.containsKey('data') && body['data'] is List
        ? body['data'] as List<dynamic>
        : <dynamic>[];

    return data
        .map((item) => EscalationHistoryDto.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<List<EscalationMatrixDto>> getEscalationMatrix() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets/escalation-matrix',
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from GET /maintenance-tickets/escalation-matrix',
      );
    }

    final data = body.containsKey('data') && body['data'] is List
        ? body['data'] as List<dynamic>
        : <dynamic>[];

    return data
        .map((item) => EscalationMatrixDto.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<MaintenanceTicketDto> linkMaintenanceTicket(
    String id,
    LinkTicketDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/link',
      data: dto.toJson(),
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/link',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<MaintenanceTicketDto> assignTeamToMaintenanceTicket(
    String id,
    String teamId,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$id/assign-team',
      data: {'team_id': teamId},
    );
    final body = response.data;
    if (body == null) {
      throw Exception(
        'Empty response from POST /maintenance-tickets/$id/assign-team',
      );
    }

    final data =
        body.containsKey('data') && body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

    return MaintenanceTicketDto.fromJson(data);
  }

  Future<List<MaintenanceTicketDto>> getChildTickets(
    String parentTicketId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/maintenance-tickets/$parentTicketId/children',
        options: Options(
          // Don't treat 404 as an error - endpoint may not exist yet
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Handle 404 - endpoint doesn't exist yet, return empty list
      if (response.statusCode == 404) {
        print(
          '⚠️ Child tickets endpoint not found (404), returning empty list',
        );
        return [];
      }

      final data = response.data;

      // Handle both raw list and wrapped { success, data: [...] } formats
      final List<dynamic> list;
      if (data is List<dynamic>) {
        list = data;
      } else if (data is Map<String, dynamic> &&
          data['data'] is List<dynamic>) {
        list = data['data'] as List<dynamic>;
      } else {
        throw Exception(
          'Invalid response format for child tickets: ${data.runtimeType}',
        );
      }

      return list
          .map(
            (json) => MaintenanceTicketDto.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      // Handle other DioExceptions (shouldn't reach here for 404 due to validateStatus)
      if (e.response?.statusCode == 404) {
        print(
          '⚠️ Child tickets endpoint not found (404), returning empty list',
        );
        return [];
      }
      // Re-throw other errors
      rethrow;
    } catch (e) {
      // Handle any other exceptions
      print('❌ Error loading child tickets: $e');
      rethrow;
    }
  }

  // Lookup endpoints for maintenance tickets
  Future<List<TeamDto>> getTeams({
    String? departmentId,
    bool? isActive,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (departmentId != null) queryParameters['department_id'] = departmentId;
    if (isActive != null) queryParameters['is_active'] = isActive;

    final response = await _dio.get<dynamic>(
      '/maintenance-tickets/lookup/teams',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.data;
    final List<dynamic> list;
    if (data is List<dynamic>) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      list = data['data'] as List<dynamic>;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Unexpected teams lookup response format: ${data.runtimeType}. Expected List or { data: [] }.',
      );
    }

    return list
        .map((json) => TeamDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<VillaDto>> getVillas({
    String? siteId,
    bool? isActive,
  }) async {
    try {
      // Use /villas/active endpoint to get actual villas with villa numbers
      // Filter by siteId on frontend if needed since backend doesn't support it as query param
      final response = await _dio.get<dynamic>('/villas/active');

      // Use the existing helper method to extract list from response
      final list = _extractListFromResponse(
        response.data,
        response.requestOptions,
      );

      // Map to VillaDto
      var villas = list
          .map((json) {
            try {
              return VillaDto.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('⚠️ Error parsing villa DTO: $e, JSON: $json');
              return null;
            }
          })
          .whereType<VillaDto>()
          .toList();

      debugPrint('📊 [getVillas] Loaded ${villas.length} villas from API');
      if (villas.isNotEmpty) {
        final sampleVilla = villas.first;
        debugPrint('📊 [getVillas] Sample villa - id: ${sampleVilla.id}, site_id: ${sampleVilla.site_id}, villa_number: ${sampleVilla.villa_number}');
        // Log unique site_ids
        final uniqueSiteIds = villas.map((v) => v.site_id).whereType<String>().toSet();
        debugPrint('📊 [getVillas] Unique site_ids in response: $uniqueSiteIds');
      }

      // Filter by siteId on frontend if provided
      if (siteId != null && siteId.isNotEmpty) {
        final beforeFilter = villas.length;
        final allSiteIdsBeforeFilter = villas.map((v) => v.site_id).whereType<String>().toSet();
        final villasWithNullSiteId = villas.where((v) => v.site_id == null || v.site_id!.isEmpty).length;
        
        // If all villas have null site_id, don't filter (show all villas)
        // This handles cases where backend data is incomplete but admin still needs to work
        if (villasWithNullSiteId == beforeFilter && beforeFilter > 0) {
          debugPrint('⚠️ [getVillas] All villas have null site_id - showing all ${beforeFilter} villas (data may be incomplete)');
          // Don't filter - show all villas
        } else {
          // Filter normally
          villas = villas.where((villa) => villa.site_id == siteId).toList();
          debugPrint('📊 [getVillas] Filtered from $beforeFilter to ${villas.length} villas for siteId: $siteId');
          if (villas.isEmpty && beforeFilter > 0) {
            // Log why filtering failed
            debugPrint('⚠️ [getVillas] No villas matched siteId $siteId. Available site_ids in response: $allSiteIdsBeforeFilter');
          }
        }
      }

      // Filter by isActive if explicitly false (active endpoint already returns active only)
      if (isActive == false) {
        villas = villas.where((villa) => villa.is_active == false).toList();
      }

      debugPrint('✅ Loaded ${villas.length} villas (filtered by siteId: $siteId)');
      return villas;
    } catch (e) {
      debugPrint('❌ Error loading villas: $e');
      rethrow;
    }
  }

  Future<List<SpaceDto>> getSpaces({
    String? siteId,
    String? categoryId,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (siteId != null) queryParameters['siteId'] = siteId;
    if (categoryId != null) queryParameters['spaceCategoryId'] = categoryId;

    final response = await _dio.get<dynamic>(
      '/tenants/spaces',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.data;
    final List<dynamic> list;
    if (data is List<dynamic>) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      list = data['data'] as List<dynamic>;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Unexpected spaces lookup response format: ${data.runtimeType}. Expected List or { data: [] }.',
      );
    }

    return list
        .map((json) => SpaceDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<TicketCategoryDto>> getTicketCategories({
    String? parentCategoryId,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (parentCategoryId != null) {
      queryParameters['parent_category_id'] = parentCategoryId;
    }

    final response = await _dio.get<dynamic>(
      '/ticket-categories',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.data;
    final List<dynamic> list;
    if (data is List<dynamic>) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      list = data['data'] as List<dynamic>;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Unexpected categories lookup response format: ${data.runtimeType}. Expected List or { data: [] }.',
      );
    }

    return list
        .map((json) => TicketCategoryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SiteDto>> getSites() async {
    // Authenticated sites lookup used in in-app flows
    final response = await _dio.get<dynamic>('/lookup/villas');

    final data = response.data;
    final List<dynamic> list;
    if (data is List<dynamic>) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      list = data['data'] as List<dynamic>;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Unexpected sites lookup response format: ${data.runtimeType}. Expected List or { data: [] }.',
      );
    }

    return list
        .map((json) => SiteDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Public companies lookup for pre-login flows (no authentication)
  Future<List<CompanyDto>> getPublicCompanies() async {
    final response = await _dio.get<dynamic>('/public/lookup/companies');

    final data = response.data;
    final List<dynamic> list;
    if (data is List<dynamic>) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      list = data['data'] as List<dynamic>;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Unexpected public companies lookup response format: ${data.runtimeType}. Expected List or { data: [] }.',
      );
    }

    return list
        .map((json) => CompanyDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<SiteDto>> getPublicSites({String? companyId}) async {
    final queryParameters = <String, dynamic>{};
    if (companyId != null) {
      queryParameters['companyId'] = companyId;
    }

    final response = await _dio.get<dynamic>(
      '/public/lookup/villas',
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final data = response.data;
    final List<dynamic> list;
    if (data is List<dynamic>) {
      list = data;
    } else if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      list = data['data'] as List<dynamic>;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        error:
            'Unexpected public sites lookup response format: ${data.runtimeType}. Expected List or { data: [] }.',
      );
    }

    return list
        .map((json) => SiteDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Departments
  Future<List<dept_dto.DepartmentDto>> getDepartments() async {
    final response = await _dio.get<List<dynamic>>('/departments');
    return (response.data ?? [])
        .map(
          (json) =>
              dept_dto.DepartmentDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<dept_dto.DepartmentDto> getDepartment(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/departments/$id');
    return dept_dto.DepartmentDto.fromJson(response.data!);
  }

  Future<dept_dto.DepartmentDto> createDepartment(
    dept_dto.CreateDepartmentDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/departments',
      data: dto.toJson(),
    );
    return dept_dto.DepartmentDto.fromJson(response.data!);
  }

  Future<dept_dto.DepartmentDto> updateDepartment(
    String id,
    dept_dto.UpdateDepartmentDto dto,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/departments/$id',
      data: dto.toJson(),
    );
    return dept_dto.DepartmentDto.fromJson(response.data!);
  }

  // Helper method to extract data from response (handles wrapped responses)
  Map<String, dynamic> _extractDataFromResponse(
    dynamic responseData,
    RequestOptions requestOptions,
  ) {
    if (responseData == null) {
      throw DioException(
        requestOptions: requestOptions,
        error: 'Response data is null',
      );
    }

    // If response is already a Map, check if it's wrapped
    if (responseData is Map<String, dynamic>) {
      // Check if response is wrapped in { data: {...} }
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      // Return as-is if not wrapped
      return responseData;
    }

    throw DioException(
      requestOptions: requestOptions,
      error: 'Unexpected response format: ${responseData.runtimeType}',
    );
  }

  /// Get the list of villas the current tenant user is allowed to access.
  /// This is backed by the user_villas mapping table on the backend and
  /// returns only villas linked to the authenticated tenant.
  Future<List<VillaDto>> getTenantVillas() async {
    final response = await _dio.get<dynamic>(
      '/maintenance-tickets/tenant/villas',
    );

    dynamic data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (json) => VillaDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  // Helper method to extract list from response (handles wrapped responses)
  List<dynamic> _extractListFromResponse(
    dynamic responseData,
    RequestOptions requestOptions,
  ) {
    if (responseData == null) {
      return [];
    }

    // If response is a List, return it directly
    if (responseData is List<dynamic>) {
      return responseData;
    }

    // If response is wrapped in { data: [...] }
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List<dynamic>) {
          return data;
        }
      }
    }

    throw DioException(
      requestOptions: requestOptions,
      error:
          'Unexpected response format: ${responseData.runtimeType}. Expected List or { data: [] }',
    );
  }

  // Villas CRUD
  Future<List<villa_dto.VillaDto>> getVillasList() async {
    final response = await _dio.get<dynamic>('/villas');
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => villa_dto.VillaDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<villa_dto.VillaDto>> getActiveVillasList() async {
    final response = await _dio.get<dynamic>('/villas/active');
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => villa_dto.VillaDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<villa_dto.VillaDto>> getAvailableVillasList() async {
    final response = await _dio.get<dynamic>('/villas/available');
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => villa_dto.VillaDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<villa_dto.VillaDto> getVillaById(String id) async {
    final response = await _dio.get<dynamic>('/villas/$id');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return villa_dto.VillaDto.fromJson(data);
  }

  Future<villa_dto.VillaDto> createVilla(villa_dto.CreateVillaDto dto) async {
    final response = await _dio.post<dynamic>(
      '/villas',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return villa_dto.VillaDto.fromJson(data);
  }

  Future<villa_dto.VillaDto> updateVilla(
    String id,
    villa_dto.UpdateVillaDto dto,
  ) async {
    final response = await _dio.put<dynamic>(
      '/villas/$id',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return villa_dto.VillaDto.fromJson(data);
  }

  Future<void> deleteVilla(String id) async {
    await _dio.delete<void>('/villas/$id');
  }

  Future<villa_dto.VillaDto> activateVilla(String id) async {
    final response = await _dio.post<dynamic>(
      '/villas/$id/activate',
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return villa_dto.VillaDto.fromJson(data);
  }

  Future<villa_dto.VillaDto> deactivateVilla(String id) async {
    final response = await _dio.post<dynamic>(
      '/villas/$id/deactivate',
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return villa_dto.VillaDto.fromJson(data);
  }

  // Maintenance Ticket Comments
  Future<List<CommentDto>> getTicketComments(String ticketId) async {
    final response = await _dio.get<dynamic>(
      '/maintenance-tickets/$ticketId/comments',
    );
    return _unwrapListResponse(
      response.data,
      (json) => CommentDto.fromJson(json),
    );
  }

  Future<CommentDto> getTicketComment(
    String ticketId,
    String commentId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/comments/$commentId',
    );
    return CommentDto.fromJson(response.data!);
  }

  Future<CommentDto> createTicketComment(
    String ticketId,
    CreateCommentDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/comments',
      data: dto.toJson(),
    );
    return CommentDto.fromJson(response.data!);
  }

  Future<CommentDto> updateTicketComment(
    String ticketId,
    String commentId,
    UpdateCommentDto dto,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/comments/$commentId',
      data: dto.toJson(),
    );
    return CommentDto.fromJson(response.data!);
  }

  Future<void> deleteTicketComment(
    String ticketId,
    String commentId,
  ) async {
    await _dio.delete<void>(
      '/maintenance-tickets/$ticketId/comments/$commentId',
    );
  }

  Future<CommentDto> addInternalNote(
    String ticketId,
    AddNotesDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/comments/internal-note',
      data: dto.toJson(),
    );
    return CommentDto.fromJson(response.data!);
  }

  Future<CommentDto> addWorkNote(
    String ticketId,
    AddNotesDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/comments/work-note',
      data: dto.toJson(),
    );
    return CommentDto.fromJson(response.data!);
  }

  // Maintenance Ticket Attachments
  Future<List<AttachmentDto>> getTicketAttachments(String ticketId) async {
    final response = await _dio.get<dynamic>(
      '/maintenance-tickets/$ticketId/attachments',
    );

    // Handle wrapped response format
    dynamic data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    if (data is! List) {
      return [];
    }

    return data
        .map((json) => AttachmentDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AttachmentDto> getTicketAttachment(
    String ticketId,
    String attachmentId,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/attachments/$attachmentId',
    );

    // Handle wrapped response format
    final dynamic responseData = response.data;
    Map<String, dynamic> data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'] as Map<String, dynamic>;
    } else {
      data = responseData as Map<String, dynamic>;
    }

    return AttachmentDto.fromJson(data);
  }

  Future<AttachmentDto> createTicketAttachment(
    String ticketId,
    CreateAttachmentDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/attachments',
      data: dto.toJson(),
    );

    // Handle wrapped response format
    final dynamic responseData = response.data;
    Map<String, dynamic> data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'] as Map<String, dynamic>;
    } else {
      data = responseData as Map<String, dynamic>;
    }

    return AttachmentDto.fromJson(data);
  }

  Future<void> deleteTicketAttachment(
    String ticketId,
    String attachmentId,
  ) async {
    await _dio.delete<void>(
      '/maintenance-tickets/$ticketId/attachments/$attachmentId',
    );
  }

  Future<List<AttachmentDto>> getTicketAttachmentsByContext(
    String ticketId,
    String context,
  ) async {
    final response = await _dio.get<dynamic>(
      '/maintenance-tickets/$ticketId/attachments/context/$context',
    );

    // Handle wrapped response format
    dynamic data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    if (data is! List) {
      return [];
    }

    return data
        .map((json) => AttachmentDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Generate presigned URL for direct S3 upload (generic endpoint)
  /// Industry-standard pattern: Backend generates pre-signed URL, client uploads directly to S3
  /// 
  /// SECURITY: No AWS credentials in Flutter. All uploads use pre-signed URLs.
  Future<PresignedUploadUrlDto> generatePresignedUploadUrlGeneric({
    required String entityType,
    required String entityId,
    required String fileName,
    required String mimeType,
    required int fileSize,
    String? checksum,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/uploads/presigned-url',
      data: {
        'entityType': entityType,
        'entityId': entityId,
        'fileName': fileName,
        'mimeType': mimeType,
        'fileSize': fileSize,
        if (checksum != null) 'checksum': checksum,
      },
    );

    // Handle wrapped response format
    final dynamic responseData = response.data;
    Map<String, dynamic> data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'] as Map<String, dynamic>;
    } else {
      data = responseData as Map<String, dynamic>;
    }

    // Add fileName, mimeType, fileSize from request (not returned by backend)
    data['fileName'] = fileName;
    data['mimeType'] = mimeType;
    data['fileSize'] = fileSize;
    if (checksum != null) {
      data['checksum'] = checksum;
    }

    return PresignedUploadUrlDto.fromJson(data);
  }

  /// Generate presigned URL for direct S3 upload (maintenance ticket - backward compatibility)
  /// DEPRECATED: Use generatePresignedUploadUrlGeneric instead
  @Deprecated('Use generatePresignedUploadUrlGeneric with entityType: "maintenance-ticket"')
  Future<PresignedUploadUrlDto> generatePresignedUploadUrl({
    required String ticketId,
    required String fileName,
    required String mimeType,
    required int fileSize,
    String? checksum,
  }) async {
    // Use generic endpoint for backward compatibility
    return generatePresignedUploadUrlGeneric(
      entityType: 'maintenance-ticket',
      entityId: ticketId,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
      checksum: checksum,
    );
  }

  /// Create attachment metadata after S3 upload
  /// Generate presigned URL for downloading/viewing files from S3 (generic endpoint)
  /// Industry-standard pattern: Backend generates pre-signed URL, client downloads directly from S3
  ///
  /// SECURITY: No AWS credentials in Flutter. All downloads use pre-signed URLs.
  ///
  /// This follows the same pattern as upload: generic endpoint for all entity types
  Future<String> generatePresignedDownloadUrlGeneric({
    required String storagePath,
    int expiresIn = 3600,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/uploads/presigned-url',
      queryParameters: {
        'storagePath': storagePath,
        'expiresIn': expiresIn,
      },
    );

    final dynamic responseData = response.data;
    Map<String, dynamic> data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'] as Map<String, dynamic>;
    } else {
      data = responseData as Map<String, dynamic>;
    }

    return data['presignedUrl'] as String;
  }

  /// Get presigned URL for viewing/downloading an attachment (ticket-specific endpoint)
  /// DEPRECATED: Use generatePresignedDownloadUrlGeneric with storagePath instead
  /// This is kept for backward compatibility
  @Deprecated('Use generatePresignedDownloadUrlGeneric with storagePath from attachment')
  Future<String> getPresignedViewUrl({
    required String ticketId,
    required String attachmentId,
    int expiresIn = 3600,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/attachments/$attachmentId/presigned-url',
      queryParameters: {'expiresIn': expiresIn},
    );

    final dynamic responseData = response.data;
    Map<String, dynamic> data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'] as Map<String, dynamic>;
    } else {
      data = responseData as Map<String, dynamic>;
    }

    return data['presignedUrl'] as String;
  }

  /// Upload file directly to backend (for local storage)
  /// Uses multipart form upload to the backend endpoint
  Future<AttachmentDto> uploadFileDirectly({
    required String ticketId,
    required FormData formData,
    ProgressCallback? onProgress,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/maintenance-tickets/$ticketId/attachments/upload',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
      onSendProgress: onProgress,
    );

    // Handle wrapped response format
    final dynamic responseData = response.data;
    Map<String, dynamic> data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      data = responseData['data'] as Map<String, dynamic>;
    } else {
      data = responseData as Map<String, dynamic>;
    }

    return AttachmentDto.fromJson(data);
  }

  Future<AttachmentDto> createAttachmentMetadata({
    required String ticketId,
    required String fileName,
    required String originalName,
    required String mimeType,
    required int fileSize,
    required String storagePath,
    required String storageUrl,
    int? width,
    int? height,
    String? checksum,
  }) async {
    // Determine attachment type from MIME type
    String? attachmentType;
    final lowerMime = mimeType.toLowerCase();
    if (lowerMime.startsWith('image/')) {
      attachmentType = 'IMAGE';
    } else if (lowerMime.startsWith('video/')) {
      attachmentType = 'VIDEO';
    } else if (lowerMime.startsWith('audio/')) {
      attachmentType = 'AUDIO';
    } else if (lowerMime.contains('pdf') ||
        lowerMime.contains('document') ||
        lowerMime.contains('word') ||
        lowerMime.contains('excel')) {
      attachmentType = 'DOCUMENT';
    }

    final dto = CreateAttachmentDto(
      file_name: fileName,
      original_name: originalName,
      mime_type: mimeType,
      file_size: fileSize,
      storage_path: storagePath,
      storage_url: storageUrl,
      attachment_type: attachmentType,
      attachment_context: AttachmentContext.ticketCreation.value,
      image_width: width,
      image_height: height,
      checksum: checksum,
    );

    return createTicketAttachment(ticketId, dto);
  }

  // Notification Template Management
  Future<List<NotificationTemplateDto>> getEmailTemplates() async {
    try {
      final response =
          await _dio.get<dynamic>('/notifications/templates/email');

      dynamic responseData = response.data;

      // Handle wrapped response format
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          responseData = responseData['data'];
        } else if (responseData.containsKey('success') &&
            responseData['success'] == true) {
          responseData = responseData['data'] ?? [];
        }
      }

      // If responseData is not a list, return empty list
      if (responseData is! List) {
        return [];
      }

      return responseData
          .map((json) {
            try {
              return NotificationTemplateDto.fromJson(
                json as Map<String, dynamic>,
              );
            } catch (e) {
              print('Error parsing template: $e');
              return null;
            }
          })
          .whereType<NotificationTemplateDto>()
          .toList();
    } catch (e) {
      print('Error fetching email templates: $e');
      return [];
    }
  }

  Future<NotificationTemplateDto> getNotificationTemplate(String id) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/notifications/templates/$id');

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return NotificationTemplateDto.fromJson(
      responseData as Map<String, dynamic>,
    );
  }

  Future<NotificationTemplateDto> updateNotificationTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/notifications/templates/$id',
      data: data,
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return NotificationTemplateDto.fromJson(
      responseData as Map<String, dynamic>,
    );
  }

  Future<void> seedEmailTemplates() async {
    await _dio.post<void>('/notifications/templates/seed');
  }

  // Announcements
  Future<PaginatedAnnouncementsResponseDto> getAnnouncements({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null) queryParameters['category'] = category;
    if (priority != null) queryParameters['priority'] = priority;
    if (search != null) queryParameters['search'] = search;
    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

    final response = await _dio.get<Map<String, dynamic>>(
      '/announcements',
      queryParameters: queryParameters,
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return PaginatedAnnouncementsResponseDto.fromJson(
      responseData as Map<String, dynamic>,
    );
  }

  Future<PaginatedAnnouncementsResponseDto> getAnnouncementsForAdmin({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null) queryParameters['category'] = category;
    if (priority != null) queryParameters['priority'] = priority;
    if (search != null) queryParameters['search'] = search;
    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

    final response = await _dio.get<Map<String, dynamic>>(
      '/announcements/admin',
      queryParameters: queryParameters,
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return PaginatedAnnouncementsResponseDto.fromJson(
      responseData as Map<String, dynamic>,
    );
  }

  Future<AnnouncementDto> getAnnouncement(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/announcements/$id',
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return AnnouncementDto.fromJson(responseData as Map<String, dynamic>);
  }

  Future<AnnouncementDto> createAnnouncement(
    CreateAnnouncementDto dto,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/announcements',
      data: dto.toJson(),
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return AnnouncementDto.fromJson(responseData as Map<String, dynamic>);
  }

  Future<AnnouncementDto> updateAnnouncement(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/announcements/$id',
      data: data,
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return AnnouncementDto.fromJson(responseData as Map<String, dynamic>);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _dio.delete<void>('/announcements/$id');
  }

  Future<AnnouncementDto> publishAnnouncement(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/announcements/$id/publish',
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return AnnouncementDto.fromJson(responseData as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> markAnnouncementAsRead(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/announcements/$id/read',
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return responseData as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUnreadAnnouncementCount() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/announcements/unread/count',
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return responseData as Map<String, dynamic>;
  }

  Future<PaginatedAnnouncementsResponseDto> getUnreadAnnouncements({
    String? category,
    String? priority,
    String? search,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null) queryParameters['category'] = category;
    if (priority != null) queryParameters['priority'] = priority;
    if (search != null) queryParameters['search'] = search;
    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

    final response = await _dio.get<Map<String, dynamic>>(
      '/announcements/unread/list',
      queryParameters: queryParameters,
    );

    dynamic responseData = response.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      responseData = responseData['data'];
    }

    return PaginatedAnnouncementsResponseDto.fromJson(
      responseData as Map<String, dynamic>,
    );
  }

  // Companies CRUD
  Future<List<company_dto.CompanyDto>> getCompanies() async {
    final response = await _dio.get<dynamic>('/tenants/companies');
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) =>
              company_dto.CompanyDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<company_dto.CompanyDto> getCompanyById(String id) async {
    final response = await _dio.get<dynamic>('/tenants/companies/$id');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return company_dto.CompanyDto.fromJson(data);
  }

  Future<company_dto.CompanyDto> createCompany(
    company_dto.CreateCompanyDto dto,
  ) async {
    final response = await _dio.post<dynamic>(
      '/tenants/companies',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return company_dto.CompanyDto.fromJson(data);
  }

  Future<company_dto.CompanyDto> updateCompany(
    String id,
    company_dto.UpdateCompanyDto dto,
  ) async {
    final response = await _dio.patch<dynamic>(
      '/tenants/companies/$id',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return company_dto.CompanyDto.fromJson(data);
  }

  Future<void> deleteCompany(String id) async {
    await _dio.delete<void>('/tenants/companies/$id');
  }

  // Site CRUD
  Future<List<site_dto.SiteDto>> getSitesForManagement({
    String? companyId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (companyId != null) {
      queryParams['companyId'] = companyId;
    }
    final response = await _dio.get<dynamic>(
      '/tenants/sites',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => site_dto.SiteDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<site_dto.SiteDto> getSiteById(String id) async {
    final response = await _dio.get<dynamic>('/tenants/sites/$id');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return site_dto.SiteDto.fromJson(data);
  }

  Future<site_dto.SiteDto> createSite(site_dto.CreateSiteDto dto) async {
    final response = await _dio.post<dynamic>(
      '/tenants/sites',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return site_dto.SiteDto.fromJson(data);
  }

  Future<site_dto.SiteDto> updateSite(
    String id,
    site_dto.UpdateSiteDto dto,
  ) async {
    final response = await _dio.patch<dynamic>(
      '/tenants/sites/$id',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return site_dto.SiteDto.fromJson(data);
  }

  Future<void> deleteSite(String id) async {
    await _dio.delete<void>('/tenants/sites/$id');
  }

  // User-Site Assignment
  Future<void> assignUserToSite(String siteId, String userId) async {
    final response = await _dio.post<dynamic>(
      '/tenants/sites/$siteId/users/$userId',
    );
    _extractDataFromResponse(response.data, response.requestOptions);
  }

  Future<void> removeUserFromSite(String siteId, String userId) async {
    final response = await _dio.delete<dynamic>(
      '/tenants/sites/$siteId/users/$userId',
    );
    _extractDataFromResponse(response.data, response.requestOptions);
  }

  Future<List<iam_dto.UserDto>> getSiteUsers(String siteId) async {
    final response = await _dio.get<dynamic>('/tenants/sites/$siteId/users');
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => iam_dto.UserDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<site_dto.SiteDto>> getUserSites(String userId) async {
    final response = await _dio.get<dynamic>('/tenants/users/$userId/sites');
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => site_dto.SiteDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  // Villa Type Configs CRUD
  Future<List<VillaTypeConfigDto>> getVillaTypeConfigs({
    bool includeInactive = false,
  }) async {
    final response = await _dio.get<dynamic>(
      '/villa-type-configs',
      queryParameters: {
        if (includeInactive) 'includeInactive': 'true',
      },
    );
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => VillaTypeConfigDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<VillaTypeConfigDto> getVillaTypeConfigById(String id) async {
    final response = await _dio.get<dynamic>('/villa-type-configs/$id');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return VillaTypeConfigDto.fromJson(data);
  }

  Future<VillaTypeConfigDto> createVillaTypeConfig(
    CreateVillaTypeConfigDto dto,
  ) async {
    final response = await _dio.post<dynamic>(
      '/villa-type-configs',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return VillaTypeConfigDto.fromJson(data);
  }

  Future<VillaTypeConfigDto> updateVillaTypeConfig(
    String id,
    UpdateVillaTypeConfigDto dto,
  ) async {
    final response = await _dio.put<dynamic>(
      '/villa-type-configs/$id',
      data: dto.toJson(),
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return VillaTypeConfigDto.fromJson(data);
  }

  Future<void> deleteVillaTypeConfig(String id) async {
    await _dio.delete<void>('/villa-type-configs/$id');
  }

  Future<VillaTypeConfigDto> activateVillaTypeConfig(String id) async {
    final response = await _dio.post<dynamic>(
      '/villa-type-configs/$id/activate',
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return VillaTypeConfigDto.fromJson(data);
  }

  Future<VillaTypeConfigDto> deactivateVillaTypeConfig(String id) async {
    final response = await _dio.post<dynamic>(
      '/villa-type-configs/$id/deactivate',
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return VillaTypeConfigDto.fromJson(data);
  }

  // Ticket Categories CRUD
  Future<List<TicketCategoryDto>> getAllTicketCategories({
    bool activeOnly = true,
  }) async {
    final response = await _dio.get<dynamic>(
      '/ticket-categories',
      queryParameters: {
        if (!activeOnly) 'active_only': 'false',
      },
    );
    final list = _extractListFromResponse(
      response.data,
      response.requestOptions,
    );
    return list
        .map(
          (json) => TicketCategoryDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<TicketCategoryDto> getTicketCategoryById(String id) async {
    final response = await _dio.get<dynamic>('/ticket-categories/$id');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return TicketCategoryDto.fromJson(data);
  }

  Future<TicketCategoryDto> createTicketCategory(
    Map<String, dynamic> dto,
  ) async {
    final response = await _dio.post<dynamic>(
      '/ticket-categories',
      data: dto,
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return TicketCategoryDto.fromJson(data);
  }

  Future<TicketCategoryDto> updateTicketCategory(
    String id,
    Map<String, dynamic> dto,
  ) async {
    final response = await _dio.put<dynamic>(
      '/ticket-categories/$id',
      data: dto,
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return TicketCategoryDto.fromJson(data);
  }

  Future<void> deleteTicketCategory(String id) async {
    await _dio.delete<void>('/ticket-categories/$id');
  }

  Future<TicketCategoryDto> activateTicketCategory(String id) async {
    final response = await _dio.post<dynamic>(
      '/ticket-categories/$id/activate',
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return TicketCategoryDto.fromJson(data);
  }

  Future<TicketCategoryDto> deactivateTicketCategory(String id) async {
    final response = await _dio.post<dynamic>(
      '/ticket-categories/$id/deactivate',
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return TicketCategoryDto.fromJson(data);
  }

  // SLA Configuration methods
  Future<List<SlaConfigurationDto>> getSlaConfigurations() async {
    final response = await _dio.get<dynamic>('/sla/configurations');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return _unwrapListResponse(
      data,
      (json) => SlaConfigurationDto.fromJson(json),
    );
  }

  Future<List<SlaConfigurationDto>> getActiveSlaConfigurations() async {
    final response = await _dio.get<dynamic>('/sla/configurations/active');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return _unwrapListResponse(
      data,
      (json) => SlaConfigurationDto.fromJson(json),
    );
  }

  Future<SlaConfigurationDto> getSlaConfigurationById(String id) async {
    final response = await _dio.get<dynamic>('/sla/configurations/$id');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return SlaConfigurationDto.fromJson(data);
  }

  Future<SlaConfigurationDto> createSlaConfiguration(
    Map<String, dynamic> dto,
  ) async {
    final response = await _dio.post<dynamic>(
      '/sla/configurations',
      data: dto,
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return SlaConfigurationDto.fromJson(data);
  }

  Future<SlaConfigurationDto> updateSlaConfiguration(
    String id,
    Map<String, dynamic> dto,
  ) async {
    final response = await _dio.put<dynamic>(
      '/sla/configurations/$id',
      data: dto,
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return SlaConfigurationDto.fromJson(data);
  }

  Future<void> deleteSlaConfiguration(String id) async {
    await _dio.delete<void>('/sla/configurations/$id');
  }

  // Escalation Scheduler Configuration methods
  Future<Map<String, dynamic>> getEscalationSchedulerConfig() async {
    final response = await _dio.get<dynamic>('/sla/escalation-scheduler/config');
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateEscalationSchedulerConfig(
    Map<String, dynamic> dto,
  ) async {
    final response = await _dio.put<dynamic>(
      '/sla/escalation-scheduler/config',
      data: dto,
    );
    final data = _extractDataFromResponse(
      response.data,
      response.requestOptions,
    );
    return data as Map<String, dynamic>;
  }
}
