import 'package:flutter/material.dart';
import 'package:lab2/models/user.dart';
import 'package:lab2/screens/home_screen.dart';
import 'package:lab2/screens/login_screen.dart';
import 'package:lab2/screens/register_screen.dart';

void main() {
  runApp(const AutoWateringApp());
}

class AutoWateringApp extends StatelessWidget {
  const AutoWateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoWatering',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF81D4FA),
          surface: Color(0xFFF9FBE7),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FBE7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            final user = settings.arguments as User;
            return MaterialPageRoute(builder: (_) => HomeScreen(user: user));
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
      initialRoute: '/login',
    );
  }
}
