import 'package:driver_app/features/auth/domain/entities/auth_user_entity.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class OtpSent extends AuthState {
  final String message;
  const OtpSent(this.message);
}

class OtpResent extends AuthState {
  final String message;
  const OtpResent(this.message);
}

class OtpVerified extends AuthState {
  final AuthResponseEntity response;
  const OtpVerified(this.response);
}

class LoggedOut extends AuthState {}

class AccountDeleted extends AuthState {}
