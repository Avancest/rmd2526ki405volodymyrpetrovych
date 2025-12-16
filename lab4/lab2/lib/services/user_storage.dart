abstract class UserStorage {
  Future<void> saveUser(String name, String email, String password);
  Future<Map<String, String>?> loadUser();

  // Додаємо функції поточного юзера:
  Future<void> saveCurrentUser(String name, String email);
  Future<Map<String, String>?> loadCurrentUser();
  Future<void> clearCurrentUser();
}
