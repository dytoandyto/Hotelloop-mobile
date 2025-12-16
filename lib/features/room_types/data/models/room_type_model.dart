// lib/features/room_types/data/models/room_type_model.dart (VERSI TERSINKRONISASI)

import 'package:intl/intl.dart'; 
// Pastikan import ini ada
// import 'package:learn_flutter_intermediate/features/home/data/models/hotel_model.dart'; 
import 'bed_model.dart'; 
import 'price_model.dart'; 

class RoomTypeModel {
  final int id;
  final String name;
  final String description;
  final int capacity;
  final String imageUrl; // URL Lengkap Gambar
  final List<String> facilities;
  final List<BedModel> beds;
  final PriceModel price; // Single Price Model
  
  // Catatan: Jika Anda berencana menggunakan relasi Hotel, Anda harus menambahkannya di sini
  // final HotelModel? hotel; 

  RoomTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.imageUrl,
    required this.facilities,
    required this.beds,
    required this.price,
    // this.hotel,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    // PASTIkan URL Ngrok ini adalah yang sedang aktif. Ganti ini jika Ngrok berubah!
    const String mediaBaseUrl = 'https://9eb2ea56402f.ngrok-free.app/storage/'; 
    
    // --- 1. Gambar (Logika Diperkuat) ---
    String image = 'https://placehold.co/600x300/E0E0E0/grey?text=No+Room+Image';
    
    final List<dynamic> rawImages = json['images'] ?? [];
    if (rawImages.isNotEmpty) {
      final path = rawImages[0]['image_url'] ?? '';
      if (path.isNotEmpty) {
        // Gabungkan Base URL dengan path relatif dari BE
        image = mediaBaseUrl + path; 
      }
    }
    
    // 2. Fasilitas (Mengambil nama dari array 'facilities')
    final List<String> facilities = (json['facilities'] as List? ?? [])
        .map((f) => f['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    // 3. Bed
    final List<BedModel> beds = (json['beds'] as List? ?? [])
        .map((b) => BedModel.fromJson(b as Map<String, dynamic>))
        .toList();
    
    // 4. Harga (Mengambil harga pertama dari array 'prices' atau default)
    final PriceModel price = (json['prices'] as List? ?? []).isNotEmpty && json['prices']![0] is Map
        ? PriceModel.fromJson(json['prices']![0] as Map<String, dynamic>)
        : PriceModel(weekdayPrice: 0.0, weekendPrice: 0.0, currency: 'IDR');

    return RoomTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tipe Kamar',
      description: json['description'] ?? 'Fasilitas dan kamar yang nyaman.',
      capacity: json['capacity'] ?? 1,
      imageUrl: image, // URL Lengkap
      facilities: facilities,
      beds: beds,
      price: price,
      // hotel: null,
    );
  }
  
  Map<String, dynamic> toJson() {
    // ... (logic toJson) ...
    return {
        'name': name,
        'description': description,
        'capacity': capacity,
        // ...
    };
  }
  
  // Helper format harga IDR
  String get formattedPrice {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(price.weekdayPrice.round()); 
  }
}