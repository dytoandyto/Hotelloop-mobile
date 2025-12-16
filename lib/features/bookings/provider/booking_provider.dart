import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';
import 'package:learn_flutter_intermediate/features/bookings/data/services/booking_service.dart';

// Provider Service
final bookingsServiceProvider = Provider<BookingsService>((ref) {
  final dio = ref.read(dioProvider);
  return BookingsService(dio);
});

// StateNotifier untuk mengelola daftar reservasi
class BookingsNotifier extends StateNotifier<AsyncValue<List<ReservationModel>>> {
  final BookingsService _service;

  BookingsNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    state = const AsyncValue.loading();
    try {
      final List<ReservationModel> reservations = await _service.fetchUserReservations(); 
      state = AsyncValue.data(reservations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Provider utama yang digunakan di UI
final bookingsNotifierProvider = 
    StateNotifierProvider<BookingsNotifier, AsyncValue<List<ReservationModel>>>((ref) {
      final service = ref.read(bookingsServiceProvider);
      return BookingsNotifier(service);
    });