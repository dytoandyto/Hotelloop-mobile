import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/dio/dio_provider.dart';
import '../data/models/hotel_detail_model.dart';
import '../data/services/detail_service.dart';

// Provider Service
final hotelDetailServiceProvider = Provider<HotelDetailService>((ref) {
  final dio = ref.read(dioProvider);
  return HotelDetailService(dio);
});

// StateNotifier untuk Detail Hotel (mengelola loading & data)
class HotelDetailNotifier extends StateNotifier<AsyncValue<HotelDetailModel>> {
  final HotelDetailService _service;
  HotelDetailNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> fetchHotelDetail(int hotelId) async {
    state = const AsyncValue.loading();
    try {
      final detail = await _service.getHotelDetail(hotelId);
      state = AsyncValue.data(detail);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// StateNotifierProvider yang menerima ID hotel (Family Provider)
final hotelDetailNotifierProvider = StateNotifierProvider.family<
    HotelDetailNotifier,
    AsyncValue<HotelDetailModel>,
    int // Tipe argumen yang diterima (hotel ID)
>((ref, hotelId) {
  final service = ref.watch(hotelDetailServiceProvider);
  final notifier = HotelDetailNotifier(service);
  notifier.fetchHotelDetail(hotelId); // Panggil fetch saat pertama kali dibuat
  return notifier;
});