abstract class SignupEvent {}

class SubmitSignup extends SignupEvent {
  final String fullName;
  final String phone;
  final String email;
  final String password;

  SubmitSignup(this.fullName, this.phone, this.email, this.password);
}
