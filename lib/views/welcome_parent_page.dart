import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeParentPage extends StatefulWidget {
  final String parentId;
  final String token;

  const WelcomeParentPage({
    Key? key,
    required this.parentId,
    required this.token,
  }) : super(key: key);

  @override
  State<WelcomeParentPage> createState() => _WelcomeParentPageState();
}

class _WelcomeParentPageState extends State<WelcomeParentPage> {
  @override
  void initState() {
    super.initState();
    _startTimerAndMarkSeen();
  }

  Future<void> _startTimerAndMarkSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcome_seen_${widget.parentId}', true);

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(
        context,
        '/choose-profile',
        arguments: {'parentId': widget.parentId, 'token': widget.token},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/family.png', width: 200),
              const SizedBox(height: 30),
              const Text(
                "🌟 Welcome, Super Parent!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 204, 125, 165),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "You've just opened the door to your child's speech journey.\nLet’s grow, play, and speak — together! 💖",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
