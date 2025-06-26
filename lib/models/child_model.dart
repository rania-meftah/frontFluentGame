class ChildModel {
  final String id;
  final String name;
  final int age;
  final bool isFirstLogin;
  final String? selectedLanguage;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.isFirstLogin,
    this.selectedLanguage,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['_id'],
      name: json['name'],
      age: json['age'] ?? 0,
      isFirstLogin: json['isFirstLogin'] ?? true,
      selectedLanguage: json['selectedLanguage'], // 🔥 ici
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'isFirstLogin': isFirstLogin,
    'selectedLanguage': selectedLanguage, // 🔥 ici
  };
}
