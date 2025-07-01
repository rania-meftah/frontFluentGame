import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/word_model.dart';
import '../constants.dart';

class TestRepository {
  final storage = FlutterSecureStorage();

  Future<List<WordModel>> fetchTestWords() async {
    final token = await storage.read(key: 'child_token');
    if (token == null) {
      throw Exception("❌ Token enfant manquant !");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/test-words"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("🔽 Réponse brute du backend : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<WordModel>.from(data.map((w) => WordModel.fromJson(w)));
    } else {
      throw Exception(
        "❌ Erreur de chargement des mots : ${response.statusCode}",
      );
    }
  }

  Future<Map<String, dynamic>> finishTest(
    List<Map<String, dynamic>> wordResults,
    String langue,
  ) async {
    final token = await storage.read(key: 'child_token');
    final response = await http.post(
      Uri.parse("$baseUrl/api/finish"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'langue': langue, 'wordResults': wordResults}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur lors de l'enregistrement du test");
    }
  }
}
