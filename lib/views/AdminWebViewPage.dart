import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminWebViewPage extends StatelessWidget {
  const AdminWebViewPage({super.key});

  Future<void> _openDashboard() async {
    final Uri url = Uri.parse('https://mon-dashboard-admin.com');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode:
            LaunchMode.externalApplication, // Ouvre dans le navigateur externe
      );
    } else {
      throw 'Impossible d\'ouvrir le lien : $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Appelle automatiquement l'ouverture au démarrage de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openDashboard();
      Navigator.pop(context); // ferme cette page après ouverture
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Petit loader temporaire
      ),
    );
  }
}
