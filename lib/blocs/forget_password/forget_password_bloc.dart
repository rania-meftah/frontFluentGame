import 'package:flutter_bloc/flutter_bloc.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';
import '../../services/auth_service.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final AuthService authService;

  ForgetPasswordBloc(this.authService) : super(ForgetPasswordInitial()) {
    on<SendResetLinkEvent>((event, emit) async {
      emit(ForgetPasswordLoading());
      try {
        final response = await authService.forgotPassword(event.email);
        if (response['success']) {
          emit(ForgetPasswordSuccess());
        } else {
          emit(ForgetPasswordFailure(response['message'] ?? 'Erreur inconnue'));
        }
      } catch (e) {
        emit(ForgetPasswordFailure('Erreur : ${e.toString()}'));
      }
    });
  }
}
