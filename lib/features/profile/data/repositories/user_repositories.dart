// lib/features/profile/data/repositories/user_repository.dart

import 'package:learn_flutter_intermediate/features/auth/data/models/user_model.dart';
import '../../../../core/storage/user_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  final UserStorage userStorage;

  UserRepository(this.userStorage);

  Future<UserModel?> getProfileData() {
    return userStorage.getUser(); // Ambil dari penyimpanan lokal
  }
  
  // Di masa depan, Anda bisa menambahkan logika API di sini:
  // Future<UserModel> fetchProfileFromApi() async { ... }
}

// Provider untuk UserStorage (harus diinisialisasi di main.dart)
final userStorageProvider = Provider<UserStorage>((ref) => UserStorage());

// Provider untuk UserRepository (menggunakan userStorageProvider)
final userRepoProvider = Provider<UserRepository>((ref) {
  final storage = ref.watch(userStorageProvider);
  return UserRepository(storage);
});