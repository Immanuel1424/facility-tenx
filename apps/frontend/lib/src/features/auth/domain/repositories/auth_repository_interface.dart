import 'package:fpdart/fpdart.dart';

import '../entities/user_entity.dart';

abstract class AuthRepositoryInterface {
  Future<Either<Exception, UserEntity>> login(
    String siteCode,
    String email,
    String password, {
    String? companyId,
  });
  Future<Either<Exception, void>> logout();
  Future<Either<Exception, UserEntity>> getCurrentUser();
  Future<Either<Exception, void>> changePassword(
    String currentPassword,
    String newPassword,
  );
  Future<Either<Exception, void>> forgotPassword(
    String email,
    String companyId,
  );
  Future<Either<Exception, String>> verifyOtp(
    String email,
    String otp,
    String companyId,
  );
  Future<Either<Exception, void>> resetPassword(
    String email,
    String token,
    String newPassword,
    String companyId,
  );
}
