abstract class NewPasswordState {}

class NewPasswordInitial extends NewPasswordState {}

class NewPasswordLoading extends NewPasswordState {}

class NewPasswordSuccess extends NewPasswordState {}

class NewPasswordFailure extends NewPasswordState {
  final String message;

  NewPasswordFailure(this.message);
}
