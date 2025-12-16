import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';


final midtransServiceProvider = Provider<MidtransService>((ref) {
  final dio = ref.read(dioProvider);
  return MidtransService(dio);
});

class MidtransService {
  final Dio dio;

  MidtransService(this.dio);

  /// Memanggil endpoint BE untuk membuat transaksi Midtrans dan mendapatkan Snap Token.
  /// POST /user/reservations/{id}/midtrans/token
  Future<String> createSnapTransaction(int reservationId) async {
    try {
      final endpoint = '/user/reservations/$reservationId/midtrans/token';
      
      // Asumsi: Payload yang dikirim kosong atau hanya metadata.
      final response = await dio.post(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        // Asumsi BE mengembalikan: { "snap_token": "token_string" }
        final snapToken = response.data['snap_token'] as String?; 
        
        if (snapToken != null && snapToken.isNotEmpty) {
          return snapToken;
        }
      }
      
      throw Exception('Gagal mendapatkan Snap Token. Respons BE tidak valid.');

    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message;
      throw Exception('Network Error saat membuat Snap Token: $errorMessage');
    } catch (e) {
      throw Exception('Kesalahan tak terduga: $e');
    }
  }
}