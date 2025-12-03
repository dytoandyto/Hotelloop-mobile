import 'room_type_model.dart'; // Import RoomTypeModel (versi kaya)

class RoomModel {
  final int id;
  final String roomNumber;
  // MENGGUNAKAN RoomTypeModel yang kaya
  final RoomTypeModel roomType; 
  
  RoomModel({required this.id, required this.roomNumber, required this.roomType});

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? 'N/A',
      // Menggunakan RoomTypeModel.fromJson
      roomType: RoomTypeModel.fromJson(json['room_type'] ?? {}),
    );
  }
}