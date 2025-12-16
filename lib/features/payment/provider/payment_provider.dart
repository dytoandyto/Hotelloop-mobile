// lib/features/payment/provider/payment_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/core/dio/dio_provider.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';

import 'package:learn_flutter_intermediate/features/payment/data/services/payment_service.dart';

// 1. PROVIDER SERVICE/REPOSITORY
// Menggunakan PaymentService untuk call API BE
final paymentServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentService(dio);
});

// 2. STATE NOTIFIER
class PaymentNotifier extends StateNotifier<PaymentState> {
  // Inject PaymentService
  final PaymentService _paymentService;

  PaymentNotifier(this._paymentService) : super(PaymentState());

  /// Fungsi untuk memanggil API Laravel dan mendapatkan Snap Token
  /// Menggunakan parameter lengkap sesuai kebutuhan BE untuk Midtrans Snap.
  Future<String?> generateSnapToken({
    // Asumsi: Kita menggunakan endpoint createUserSnapToken,
    // sehingga membutuhkan data reservasi lengkap (kecuali hotelId)
    required int reservationId,
    required double amount,
    required String customerEmail,
    required String customerName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Panggil PaymentService untuk mendapatkan Snap Token
      final snapTokenModel = await _paymentService.createSnapTransaction(
        reservationId: reservationId,
        amount: amount,
        customerEmail: customerEmail,
        customerName: customerName,
      );

      // Setelah berhasil, kembalikan snapToken
      state = state.copyWith(isLoading: false);
      return snapTokenModel.snapToken;

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
      // Panggil PaymentService untuk mock cek status
      final statusModel = await _paymentService.checkStatus(
        reservationId.toString(),
      );
      
      // Update ReservationModel berdasarkan hasil status Midtrans
      final updatedReservation = oldReservation.copyWith(
        paymentStatus: statusModel.transactionStatus, 
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
      verifiedReservation: verifiedReservation,
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