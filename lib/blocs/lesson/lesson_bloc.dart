import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/lesson_repository.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonRepository repository;

  LessonBloc(this.repository) : super(LessonInitial()) {
    on<LoadLessonWords>(_onLoad);
    on<NextLessonWord>(_onNext);
    on<FinishLessonEvent>(_onFinish);
  }

  Future<void> _onLoad(LoadLessonWords event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      final words = await repository.fetchLessonWords(
        event.domainId,
        event.lessonNumber,
        event.level,
      );
      emit(LessonLoaded(words, 0));
    } catch (e) {
      emit(LessonError("Erreur chargement : $e"));
    }
  }

  void _onNext(NextLessonWord event, Emitter<LessonState> emit) {
    if (state is LessonLoaded) {
      final loaded = state as LessonLoaded;
      if (!loaded.isLast) {
        emit(LessonLoaded(loaded.words, loaded.currentIndex + 1));
      } else {
        emit(LessonFinished());
      }
    }
  }

  Future<void> _onFinish(
    FinishLessonEvent event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());
    try {
      final result = await repository.finishLesson(
        event.wordResults,
        event.domainId,
        event.lessonNumber,
      );
      emit(LessonResultState(result['score'], result['feedback']));
    } catch (e) {
      emit(LessonError("Erreur soumission : $e"));
    }
  }
}
