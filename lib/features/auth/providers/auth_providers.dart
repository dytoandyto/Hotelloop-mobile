import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/storage/user_storage.dart';
import 'package:learn_flutter_intermediate/features/profile/data/repositories/user_repositories.dart';
import '../../../core/dio/dio_provider.dart';
import '../../../core/storage/token_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/auth_service.dart';
import '../data/models/auth_response.dart';
import '../data/models/user_model.dart';
import '../../../core/storage/remember_me_storage.dart';

/// Service provider (uses your existing dioProvider)
final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.read(dioProvider);
  final storage = TokenStorage();
  return AuthService(dio, storage);
});

final rememberMeStorageProvider = Provider<RememberMeStorage>((ref) {
  return RememberMeStorage();
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
  final bool isRemembered;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isRemembered = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isRemembered,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isRemembered: isRemembered ?? this.isRemembered,
    );
  }
}

/// AuthNotifier - handles login / register / getUser / logout
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final UserStorage userStorage;
  final RememberMeStorage rememberMeStorage; // <-- Dependency baru
  final TokenStorage tokenStorage; // <--

  AuthNotifier(
    this.repository,
    this.userStorage,
    this.rememberMeStorage,
    this.tokenStorage,
  ) : super(const AuthState()) {
    // Panggil fungsi auto-login/load state saat Notifier dibuat
    loadAuthState();
  }

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

  Future<void> loadAuthState() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Cek status Remember Me
      final isRemembered = await rememberMeStorage.getRememberMe();

      // 2. Cek apakah ada token
      final token = await tokenStorage.getToken();

      if (isRemembered && token != null) {
        // Jika Remembered true DAN ada token, coba ambil data user (auto-login)
        final AuthResponse res = await repository.getUser();
        if (res.user != null) {
          state = state.copyWith(
            user: res.user,
            isLoading: false,
            isRemembered: true,
          );
        } else {
          // Token valid tapi gagal ambil user, clear storage
          await logout(shouldClearLocal: true);
        }
      } else {
        // Jika tidak ada token atau Remember Me false
        state = state.copyWith(isLoading: false, isRemembered: isRemembered);
      }
    } catch (e) {
      // Jika auto-login gagal (misal 401 token expired), tetap set loading=false
      await logout(shouldClearLocal: true);
    }
  }

  // --- MODIFIKASI: LOGIN ---
  Future<void> login(String email, String password, bool rememberMe) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final AuthResponse res = await repository.login(email, password);

      if (res.user != null) {
        await userStorage.saveUser(res.user!);
      }

      // Simpan preferensi Remember Me
      await rememberMeStorage.setRememberMe(
        rememberMe,
      ); // <-- SIMPAN PREFERENSI

      state = state.copyWith(
        user: res.user,
        isLoading: false,
        error: null,
        isRemembered: rememberMe, // <-- UPDATE STATE
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }

  // --- MODIFIKASI: LOGOUT ---
  // Parameter baru untuk menentukan apakah kita menghapus lokal storage
  Future<void> logout({bool shouldClearLocal = true}) async {
    try {
      // Coba panggil API logout
      await repository.logout();
    } catch (_) {
      // Ignore API errors, tetap lanjutkan clear local state
    } finally {
      if (shouldClearLocal) {
        await userStorage.deleteUser();
        // Hapus Token, KECUALI jika isRemembered=true, tapi di sini kita anggap
        // logout manual berarti hapus token.
        await tokenStorage.deleteToken();
      }

      // Jika user logout secara manual (shouldClearLocal=true), kita set RememberMe=false juga
      if (shouldClearLocal) {
        await rememberMeStorage.setRememberMe(false);
      }

      state = const AuthState(); // Reset state
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

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repo = ref.read(authRepositoryProvider);
  final userStorage = ref.read(userStorageProvider);
  final rememberStorage = ref.read(rememberMeStorageProvider); // <-- Ambil
  final tokenStorage = TokenStorage(); // <-- Ambil
  
  return AuthNotifier(repo, userStorage, rememberStorage, tokenStorage); // <-- Kirim
});