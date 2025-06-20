abstract class LanguageEvent {}

class LoadLanguagesEvent extends LanguageEvent {}

class SelectLanguageEvent extends LanguageEvent {
  final String languageId;
  SelectLanguageEvent(this.languageId);
}
