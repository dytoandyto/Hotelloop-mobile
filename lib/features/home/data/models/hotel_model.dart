import 'package:intl/intl.dart'; // Tambahkan impor Intl jika Anda menggunakan formattedPrice helper

// Menghapus import 'package:flutter_dotenv/flutter_dotenv.dart';

class HotelModel {
  final int id;
  final String name;
  final String address; 
  final String fullAddressText;
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
    // PERUBAHAN UTAMA: Menggunakan mediaBaseUrl yang di-hardcode
    const String mediaBaseUrl = 'https://9132a71cf343.ngrok-free.app/storage/'; 
    
    // 1. Logika Ambil Gambar
    final List<dynamic> rawImages = json['images'] ?? [];
    String image = 'https://placehold.co/150x150/E0E0E0/grey?text=No+Image';

    if (rawImages.isNotEmpty) {
      final String? relativeUrl = rawImages[0]['image_url'];
      if (relativeUrl != null && relativeUrl.isNotEmpty) {
         // Gabungkan BASE URL storage dengan path relatif
         image = mediaBaseUrl + relativeUrl; 
      }
    }
    
    // 2. Logika Ambil Fasilitas
    final List<dynamic> rawFacilities = json['facilities'] ?? [];
    final List<String> facilityNames = rawFacilities
        .map((f) => f['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    // 3. Logika Alamat Gabungan (menggunakan data region dari API)
    final provinceName = json['province']?['name'] ?? '';
    final cityName = json['city']?['name'] ?? '';
    final districtName = json['district']?['name'] ?? '';
    final subDistrictName = json['sub_district']?['name'] ?? '';
    
    final shortAddress = '$cityName, $provinceName'; 

    final fullAddressText = '${json['address'] ?? ''}, ${subDistrictName}, ${districtName}, ${cityName}, ${provinceName}';
    
    // 4. Logika Rating & Harga (DUMMY/FALLBACK)
    final double rating = double.tryParse(json['rating']?.toString() ?? '') ?? 4.5; 
    final int startPrice = json['start_price'] ?? 500000; 

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
    // Menggunakan NumberFormat untuk pemformatan yang lebih aman
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(startPrice);
  }
}