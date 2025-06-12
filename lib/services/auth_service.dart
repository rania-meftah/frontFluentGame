import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('http://192.168.1.14:5000/auth/signin');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email, 'Mot_de_passe': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }
}
