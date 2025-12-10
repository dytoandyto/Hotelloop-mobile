// lib/features/home/data/models/hotel_model.dart
import 'package:intl/intl.dart';

// URL Ngrok yang digunakan sebagai base media
const String _mediaBaseUrl = 'https://5dfbf810413c.ngrok-free.app/storage/';

class HotelModel {
  final int id;
  final String name;
  final String address; // Alamat Fisik (Short)
  final String fullAddressText; // Alamat Lengkap (Long)
  final String description;
  final double rating;
  final int startPrice;
  final String imageUrl;
  final List<String> facilities;

  HotelModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.rating,
    required this.startPrice,
    required this.imageUrl,
    required this.fullAddressText,
    required this.facilities,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    // --- 1. Logika Gambar ---
    final List<dynamic> rawImages = json['images'] ?? [];
    String image = 'https://placehold.co/150x150/E0E0E0/grey?text=No+Image';

    if (rawImages.isNotEmpty) {
      final String? relativeUrl = rawImages[0]['image_url'];
      if (relativeUrl != null && relativeUrl.isNotEmpty) {
        image = _mediaBaseUrl + relativeUrl;
      }
    }

    // --- 2. Logika Fasilitas (Hanya Nama) ---
    final List<dynamic> rawFacilities = json['facilities'] ?? [];
    final List<String> facilityNames = rawFacilities
        .map((f) => f['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    // --- 3. Logika Alamat (DIUATKAN UNTUK MENANGANI NULL) ---
    final String physicalAddress = json['address'] ?? ''; // Jangan pakai default "Tidak Diketahui" di sini agar bisa dihilangkan jika null

    final provinceName = json['province']?['name'] ?? '';
    final cityName = json['city']?['name'] ?? '';
    final districtName = json['district']?['name'] ?? '';
    final subDistrictName = json['sub_district']?['name'] ?? '';

    // address (Short/List): Prioritas alamat fisik, fallback ke Kota/Provinsi jika fisik kosong
    final shortAddress = physicalAddress.isNotEmpty
        ? physicalAddress
        : (cityName.isNotEmpty ? '$cityName, $provinceName' : 'Lokasi Tidak Diketahui');

    // fullAddressText (Detail): Gabungan lengkap, menghilangkan bagian yang kosong
    final fullAddressTextParts = [
      physicalAddress,
      subDistrictName,
      districtName,
      cityName,
      provinceName,
    ].where((part) => part.isNotEmpty).toList();

    // Menggunakan join(', ') hanya pada bagian yang terisi
    final fullAddressText = fullAddressTextParts.join(', ');

    // --- 4. Logika Rating & Harga ---
    final double rating = double.tryParse(json['rating']?.toString() ?? '') ?? 4.5;
    final int startPrice = json['start_price'] ?? 0;

    return HotelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Hotel',
      address: shortAddress,
      fullAddressText: fullAddressText,
      description: json['description'] ?? '',
      rating: rating,
      startPrice: startPrice,
      imageUrl: image,
      facilities: facilityNames,
    );
  }

  // Helper untuk format harga (Simulasi Rupiah)
  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(startPrice);
  }
}