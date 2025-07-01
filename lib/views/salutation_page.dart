// user_home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'avatar_selection_page.dart';

class UserHomePage extends StatefulWidget {
  final String childId;
  final String parentId;
  final String childName;
  final bool isFirstLogin;

  const UserHomePage({
    super.key,
    required this.childId,
    required this.parentId,
    required this.childName,
    required this.isFirstLogin, required level,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => AvatarSelectionPage(
                childId: widget.childId,
                parentId: widget.parentId,
              ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello ${widget.childName} 👋',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/images/hello.png', width: 260, height: 260),
            const SizedBox(height: 12),
            const Text(
              'We’re happy to see you today!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
