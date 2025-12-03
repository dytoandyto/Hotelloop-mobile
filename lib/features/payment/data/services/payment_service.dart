// data/services/payment_service.dart
import 'package:dio/dio.dart';
// import models yang sudah direvisi
import 'package:learn_flutter_intermediate/features/payment/data/models/snap_token_model.dart';
import 'package:learn_flutter_intermediate/features/payment/data/models/midtrans_status_model.dart'; // Asumsi Anda punya model ini

class PaymentService {
  final Dio dio;

  PaymentService(this.dio);

  // Mengganti PaymentResponse dengan SnapTokenModel
  Future<SnapTokenModel> createSnapTransaction({
    required int reservationId,
    required double amount,
    required String customerEmail,
    required String customerName,
  }) async {
    try {
      final response = await dio.post(
        '/user/reservations/$reservationId/midtrans/token', // Endpoint BE Anda
        data: {
          'amount': amount,
          'customer_name': customerName,
          'customer_email': customerEmail,
        },
      );

      // Menggunakan SnapTokenModel
      return SnapTokenModel.fromJson(response.data);
    } catch (e) {
      // Perluas error handling di sini jika ada DioException
      throw Exception("Gagal membuat snap token: $e");
    }
  }
  
  // Fungsi Cek Status (dibiarkan seperti sebelumnya, asumsikan MidtransResponseModel
  // diubah namanya menjadi MidtransStatusModel)
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