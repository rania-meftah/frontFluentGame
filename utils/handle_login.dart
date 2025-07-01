import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/views/welcome_parent_page.dart';

Future<void> handleLogin(
  BuildContext context,
  String parentId,
  String token,
) async {
  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('welcome_seen_$parentId') ?? false;

  if (!seen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomeParentPage(parentId: parentId, token: token),
      ),
    );
  } else {
    Navigator.pushReplacementNamed(
      context,
      '/choose-profile',
      arguments: {'parentId': parentId, 'token': token},
    );
  }
}
