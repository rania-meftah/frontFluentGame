import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';

class TestRepository {
  final String baseUrl = "http://192.168.1.12:5000";

  Future<List<WordModel>> fetchTestWords(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/test-words"),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("🔽 Réponse brute du backend : ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Données parsées : $data");

      return List<WordModel>.from(data.map((w) => WordModel.fromJson(w)));
    } else {
      throw Exception("Erreur de chargement des mots");
    }
  }
}
