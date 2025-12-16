// lib/features/booking_form/data/services/reservation_services.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';
import '../models/reservation_model.dart';
import '../../../room_types/data/models/room_model.dart';
import 'dart:convert';

class ReservationService {
  final Dio dio;
  ReservationService(this.dio);

  final reservationServiceProvider = Provider<ReservationService>((ref) {
    // Pastikan ini menggunakan dioProvider dari core yang sudah ada Interceptor
    final dio = ref.read(dioProvider);
    return ReservationService(dio);
  });

  // --- FUNGSI BARU: MENCARI ROOM ID FISIK YANG TERSEDIA ---
  // Kita hilangkan penamaan calculatePrice yang salah, dan fokus ke tujuan utamanya
  Future<int> findAvailableRoomId({
    required int roomTypeId,
    required String checkInDate,
    required String checkOutDate,
  }) async {
    try {
      // 1. Panggil Endpoint Rooms
      final response = await dio.get(
        '/rooms',
        queryParameters: {
          'room_type_id': roomTypeId,
          // Tanggal di sini diabaikan oleh BE, tapi kita kirimkan untuk dokumentasi:
          'check_in': checkInDate,
          'check_out': checkOutDate,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> roomListData =
            response.data['data']['data'] as List? ?? [];

        // 2. Filter sisi FE (Ambil ID kamar fisik pertama yang available)
        final availableRoom = roomListData
            .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
            .firstWhere(
              (room) =>
                  // HANYA COCOKKAN TIPE KAMAR dan STATUS:
                  room.roomTypeId == roomTypeId &&
                  room.status.toLowerCase() == 'available',
              orElse: () {
                // Jika stok kamar fisik habis, lemparkan error sebelum POST reservasi
                throw Exception(
                  "Semua kamar tipe ini sudah terisi. Coba tanggal lain.",
                );
              },
            );
        // 3. Kembalikan ID Kamar Fisik
        return availableRoom.id;
      } else {
        throw Exception('Gagal memuat daftar kamar.');
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ??
          'Kesalahan jaringan saat mencari kamar.';
      throw Exception(errorMessage);
    } catch (e) {
      // Menangkap exception dari orElse:
      throw Exception(e.toString());
    }
  }

  // 3. Fungsi untuk membuat reservasi (POST /api/store)
  Future<ReservationModel> createReservation({
    required int roomId,
    required int userId, // <--- TAMBAH
    required String guestName, // <--- TAMBAH
    required String guestEmail, // <--- TAMBAH
    required String guestPhone, // <--- TAMBAH
    required String checkInDate,
    required String checkOutDate,
  }) async {
    final payload = {
      'room_id': roomId,
      'user_id': userId, // <--- DITAMBAHKAN KE PAYLOAD
      'guest_name': guestName, // <--- DITAMBAHKAN KE PAYLOAD
      'guest_email': guestEmail, // <--- DITAMBAHKAN KE PAYLOAD
      'guest_phone': guestPhone, // <--- DITAMBAHKAN KE PAYLOAD
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      // Note: Controller Anda TIDAK memerlukan hotel_id secara eksplisit di sini karena endpoint storeByHotelId,
      // tetapi jika Anda menggunakan endpoint /reservations/store, hotel_id mungkin diperlukan.
      // Kita kirimkan hotel_id sesuai permintaan form.
    };

    try {
      // Ganti dengan endpoint BE Anda yang sesungguhnya: /api/reservations/store
      final response = await dio.post('/reservations/user', data: payload);

      if (response.statusCode == 201) {
        return ReservationModel.fromJson(
          response.data['reservation'] ?? response.data,
        );
      } else {
        throw Exception(
          'Gagal membuat reservasi: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Menangkap pesan error spesifik dari BE
      final errorMessage =
          e.response?.data['message'] ??
          e.response?.data['error'] ??
          'Kesalahan API saat reservasi.';
      throw Exception(errorMessage);
    }
  }
}
