import 'package:fpdart/fpdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/jwt_utils.dart';
import '../../../../core/storage/company_id_storage.dart';
import '../../../../core/storage/cache_clear_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../dto/login_dto.dart';

class AuthRepository implements AuthRepositoryInterface {
  AuthRepository({
    required ApiClient apiClient,
    required FlutterSecureStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _companyIdKey = 'company_id';

  /// Get company name from stored token
  Future<String?> getCompanyNameFromToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token == null) {
        print('⚠️ No access token found in storage');
        return null;
      }
      final companyName = JwtUtils.getCompanyName(token);
      print('🔍 Extracted company name from token: $companyName');
      if (companyName == null) {
        // Debug: print token payload to see what's available
        final payload = JwtUtils.decodeToken(token);
        print('🔍 Token payload keys: ${payload?.keys.toList()}');
        print('🔍 Token payload: $payload');
      }
      return companyName;
    } catch (e) {
      print('⚠️ Error reading company name from token: $e');
      return null;
    }
  }

  @override
  Future<Either<Exception, UserEntity>> login(
    String siteCode,
    String email,
    String password, {
    String? companyId,
  }) async {
    try {
      final dto = LoginDto(
        siteCode: siteCode,
        email: email,
        password: password,
        companyId: companyId,
      );
      final response = await _apiClient.login(dto);

      // Store tokens in secure storage
      await _storage.write(key: _accessTokenKey, value: response.accessToken);
      await _storage.write(key: _refreshTokenKey, value: response.refreshToken);

      // Decode JWT to get user info
      final userInfo = JwtUtils.getUserInfo(response.accessToken);
      if (userInfo == null) {
        return Left(Exception('Failed to decode JWT token'));
      }

      final userId = JwtUtils.getUserId(response.accessToken) ??
          userInfo['sub'] as String? ??
          email;
      final tokenCompanyId = JwtUtils.getCompanyId(response.accessToken);
      final tokenSiteId = JwtUtils.getSiteId(response.accessToken);
      final tokenSiteCode = JwtUtils.getSiteCode(response.accessToken);
      final roles = JwtUtils.getRoles(response.accessToken);
      final permissions = JwtUtils.getPermissions(response.accessToken);

      // Store tenant context from JWT token
      if (tokenCompanyId != null) {
        await _storage.write(key: _companyIdKey, value: tokenCompanyId);
        await CompanyIdStorage.saveCompanyId(tokenCompanyId);
      }

      // Fetch full user profile to get villaNumber and other details
      try {
        final userProfile = await _apiClient.getCurrentUser();
        print(
          '✅ Successfully fetched user profile - villaNumber: ${userProfile.villaNumber}',
        );

        // Map raw villas payload (if any) into TenantVillaEntity list
        final List<TenantVillaEntity> villas =
            (userProfile.villas ?? <Map<String, dynamic>>[])
                .map((Map<String, dynamic> v) {
          final dynamic rawNumber = v['villa_number'] ??
              v['villaNumber'] ??
              v['villa_number'.toString()];
          final String villaNumber = rawNumber?.toString() ?? '';
          return TenantVillaEntity(
            id: v['id'] as String,
            villaNumber: villaNumber,
            villaCode:
                (v['villa_code'] as String?) ?? (v['villaCode'] as String?),
            name: v['name'] as String?,
          );
        }).toList();

        return Right(
          UserEntity(
            id: userId,
            email: userProfile.email,
            companyId: tokenCompanyId ?? '',
            siteId: tokenSiteId ?? '',
            siteCode: tokenSiteCode ?? '',
            firstName: userProfile.firstName,
            lastName: userProfile.lastName,
            villaNumber: userProfile.villaNumber,
            villas: villas,
            phoneNumber: userProfile.phoneNumber, // Updated
            alternatePhoneNumber: userProfile.alternatePhoneNumber,
            leaseExpiryDate: userProfile.leaseExpiryDate,
            roles: roles,
            permissions: permissions,
          ),
        );
      } catch (e, stackTrace) {
        // Log error with details
        print('⚠️ Failed to fetch user profile: $e');
        print('Stack trace: $stackTrace');
        // Fallback to JWT data if profile fetch fails
        // Note: villaNumber will be null in this case
        print('⚠️ Falling back to JWT data (villaNumber will be null)');
        return Right(
          UserEntity(
            id: userId,
            email: email,
            companyId: tokenCompanyId ?? '',
            siteId: tokenSiteId ?? '',
            siteCode: tokenSiteCode ?? '',
            firstName: userInfo['firstName'] as String?,
            lastName: userInfo['lastName'] as String?,
            roles: roles,
            permissions: permissions,
          ),
        );
      }
    } on DioException catch (e) {
      // Map DioException (including validation errors) to a rich AppException
      final appException = ErrorHandler.handleError(e);

      // Clear stored company-id on error
      await _storage.delete(key: _companyIdKey);
      return Left(appException);
    } on Exception catch (e) {
      // Clear stored company-id on error
      await _storage.delete(key: _companyIdKey);
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> logout() async {
    try {
      // Attempt to call logout API (may fail if token is invalid, but that's okay)
      try {
        await _apiClient.logout();
      } catch (_) {
        // Ignore API errors during logout - we still want to clear local storage
      }

      // Clear all cache and user data comprehensively
      // This includes:
      // - All FlutterSecureStorage keys (tokens, company_id)
      // - SharedPreferences (company_id)
      // - Push notification device token
      // - Image cache
      await CacheClearService.clearAllCache();

      return const Right(null);
    } on Exception catch (e) {
      // Even if there's an error, try to clear all cache
      // This ensures user is logged out locally regardless of errors
      try {
        await CacheClearService.clearAllCache();
      } catch (clearError) {
        // Log but don't fail - partial cleanup is better than none
        print('⚠️ Error during cache clear on logout: $clearError');
      }
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, UserEntity>> getCurrentUser() async {
    try {
      // Check if we have a token
      var token = await _storage.read(key: _accessTokenKey);

      if (token == null) {
        return Left(Exception('No active session'));
      }

      // Check if token is expired and refresh if needed
      if (JwtUtils.isTokenExpired(token)) {
        final refreshResult = await refreshAccessToken();
        refreshResult.fold(
          (error) => throw error,
          (newToken) => token = newToken,
        );
      }

      // Decode JWT to get user info
      final userInfo = JwtUtils.getUserInfo(token!);
      if (userInfo == null) {
        return Left(Exception('Failed to decode JWT token'));
      }

      // Ensure token is non-null (we already checked with token!)
      final String nonNullToken = token!;

      // Extract user ID
      final userIdFromToken = JwtUtils.getUserId(nonNullToken);
      final userIdFromSub = userInfo['sub'] as String?;
      final userIdFromUserId = userInfo['userId'] as String?;
      final String userId =
          userIdFromToken ?? userIdFromSub ?? userIdFromUserId ?? '';

      // Extract company ID - prioritize token, then secure storage, then SharedPreferences
      final tokenCompanyId = JwtUtils.getCompanyId(nonNullToken);
      final secureStorageCompanyId = await _storage.read(key: _companyIdKey);
      final sharedPrefsCompanyId = await CompanyIdStorage.getCompanyId();
      
      final String companyIdString = tokenCompanyId ?? 
          secureStorageCompanyId ?? 
          sharedPrefsCompanyId ?? 
          '';
      
      if (companyIdString.isEmpty) {
        return Left(Exception('Company ID not found in token or context'));
      }
      
      // Ensure companyId is stored in both secure storage and SharedPreferences for consistency
      if (tokenCompanyId != null && tokenCompanyId != secureStorageCompanyId) {
        await _storage.write(key: _companyIdKey, value: tokenCompanyId);
      }
      if (tokenCompanyId != null && tokenCompanyId != sharedPrefsCompanyId) {
        await CompanyIdStorage.saveCompanyId(tokenCompanyId);
      }

      // Extract roles and permissions
      final List<String> roles = JwtUtils.getRoles(nonNullToken);
      final List<String> permissions = JwtUtils.getPermissions(nonNullToken);

      // Fetch full user profile to get villaNumber and other details
      try {
        final userProfile = await _apiClient.getCurrentUser();
        print(
          '✅ Successfully fetched user profile in getCurrentUser - villaNumber: ${userProfile.villaNumber}',
        );

        final List<TenantVillaEntity> villas =
            (userProfile.villas ?? <Map<String, dynamic>>[])
                .map((Map<String, dynamic> v) {
          final dynamic rawNumber = v['villa_number'] ??
              v['villaNumber'] ??
              v['villa_number'.toString()];
          final String villaNumber = rawNumber?.toString() ?? '';
          return TenantVillaEntity(
            id: v['id'] as String,
            villaNumber: villaNumber,
            villaCode:
                (v['villa_code'] as String?) ?? (v['villaCode'] as String?),
            name: v['name'] as String?,
          );
        }).toList();

        final tokenSiteId = JwtUtils.getSiteId(nonNullToken);
        final tokenSiteCode = JwtUtils.getSiteCode(nonNullToken);

        return Right(
          UserEntity(
            id: userId,
            email: userProfile.email,
            companyId: companyIdString,
            siteId: tokenSiteId ?? '',
            siteCode: tokenSiteCode ?? '',
            firstName: userProfile.firstName,
            lastName: userProfile.lastName,
            villaNumber: userProfile.villaNumber,
            villas: villas,
            phoneNumber: userProfile.phoneNumber, // Updated
            alternatePhoneNumber: userProfile.alternatePhoneNumber,
            leaseExpiryDate: userProfile.leaseExpiryDate,
            roles: roles,
            permissions: permissions,
          ),
        );
      } catch (e, stackTrace) {
        // Log error with details
        print('⚠️ Failed to fetch user profile in getCurrentUser: $e');
        print('Stack trace: $stackTrace');
        // Fallback to JWT data if profile fetch fails
        // Note: villaNumber will be null in this case
        print('⚠️ Falling back to JWT data (villaNumber will be null)');
        final tokenSiteId = JwtUtils.getSiteId(nonNullToken);
        final tokenSiteCode = JwtUtils.getSiteCode(nonNullToken);

        return Right(
          UserEntity(
            id: userId,
            email: (userInfo['email'] as String?) ?? '',
            companyId: companyIdString,
            siteId: tokenSiteId ?? '',
            siteCode: tokenSiteCode ?? '',
            firstName: userInfo['firstName'] as String?,
            lastName: userInfo['lastName'] as String?,
            roles: roles,
            permissions: permissions,
          ),
        );
      }
    } on Exception catch (e) {
      return Left(e);
    }
  }

  /// Refreshes the access token using the refresh token
  Future<Either<Exception, String>> refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        return Left(Exception('No refresh token available'));
      }

      final response = await _apiClient.refreshToken({
        'refreshToken': refreshToken,
      });

      // Store new tokens
      await _storage.write(key: _accessTokenKey, value: response.accessToken);
      await _storage.write(key: _refreshTokenKey, value: response.refreshToken);

      return Right(response.accessToken);
    } on Exception catch (e) {
      // Clear tokens on refresh failure
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _apiClient.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleError(e));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> forgotPassword(
    String email,
    String companyId,
  ) async {
    try {
      print('🔵 AuthRepository: forgotPassword called');
      print('📧 Email: $email');
      print('🏢 Company ID: $companyId');

      await _storage.write(key: _companyIdKey, value: companyId);
      print('✅ Company ID stored in secure storage');

      print('📞 Calling API client forgotPassword');
      await _apiClient.forgotPassword(email);
      print('✅ API call successful');

      return const Right(null);
    } on DioException catch (e) {
      print('❌ DioException in forgotPassword: $e');
      print('Response: ${e.response?.data}');
      return Left(ErrorHandler.handleError(e));
    } on Exception catch (e) {
      print('❌ Exception in forgotPassword: $e');
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, String>> verifyOtp(
    String email,
    String otp,
    String companyId,
  ) async {
    try {
      await _storage.write(key: _companyIdKey, value: companyId);
      final response = await _apiClient.verifyOtp(email, otp);
      final token = response['token'] as String? ?? '';
      if (token.isEmpty) {
        return Left(Exception('Token not found in response'));
      }
      return Right(token);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleError(e));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, void>> resetPassword(
    String email,
    String token,
    String newPassword,
    String companyId,
  ) async {
    try {
      await _storage.write(key: _companyIdKey, value: companyId);
      await _apiClient.resetPassword(email, token, newPassword);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleError(e));
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
