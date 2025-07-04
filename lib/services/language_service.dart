import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/language_model.dart';
import '../constants.dart';

class LanguageService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<List<LanguageModel>> fetchLanguages() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception("Token manquant !");

      final response = await http.get(
        Uri.parse('$baseUrl/api/language/all'),
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

  Future<void> selectLanguage(String languageId, String childId) async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception("Token manquant !");

      final response = await http.post(
        Uri.parse('$baseUrl/api/language/select'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'languageId': languageId, 'childId': childId}),
      );

      print("✅ SelectLanguage Status: ${response.statusCode}");
      print("✅ SelectLanguage Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur lors de la sélection de la langue : ${response.body}',
        );
      }

      // ✅ EXTRACTION ET STOCKAGE DU NOUVEAU TOKEN ENFANT
      final data = json.decode(response.body);
      final childToken = data['token']; // <- récupéré depuis backend

      if (childToken != null) {
        await storage.write(key: 'child_token', value: childToken);
        print("✅ Token enfant stocké avec succès !");
      } else {
        print("⚠️ Avertissement : Pas de token enfant retourné !");
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection de la langue: $e');
      rethrow;
    }
  }
}
