// lib/features/room_types/data/models/room_type_model.dart
import 'package:intl/intl.dart'; 
import 'bed_model.dart'; // Import BedModel
import 'price_model.dart'; // Import PriceModel

class RoomTypeModel {
  final int id;
  final String name;
  final String description;
  final int capacity;
  final String imageUrl;
  final List<String> facilities;
  final List<BedModel> beds;
  final PriceModel price;
  

  RoomTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.imageUrl,
    required this.facilities,
    required this.beds,
    required this.price,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    // PASTIkan URL Ngrok ini adalah yang sedang aktif
    const String mediaBaseUrl = 'https://5dfbf810413c.ngrok-free.app/storage/'; 
    
    // 1. Gambar
    String image = 'https://placehold.co/600x300/E0E0E0/grey?text=No+Room+Image';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final path = json['images'][0]['image_url'] ?? '';
      if (path.isNotEmpty) {
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
        // Asumsi BedModel memiliki factory fromJson
        // Di sini kita TIDAK perlu memanggil toJson dari BedModel karena POST /room-types
        // biasanya mengirimkan data harga dan bed type, bukan model lengkap.
        .map((b) => BedModel.fromJson(b as Map<String, dynamic>))
        .toList();
    
    // 4. Harga (Asumsi mengambil harga pertama dari array 'prices')
    final PriceModel price = (json['prices'] as List? ?? []).isNotEmpty
        ? PriceModel.fromJson(json['prices'][0])
        : PriceModel(weekdayPrice: 0.0, weekendPrice: 0.0, currency: 'IDR');

    return RoomTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Tipe Kamar',
      description: json['description'] ?? 'Fasilitas dan kamar yang nyaman.',
      capacity: json['capacity'] ?? 1,
      imageUrl: image,
      facilities: facilities,
      beds: beds,
      price: price,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'capacity': capacity,
      // Jika BE Anda mengharapkan list bed dan harga, Anda perlu menambahkan:
      // 'beds': beds.map((b) => b.toJson()).toList(), 
      // 'prices': [price.toJson()],
    };
  }
  
  // Helper format harga IDR
  String get formattedPrice {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    // Kita ambil harga weekday sebagai harga dasar
    return format.format(price.weekdayPrice.round()); 
  }
}