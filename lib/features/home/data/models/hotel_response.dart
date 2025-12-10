// lib/features/home/data/models/hotel_response.dart
import 'hotel_model.dart';

class HotelResponse {
  final List<HotelModel> hotels;
  final String? message;
  final String? error;

  HotelResponse({
    required this.hotels,
    this.message,
    this.error,
  });

  factory HotelResponse.fromJson(Map<String, dynamic> json) {
    // 1. Ambil objek 'data' terluar (yang berisi pagination metadata)
    final outerData = json['data']; 
    
    // 2. Ambil list hotel dari kunci 'data' di dalam objek pagination
    final List<dynamic> hotelListData = outerData != null && outerData['data'] is List 
        ? outerData['data'] as List 
        : []; 

    final List<HotelModel> hotelList = hotelListData
        .map((e) => HotelModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return HotelResponse(
      hotels: hotelList,
      message: json['message'],
      error: json['error'],
    );
  }
}