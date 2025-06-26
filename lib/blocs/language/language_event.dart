abstract class LanguageEvent {}

class LoadLanguagesEvent extends LanguageEvent {
  final String childId;

  LoadLanguagesEvent(this.childId);
}

class SelectLanguageEvent extends LanguageEvent {
  final String languageId;
  final String childId;

  SelectLanguageEvent(this.languageId, this.childId);
}
