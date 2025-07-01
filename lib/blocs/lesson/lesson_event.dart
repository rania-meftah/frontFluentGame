abstract class LessonEvent {}

class LoadLessonWords extends LessonEvent {
  final String domainId;
  final int lessonNumber;
  final String level;

  LoadLessonWords(this.domainId, this.lessonNumber, this.level);
}

class NextLessonWord extends LessonEvent {}

class FinishLessonEvent extends LessonEvent {
  final List<Map<String, dynamic>> wordResults;
  final String domainId;
  final int lessonNumber;

  FinishLessonEvent(this.wordResults, this.domainId, this.lessonNumber);
}
