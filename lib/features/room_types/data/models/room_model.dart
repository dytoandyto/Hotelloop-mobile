// lib/features/room_types/data/models/room_model.dart
import 'room_type_model.dart';
// Note: HotelModel tidak ada di sini, tapi ada di respons Room Type.
// Kita hanya ambil data dasar yang dibutuhkan.

class RoomModel {
  final int id; // ID Kamar Fisik (Yang dibutuhkan di payload reservasi)
  final int roomTypeId; 
  final String roomNumber;
  final String status; // 'available' atau 'occupied'

  // Model ini bisa disederhanakan karena RoomTypeModel sudah di-fetch di tempat lain
  // Namun, kita tetap parsing semua field yang penting untuk debug.
  final RoomTypeModel roomType; // <--- PASTIKAN INI ADA!
  
  RoomModel({
    required this.id, 
    required this.roomTypeId, 
    required this.roomNumber, 
    required this.status,
    // Kita hapus RoomTypeModel dari constructor ini untuk menyederhanakan
    required this.roomType,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      roomTypeId: json['room_type_id'] ?? 0,
      roomNumber: json['room_number'] ?? 'N/A',
      status: json['status'] ?? 'unknown',
      // Kita tidak perlu parsing RoomType di sini karena sudah ada di RoomTypeModel
      roomType: RoomTypeModel.fromJson(json['room_type'] ?? {}),
    );
  }
}