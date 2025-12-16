import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';
import 'package:learn_flutter_intermediate/features/bookings/presentation/booking_screen.dart';
import 'package:learn_flutter_intermediate/features/home/data/models/hotel_model.dart';
import 'package:learn_flutter_intermediate/features/home/presentation/home_screen.dart';
// PASTIKAN midtrans_services.dart sudah berisi implementasi url_launcher
import 'package:learn_flutter_intermediate/features/payment/data/services/midtrans_services.dart';
import 'package:learn_flutter_intermediate/features/room_types/data/models/room_type_model.dart';
import 'package:learn_flutter_intermediate/features/payment/provider/payment_provider.dart';

// --- KONSTANTA GAYA MODERN ---
const Color _primaryBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _largeRadius = 24.0;
const double _mediumRadius = 16.0;
const double _smallRadius = 8.0;

class PaymentSummaryScreen extends ConsumerStatefulWidget {
  final ReservationModel reservation;
  final HotelModel hotel;
  final RoomTypeModel roomType;

  const PaymentSummaryScreen({
    super.key,
    required this.reservation,
    required this.hotel,
    required this.roomType,
  });

  @override
  ConsumerState<PaymentSummaryScreen> createState() =>
      _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends ConsumerState<PaymentSummaryScreen> {
  // State lokal untuk menampilkan data reservasi (yang bisa diupdate dari Riverpod)
  late ReservationModel currentReservation;

  @override
  void initState() {
    super.initState();
    currentReservation = widget.reservation;

    // Panggil verifikasi awal jika masih pending (untuk mendapatkan VA atau status terbaru)
    if (currentReservation.paymentStatus.toLowerCase() == 'pending') {
      Future.delayed(const Duration(seconds: 1), () {
        // Cek apakah data VA/TransId sudah ada dari BE (setelah submit)
        _verifyPayment();
      });
    }
  }

  // --- LOGIKA HARGA ---
  final double taxRate = 0;

  double get _reservationSubtotal {
    return currentReservation.totalPrice / (1 + taxRate);
  }

  double get _taxAmount {
    return currentReservation.totalPrice - _reservationSubtotal;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'settlement':
      case 'success':
        return Colors.green.shade600;
      case 'pending':
      case 'authorize':
        return Colors.orange.shade600;
      case 'failed':
      case 'expire':
      case 'cancel':
        return Colors.red.shade600;
      default:
        return _secondaryColor;
    }
  }

  // --- FUNGSI VERIFIKASI ---
  Future<void> _verifyPayment() async {
    final notifier = ref.read(paymentNotifierProvider.notifier);

    // Tampilkan loading saat verifikasi berjalan
    // FIX: Menggunakan checkPaymentStatus dan menambahkan oldReservation
    await notifier.checkPaymentStatus(
      reservationId: currentReservation.id,
      oldReservation: currentReservation,
    );

    // Di sini listener akan menangani pembaruan state
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final paymentState = ref.watch(paymentNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Payment Summary',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'DMSans',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Error Message
            if (paymentState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(_smallRadius),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Error: ${paymentState.error!}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
              ),

            _buildSectionHeader('Hotel & Room'),
            const SizedBox(height: 12),
            _buildHotelCard(context),

            const SizedBox(height: 32),

            _buildSectionHeader('Guest Details'),
            const SizedBox(height: 12),
            _buildGuestCard(),

            const SizedBox(height: 32),

            _buildSectionHeader('Booking Schedule'),
            const SizedBox(height: 12),
            _buildScheduleCard(),

            const SizedBox(height: 32),

            _buildSectionHeader('Payment Details'),
            const SizedBox(height: 12),
            _buildPriceDetailCard(formatter),

            // Tombol Cek Status Manual
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: _verifyPayment,
                  icon: const Icon(Icons.refresh, color: _primaryBlue),
                  label: const Text(
                    'Cek Status Pembayaran Manual',
                    style: TextStyle(color: _primaryBlue, fontFamily: 'DMSans'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPaymentBar(
        context,
        formatter,
        ref,
        paymentState,
      ),
    );
  }

  // --- WIDGET HEADING SECTION ---
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFamily: 'DMSans',
        color: Colors.black87,
      ),
    );
  }

  // --- 1. HOTEL CARD ---
  Widget _buildHotelCard(BuildContext context) {
    final roomType = widget.roomType;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gambar Kamar
          ClipRRect(
            borderRadius: BorderRadius.circular(_smallRadius),
            child: Image.network(
              widget
                  .hotel
                  .imageUrl, // Mengambil gambar dari HotelModel yang dilewatkan
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 90,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Detail Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotel.name, // Nama Hotel
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'DMSans',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Badge Nama Kamar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    roomType.name, // Nama Tipe Kamar
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primaryBlue,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamar No: ${currentReservation.room.roomNumber} | Kapasitas: ${roomType.capacity} orang',
                  style: const TextStyle(
                    color: _secondaryColor,
                    fontSize: 13,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. GUEST DETAILS CARD ---
  Widget _buildGuestCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildScheduleRow(
            'Nama Tamu',
            currentReservation.guestName,
            Icons.person_outline_rounded,
          ),
          const Divider(height: 24),
          _buildScheduleRow(
            'Email',
            currentReservation.guestEmail,
            Icons.email_outlined,
          ),
          const Divider(height: 24),
          _buildScheduleRow(
            'Telepon',
            currentReservation.guestPhone,
            Icons.phone_outlined,
          ),
        ],
      ),
    );
  }

  // --- 3. SCHEDULE CARD ---
  Widget _buildScheduleCard() {
    final checkInStr = DateFormat(
      'EEE, dd MMM yyyy',
    ).format(currentReservation.checkInDate);
    final checkOutStr = DateFormat(
      'EEE, dd MMM yyyy',
    ).format(currentReservation.checkOutDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildScheduleRow('Check-in', checkInStr, Icons.login_rounded),
          const Divider(height: 24),
          _buildScheduleRow('Check-out', checkOutStr, Icons.logout_rounded),
          const Divider(height: 24),
          _buildScheduleRow(
            'Jumlah Malam',
            '${currentReservation.nights} Malam',
            Icons.nightlight_round,
          ),
          const Divider(height: 24),
          _buildScheduleRow(
            'Kode Reservasi',
            currentReservation.reservationCode,
            Icons.vpn_key_outlined,
            isCode: true,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(
    String label,
    String value,
    IconData icon, {
    bool isCode = false,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: highlight ? Colors.red.shade700 : _primaryBlue,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _secondaryColor,
              fontFamily: 'DMSans',
              fontSize: 14,
            ),
          ),
        ),
        // Kontrol tampilan kode reservasi
        if (isCode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: highlight ? Colors.red.shade50 : Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'DMSans',
                fontSize: 14,
                color: highlight ? Colors.red.shade900 : Colors.black87,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'DMSans',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  // --- 4. PRICE DETAIL CARD ---
  Widget _buildPriceDetailCard(NumberFormat formatter) {
    final subtotalStr = formatter.format(_reservationSubtotal);
    final taxStr = formatter.format(_taxAmount);
    final totalStr = formatter.format(currentReservation.totalPrice);
    final statusColor = _getStatusColor(currentReservation.paymentStatus);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Harga Kamar (${currentReservation.nights} Malam)',
            subtotalStr,
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            'Pajak & Biaya Layanan (${(taxRate * 100).toInt()}%)',
            taxStr,
          ),
          const SizedBox(height: 12),
          // Status Pembayaran
          _buildPriceRow(
            'Status Pembayaran',
            currentReservation.paymentStatus.toUpperCase(),
            color: statusColor,
            isStatus: true,
          ),

          const Divider(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'DMSans',
                  color: Colors.black87,
                ),
              ),
              Text(
                totalStr,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: _primaryBlue,
                  fontFamily: 'DMSans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color color = Colors.black,
    bool isStatus = false,
  }) {
    final textColor = color == Colors.black ? Colors.black87 : color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _secondaryColor,
            fontFamily: 'DMSans',
            fontSize: 14,
          ),
        ),
        // Kontrol tampilan status/harga
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'DMSans',
                color: textColor,
                fontSize: 14.5,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'DMSans',
              color: textColor,
              fontSize: 14.5,
            ),
          ),
      ],
    );
  }

  // --- BOTTOM PAYMENT BAR (FINAL) ---
  Widget _buildBottomPaymentBar(
    BuildContext context,
    NumberFormat formatter,
    WidgetRef ref,
    PaymentState paymentState,
  ) {
    final bool isPending =
        currentReservation.paymentStatus.toLowerCase() == 'pending' ||
        currentReservation.paymentStatus.toLowerCase() == 'authorize';
    final bool isSettlementOrPaid =
        currentReservation.paymentStatus.toLowerCase() == 'settlement' ||
        currentReservation.paymentStatus.toLowerCase() == 'paid' ||
        currentReservation.paymentStatus.toLowerCase() == 'success';

    final bool isVerifying = paymentState.isVerifying;
    final bool isGeneratingToken = paymentState.isLoading;

    String buttonText;
    VoidCallback? onPressed;
    bool showLoading = false;

    if (isSettlementOrPaid) {
      // Jika sudah terbayar
      buttonText = 'Pembayaran Berhasil';
      onPressed = () => Navigator.popUntil(context, (route) => route.isFirst);
    } else if (isPending) {
      // Jika belum terbayar dan belum ada token (buat token pertama kali)
      buttonText = isGeneratingToken ? 'Membuat Token...' : 'Bayar Sekarang';
      onPressed = isGeneratingToken
          ? null
          : () async {
              _triggerGenerateAndPay(ref, paymentState);
            };
      showLoading = isGeneratingToken;
    } else {
      // Status lain (expired/failed)
      buttonText =
          'Reservasi ${currentReservation.paymentStatus.toUpperCase()}';
      onPressed = null;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_largeRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Display Total Price (di atas tombol)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Bayar:',
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryColor,
                    fontFamily: 'DMSans',
                  ),
                ),
                Text(
                  formatter.format(currentReservation.totalPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryBlue,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Tombol Aksi
            if (isSettlementOrPaid)
              _buildPaidButton(context)
            else if (isPending)
              _buildPendingOptions(
                context,
                ref,
                paymentState,
              ) // <-- Tampilkan 2 Tombol
            else
              // Status Lain (Expired/Cancel)
              _buildStatusText(currentReservation.paymentStatus.toUpperCase()),
          ],
        ),
      ),
    );
  }

  // --- HELPER UNTUK MEMANGGIL GENERATE TOKEN DAN PEMBAYARAN ---
  // MODIFIKASI: Menerima snapUrl dari provider dan membukanya
  Future<void> _triggerGenerateAndPay(
    WidgetRef ref,
    PaymentState paymentState,
  ) async {
    final notifier = ref.read(paymentNotifierProvider.notifier);

    // 1. Panggil Notifier untuk mendapatkan Snap URL
    // Asumsi notifier.generateSnapToken mengembalikan String snapUrl
    final snapUrl = await notifier.generateSnapToken(
      reservationId: currentReservation.id,
      amount: currentReservation.totalPrice,
      customerEmail: currentReservation.guestEmail,
      customerName: currentReservation.guestName,
    );

    // 2. Jika sukses dan tidak ada error, buka Snap URL
    if (snapUrl != null &&
        !paymentState.isLoading &&
        paymentState.error == null) {
      try {
        // Panggil MidtransService untuk membuka browser/external app
        // await MidtransService.startPayment(snapUrl);

        // Opsional: Tampilkan pesan notifikasi setelah memicu pembukaan browser
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mengarahkan ke halaman pembayaran Midtrans...'),
            backgroundColor: _primaryBlue,
          ),
        );
      } catch (e) {
        // Error handling jika gagal membuka browser
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka halaman Snap: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// --- HELPER UNTUK STATUS PENDING (BAYAR SEKARANG & BAYAR NANTI) ---
Widget _buildPendingOptions(
  BuildContext context,
  WidgetRef ref,
  PaymentState paymentState,
) {
  final isGeneratingToken = paymentState.isLoading;

  return Row(
    children: [
      // TOMBOL 1: BAYAR NANTI (Pay Later / Lanjut ke Riwayat)
      Expanded(
        child: OutlinedButton(
          onPressed: isGeneratingToken
              ? null
              : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                ), // Cukup kembali ke Home/Riwayat
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 56),
            side: const BorderSide(color: _primaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_mediumRadius),
            ),
          ),
          child: const Text(
            'Bayar Nanti',
            style: TextStyle(
              color: _primaryBlue,
              fontWeight: FontWeight.bold,
              fontFamily: 'DMSans',
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),

      // TOMBOL 2: BAYAR SEKARANG (Midtrans Snap)
      Expanded(
        child: ElevatedButton(
          onPressed: isGeneratingToken
              ? null
              : () async {
                  // _triggerGenerateAndPay(ref, paymentState);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            minimumSize: const Size(0, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_mediumRadius),
            ),
          ),
          child: isGeneratingToken
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'DMSans',
                  ),
                ),
        ),
      ),
    ],
  );
}

// --- HELPER TOMBOL STATUS FINAL ---
Widget _buildPaidButton(BuildContext context) {
  return ElevatedButton.icon(
    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    label: const Text(
      'Pembayaran Berhasil',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'DMSans',
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green.shade600,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_mediumRadius),
      ),
    ),
  );
}

Widget _buildStatusText(String status) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(_mediumRadius),
    ),
    child: Text(
      'Status: $status',
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
    ),
  );
}
