// features/payment/data/services/midtrans_services.dart
import 'package:dio/src/dio.dart';
import 'package:url_launcher/url_launcher.dart'; 

class MidtransService {
  MidtransService(Dio dio);

  // Fungsi utilitas untuk membuka URL pembayaran Snap di browser
  static Future<void> startPayment(String snapUrl) async {
    final uri = Uri.parse(snapUrl);
    
    // Gunakan mode externalApplication untuk membuka di browser penuh
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) { 
      throw Exception('Gagal membuka halaman Midtrans Snap: $snapUrl');
    }
  }
}