class UserModel {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String parentPin; // 🔐 Nouveau champ

  UserModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.parentPin, // obligatoire au signup
  });

  Map<String, dynamic> toJson() => {
    "Nom": fullName,
    "numero_telephone": phone,
    "Email": email,
    "Mot_de_passe": password,
    "parentPin": parentPin, 
  };
}
