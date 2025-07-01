import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_flutter_app/views/HomeChildPage.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final String feedback;

  const ResultPage({super.key, required this.score, required this.feedback});

  // 🔁 Fonction pour déduire le niveau à partir du score
  String getLevelFromScore(int score) {
    if (score >= 85) return 'Hard';
    if (score >= 60) return 'Medium';
    return 'Easy';
  }

  @override
  Widget build(BuildContext context) {
    String imagePath;
    if (score >= 90) {
      imagePath = "assets/images/cat_celebrate.png";
    } else if (score >= 60) {
      imagePath = "assets/images/cat_okay.png";
    } else {
      imagePath = "assets/images/cat_sad.png";
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Result Of Your Practice Test",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(imagePath, height: 160),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  // ✅ Déduire le niveau
                  final level = getLevelFromScore(score);

                  // ✅ Enregistrer le niveau en local
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'child_level', value: level);

                  // ✅ Rediriger vers la page d’accueil de l’enfant
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeChildPage()),
                  );
                },
                child: const Text(
                  "Start Your Journey",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
