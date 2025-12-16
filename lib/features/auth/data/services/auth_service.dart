// lib/features/auth/data/services/auth_service.dart
import 'package:dio/dio.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_response.dart';

class AuthService {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthService(this.dio, this.tokenStorage);

  Future<AuthResponse> login(String email, String password) async {
    final response = await dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    final authResponse = AuthResponse.fromJson(response.data);
    if (authResponse.token != null) {
      await tokenStorage.saveToken(authResponse.token!);
    }
    return authResponse;
  }

  Future<AuthResponse> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await dio.post(
      '/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    final authResponse = AuthResponse.fromJson(response.data);
    if (authResponse.token != null) {
      await tokenStorage.saveToken(authResponse.token!);
    }
    return authResponse;
  }

  Future<void> logout() async {
    await dio.post('/logout');
    await tokenStorage.deleteToken();
  }

  Future<AuthResponse> getUser() async {
    final response = await dio.get('/user');
    return AuthResponse.fromJson(response.data);
  }

  Future<void> resetPasswordRequest(String email) async {
    await dio.post('/reset-password-request', data: {'email': email});
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String code) async {
    final response = await dio.post(
      '/verify-otp',
      data: {'email': email, 'code': code},
    );
    return response.data['data']; // contains email + token
  }

  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    await dio.post(
      '/reset-password',
      data: {'email': email, 'token': token, 'new_password': newPassword},
    );
  }
}
