import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/signin');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email, 'Mot_de_passe': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Échec de la connexion',
      };
    }
  }

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String parentPin,
  }) async {
    final url = Uri.parse('$baseUrl/auth/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Nom': fullName,
        'numero_telephone': phone,
        'Email': email,
        'Mot_de_passe': password,
        'parentPin': parentPin,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': data['errormessage'] ?? 'Échec de l\'inscription',
      };
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'] ?? 'Lien de réinitialisation envoyé',
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Erreur lors de l\'envoi du lien',
      };
    }
  }

  /// ✅ L’ordre correct : email puis code
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final url = Uri.parse('$baseUrl/auth/verify-reset-code');
    print('Vérification code avec email: $email et code: $code');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email, 'code': code}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Code invalide ou expiré',
      };
    }
  }

  Future<void> resendCode(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erreur lors de l\'envoi du code');
    }
  }

  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': email,
        'code': code,
        'newPassword': newPassword,
        'confirmPassword': newPassword, // ajoute confirmPassword
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to reset password');
    }
  }
}
