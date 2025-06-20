abstract class NewPasswordEvent {}

class SubmitNewPasswordEvent extends NewPasswordEvent {
  final String email;
  final String code;
  final String newPassword;

  SubmitNewPasswordEvent({
    required this.email,
    required this.code,
    required this.newPassword,
  });
}
