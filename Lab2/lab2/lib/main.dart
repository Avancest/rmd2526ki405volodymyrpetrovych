// Імпорт основної бібліотеки Flutter для створення UI
import 'package:flutter/material.dart';

// Імпорт екрана домашньої сторінки (список вазонів)
import 'package:lab2/screens/home_screen.dart';

// Імпорт екрана входу користувача
import 'package:lab2/screens/login_screen.dart';

// Імпорт екрана профілю користувача
import 'package:lab2/screens/profile_screen.dart';

// Імпорт екрана реєстрації користувача
import 'package:lab2/screens/register_screen.dart';

// Точка входу в програму. Викликає функцію runApp і запускає застосунок AutoWateringApp
void main() => runApp(const AutoWateringApp());

// Головний клас застосунку, який не має внутрішнього стану (StatelessWidget)
class AutoWateringApp extends StatelessWidget {
  // Конструктор з ключем super.key для передачі ключів Flutter
  const AutoWateringApp({super.key});

  // Основний метод побудови інтерфейсу програми
  @override
  Widget build(BuildContext context) {
    // MaterialApp — головний контейнер для всього застосунку з налаштуванням теми, маршрутів і назв
    return MaterialApp(
      // Назва застосунку (відображається, наприклад, у списку запущених програм)
      title: 'AutoWatering',

      // Основна тема застосунку
      theme: ThemeData(
        // Визначення кольорової схеми програми
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4CAF50), // Основний колір (зелений — асоціюється з рослинами)
          secondary: Color(0xFF81D4FA), // Додатковий колір (блакитний — асоціюється з водою)
          surface: Color(0xFFF9FBE7), // Колір поверхні (світлий фон)
        ),

        // Колір фону всіх екранів (Scaffold)
        scaffoldBackgroundColor: const Color(0xFFF9FBE7),

        // Оформлення верхньої панелі (AppBar)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50), // Колір фону AppBar
          foregroundColor: Colors.white, // Колір тексту і іконок у AppBar
          elevation: 2, // Тінь під AppBar
        ),

        // Налаштування стилю всіх кнопок ElevatedButton у програмі
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Зелений фон кнопок
            foregroundColor: Colors.white, // Білий колір тексту
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // Закруглені кути кнопок
            ),
          ),
        ),
      ),

      // Початковий маршрут, який відкривається при запуску програми
      initialRoute: '/login',

      // Маршрути між сторінками програми
      routes: {
        '/login': (_) => const LoginScreen(), // Сторінка входу
        '/register': (_) => const RegisterScreen(), // Сторінка реєстрації
        '/home': (_) => const HomeScreen(), // Домашня сторінка (вазони)
        '/profile': (_) => const ProfileScreen(), // Сторінка профілю користувача
      },
    );
  }
}
