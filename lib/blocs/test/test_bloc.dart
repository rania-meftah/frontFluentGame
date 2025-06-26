import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'test_event.dart';
import 'test_state.dart';
import '../../repositories/test_repository.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  TestBloc(this.repository) : super(TestInitial()) {
    on<LoadTestWords>(_onLoad);
    on<NextWord>(_onNext);
  }

  Future<void> _onLoad(LoadTestWords event, Emitter<TestState> emit) async {
    emit(TestLoading());
    try {
      final token = await storage.read(key: 'auth_token') ?? '';
      if (token.isEmpty) throw Exception("Token manquant !");
      final data = await repository.fetchTestWords();
      emit(TestLoaded(data, 0));
    } catch (e) {
      emit(TestError("Erreur de chargement : ${e.toString()}"));
    }
  }

  void _onNext(NextWord event, Emitter<TestState> emit) {
    if (state is TestLoaded) {
      final loaded = state as TestLoaded;
      if (!loaded.isLast) {
        emit(TestLoaded(loaded.words, loaded.currentIndex + 1));
      } else {
        emit(TestFinished());
      }
    }
  }
}
