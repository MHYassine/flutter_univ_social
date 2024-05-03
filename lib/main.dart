import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/Profile/Profile.dart';
import 'Auth/ForgotpassPage.dart';
import 'Auth/Register_page.dart';
import 'Auth/Sign_in.dart';
import 'Drawer/Settings_page.dart';
import 'Drawer/follwedteachers.dart';
import 'Home/home.dart';
import 'firebase/firebase_tools.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'Register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: 'sign-in',
          builder: (context, state) => const SignInPage2(),
        ),
        GoRoute(
          path: 'Reset-pass',
          builder: (context, state) => ForgotPasswordPage(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: 'Settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: 'Followed',
          builder: (context, state) => const FollowedTeachersPage(),
        ),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'University Social Media',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              highlightColor: Colors.deepPurple,
            ),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: _router, // new
    );
  }
}
