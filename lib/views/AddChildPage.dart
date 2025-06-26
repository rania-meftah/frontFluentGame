import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/blocs/children/children_bloc.dart';
import 'package:my_flutter_app/blocs/children/children_event.dart';
import 'package:my_flutter_app/blocs/children/children_state.dart';
import 'package:my_flutter_app/models/child_model.dart';

class AddChildPage extends StatefulWidget {
  final String parentId;
  final String token;

  const AddChildPage({super.key, required this.parentId, required this.token});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  void _submit() {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());

    print("🧪 Soumission : name=$name, age=$age");

    if (name.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un nom et un âge valides."),
        ),
      );
      return;
    }

    final newChild = ChildModel(
      id: '', // sera défini côté backend
      name: name,
      age: age,
      isFirstLogin: true,
    );

    print("📤 Envoi AddChildEvent");
    context.read<ChildrenBloc>().add(
      AddChildEvent(newChild, widget.parentId, widget.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un enfant")),
      body: BlocConsumer<ChildrenBloc, ChildrenState>(
        listener: (context, state) {
          print("🎯 Listener: $state");

          if (state is ChildrenLoaded) {
            print("✅ Enfant ajouté avec succès.");
            // Redirection directe vers ChooseProfilePage
            Navigator.pushReplacementNamed(context, '/choose-profile');
          } else if (state is ChildrenError) {
            print("❌ Erreur : ${state.message}");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nom de l'enfant",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Âge"),
                ),
                const SizedBox(height: 24),
                if (state is ChildrenLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Créer le compte"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
