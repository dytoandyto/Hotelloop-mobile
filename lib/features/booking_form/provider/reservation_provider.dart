import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/services/reservation_services.dart';
import '../data/models/reservation_model.dart';
import '../provider/reservation_provider.dart';


// State untuk proses Reservasi
class ReservationState {
  final bool isLoading;
  final ReservationModel? reservation;
  final String? error;

  const ReservationState({this.isLoading = false, this.reservation, this.error});

  ReservationState copyWith({bool? isLoading, ReservationModel? reservation, String? error}) {
    return ReservationState(
      isLoading: isLoading ?? this.isLoading,
      reservation: reservation ?? this.reservation,
      error: error,
    );
  }
}

// Notifier yang menangani logic API
class ReservationNotifier extends StateNotifier<ReservationState> {
  final ReservationService service;

  ReservationNotifier(this.service) : super(const ReservationState());

  Future<ReservationModel?> submitReservation({
    required int roomTypeId,
    required int hotelId, // Tambahkan hotelId sebagai data tambahan yang mungkin dibutuhkan backend
    required int nights,
    required String checkInDate,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulasi pemilihan room ID (karena backend Anda memerlukan room_id, bukan hanya room_type_id)
    // Dalam aplikasi nyata, Anda akan memiliki endpoint untuk mengecek ketersediaan kamar spesifik.
    // Kita hardcode Room ID 1 untuk demo.
    const int dummyRoomId = 1; 

    try {
      // Hitung check out
      final checkOutDate = DateTime.parse(checkInDate)
          .add(Duration(days: nights))
          .toIso8601String()
          .split('T')[0];

      final reservation = await service.createReservation(
        roomTypeId: roomTypeId,
        roomId: dummyRoomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        guestName: guestName,
        guestEmail: guestEmail,
        guestPhone: guestPhone,
      );

      state = state.copyWith(isLoading: false, reservation: reservation);
      return reservation;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

// Provider
final reservationNotifierProvider = StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  final service = ref.read(reservationServiceProvider);
  return ReservationNotifier(service);
});

// Provider Service (Perlu diupdate jika belum ada)
final reservationServiceProvider = Provider<ReservationService>((ref) {
  // Asumsi DioProvider sudah ada di core
  final dio = ref.read(dioProvider); 
  return ReservationService(dio);
});