import '../../models/word_model.dart';

abstract class LessonState {}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonLoaded extends LessonState {
  final List<WordModel> words;
  final int currentIndex;

  LessonLoaded(this.words, this.currentIndex);

  WordModel get currentWord => words[currentIndex];
  bool get isLast => currentIndex == words.length - 1;
}

class LessonFinished extends LessonState {}

class LessonResultState extends LessonState {
  final int score;
  final String feedback;

  LessonResultState(this.score, this.feedback);
}

class LessonError extends LessonState {
  final String message;
  LessonError(this.message);
}
