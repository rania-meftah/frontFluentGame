import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/views/test_page.dart';
import '../blocs/language/language_bloc.dart';
import '../blocs/language/language_event.dart';
import '../blocs/language/language_state.dart';

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
    context.read<LanguageBloc>().add(LoadLanguagesEvent(widget.childId));
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
                // Image
                Image.asset(
                  'assets/images/cible.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),

                // Titre
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

                // Sélection de langue (modale personnalisée)
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, state) {
                    if (state is LanguageLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is LanguageLoaded) {
                      return GestureDetector(
                        onTap: () async {
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return ListView(
                                shrinkWrap: true,
                                children:
                                    state.languages.map((lang) {
                                      return ListTile(
                                        title: Text(lang.name),
                                        onTap:
                                            () =>
                                                Navigator.pop(context, lang.id),
                                      );
                                    }).toList(),
                              );
                            },
                          );

                          if (selected != null) {
                            setState(() => selectedLanguageId = selected);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedLanguageId == null
                                    ? "Select a language"
                                    : state.languages
                                        .firstWhere(
                                          (lang) =>
                                              lang.id == selectedLanguageId,
                                        )
                                        .name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      );
                    } else if (state is LanguageError) {
                      return Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 30),

                // Bouton Continuer
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        selectedLanguageId == null
                            ? null
                            : () {
                              context.read<LanguageBloc>().add(
                                SelectLanguageEvent(
                                  selectedLanguageId!,
                                  widget.childId,
                                ),
                              );

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
