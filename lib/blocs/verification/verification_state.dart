abstract class VerificationState {}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationSuccess extends VerificationState {
  final String code;

  VerificationSuccess(this.code);
}

class VerificationFailure extends VerificationState {
  final String message;

  VerificationFailure(this.message);
}
