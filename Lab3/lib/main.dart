import 'package:flutter/material.dart';
import 'package:lab2/models/user.dart';
import 'package:lab2/screens/home_screen.dart';
import 'package:lab2/screens/login_screen.dart';
import 'package:lab2/screens/register_screen.dart';

void main() => runApp(const AutoWateringApp());

class AutoWateringApp extends StatelessWidget {
  const AutoWateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoWatering',
      theme: ThemeData(
        // -- ПОВЕРНУТІ КОЛЬОРИ ТЕМИ --
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4CAF50), // Зелений
          secondary: Color(0xFF81D4FA), // Блакитний
          surface: Color(0xFFF9FBE7), // Кремовий
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FBE7), // Колір фону
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4CAF50), // Кнопки зеленого кольору
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        // -----------------------------
      ),
      
      // Використовуємо onGenerateRoute для коректної навігації з аргументами
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          
          case '/home':
            // Отримуємо аргументи (наш об'єкт User) і передаємо їх в HomeScreen
            final user = settings.arguments as User; 
            return MaterialPageRoute(
              builder: (_) => HomeScreen(user: user), 
            );

          default:
            // Початковий екран за замовчуванням, якщо інший маршрут не вказано
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
