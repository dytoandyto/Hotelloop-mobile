// lib/features/room_types/data/models/bed_model.dart
class BedModel {
  final String name;
  final int quantity;

  BedModel({required this.name, required this.quantity});

  factory BedModel.fromJson(Map<String, dynamic> json) {
    return BedModel(
      name: json['bed_type']?['name'] ?? 'Kasur Standar',
      quantity: json['quantity'] ?? 1,
    );
  }
}