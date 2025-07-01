class ChildModel {
  final String id;
  final String name;
  final int age;
  final bool isFirstLogin;
  final String? selectedLanguage;
  final String? avatar;
  final String? level; // ✅ ajouté

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.isFirstLogin,
    this.selectedLanguage,
    this.avatar,
    this.level,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['_id'],
      name: json['name'],
      age: json['age'] ?? 0,
      isFirstLogin: json['isFirstLogin'] ?? true,
      selectedLanguage: json['selectedLanguage'],
      avatar: json['avatar'],
      level: json['level'], // ✅
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'isFirstLogin': isFirstLogin,
    'selectedLanguage': selectedLanguage,
    'avatar': avatar,
    'level': level, // ✅
  };
}
