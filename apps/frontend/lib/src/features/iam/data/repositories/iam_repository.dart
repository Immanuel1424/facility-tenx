import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/network/api_client.dart';
import '../dto/role_dto.dart';
import '../dto/permission_dto.dart';
import '../dto/user_dto.dart';
import '../mappers/role_mapper.dart';
import '../mappers/permission_mapper.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/permission_entity.dart';

class IamRepository {
  IamRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  // Roles
  Future<Either<Exception, List<RoleEntity>>> getRoles(
      {String? companyId}) async {
    try {
      final dtos = await _apiClient.getRoles(companyId: companyId);
      final entities = dtos.map(RoleMapper.dtoToEntity).toList();
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, RoleEntity>> getRole(String id) async {
    try {
      final dto = await _apiClient.getRole(id);
      return Right(RoleMapper.dtoToEntity(dto));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, RoleEntity>> createRole(CreateRoleDto dto) async {
    try {
      final response = await _apiClient.createRole(dto);
      return Right(RoleMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, RoleEntity>> updateRole(
    String id,
    UpdateRoleDto dto,
  ) async {
    try {
      final response = await _apiClient.updateRole(id, dto);
      return Right(RoleMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> deleteRole(String id) async {
    try {
      await _apiClient.deleteRole(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> assignPermissionToRole(
    String roleId,
    String permissionId,
  ) async {
    try {
      await _apiClient.assignPermissionToRole(
        roleId,
        AssignPermissionDto(permissionId: permissionId),
      );
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Permissions
  Future<Either<Exception, List<PermissionEntity>>> getPermissions() async {
    try {
      final dtos = await _apiClient.getPermissions();
      final entities = dtos.map(PermissionMapper.dtoToEntity).toList();
      return Right(entities);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, PermissionEntity>> getPermission(String id) async {
    try {
      final dto = await _apiClient.getPermission(id);
      return Right(PermissionMapper.dtoToEntity(dto));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, PermissionEntity>> createPermission(
    CreatePermissionDto dto,
  ) async {
    try {
      final response = await _apiClient.createPermission(dto);
      return Right(PermissionMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, PermissionEntity>> updatePermission(
    String id,
    UpdatePermissionDto dto,
  ) async {
    try {
      final response = await _apiClient.updatePermission(id, dto);
      return Right(PermissionMapper.dtoToEntity(response));
    } on Exception catch (e) {
      return Left(e);
    }
  }

  Future<Either<Exception, void>> deletePermission(String id) async {
    try {
      await _apiClient.deletePermission(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  // Users
  Future<Either<Exception, List<UserDto>>> getUsers({String? companyId}) async {
    try {
      final response = await _apiClient.getUsers(companyId: companyId);
      // Sort by createdAt descending (newest first)
      final sortedResponse = List<UserDto>.from(response)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(sortedResponse);
    } on DioException catch (e) {
      // Handle 404 gracefully - no users is an empty list, not an error
      if (e.response?.statusCode == 404) {
        return const Right([]);
      }
      // Extract user-friendly error message from response
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, UserDto>> getUser(String id, {String? companyId}) async {
    try {
      final response = await _apiClient.getUser(id, companyId: companyId);
      return Right(response);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, UserDto>> createUser(CreateUserDto dto) async {
    try {
      final response = await _apiClient.createUser(dto);
      return Right(response);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, UserDto>> updateUser(
    String id,
    UpdateUserDto dto,
  ) async {
    try {
      final response = await _apiClient.updateUser(id, dto);
      return Right(response);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, UserDto>> activateUser(String id) async {
    try {
      final response = await _apiClient.activateUser(id);
      return Right(response);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, UserDto>> deactivateUser(String id) async {
    try {
      final response = await _apiClient.deactivateUser(id);
      return Right(response);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, void>> resetUserPassword(
    String id,
    ResetPasswordDto dto,
  ) async {
    try {
      await _apiClient.resetUserPassword(id, dto);
      return const Right(null);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, void>> assignRoleToUser(
    String userId,
    String roleId,
  ) async {
    try {
      await _apiClient.assignRoleToUser(
        userId,
        AssignRoleDto(userId: userId, roleId: roleId),
      );
      return const Right(null);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, void>> deleteUser(String id) async {
    try {
      await _apiClient.deleteUser(id);
      return const Right(null);
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      return Left(Exception(errorMessage));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  /// Extract user-friendly error message from DioException
  String _extractErrorMessage(DioException e) {
    // Try to extract message from response body
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        // Check common error message fields
        final message = data['message'] as String? ??
            data['error'] as String? ??
            data['msg'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    }

    // Use status code to provide helpful messages
    final statusCode = e.response?.statusCode;
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. This resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        // Use the exception message or type if available
        if (e.message != null && e.message!.isNotEmpty) {
          return e.message!;
        }
        return 'An error occurred: ${e.type}';
    }
  }
}
