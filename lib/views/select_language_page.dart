import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/views/test_page.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';
import '../models/language_model.dart';

class SelectLanguagePage extends StatefulWidget {
  final String childId;

  const SelectLanguagePage({super.key, required this.childId});

  @override
  State<SelectLanguagePage> createState() => _SelectLanguagePageState();
}

class _SelectLanguagePageState extends State<SelectLanguagePage> {
  String? selectedLanguageId;

  @override
  void initState() {
    super.initState();
    context.read<LanguageBloc>().add(
      LoadLanguagesEvent(
        widget.childId, // ✅ envoyer le bon childId ici
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Image en haut
                Image.asset(
                  'assets/images/cible.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),

                // ✅ Titre
                const Text(
                  "What would you like to learn..?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ Liste déroulante (DropdownButton)
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, state) {
                    if (state is LanguageLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is LanguageLoaded) {
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: selectedLanguageId,
                        hint: const Text("Select a language"),
                        items:
                            state.languages.map((LanguageModel lang) {
                              return DropdownMenuItem(
                                value: lang.id,
                                child: Text(lang.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() => selectedLanguageId = value);
                        },
                      );
                    } else if (state is LanguageError) {
                      return Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    return Container();
                  },
                ),

                const SizedBox(height: 30),

                // ✅ Bouton Continuer
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        selectedLanguageId == null
                            ? null
                            : () {
                              // ✅ Envoie de l’événement vers le bloc
                              context.read<LanguageBloc>().add(
                                SelectLanguageEvent(
                                  selectedLanguageId!,
                                  widget.childId,
                                ),
                              );

                              // ✅ Attendre un petit délai si besoin (optionnel)
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const TestPage(),
                                    ),
                                  );
                                },
                              );
                            },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 186, 76),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Continuer"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
