import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/signup/signup_bloc.dart';
import '../blocs/signup/signup_event.dart';
import '../blocs/signup/signup_state.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitSignup(BuildContext context) {
    context.read<SignupBloc>().add(
      SubmitSignup(
        _fullNameController.text,
        _phoneController.text,
        _emailController.text,
        _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 600 : double.infinity,
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/love.png', height: 150),
                    const SizedBox(height: 20),
                    _buildInputField(
                      'Full Name',
                      _fullNameController,
                      Icons.person,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      'Phone',
                      _phoneController,
                      Icons.phone,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      'Email',
                      _emailController,
                      Icons.email,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      'Password',
                      _passwordController,
                      Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 25),
                    BlocConsumer<SignupBloc, SignupState>(
                      listener: (context, state) {
                        if (state is SignupSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signup successful!')),
                          );
                          // Redirection vers la page login
                          Navigator.pushReplacementNamed(context, '/login');
                        } else if (state is SignupFailure) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(state.error)));
                        }
                      },
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed:
                              state is SignupLoading
                                  ? null
                                  : () => _submitSignup(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child:
                              state is SignupLoading
                                  ? const CircularProgressIndicator(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  )
                                  : const Text("Create Account"),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('or continue with'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => print("Signup with Google"),
                          icon: const Icon(
                            Icons.g_mobiledata,
                            size: 40,
                                      color: Color.fromARGB(255, 204, 125, 165),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () => print("Signup with Phone"),
                          icon: const Icon(
                            Icons.phone_android,
                            size: 20,
                                      color: Color.fromARGB(255, 204, 125, 165),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
