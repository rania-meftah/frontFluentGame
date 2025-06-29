import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'views/AddChildPage.dart';
import 'views/ChooseProfilePage.dart';

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
import 'blocs/children/children_bloc.dart';

import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'repositories/children_repository.dart';

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
        ),
        BlocProvider<ChildrenBloc>(
          create: (context) => ChildrenBloc(ChildrenRepository()),
        ),
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
          '/home': (context) => const UserHomePage(childId: '', parentId: ''),
          '/forget': (context) => ForgetPasswordPage(),
          '/verification': (context) => VerificationPage(),
          '/select-language':
              (context) => const SelectLanguagePage(childId: ''),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/new_password') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (context) =>
                      NewPasswordPage(email: args['email'], code: args['code']),
            );
          } else if (settings.name == '/choose-profile') {
            return MaterialPageRoute(builder: (context) => ChooseProfilePage());
          } else if (settings.name == '/add-child') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (context) => AddChildPage(
                    parentId: args['parentId'],
                    token: args['token'],
                  ),
            );
          } else if (settings.name == '/user-home') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (context) => UserHomePage(
                    childId: args['childId'],
                    parentId: args['parentId'],
                  ),
            );
          }
          return null;
        },
      ),
    );
  }
}
