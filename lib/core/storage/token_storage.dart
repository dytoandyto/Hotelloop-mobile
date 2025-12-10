// lib/core/storage/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'auth_token';
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async =>
      await _storage.write(key: _key, value: token);

  Future<String?> getToken() async =>
      await _storage.read(key: _key);

  Future<void> deleteToken() async =>
      await _storage.delete(key: _key);
}
