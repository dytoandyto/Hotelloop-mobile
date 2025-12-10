import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RememberMeStorage {
  static const _keyRememberMe = 'remember_me_preference';

  // Menyimpan preferensi 'Remember Me'
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, value);
  }

  // Mengambil preferensi 'Remember Me'
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false; // Default: false
  }

  // Menghapus preferensi (biasanya tidak perlu, tapi bagus untuk cleanup)
  Future<void> deleteRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
  }
}

// Riverpod Provider untuk RememberMeStorage
final rememberMeStorageProvider = Provider<RememberMeStorage>((ref) {
  return RememberMeStorage();
});