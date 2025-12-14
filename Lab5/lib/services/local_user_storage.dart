import 'package:lab2/services/user_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserStorage implements UserStorage {
  @override
  Future<void> saveUser(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_name', name);
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
  }

  @override
  Future<Map<String, String>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('saved_name');
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');

    if (name == null || email == null || password == null) return null;

    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  @override
  Future<void> saveCurrentUser(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_name', name);
    await prefs.setString('current_email', email);
  }

  @override
  Future<Map<String, String>?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('current_name');
    final email = prefs.getString('current_email');

    if (name == null || email == null) return null;

    return {
      'name': name,
      'email': email,
    };
  }

  @override
  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_name');
    await prefs.remove('current_email');
  }
}
