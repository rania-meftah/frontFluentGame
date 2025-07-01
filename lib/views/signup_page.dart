import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/signup/signup_bloc.dart';
import '../blocs/signup/signup_event.dart';
import '../blocs/signup/signup_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  bool obscurePassword = true;
  bool obscurePin = true;

  // ✅ Vérifie si email a un bon format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  void _submitSignup(BuildContext context) {
    final fullName = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final pin = _pinController.text.trim();

    // ✅ Vérifications avant envoi
    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid email format')));
      return;
    }

    if (pin.length != 4 || int.tryParse(pin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be a 4-digit number')),
      );
      return;
    }

    // ✅ Si tout est OK : envoi l’événement
    context.read<SignupBloc>().add(
      SubmitSignup(fullName, phone, email, password, pin),
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
                    Image.asset('assets/images/familysignup.png', height: 150),
                    const SizedBox(height: 20),
                    _buildInputField(
                      label: 'Full Name',
                      controller: _fullNameController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      label: 'Phone',
                      controller: _phoneController,
                      icon: Icons.phone,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.email,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      label: 'Password',
                      controller: _passwordController,
                      icon: Icons.lock,
                      isPassword: true,
                      obscureText: obscurePassword,
                      toggleObscure: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildInputField(
                      label: 'Parent PIN (ex: 1234)',
                      controller: _pinController,
                      icon: Icons.pin,
                      type: TextInputType.number,
                      isPassword: true,
                      obscureText: obscurePin,
                      toggleObscure: () {
                        setState(() {
                          obscurePin = !obscurePin;
                        });
                      },
                    ),
                    const SizedBox(height: 25),
                    BlocConsumer<SignupBloc, SignupState>(
                      listener: (context, state) {
                        if (state is SignupSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signup successful!')),
                          );
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
                                    color: Colors.white,
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

  // ✅ Widget pour champ avec option mot de passe/obscure
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword ? obscureText : false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: toggleObscure,
                )
                : null,
      ),
    );
  }
}
