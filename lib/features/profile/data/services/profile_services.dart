import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';
import 'package:learn_flutter_intermediate/features/auth/data/models/user_model.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileService(dio);
});

class ProfileService {
  final Dio dio;

  ProfileService(this.dio);

  /// Mendapatkan detail user berdasarkan ID
  /// GET /users/{id}
  Future<UserModel> fetchUserDetails(int userId) async {
    try {
      final response = await dio.get('/users/$userId');

      if (response.statusCode == 200 && response.data != null) {
        // Asumsi BE mengembalikan objek user langsung di root response
        return UserModel.fromJson(response.data); 
      }
      
      throw Exception('Gagal memuat detail profil. Status: ${response.statusCode}');

    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      throw Exception('Network Error: $errorMessage');
    } catch (e) {
      throw Exception('Kesalahan tak terduga: $e');
    }
  }
}