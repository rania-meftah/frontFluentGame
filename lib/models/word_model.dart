class WordModel {
  final String id;
  final String word;
  final String? phonetic;
  final String? wordAudio;
  final List<String>? images;

  WordModel({
    required this.id,
    required this.word,
    this.phonetic,
    this.wordAudio,
    this.images,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['_id'],
      word: json['word'],
      phonetic: json['phonetic'],
      wordAudio: json['wordAudio'],
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
