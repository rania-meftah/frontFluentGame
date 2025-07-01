import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_flutter_app/blocs/children/children_bloc.dart';
import 'package:my_flutter_app/blocs/children/children_event.dart';
import 'package:my_flutter_app/blocs/children/children_state.dart';

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
        return AlertDialog(
          title: const Text("Enter PIN Code"),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "PIN Code"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Confirm"),
              onPressed: () async {
                final pin = controller.text.trim();
                if (pin.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN is required")),
                  );
                  return;
                }

                Navigator.pop(context);
                onSuccess();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (token == null || parentId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("👧 Choose a Profile"),
        backgroundColor: Colors.pink[300],
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFF8F0),
      body: BlocBuilder<ChildrenBloc, ChildrenState>(
        builder: (context, state) {
          if (state is ChildrenLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChildrenLoaded) {
            final children = state.children;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🌸 Your Children:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: children.length + 1,
                      itemBuilder: (context, index) {
                        if (index < children.length) {
                          final child = children[index];

                          return GestureDetector(
                            onTap: () {
                              if (child.isFirstLogin) {
                                Navigator.pushNamed(
                                  context,
                                  '/user-home',
                                  arguments: {
                                    'childId': child.id,
                                    'parentId': parentId,
                                    'childName': child.name,
                                    'isFirstLogin': true,
                                  },
                                );
                              } else if (child.avatar == null ||
                                  child.avatar!.isEmpty) {
                                Navigator.pushNamed(
                                  context,
                                  '/choose-avatar',
                                  arguments: {
                                    'childId': child.id,
                                    'parentId': parentId,
                                  },
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  '/child-home',
                                  arguments: {
                                    'childId': child.id,
                                    'parentId': parentId,
                                    'childName': child.name,
                                    'isFirstLogin': false,
                                  },
                                );
                              }
                            },
                            onLongPress: () {
                              _openPinPrompt(context, () {
                                context.read<ChildrenBloc>().add(
                                  DeleteChildEvent(child.id, parentId!, token!),
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 8,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.pink[100],
                                    radius: 40,
                                    backgroundImage:
                                        child.avatar != null
                                            ? AssetImage(
                                              'assets/avatars/${child.avatar!}',
                                            )
                                            : null,
                                    child:
                                        child.avatar == null
                                            ? const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () {
                              _openPinPrompt(context, () {
                                Navigator.pushNamed(
                                  context,
                                  '/add-child',
                                  arguments: {
                                    'parentId': parentId,
                                    'token': token,
                                  },
                                ).then((result) {
                                  if (result == true && mounted) {
                                    context.read<ChildrenBloc>().add(
                                      LoadChildren(parentId!, token!),
                                    );
                                  }
                                });
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.pink[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ChildrenError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
