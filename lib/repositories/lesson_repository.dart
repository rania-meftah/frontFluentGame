import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/word_model.dart';

class LessonRepository {
  final _storage = const FlutterSecureStorage();

  Future<List<WordModel>> fetchLessonWords(
    String domainId,
    int lessonNumber,
    String level,
  ) async {
    final token = await _storage.read(key: 'child_token');
    if (token == null) throw Exception("❌ Token enfant manquant");

    final url = '$baseUrl/api/lesson/$domainId/$lessonNumber?level=$level';
    print("📤 URL GET: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📥 Status code: ${response.statusCode}');
    print('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['words'] == null || data['words'] is! List) {
        throw Exception("❌ Format invalide: ${data.toString()}");
      }

      return (data['words'] as List).map((e) => WordModel.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      throw Exception("❌ Aucune leçon trouvée pour ce niveau");
    } else {
      throw Exception('❌ Erreur ${response.statusCode}: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> finishLesson(
    List<Map<String, dynamic>> results,
    String domainId,
    int lessonNumber,
  ) async {
    final token = await _storage.read(key: 'child_token');
    if (token == null) throw Exception("❌ Token enfant manquant");

    final response = await http.post(
      Uri.parse('$baseUrl/api/finish-lesson'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "domain": domainId,
        "lessonNumber": lessonNumber,
        "wordResults": results,
        "sentenceResults": [],
      }),
    );

    print('📤 POST /finish-lesson status: ${response.statusCode}');
    print('📤 Response: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('❌ Erreur ${response.statusCode}: ${response.body}');
    }
  }
}
