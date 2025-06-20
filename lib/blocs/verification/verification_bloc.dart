import 'package:flutter_bloc/flutter_bloc.dart';
import 'verification_event.dart';
import 'verification_state.dart';
import '../../services/auth_service.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final AuthService authService;

  VerificationBloc(this.authService) : super(VerificationInitial()) {
    on<SubmitVerificationCode>((event, emit) async {
      emit(VerificationLoading());
      try {
        final response = await authService.verifyCode(event.email, event.code);
        if (response['success']) {
          emit(VerificationSuccess(event.code)); // 👈 transmettre le code ici
        } else {
          emit(VerificationFailure(response['message'] ?? 'Erreur inconnue'));
        }
      } catch (e) {
        emit(VerificationFailure(e.toString()));
      }
    });

    on<ResendCodeEvent>((event, emit) async {
      emit(VerificationLoading());
      try {
        await authService.resendCode(event.email);
        emit(VerificationInitial());
      } catch (e) {
        emit(VerificationFailure("Erreur lors de l'envoi du code"));
      }
    });
  }
}
