import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'views/splash_page.dart';
import 'views/login_page.dart';
import 'views/signup_page.dart';
import 'views/forget_password_page.dart';
import 'views/verification_page.dart';
import 'views/NewPasswordPage.dart';
import 'views/admin_page.dart';
import 'views/salutation_page.dart';
import 'views/select_language_page.dart';

import 'blocs/login/auth_bloc.dart';
import 'blocs/signup/signup_bloc.dart';
import 'blocs/forget_password/forget_password_bloc.dart';
import 'blocs/verification/verification_bloc.dart';
import 'blocs/newPassword/new_password_bloc.dart';
import 'blocs/language/language_bloc.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final languageService = LanguageService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc(authService)),
        BlocProvider<SignupBloc>(create: (context) => SignupBloc(authService)),
        BlocProvider<ForgetPasswordBloc>(
          create: (context) => ForgetPasswordBloc(authService),
        ),
        BlocProvider<VerificationBloc>(
          create: (context) => VerificationBloc(authService),
        ),
        BlocProvider<NewPasswordBloc>(
          create: (context) => NewPasswordBloc(authService: authService),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(service: languageService),
        ), // ✅ Ajout du bloc language
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
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/admin': (context) => const AdminPage(),
          '/home': (context) => const UserHomePage(),
          '/forget': (context) => ForgetPasswordPage(),
          '/verification': (context) => VerificationPage(),
          '/select-language':
              (context) => const SelectLanguagePage(), // ✅ Route ajoutée
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/new_password') {
            final args = settings.arguments as Map<String, dynamic>;
            final email = args['email'] as String;
            final code = args['code'] as String;
            return MaterialPageRoute(
              builder: (context) => NewPasswordPage(email: email, code: code),
            );
          }
          return null;
        },
      ),
    );
  }
}
