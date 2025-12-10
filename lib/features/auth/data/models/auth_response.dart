// lib/features/auth/data/models/auth_response.dart
import 'user_model.dart';

class AuthResponse {
  final UserModel? user;
  final String? token;
  final List<String> roles;
  final String? message;
  final String? error;

  AuthResponse({
    this.user,
    this.token,
    this.roles = const [],
    this.message,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponse(
      user: data != null && data['user'] != null
          ? UserModel.fromJson(data['user'])
          : null,
      token: data?['token'],
      roles: (data?['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      message: json['message'],
      error: json['error'],
    );
  }
}
