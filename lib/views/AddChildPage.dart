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
    final ageText = ageController.text.trim();
    final age = int.tryParse(ageText);

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le nom doit contenir au moins 2 caractères."),
        ),
      );
      return;
    }

    if (age == null || age <= 0 || age > 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("L'âge doit être un nombre entre 1 et 14."),
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
          if (state is ChildrenLoaded) {
            Navigator.pushReplacementNamed(context, '/choose-profile');
          } else if (state is ChildrenError) {
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
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Âge",
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                if (state is ChildrenLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
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
