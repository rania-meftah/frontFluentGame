abstract class ForgetPasswordEvent {}

class SendResetLinkEvent extends ForgetPasswordEvent {
  final String email;
  SendResetLinkEvent(this.email);
}
