import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_flutter_app/models/DomaineModel.dart';
import '../constants.dart';

class DomaineRepository {
  final storage = FlutterSecureStorage();

  Future<List<DomaineModel>> fetchDomaines() async {
    try {
      final token = await storage.read(key: 'child_token');
      if (token == null) throw Exception("❌ Token enfant manquant");

      print("📤 Appel API GET /api/domaines avec token: $token");

      final response = await http.get(
        Uri.parse('$baseUrl/api/domaines'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📥 Status code: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<DomaineModel>.from(
          data.map((d) => DomaineModel.fromJson(d)),
        );
      } else {
        throw Exception(
          "Erreur chargement domaines (code ${response.statusCode})",
        );
      }
    } catch (e) {
      print("❌ Erreur fetchDomaines: $e");
      throw Exception("Erreur chargement domaines");
    }
  }
}
