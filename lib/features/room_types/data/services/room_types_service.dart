// lib/features/room_types/data/services/room_types_service.dart
import 'package:dio/dio.dart';
import '../models/room_type_model.dart';

class RoomTypeService {
  final Dio dio;

  RoomTypeService(this.dio);

  // 1. Fungsi untuk membuat Tipe Kamar baru
  Future<Response> postRoomType(RoomTypeModel roomType) async {
    try {
      // Endpoint /room-types (Sesuai dengan API Anda)
      final response = await dio.post(
        '/room-types', 
        data: roomType.toJson(), // Membutuhkan method .toJson() di RoomTypeModel
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response; // Mengembalikan objek Response jika berhasil
      } else {
        throw Exception('Gagal membuat tipe kamar: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        // Menangkap error jaringan atau respons non-2xx dari server
        final statusCode = e.response?.statusCode ?? 'Connection Failed';
        final message = e.response?.data['message'] ?? e.response?.data['error'] ?? 'Network Error';
        throw Exception('API Error ($statusCode): $message');
      }
      throw Exception('Kesalahan tak terduga saat post room types: $e');
    }
  }
  
  // Asumsi fungsi lain (misalnya fetchRoomTypes) ada di sini
}