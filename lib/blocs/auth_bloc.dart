import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _authService.login(event.email, event.password);
        if (result['success']) {
          await storage.write(
            key: 'auth_token',
            value: result['data']['token'],
          );
          emit(AuthSuccess(result['data']['user']['role'] ?? 'user'));
        } else {
          emit(AuthFailure(result['message']));
        }
      } catch (e) {
        emit(AuthFailure('An error occurred: $e'));
      }
    });
  }
}
