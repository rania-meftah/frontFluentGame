import '../../models/language_model.dart';

abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final List<LanguageModel> languages;
  LanguageLoaded(this.languages);
}

class LanguageSelected extends LanguageState {}

class LanguageError extends LanguageState {
  final String message;
  LanguageError(this.message);
}
