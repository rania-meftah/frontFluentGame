import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_flutter_app/blocs/children/children_bloc.dart';
import 'package:my_flutter_app/blocs/children/children_event.dart';
import 'package:my_flutter_app/blocs/children/children_state.dart';
import 'package:my_flutter_app/repositories/children_repository.dart';

class ChooseProfilePage extends StatefulWidget {
  const ChooseProfilePage({super.key});

  @override
  State<ChooseProfilePage> createState() => _ChooseProfilePageState();
}

class _ChooseProfilePageState extends State<ChooseProfilePage> {
  String? parentId;
  String? token;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  void _loadFromStorage() async {
    final storedToken = await storage.read(key: 'auth_token');
    final storedParentId = await storage.read(key: 'parent_id');

    if (!mounted) return;

    if (storedToken != null && storedParentId != null) {
      setState(() {
        token = storedToken;
        parentId = storedParentId;
      });

      context.read<ChildrenBloc>().add(
        LoadChildren(storedParentId, storedToken),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _openPinPrompt(BuildContext context, VoidCallback onSuccess) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Entrer le code PIN"),
              content: TextField(
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Code PIN"),
              ),
              actions: [
                TextButton(
                  child: const Text("Annuler"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Valider"),
                  onPressed: () async {
                    final pin = controller.text.trim();
                    if (pin.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Veuillez entrer un code PIN"),
                        ),
                      );
                      return;
                    }

                    try {
                      final isValid = await ChildrenRepository().verifyPin(
                        token: token!,
                        parentId: parentId!,
                        pin: pin,
                      );

                      if (isValid) {
                        Navigator.pop(context);
                        onSuccess();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Code PIN incorrect")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Erreur lors de la vérification : $e"),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (token == null || parentId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Choisir un profil")),
      body: BlocBuilder<ChildrenBloc, ChildrenState>(
        builder: (context, state) {
          if (state is ChildrenLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChildrenLoaded) {
            final children = state.children;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  ...children.map(
                    (child) => GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          child.isFirstLogin ? '/user-home' : '/child-workflow',
                          arguments: {
                            'childId': child.id,
                            'parentId': parentId,
                          },
                        );
                      },
                      onLongPress: () {
                        _openPinPrompt(context, () {
                          context.read<ChildrenBloc>().add(
                            DeleteChildEvent(child.id, parentId!, token!),
                          );
                        });
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.purple,
                              radius: 50,
                              child: Icon(Icons.person, size: 60),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              child.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _openPinPrompt(context, () {
                        Navigator.pushNamed(
                          context,
                          '/add-child',
                          arguments: {'parentId': parentId, 'token': token},
                        ).then((result) {
                          if (result == true && mounted) {
                            setState(() {}); // optionnel
                            context.read<ChildrenBloc>().add(
                              LoadChildren(parentId!, token!),
                            );
                          }
                        });
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.pink[100],
                      child: const Center(
                        child: Icon(Icons.add, size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ChildrenError) {
            return Center(child: Text("Erreur : ${state.message}"));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
