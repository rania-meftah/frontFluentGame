import 'dart:async';
import 'package:flutter/material.dart';
import 'avatar_selection_page.dart';

class UserHomePage extends StatefulWidget {
  final String childId;
  final String parentId;
  const UserHomePage({Key? key, required this.childId, required this.parentId})
    : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  void initState() {
    super.initState();
    // Redirection automatique après 3 secondes
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
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/hello.png',
          width: 300, // Image plus grande
          height: 300,
        ),
      ),
    );
  }
}
