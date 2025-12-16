import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';
import 'package:learn_flutter_intermediate/features/auth/providers/auth_providers.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/services/reservation_services.dart';
import '../data/models/reservation_model.dart';
// WAJIB IMPOR SEMUA MODEL UNTUK MOCK OBJECT DI BAWAH INI
import '../../room_types/data/models/room_type_model.dart';
import '../../room_types/data/models/room_model.dart';
import '../../room_types/data/models/price_model.dart';

// State untuk proses Reservasi (ReservationState sudah benar)
class ReservationState {
  final bool isLoading;
  final ReservationModel? reservation;
  final String? error;

  const ReservationState({
    this.isLoading = false,
    this.reservation,
    this.error,
  });

  ReservationState copyWith({
    bool? isLoading,
    ReservationModel? reservation,
    String? error,
  }) {
    // Note: error di-set null jika tidak ada error baru, agar bisa hilang saat success/loading
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
  final AuthNotifier _authNotifier; // Digunakan untuk mengambil user ID

  // KOREKSI CONSTRUCTOR: Gunakan parameter yang sama dengan provider di bawah
  ReservationNotifier(this.service, this._authNotifier)
    : super(const ReservationState()); // Harus pakai ReservationState

  // KOREKSI TIPE RETURN: Mengembalikan Future<ReservationModel?>
  Future<ReservationModel?> submitReservation({
    required int hotelId,
    required RoomTypeModel roomType,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    required String checkInDate,
    required int nights,
    required int guests, // Menggunakan 'guests' dari form
  }) async {
    // START: Gunakan copyWith dari ReservationState
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Ambil User ID dari AuthNotifier
      // FIX: Akses ID melalui state AuthNotifier
      final currentUserId = _authNotifier.state.user?.id;

      // 2. Cek jika user ID tidak ditemukan (meskipun harusnya sudah login)
      if (currentUserId == null) {
        throw Exception("User ID tidak ditemukan. Harap login kembali.");
      }

      // Hitung tanggal check-out
      final checkOutDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.parse(checkInDate).add(Duration(days: nights)));

      // Dapatkan Room ID Fisik yang tersedia
      final roomId = await service.findAvailableRoomId(
        roomTypeId: roomType.id,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      // 3. Panggil service dengan menambahkan data sesuai payload minimal BE
      final reservation = await service.createReservation(
        roomId: roomId,
        userId: currentUserId,
        guestName: guestName,
        guestEmail: guestEmail,
        guestPhone: guestPhone,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        // Parameter 'guests' dan 'notes' diabaikan di sini karena BE minimal hanya butuh 7 field
      );

      // SUCCESS: Emit ReservationState baru dengan data reservasi
      state = state.copyWith(
        isLoading: false,
        reservation: reservation,
        error: null,
      );
      return reservation;
    } catch (e) {
      // ERROR: Emit ReservationState baru dengan error
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

// Provider Service (Tidak ada perubahan, sudah benar)
final reservationServiceProvider = Provider<ReservationService>((ref) {
  final dio = ref.read(dioProvider);
  return ReservationService(dio);
});

final reservationNotifierProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
      return ReservationNotifier(
        ref.read(reservationServiceProvider),
        // FIX: Menggunakan read() untuk Notifier Auth
        ref.read(authNotifierProvider.notifier),
      );
    });