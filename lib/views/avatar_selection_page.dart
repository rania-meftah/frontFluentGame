import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_flutter_app/blocs/language/language_bloc.dart';
import 'package:my_flutter_app/services/language_service.dart';
import 'package:my_flutter_app/views/select_language_page.dart';

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

    final url = Uri.parse('http://192.168.1.12:5000/user/avatar');

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
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Choose your avatar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Partie scrollable avec Grid
                      Expanded(
                        child: GridView.builder(
                          itemCount: avatarPaths.length,
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
                                    avatarPaths[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Bouton en bas
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
                                  avatarPaths[selectedAvatarIndex!];
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
                                        child: const SelectLanguagePage(),
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Veuillez sélectionner un avatar.",
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Continue',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
