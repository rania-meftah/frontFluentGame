abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String userId;
  final String token;

  AuthSuccess({required this.userId, required this.token});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
