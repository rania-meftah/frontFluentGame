abstract class SignupEvent {}

class SubmitSignup extends SignupEvent {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String parentPin;

  SubmitSignup(
    this.fullName,
    this.phone,
    this.email,
    this.password,
    this.parentPin,
  );
}
