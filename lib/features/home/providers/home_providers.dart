// lib/features/home/providers/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/dio/dio_provider.dart'; 
import '../../auth/providers/auth_providers.dart'; // Digunakan untuk dependensi
import '../data/models/hotel_model.dart';
import '../data/models/hotel_response.dart';
import '../data/repositories/hotel_repository.dart';
import '../data/services/home_service.dart';

/// Service provider
final homeServiceProvider = Provider<HomeService>((ref) {
  final dio = ref.read(dioProvider);
  return HomeService(dio);
});

/// Repository provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final service = ref.read(homeServiceProvider);
  return HomeRepository(service);
});

/// HomeState - Mirip AuthState
class HomeState {
  final bool isLoading;
  final List<HotelModel> hotels;
  final String? error;

  const HomeState({this.isLoading = false, this.hotels = const [], this.error});

  get message => null;

  HomeState copyWith({bool? isLoading, List<HotelModel>? hotels, String? error}) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      hotels: hotels ?? this.hotels,
      error: error,
    );
  }
}
class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository repository;

  HomeNotifier(this.repository) : super(const HomeState()) {
    fetchHotels(); 
  }

  // Helper untuk memformat error
  String _formatError(Object error) {
    if (error is DioException) {
      // 1. Cek jika ini adalah respon API yang mengembalikan pesan
      if (error.response?.data is Map) {
        final Map<String, dynamic> responseData = error.response!.data;
        // Coba ambil pesan dari field 'message' atau 'error'
        return responseData['message'] ?? responseData['error'] ?? 'Kesalahan API tidak dikenal';
      }
      // 2. Cek jika ini adalah error koneksi
      if (error.type == DioExceptionType.connectionError) {
        return 'Kesalahan Koneksi: Cek BASE URL dan status server Anda.';
      }
    } else if (error is String) {
      return error;
    }
    return 'Terjadi Kesalahan Tak Terduga: ${error.toString()}';
  }

  Future<void> fetchHotels() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final HotelResponse res = await repository.getHotels();
      
      if (res.hotels.isEmpty) {
         state = state.copyWith(isLoading: false, error: 'Tidak ada hotel ditemukan.');
      } else {
         state = state.copyWith(hotels: res.hotels, isLoading: false, error: null);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _formatError(e));
    }
  }
}


/// Provider untuk Notifier global hotel
final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  ref.watch(authNotifierProvider); 
  final repo = ref.read(homeRepositoryProvider);
  return HomeNotifier(repo);
});