class UserModel {
  final String fullName;
  final String phone;
  final String email;
  final String password;

  UserModel({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });

  // ✅ Corriger les clés envoyées au backend
  Map<String, dynamic> toJson() => {
    "Nom": fullName,
    "numero_telephone": phone,
    "Email": email,
    "Mot_de_passe": password,
  };
}
