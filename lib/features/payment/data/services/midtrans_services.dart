// data/services/midtrans_services.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // <<< Tambahkan ini

// Model-model Midtrans response yang berulang dihilangkan, 
// dan dipanggil dari file model yang seharusnya.
// Model MidtransResponseModel di sini dihapus / dipindahkan.

class MidtransService {

  // Fungsi utilitas untuk membuka URL pembayaran Snap
  static Future<void> startPayment(String snapUrl) async {
    final uri = Uri.parse(snapUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Lebih baik throw Exception agar bisa ditangkap di Provider/Screen
      throw Exception('Could not launch Midtrans Snap URL: $snapUrl');
    }
  }
}