import 'package:dio/dio.dart';
import '../models/reservation_model.dart';

class ReservationService {
  final Dio dio;
  ReservationService(this.dio);

  Future<ReservationModel> createReservation({
    required int roomTypeId,
    required int roomId,
    required String checkInDate,
    required String checkOutDate,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
  }) async {
    try {
      final response = await dio.post(
        '/reservations',
        data: {
          'room_type_id': roomTypeId,
          'room_id': roomId, // Perlu memilih room ID yang tersedia
          'check_in_date': checkInDate,
          'check_out_date': checkOutDate,
          'guest_name': guestName,
          'guest_email': guestEmail,
          'guest_phone': guestPhone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReservationModel.fromJson(response.data);
      } else {
        throw Exception('Gagal membuat reservasi: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw e.response!.data['message'] ?? 'Kesalahan API saat reservasi.';
      }
      throw Exception('Kesalahan Jaringan: $e');
    }
  }
}