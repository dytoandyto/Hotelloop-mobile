import 'package:dio/dio.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';

class BookingsService {
  final Dio dio;

  BookingsService(this.dio);

  Future<List<ReservationModel>> fetchUserReservations() async { 
    try {
      final response = await dio.get('/user/reservations'); 

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawList = response.data['data'] as List? ?? [];
        
        return rawList
            .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Gagal memuat riwayat reservasi');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Sesi berakhir atau gagal koneksi.';
      throw Exception(errorMessage);
    }
  }
}