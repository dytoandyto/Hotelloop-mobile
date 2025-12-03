import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dio/dio_provider.dart';
import '../../../core/storage/token_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/auth_service.dart';
import '../data/models/auth_response.dart';
import '../data/models/user_model.dart';

/// Service provider (uses your existing dioProvider)
final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.read(dioProvider);
  final storage = TokenStorage();
  return AuthService(dio, storage);
});

/// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.read(authServiceProvider);
  return AuthRepository(service);
});

/// AuthState - holds loading, user and error
class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, UserModel? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// AuthNotifier - handles login / register / getUser / logout
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  AuthNotifier(this.repository) : super(const AuthState());

  /// Helper to format thrown errors (handles validation structure thrown by AuthService)
  String _formatError(Object error) {
    try {
      if (error is Map && error['type'] == 'validation') {
        final errs = error['errors'] as List<dynamic>? ?? [];
        return errs
            .map((e) {
              final field = e['field'] ?? '';
              final msg = e['message'] ?? e.toString();
              return field.isNotEmpty ? '$field: $msg' : '$msg';
            })
            .join('\n');
      } else if (error is String) {
        return error;
      } else {
        return error.toString();
      }
    } catch (_) {
      return error.toString();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final AuthResponse res = await repository.login(email, password);
      state = state.copyWith(user: res.user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final AuthResponse res = await repository.register(name, email, password);
      state = state.copyWith(user: res.user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> getUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final AuthResponse res = await repository.getUser();
      state = state.copyWith(user: res.user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
    } catch (_) {
      // ignore logout errors - we still clear local state
    } finally {
      state = AuthState(); // reset state
    }
  }

  Future<void> resetPasswordRequest(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.resetPasswordRequest(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  Future<Map<String, dynamic>?> verifyOTP(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await repository.verifyOTP(email, code);
      state = state.copyWith(isLoading: false);
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
      return null;
    }
  }

  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.resetPassword(email, token, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }
}

/// Provider for the global auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(repo);
});
