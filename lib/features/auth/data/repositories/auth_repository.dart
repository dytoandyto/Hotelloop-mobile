// lib/features/auth/data/repositories/auth_repository.dart
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  Future<AuthResponse> login(String email, String password) {
    return authService.login(email, password);
  }

  Future<AuthResponse> register(String name, String email, String password) {
    return authService.register(name, email, password);
  }

  Future<void> logout() {
    return authService.logout();
  }

  Future<AuthResponse> getUser() {
    return authService.getUser();
  }

  Future<void> resetPasswordRequest(String email) {
    return authService.resetPasswordRequest(email);
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String code) {
    return authService.verifyOTP(email, code);
  }

  Future<void> resetPassword(String email, String token, String newPassword) {
    return authService.resetPassword(email, token, newPassword);
  }
}
