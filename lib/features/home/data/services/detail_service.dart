// lib/features/home/data/services/detail_service.dart
import 'package:dio/dio.dart';
import '../models/hotel_detail_model.dart';

class HotelDetailService {
  final Dio dio;
  HotelDetailService(this.dio);

  Future<HotelDetailModel> getHotelDetail(int hotelId) async {
    try {
      // Endpoint: /api/hotels/{id}
      final response = await dio.get('/hotels/$hotelId'); 

      if (response.statusCode == 200 && response.data != null) {
        // Asumsi respons detail mengembalikan objek hotel di field 'data'
        final hotelData = response.data['data']; 
        return HotelDetailModel.fromJson(hotelData);
      } else {
        throw Exception('Gagal memuat detail hotel: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Gagal memuat detail hotel: ${e.response?.statusCode ?? 'Network Error'}');
      }
      throw Exception('Kesalahan tak terduga saat fetch detail: $e');
    }
  }
}