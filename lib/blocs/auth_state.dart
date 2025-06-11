abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String role;
  AuthSuccess(this.role);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
