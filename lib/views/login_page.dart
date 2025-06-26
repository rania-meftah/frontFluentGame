import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/login/auth_bloc.dart';
import '../blocs/login/auth_event.dart';
import '../blocs/login/auth_state.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _navigateAfterLogin(BuildContext context, String userId, String token) {
    Navigator.pushReplacementNamed(
      context,
      '/choose-profile',
      arguments: {'parentId': userId, 'token': token},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login successful')));
            _navigateAfterLogin(context, state.userId, state.token);
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics:
                    constraints.maxHeight < 600
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Image.asset(
                                'assets/images/cat.png',
                                width: 120,
                                height: 120,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Welcome',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 204, 125, 165),
                                ),
                              ),
                              const Text(
                                'FLUBINGO',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 204, 125, 165),
                                ),
                              ),
                              const SizedBox(height: 32),
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/forget',
                                      ),
                                  child: const Text('Forget Password?'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              state is AuthLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                    onPressed: () {
                                      final email = emailController.text.trim();
                                      final password =
                                          passwordController.text.trim();
                                      context.read<AuthBloc>().add(
                                        LoginRequested(
                                          email: email,
                                          password: password,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF09935),
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                              const SizedBox(height: 20),
                              const Text('or continue with'),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed:
                                        () => context.read<AuthBloc>().add(
                                          GoogleLoginRequested(),
                                        ),
                                    icon: const Icon(
                                      Icons.g_mobiledata,
                                      size: 40,
                                      color: Color.fromARGB(255, 204, 125, 165),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    onPressed:
                                        () => context.read<AuthBloc>().add(
                                          PhoneLoginRequested(),
                                        ),
                                    icon: const Icon(
                                      Icons.phone_android,
                                      size: 20,
                                      color: Color.fromARGB(255, 204, 125, 165),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed:
                                    () =>
                                        Navigator.pushNamed(context, '/signup'),
                                child: const Text(
                                  "Don't have an account? Sign up",
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
