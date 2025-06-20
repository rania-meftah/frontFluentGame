// verification_event.dart

abstract class VerificationEvent {}

// ✅ Utilisation de paramètres nommés avec `required`
class SubmitVerificationCode extends VerificationEvent {
  final String email;
  final String code;

  SubmitVerificationCode({required this.email, required this.code});
}

// Tu peux garder ResendCodeEvent tel quel si tu veux des paramètres positionnels
class ResendCodeEvent extends VerificationEvent {
  final String email;

  ResendCodeEvent(this.email);
}
