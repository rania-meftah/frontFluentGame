import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import '../../services/auth_service.dart'; // Assure-toi du bon chemin

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthService _authService;

  SignupBloc(this._authService) : super(SignupInitial()) {
    on<SubmitSignup>((event, emit) async {
      emit(SignupLoading());

      try {
        final result = await _authService.signup(
          fullName: event.fullName,
          phone: event.phone,
          email: event.email,
          password: event.password,
          parentPin: event.parentPin,
        );

        if (result['success']) {
          emit(SignupSuccess());
        } else {
          emit(SignupFailure(result['message']));
        }
      } catch (e) {
        emit(SignupFailure("Une erreur réseau s'est produite : $e"));
      }
    });
  }
}
