import '../../models/word_model.dart';

abstract class TestState {}

class TestInitial extends TestState {}

class TestLoading extends TestState {}

class TestLoaded extends TestState {
  final List<WordModel> words;
  final int currentIndex;

  TestLoaded(this.words, this.currentIndex);

  WordModel get currentWord => words[currentIndex];

  bool get isLast => currentIndex == words.length - 1;
}

class TestFinished extends TestState {}

class TestError extends TestState {
  final String message;

  TestError(this.message);
}

class TestResultState extends TestState {
  final int score;
  final String feedback;

  TestResultState(this.score, this.feedback);
}
