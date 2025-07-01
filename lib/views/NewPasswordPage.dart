import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/newPassword/new_password_bloc.dart';
import '../blocs/newPassword/new_password_event.dart';
import '../blocs/newPassword/new_password_state.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String code;

  const NewPasswordPage({super.key, required this.email, required this.code});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final password = _passwordController.text.trim();

      // Envoi de l'événement au bloc
      context.read<NewPasswordBloc>().add(
        SubmitNewPasswordEvent(
          email: widget.email,
          code: widget.code,
          newPassword: password,
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<NewPasswordBloc, NewPasswordState>(
        listener: (context, state) {
          if (state is NewPasswordSuccess) {
            // En cas de succès, redirection vers la page login
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successful! Please login.'),
              ),
            );
          } else if (state is NewPasswordFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Enter New Password",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 239, 178, 11),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    BlocBuilder<NewPasswordBloc, NewPasswordState>(
                      builder: (context, state) {
                        if (state is NewPasswordLoading) {
                          return const CircularProgressIndicator();
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF09935),
                            ),
                            child: const Text(
                              "Send",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Image.asset('assets/images/newPassword.png', height: 150),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
