import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_flutter_app/blocs/domaine/domaine_bloc.dart';
import 'package:my_flutter_app/constants.dart';
import 'package:my_flutter_app/repositories/DomaineRepository.dart';
import 'package:my_flutter_app/views/lesson_page.dart';

class HomeChildPage extends StatelessWidget {
  const HomeChildPage({super.key});

  // 🔁 Fonction appelée quand un domaine est sélectionné
  Future<void> _onDomainSelected(BuildContext context, String domainId) async {
    const storage = FlutterSecureStorage();
    final level =
        await storage.read(key: 'child_level') ??
        'Easy'; // 🔥 récupère le niveau stocké

    // 👉 Naviguer vers la page des leçons (lesson_page.dart)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                LessonPage(domainId: domainId, lessonNumber: 1, level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DomaineBloc(DomaineRepository())..add(LoadDomaines()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("What exactly do you want to learn?"),
          centerTitle: true,
        ),
        body: BlocBuilder<DomaineBloc, DomaineState>(
          builder: (context, state) {
            if (state is DomaineLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DomaineLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children:
                      state.domaines.map((domaine) {
                        return GestureDetector(
                          onTap: () {
                            _onDomainSelected(
                              context,
                              domaine.id,
                            ); // ✅ Appel fonction
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (domaine.image.isNotEmpty)
                                  Image.network(
                                    baseUrl + domaine.image,
                                    height: 80,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                      );
                                    },
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  domaine.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              );
            } else if (state is DomaineError) {
              return Center(child: Text("Erreur: ${state.message}"));
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
