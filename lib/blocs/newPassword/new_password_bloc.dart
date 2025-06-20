import 'package:flutter_bloc/flutter_bloc.dart';
import 'new_password_event.dart';
import 'new_password_state.dart';
import '../../services/auth_service.dart';

class NewPasswordBloc extends Bloc<NewPasswordEvent, NewPasswordState> {
  final AuthService authService;

  NewPasswordBloc({required this.authService}) : super(NewPasswordInitial()) {
    on<SubmitNewPasswordEvent>((event, emit) async {
      emit(NewPasswordLoading());

      try {
        final success = await authService.resetPassword(
          event.email,
          event.code,
          event.newPassword,
        );

        if (success) {
          emit(NewPasswordSuccess());
        } else {
          emit(NewPasswordFailure('Erreur lors de la réinitialisation'));
        }
      } catch (e) {
        emit(NewPasswordFailure(e.toString()));
      }
    });
  }
}
