// lib/features/home/data/models/hotel_detail_model.dart
import 'package:learn_flutter_intermediate/features/home/data/models/hotel_model.dart';

class HotelDetailModel extends HotelModel {
  final List<String> imageUrls;
  final List<FacilityModel> fullFacilities;

  HotelDetailModel({
    required super.id,
    required super.name,
    required super.address,
    required super.description,
    required super.rating,
    required super.startPrice,
    required super.imageUrl,
    required super.fullAddressText,
    required super.facilities,
    required this.imageUrls,
    required this.fullFacilities,
  });

  factory HotelDetailModel.fromJson(Map<String, dynamic> json) {
    // Data detail hotel diasumsikan ada di root object atau 'data'
    final Map<String, dynamic> hotel = json['data'] ?? json;

    // 1. Ambil data dasar (rating, price, address, dll.)
    // Logic alamat yang di-perkuat sudah ada di HotelModel.fromJson
    final HotelModel base = HotelModel.fromJson(hotel);

    // 2. Ambil list URL Gambar (Semua Gambar)
    const String mediaBaseUrl = 'https://9eb2ea56402f.ngrok-free.app/storage/'; 
    final List<dynamic> rawImages = hotel['images'] ?? [];
    
    final List<String> imageUrls = rawImages.map<String>((img) {
      final String? relativeUrl = img['image_url'];
      if (relativeUrl != null && relativeUrl.isNotEmpty) {
        return mediaBaseUrl + relativeUrl;
      }
      return 'https://placehold.co/150x150/E0E0E0/grey?text=No+Image';
    }).toList();

    // 3. Ambil Fasilitas Lengkap (Objek FacilityModel)
    final List<dynamic> rawFacilities = hotel['facilities'] ?? [];
    final List<FacilityModel> facilities = rawFacilities
        .map((f) => FacilityModel.fromJson(f as Map<String, dynamic>))
        .toList();

    // 4. Mengembalikan HotelDetailModel
    return HotelDetailModel(
      id: base.id,
      name: base.name,
      address: base.address,
      description: base.description,
      rating: base.rating,
      startPrice: base.startPrice,
      imageUrl: base.imageUrl,
      fullAddressText: base.fullAddressText,
      facilities: base.facilities,
      imageUrls: imageUrls,
      fullFacilities: facilities,
    );
  }
}

// Tambahkan FacilityModel di sini jika tidak dibuat di file terpisah
class FacilityModel {
  final String name;
  FacilityModel({required this.name});

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(name: json['name'] ?? '');
  }
}