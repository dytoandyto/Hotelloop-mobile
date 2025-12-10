// lib/core/storage/user_storage.dart

import 'package:learn_flutter_intermediate/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';

  // Menyimpan detail pengguna setelah login/register
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    // Tambahkan status login jika belum ada di TokenStorage
    await prefs.setBool('isLoggedIn', true); 
  }

  // Mengambil detail pengguna untuk ditampilkan di ProfileScreen
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyUserId);
    final name = prefs.getString(_keyUserName);
    final email = prefs.getString(_keyUserEmail);

    if (id != null && name != null && email != null) {
      return UserModel(id: id, name: name, email: email);
    }
    return null;
  }
  
  // Menghapus data pengguna saat logout
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove('isLoggedIn'); 
  }
}