import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:my_flutter_app/blocs/language/language_bloc.dart';
import 'package:my_flutter_app/services/language_service.dart';
import 'package:my_flutter_app/views/select_language_page.dart';
import '../constants.dart';

class AvatarSelectionPage extends StatefulWidget {
  final String childId;
  final String parentId;

  const AvatarSelectionPage({
    super.key,
    required this.childId,
    required this.parentId,
  });

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  int? selectedAvatarIndex;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// ✅ Liste des noms de fichiers sans chemin complet
  final List<String> avatarNames = [
    'avatar1.png',
    'avatar2.png',
    'avatar3.png',
    'avatar4.png',
    'avatar5.png',
    'avatar6.png',
    'avatar7.png',
    'avatar8.png',
    'avatar9.png',
  ];

  /// ✅ Envoie avatarName au backend
  Future<void> updateAvatar(String avatarName) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      print('❌ Token manquant !');
      return;
    }

    final url = Uri.parse(
      '$baseUrl/api/parent/${widget.parentId}/child/${widget.childId}/settings',
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'avatar': avatarName, // ✅ avatar9.png uniquement
        'isFirstLogin': false,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Avatar mis à jour avec succès');
    } else {
      print('❌ Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Choisis ton avatar préféré 🎨',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.builder(
                      itemCount: avatarNames.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
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
                                'assets/avatars/${avatarNames[index]}', // ✅ Affichage
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF09935),
                      ),
                      onPressed: () async {
                        if (selectedAvatarIndex != null) {
                          final selectedAvatar =
                              avatarNames[selectedAvatarIndex!];
                          await updateAvatar(selectedAvatar);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BlocProvider(
                                    create:
                                        (_) => LanguageBloc(
                                          service: LanguageService(),
                                        ),
                                    child: SelectLanguagePage(
                                      childId: widget.childId,
                                    ),
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Veuillez sélectionner un avatar."),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Continuer',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
