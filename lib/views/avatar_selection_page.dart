import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({Key? key}) : super(key: key);

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  int? selectedAvatarIndex;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final List<String> avatarPaths = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png',
    'assets/avatars/avatar9.png',
  ];

  Future<void> updateAvatar(String avatarPath) async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      print('Token manquant !');
      return;
    }

    final url = Uri.parse('http://127.0.0.1:5000/user/avatar');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'avatar': avatarPath}),
    );

    if (response.statusCode == 200) {
      print('✅ Avatar mis à jour avec succès');
    } else {
      print('❌ Erreur: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calcul dynamique de la taille des avatars
    final int crossAxisCount =
        3; // tu peux changer à 4 ou 5 pour écran plus large
    final double paddingHorizontal = 16 * 2; // padding total horizontal
    final double spacing =
        10 * (crossAxisCount - 1); // total espace entre items

    final double avatarSize =
        (screenWidth - paddingHorizontal - spacing) / crossAxisCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Avatar'),
        backgroundColor: const Color(0xFFF09935),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Choose your avatar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: avatarPaths.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1, // carré
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatarIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              selectedAvatarIndex == index
                                  ? const Color(0xFFF09935)
                                  : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          avatarPaths[index],
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF09935),
                ),
                onPressed: () async {
                  if (selectedAvatarIndex != null) {
                    final selectedAvatar = avatarPaths[selectedAvatarIndex!];
                    await updateAvatar(selectedAvatar);
                    Navigator.pop(context, selectedAvatar);
                  }
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
