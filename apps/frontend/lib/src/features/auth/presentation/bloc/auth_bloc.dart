import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<RefreshAuthEvent>(_onRefreshAuth);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  final AuthRepository _authRepository;

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(
      event.siteCode,
      event.email,
      event.password,
      companyId: event.companyId,
    );

    result.fold(
      (error) {
        String message;

        if (error is ValidationException) {
          // Prefer specific field error messages when available
          final fieldErrors = error.fieldErrors;
          if (fieldErrors != null && fieldErrors.isNotEmpty) {
            message = fieldErrors.values.first;
          } else {
            message = error.message;
          }
        } else if (error is AppException) {
          message = error.message;
        } else {
          message = error.toString();
        }

        emit(AuthError(message: message));
      },
      (user) => emit(
        AuthAuthenticated(user: user),
      ),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.logout();

    // Always emit unauthenticated state, even if API call fails
    // This ensures user is logged out locally regardless of network issues
    emit(const AuthUnauthenticated());

    result.fold(
      (error) {
        // Log error but don't change state (already unauthenticated)
        // In production, you might want to show a warning
      },
      (_) {
        // Successfully logged out
      },
    );
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.getCurrentUser();

    result.fold(
      (error) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onRefreshAuth(
    RefreshAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Intentionally NOT emitting AuthLoading to avoid UI flicker or redirects
    final result = await _authRepository.getCurrentUser();

    result.fold(
      (error) {
        // If refresh fails, we keep the current state unless it's critical
        // For now, we'll just log it and potentially keep the user logged in
        // if the error isn't about invalid credentials.
        // If we wanted to force logout on failure:
        // emit(const AuthUnauthenticated());
      },
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('🔵 AuthBloc: _onForgotPassword called');
    print('📧 Email: ${event.email}');
    print('🏢 Company ID: ${event.companyId}');

    emit(const AuthLoading());

    try {
      print('📞 Calling authRepository.forgotPassword');
      final result = await _authRepository.forgotPassword(
        event.email,
        event.companyId,
      );

      result.fold(
        (error) {
          print('❌ Forgot password error: $error');
          String message;
          if (error is AppException) {
            message = error.message;
          } else {
            message = error.toString();
          }
          emit(AuthError(message: message));
        },
        (_) {
          print('✅ Forgot password success, emitting ForgotPasswordSent');
          emit(ForgotPasswordSent(email: event.email));
        },
      );
    } catch (e, stackTrace) {
      print('💥 Exception in _onForgotPassword: $e');
      print('Stack trace: $stackTrace');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.verifyOtp(
      event.email,
      event.otp,
      event.companyId,
    );

    result.fold(
      (error) {
        String message;
        if (error is AppException) {
          message = error.message;
        } else {
          message = error.toString();
        }
        emit(AuthError(message: message));
      },
      (token) => emit(OtpVerified(token: token, email: event.email)),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.resetPassword(
      event.email,
      event.token,
      event.newPassword,
      event.companyId,
    );

    result.fold(
      (error) {
        String message;
        if (error is AppException) {
          message = error.message;
        } else {
          message = error.toString();
        }
        emit(AuthError(message: message));
      },
      (_) => emit(const PasswordResetSuccess()),
    );
  }
}
