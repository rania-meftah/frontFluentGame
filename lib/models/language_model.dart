class LanguageModel {
  final String id;
  final String name;

  LanguageModel({required this.id, required this.name});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(id: json['_id'], name: json['name']);
  }
}
