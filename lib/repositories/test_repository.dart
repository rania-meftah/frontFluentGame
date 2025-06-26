import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/word_model.dart';

class TestRepository {
  final String baseUrl = "http://192.168.1.12:5000";
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
}
