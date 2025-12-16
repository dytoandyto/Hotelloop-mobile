// lib/features/home/data/repositories/hotel_repository.dart
import '../models/hotel_response.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeService homeService;

  HomeRepository(this.homeService);

  Future<HotelResponse> getHotels() {
    return homeService.getHotels();
  }
}