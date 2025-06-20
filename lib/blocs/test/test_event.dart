abstract class TestEvent {}

class LoadTestWords extends TestEvent {}

class SubmitWordAudio extends TestEvent {
  final String wordId;
  final String filePath;

  SubmitWordAudio(this.wordId, this.filePath);
}

class NextWord extends TestEvent {}
