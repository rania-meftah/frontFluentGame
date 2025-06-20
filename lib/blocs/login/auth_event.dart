abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class GoogleLoginRequested extends AuthEvent {}

class PhoneLoginRequested extends AuthEvent {}
