// data/services/payment_service.dart
import 'package:dio/dio.dart';
// import models yang sudah direvisi
import 'package:learn_flutter_intermediate/features/payment/data/models/snap_token_model.dart';
import 'package:learn_flutter_intermediate/features/payment/data/models/midtrans_status_model.dart'; 

class PaymentService {
  final Dio dio;

  PaymentService(this.dio);

  Future<SnapTokenModel> createSnapTransaction({
    required int reservationId,
    required double amount,
    required String customerEmail,
    required String customerName,
  }) async {
    try {
      final response = await dio.post(
        '/user/reservations/$reservationId/midtrans/token', 
        data: {
          'amount': amount,
          'customer_name': customerName,
          'customer_email': customerEmail,
        },
      );

      // --- Mencegah Parsing Error: Ambil Data Langsung ---
      // Jika Dio sukses (status 2xx), coba parse.
      return SnapTokenModel.fromJson(response.data);
      
    } on DioException catch (e) {
      // 1. Tangani Error Jaringan atau Status API 4xx/5xx
      String errorMessage = e.response?.data['error'] ?? e.response?.data['message'] ?? e.message ?? 'Kesalahan API Midtrans.';
      throw Exception(errorMessage);

    } catch (e) {
      // 2. Tangani Error Parsing JSON (e.g., tipe data tidak cocok)
      // Ini sering terjadi jika model tidak cocok dengan response BE.
      throw Exception("Gagal memproses data Snap Token dari BE: $e");
    }
  }
  
  // Fungsi Cek Status (tetap sama)
  Future<MidtransStatusModel> checkStatus(String reservationId) async {
    // ... Implementasi call API cek status ke backend Anda
    
    // MOCK HASIL CHECK STATUS
    await Future.delayed(const Duration(seconds: 2));
    return MidtransStatusModel.fromJson({
      'transaction_id': 'MID-TRANS-12345-${reservationId}',
      'order_id': 'RSV-${reservationId}',
      'gross_amount': '100000.00',
      'transaction_status': 'settlement', 
      'payment_type': 'bank_transfer',
    });
  }
}