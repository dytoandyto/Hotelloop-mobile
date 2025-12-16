//
import 'package:intl/intl.dart';
import 'package:learn_flutter_intermediate/features/room_types/data/models/bed_model.dart';
// Import RoomModel yang sudah menggunakan RoomTypeModel baru
import '../../../room_types/data/models/room_model.dart';

class ReservationModel {
  final int id;
  final int? userId;
  final String reservationCode;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final double totalPrice;
  final String paymentStatus;
  final String reservationStatus;
  final RoomModel room;

  // --- FIELD BARU YANG DIBUTUHKAN ---
  final String? plannedCheckIn; // Format Waktu, e.g., "14.00"
  final String? plannedCheckOut; // Format Waktu, e.g., "12.00"
  // ----------------------------------

  ReservationModel({
    required this.id,
    required this.userId,
    required this.reservationCode,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.totalPrice,
    required this.paymentStatus,
    required this.reservationStatus,
    required this.room,
    // --- TAMBAHKAN DI CONSTRUCTOR ---
    this.plannedCheckIn,
    this.plannedCheckOut,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // Menangani respons yang mungkin berupa objek tunggal atau array data (untuk list/detail)
    final data = json['data'] is List
        ? json['data'][0]
        : (json['reservation'] ?? json);

    return ReservationModel(
      id: data['id'] ?? 0,
      userId: data['user_id'] ?? 0,
      reservationCode: data['reservation_code'] ?? 'RSV-N/A',
      checkInDate:
          DateTime.tryParse(data['check_in_date'] ?? '') ?? DateTime.now(),
      checkOutDate:
          DateTime.tryParse(data['check_out_date'] ?? '') ?? DateTime.now(),
      nights: data['nights'] ?? 1,
      guestName: data['guest_name'] ?? 'Tamu',
      guestEmail: data['guest_email'] ?? 'tamu@mail.com',
      guestPhone: data['guest_phone'] ?? 'N/A',
      totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: data['payment_status'] ?? 'pending',
      reservationStatus: data['reservation_status'] ?? 'booked',
      room: RoomModel.fromJson(data['room'] ?? {}),
      // --- Parsing properti Midtrans (Diasumsikan ada di respons API) ---
      // Catatan: Jika properti ini tidak ada di respons API Anda, nilainya akan null.
      // --- PARSING FIELD BARU DARI BACKEND ---
      plannedCheckIn: data['planned_check_in'] as String?,
      plannedCheckOut: data['planned_check_out'] as String?,
    );
  }

  // Helper untuk membuat objek baru dengan status/properti pembayaran yang diperbarui
  ReservationModel copyWith({
    int? id,
    int? userId,
    String? reservationCode,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? nights,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    double? totalPrice,
    String? paymentStatus,
    String? reservationStatus,
    RoomModel? room,
    BedModel? bed,
    String? plannedCheckIn,
    String? plannedCheckOut,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reservationCode: reservationCode ?? this.reservationCode,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      nights: nights ?? this.nights,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      reservationStatus: reservationStatus ?? this.reservationStatus,
      room: room ?? this.room,
      plannedCheckIn: plannedCheckIn ?? this.plannedCheckIn,
      plannedCheckOut: plannedCheckOut ?? this.plannedCheckOut,
    );
  }

  String get formattedTotalPrice {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(totalPrice.round());
  }
}
