import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/language_model.dart';

class LanguageService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.1.12:5000/api/language';

  Future<List<LanguageModel>> fetchLanguages() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception("Token manquant !");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("✅ Status: ${response.statusCode}");
      print("✅ Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LanguageModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Erreur backend: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des langues: $e');
      rethrow;
    }
  }

  Future<void> selectLanguage(String languageId) async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception("Token manquant !");
      }

      final response = await http.post(
        Uri.parse('$baseUrl/select'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'languageId': languageId}),
      );

      print("✅ SelectLanguage Status: ${response.statusCode}");
      print("✅ SelectLanguage Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur lors de la sélection de la langue : ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection de la langue: $e');
      rethrow;
    }
  }
}
