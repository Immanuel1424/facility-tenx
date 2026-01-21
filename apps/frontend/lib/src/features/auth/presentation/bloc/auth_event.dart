import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  const LoginEvent({
    required this.siteCode,
    required this.email,
    required this.password,
    this.companyId,
  });

  final String siteCode;
  final String email;
  final String password;
  final String? companyId;

  @override
  List<Object?> get props => [siteCode, email, password, companyId];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class RefreshAuthEvent extends AuthEvent {
  const RefreshAuthEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  const ForgotPasswordEvent({
    required this.email,
    required this.companyId,
  });

  final String email;
  final String companyId;

  @override
  List<Object> get props => [email, companyId];
}

class VerifyOtpEvent extends AuthEvent {
  const VerifyOtpEvent({
    required this.email,
    required this.otp,
    required this.companyId,
  });

  final String email;
  final String otp;
  final String companyId;

  @override
  List<Object> get props => [email, otp, companyId];
}

class ResetPasswordEvent extends AuthEvent {
  const ResetPasswordEvent({
    required this.email,
    required this.token,
    required this.newPassword,
    required this.companyId,
  });

  final String email;
  final String token;
  final String newPassword;
  final String companyId;

  @override
  List<Object> get props => [email, token, newPassword, companyId];
}
