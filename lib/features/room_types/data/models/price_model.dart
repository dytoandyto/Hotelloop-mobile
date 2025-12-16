// lib/features/room_types/data/models/price_model.dart
import 'package:intl/intl.dart'; 

class PriceModel {
  final double weekdayPrice;
  final double weekendPrice;
  final String currency;

  PriceModel({
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.currency,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    // Parsing String/Decimal ke Double dengan aman
    final weekdayPriceStr = json['weekday_price']?.toString() ?? '0';
    final weekendPriceStr = json['weekend_price']?.toString() ?? '0';

    return PriceModel(
      weekdayPrice: double.tryParse(weekdayPriceStr) ?? 0.0,
      weekendPrice: double.tryParse(weekendPriceStr) ?? 0.0,
      currency: json['currency'] ?? 'IDR',
    );
  }

  // --- HELPER BARU ---
  /// Mengambil harga terendah dari weekdayPrice atau weekendPrice.
  /// Harga dikonversi ke integer (pembulatan ke bawah) karena harga biasanya bulat.
  int get lowestPrice {
    // Memastikan tidak ada harga negatif
    final price1 = weekdayPrice > 0 ? weekdayPrice : double.maxFinite;
    final price2 = weekendPrice > 0 ? weekendPrice : double.maxFinite;

    if (price1 == double.maxFinite && price2 == double.maxFinite) {
      return 0; // Kedua harga nol atau tidak valid
    }

    // Mengambil harga minimum
    final minPrice = (price1 < price2) ? price1 : price2;
    
    // Pembulatan ke integer terdekat (kebawah/floor)
    return minPrice.floor();
  }

  /// Mengambil harga minimum dan memformatnya ke Rupiah (Rp).
  String get formattedPrice {
    final price = lowestPrice;

    if (price == 0) {
      return 'Harga Tidak Tersedia';
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    // Harga ditampilkan sebagai harga terendah (lowestPrice)
    return formatter.format(price);
  }
}