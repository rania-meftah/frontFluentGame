import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'views/splash_page.dart';
import 'views/login_page.dart';
import 'views/signup_page.dart';
import 'views/forget_password_page.dart';
import 'views/verification_page.dart';
import 'views/admin_page.dart';
import 'views/salutation_page.dart';

import 'blocs/auth_bloc.dart';
import 'blocs/auth_event.dart';
import 'blocs/auth_state.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc(AuthService())),
      ],
      child: MaterialApp(
        title: 'FLUBINGO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashPage(),
        routes: {
          '/login':
              (context) =>
                  LoginPage(), // ⚠️ Sans `const` ici car étatful avec controller
          '/signup': (context) => const SignupPage(),
          '/admin': (context) => const DashboardPage(),
          '/home': (context) => const UserHomePage(),
          '/forget': (context) => const ForgetPasswordPage(),
          '/verification': (context) => const VerificationPage(),
        },
      ),
    );
  }
}
