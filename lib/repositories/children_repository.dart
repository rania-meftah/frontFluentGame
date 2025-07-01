import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/child_model.dart';
import '../constants.dart';

class ChildrenRepository {
  // 🔍 Récupérer la liste des enfants
  Future<List<ChildModel>> fetchChildren(String parentId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/parent/$parentId/children'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is Map && data.containsKey('children')) {
        final children = data['children'];
        if (children is List) {
          return children.map((e) => ChildModel.fromJson(e)).toList();
        }
      }

      return [];
    } else {
      throw Exception(
        'Erreur lors du chargement des enfants (${response.statusCode})',
      );
    }
  }

  // ✅ Ajouter un enfant (corrigé)
  Future<String> addChild(
    String parentId,
    ChildModel child,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/parent/$parentId/add-child'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(child.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      final childToken = data['token'];
      if (childToken == null) {
        throw Exception("Aucun token enfant reçu.");
      }
      return childToken;
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? "Erreur lors de l'ajout");
    }
  }

  // 🗑 Supprimer un enfant
  Future<void> deleteChild(
    String parentId,
    String childId,
    String token,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/parent/$parentId/delete-child/$childId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de l’enfant');
    }
  }

  // 🔐 Vérifier le code PIN côté backend
  Future<bool> verifyPin({
    required String token,
    required String parentId,
    required String pin,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/verify-parent-pin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'pin': pin,
        'userId': parentId, // ou 'parentId', selon ton naming
      }),
    );

    if (response.statusCode == 200) {
      // PIN correct
      return true;
    } else if (response.statusCode == 401 || response.statusCode == 400) {
      // PIN incorrect ou autre erreur liée au pin
      return false;
    } else {
      // Autre erreur serveur
      throw Exception('Erreur serveur lors de la vérification du PIN');
    }
  }
}
