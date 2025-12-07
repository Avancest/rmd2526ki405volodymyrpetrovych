import 'package:lab2/models/user.dart';
import 'package:lab2/services/user_storage.dart';

class AuthController {
  final UserStorage storage;

  AuthController({required this.storage});

  // Валідація
  String? validate(String name, String email, String password) {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return 'Заповніть всі поля';
    }

    if (!email.contains('@')) return 'Email повинен містити @';
    if (name.contains(RegExp(r'[0-9]'))) return 'Імʼя не може містити цифри';
    if (password.length < 6) return 'Пароль має бути мінімум 6 символів';

    return null;
  }

  // Реєстрація
  Future<String?> register(String name, String email, String password) async {
    final error = validate(name, email, password);
    if (error != null) return error;

    await storage.saveUser(name, email, password);
    return null; // успішно
  }

  // Логін
  Future<String?> login(String email, String password) async {
    final userData = await storage.loadUser();
    if (userData == null) return 'Користувача не знайдено';

    if (email != userData['email'] || password != userData['password']) {
      return 'Невірні дані';
    }

    // Зберігаємо поточного користувача
    await storage.saveCurrentUser(
      userData['name']!,
      userData['email']!,
    );

    return null; // успішно
  }

  // Повертаємо поточного користувача
  Future<User?> getCurrentUser() async {
    final data = await storage.loadCurrentUser();
    if (data == null) return null;

    return User(
      name: data['name']!,
      email: data['email']!,
    );
  }

  // Вихід з акаунту
  Future<void> logout() async {
    await storage.clearCurrentUser();
  }
}
