import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(UserEntity user) authenticated,
    required T Function() unauthenticated,
    required T Function(String message) error,
  }) {
    if (this is AuthInitial) {
      return initial();
    } else if (this is AuthLoading) {
      return loading();
    } else if (this is AuthAuthenticated) {
      return authenticated((this as AuthAuthenticated).user);
    } else if (this is AuthUnauthenticated) {
      return unauthenticated();
    } else if (this is AuthError) {
      return error((this as AuthError).message);
    }
    throw Exception('Unknown AuthState');
  }

  T? maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(UserEntity user)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
    T Function(String email)? forgotPasswordSent,
    T Function(String token, String email)? otpVerified,
    T Function()? passwordResetSuccess,
    required T Function() orElse,
  }) {
    if (this is AuthInitial && initial != null) {
      return initial();
    } else if (this is AuthLoading && loading != null) {
      return loading();
    } else if (this is AuthAuthenticated && authenticated != null) {
      return authenticated((this as AuthAuthenticated).user);
    } else if (this is AuthUnauthenticated && unauthenticated != null) {
      return unauthenticated();
    } else if (this is AuthError && error != null) {
      return error((this as AuthError).message);
    } else if (this is ForgotPasswordSent && forgotPasswordSent != null) {
      return forgotPasswordSent((this as ForgotPasswordSent).email);
    } else if (this is OtpVerified && otpVerified != null) {
      return otpVerified((this as OtpVerified).token, (this as OtpVerified).email);
    } else if (this is PasswordResetSuccess && passwordResetSuccess != null) {
      return passwordResetSuccess();
    }
    return orElse();
  }
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final UserEntity user;

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

class ForgotPasswordSent extends AuthState {
  const ForgotPasswordSent({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

class OtpVerified extends AuthState {
  const OtpVerified({required this.token, required this.email});

  final String token;
  final String email;

  @override
  List<Object> get props => [token, email];
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();

  @override
  List<Object> get props => [];
}

