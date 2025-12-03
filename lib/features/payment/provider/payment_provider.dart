// provider/payment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';
import 'package:learn_flutter_intermediate/features/payment/data/services/payment_service.dart'; // Diperlukan untuk Dio/Service

// Provider untuk PaymentService (Repository)
final paymentServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentService(dio);
});

// ... (Definisi PaymentState dan ReservationModel) ...

// 2. STATE NOTIFIER
class PaymentNotifier extends StateNotifier<PaymentState> {
  // Inject PaymentService yang sesungguhnya
  final PaymentService _paymentService;

  PaymentNotifier(this._paymentService) : super(PaymentState());

  // Menggunakan fungsi yang di-inject dari service
  Future<String?> generateSnapToken({
    required int reservationId,
    required double amount,
    required String customerEmail,
    required String customerName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Panggil service yang menggunakan Dio dan endpoint BE Anda
      final snapTokenModel = await _paymentService.createSnapTransaction(
        reservationId: reservationId,
        amount: amount,
        customerEmail: customerEmail,
        customerName: customerName,
      );

      final String snapUrl = snapTokenModel.snapUrl;

      if (snapUrl.isEmpty) {
        throw Exception("Snap URL kosong dari backend.");
      }

      state = state.copyWith(isLoading: false);
      return snapUrl; // Mengembalikan URL untuk dibuka di screen
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal membuat token: ${e.toString()}',
      );
      return null;
    }
  }

  // 2. Cek Status Pembayaran
  Future<ReservationModel?> checkPaymentStatus({
    required int reservationId,
    required ReservationModel oldReservation,
  }) async {
    state = state.copyWith(isVerifying: true, error: null);

    try {
      // Panggil service untuk cek status (menggantikan mock HTTP client)
      final statusModel = await _paymentService.checkStatus(
        reservationId.toString(),
      );

      final updatedReservation = oldReservation.copyWith(
        paymentStatus: statusModel.transactionStatus,
        // Anda mungkin perlu menyesuaikan bagaimana VA Number didapatkan
        // dari MidtransStatusModel jika BE Anda mengembalikannya
        midtransTransactionId: statusModel.transactionId,
      );

      state = state.copyWith(
        isVerifying: false,
        verifiedReservation: updatedReservation,
      );
      return updatedReservation;
    } catch (e) {
      state = state.copyWith(
        isVerifying: false,
        error: 'Gagal verifikasi status: ${e.toString()}',
      );
      return null;
    }
  }

  // 3. Reset state verifikasi setelah UI memprosesnya
  void resetVerificationState() {
    state = state.copyWith(verifiedReservation: null);
  }
}

class PaymentState {
  final bool isLoading;
  final bool isVerifying;
  final String? error;
  final ReservationModel? verifiedReservation;

  PaymentState({
    this.isLoading = false,
    this.isVerifying = false,
    this.error,
    this.verifiedReservation,
  });

  PaymentState copyWith({
    bool? isLoading,
    bool? isVerifying,
    String? error,
    ReservationModel? verifiedReservation,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      error: error,
      verifiedReservation: verifiedReservation ?? this.verifiedReservation,
    );
  }
}

// 3. GLOBAL PROVIDER
final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
      // Inject service
      final service = ref.watch(paymentServiceProvider);
      return PaymentNotifier(service);
    });
