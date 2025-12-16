import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';
import 'package:learn_flutter_intermediate/features/bookings/provider/booking_provider.dart';
import 'package:learn_flutter_intermediate/features/payment/data/services/midtrans_services.dart';
import 'package:url_launcher/url_launcher.dart'; // Import untuk Webview

// --- CONSTANTS ---
const double _mediumRadius = 12.0;
const Color _primaryColor = Color(0xFF1E88E5); // Blue
const Color _secondaryColor = Colors.grey;
const Color _successColor = Colors.green;
const Color _pendingColor = Colors.orange;

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  // --- HELPER 1: MENGAMBIL NAMA RESERVASI/KAMAR ---
  String _getReservationName(ReservationModel booking) {
    return 'Reservasi: ${booking.room.roomType.name ?? 'Tipe Kamar'}';
  }

  // --- HELPER 2: MENGAMBIL IMAGE URL ---
  String _getImageUrl(ReservationModel booking) {
    return booking.room.roomType.imageUrl ?? '';
  }

  // --- HELPER 3: MENGAMBIL NOMOR RESERVASI ---
  String _getReservationCode(ReservationModel booking) {
    return booking.reservationCode;
  }

  // --- WIDGET LIST VIEW UNTUK TAB (DIPERBAIKI SCOPE) ---
  Widget _buildBookingList(
    List<ReservationModel> bookings,
    BuildContext context,
    WidgetRef ref, // Menerima WidgetRef
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.luggage_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pesanan di sini.',
              style: TextStyle(
                fontSize: 16,
                color: _secondaryColor,
                fontFamily: 'DMSans',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(bookings[index], context, ref); // Meneruskan ref
      },
    );
  }

  // --- WIDGET CARD UNTUK PESANAN INDIVIDUAL (DIPERBAIKI SCOPE) ---
  Widget _buildBookingCard(
      ReservationModel booking, BuildContext context, WidgetRef ref) {
    String formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);

    final bool isUpcoming = booking.checkInDate.isAfter(DateTime.now());
    final bool requiresPayment =
        booking.paymentStatus.toLowerCase() == 'pending' && isUpcoming;

    final Color statusColor = _getStatusColor(booking.paymentStatus);

    final String reservationName = _getReservationName(booking);
    final String imageUrl = _getImageUrl(booking);
    final String reservationCode = _getReservationCode(booking);

    final String formattedPrice = booking.formattedTotalPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Header (Gambar)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_mediumRadius),
            ),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: _secondaryColor),
                      ),
                    ),
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.hotel, color: _secondaryColor),
                    ),
                  ),
          ),

          // Detail Booking
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Reservasi / Tipe Kamar
                Text(
                  reservationName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DMSans',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Nomor Reservasi
                Text(
                  'Nomor Reservasi: $reservationCode',
                  style: TextStyle(
                    fontSize: 14,
                    color: _secondaryColor,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 12),

                // Status & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Badge (Pembayaran)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        booking.paymentStatus.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Total Price
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Tanggal Check-in & Check-out
                _buildDateRow(
                  'Check-in',
                  formatDate(booking.checkInDate),
                  booking.plannedCheckIn ?? '--:--',
                ),
                const SizedBox(height: 8),
                _buildDateRow(
                  'Check-out',
                  formatDate(booking.checkOutDate),
                  booking.plannedCheckOut ?? '--:--',
                ),

                const Divider(height: 24),

                // Action Button (FIXED)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (requiresPayment) {
                        // Jika status pending, tampilkan opsi bayar
                        _showPaymentOptionsSheet(context, ref, booking);
                      } else {
                        // Jika sudah dibayar atau sudah lewat, tampilkan detail
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Detail untuk Reservasi ID ${booking.id}',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: requiresPayment
                          ? _successColor // Warna hijau untuk Bayar
                          : isUpcoming
                              ? _primaryColor
                              : _secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      requiresPayment
                          ? 'Bayar Sekarang' // FIX: Tombol untuk Pembayaran
                          : isUpcoming
                              ? 'Lihat Detail / Kelola'
                              : 'Sudah Selesai',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM SHEET UNTUK PEMBAYARAN (DIPERBAIKI SCOPE) ---
  void _showPaymentOptionsSheet(
      BuildContext context, WidgetRef ref, ReservationModel booking) {
    // Ambil service Midtrans
    final midtransService = ref.read(midtransServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lanjutkan Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DMSans',
                ),
              ),
              const Divider(height: 30),
              _buildPaymentDetailRow(
                'Nomor Reservasi',
                booking.reservationCode,
              ),
              _buildPaymentDetailRow(
                'Total Pembayaran',
                booking.formattedTotalPrice,
                isPrice: true,
              ),
              const SizedBox(height: 20),
              
              // Opsi Pembayaran (Simulasi)
              _buildPaymentMethodOption(context, 'Pilih & Bayar via Midtrans'),
              
              const Divider(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Tutup sheet
                    await _startMidtransPayment(
                        context, midtransService, ref, booking.id); // Tambahkan ref
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Bayar dengan Midtrans Snap',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // --- FUNGSI ASYNCHRONOUS UNTUK MEMULAI PEMBAYARAN ---
  Future<void> _startMidtransPayment(
    BuildContext context,
    MidtransService service,
    WidgetRef ref, // Tambahkan ref di sini
    int reservationId,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membuat transaksi Midtrans...')),
    );

    try {
      final snapToken = await service.createSnapTransaction(reservationId);
      
      // Midtrans Snap URL selalu menggunakan:
      // Di sini kita asumsikan menggunakan Sandbox URL
      final paymentUrl = 'https://app.sandbox.midtrans.com/snap/v1/embed?token=$snapToken'; 

      final url = Uri.parse(paymentUrl);
      
      // Membuka Webview/Browser
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, 
        );
        
        // Setelah user diarahkan ke webview, kita asumsikan transaksi akan berlanjut.
        // Kita bisa refresh data list reservasi setelah jeda sebentar (simulasi callback dari BE).
        await Future.delayed(const Duration(seconds: 3));
        ref.read(bookingsNotifierProvider.notifier).fetchBookings(); 
        
      } else {
        throw Exception('Tidak dapat membuka URL pembayaran: $paymentUrl');
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran gagal: ${e.toString().split('Exception: ').last}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // --- HELPER DETAIL PAYMENT SHEET ---
  Widget _buildPaymentDetailRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _secondaryColor)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
              color: isPrice ? _primaryColor : Colors.black87,
              fontSize: isPrice ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodOption(BuildContext context, String method) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(method, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: _secondaryColor),
          ],
        ),
      ),
    );
  }


  // --- SISA CLASS DENGAN FUNGSI LAINNYA ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'settlement':
        return _successColor;
      case 'pending':
      case 'booked': 
        return _pendingColor;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return _secondaryColor;
    }
  }

  Widget _buildDateRow(String label, String date, String time) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: _primaryColor),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(
          '$date, Pkl. $time',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Widget untuk menampilkan error dan tombol retry
  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data: ${error.split('Exception: ').last}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: _secondaryColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(bookingsNotifierProvider.notifier).fetchBookings();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH the bookingsNotifierProvider
    final bookingsAsyncValue = ref.watch(bookingsNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'Riwayat Reservasi',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'DMSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: _primaryColor,
            labelColor: _primaryColor,
            unselectedLabelColor: _secondaryColor,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'DMSans',
            ),
            tabs: [
              Tab(text: 'Mendatang'), // Upcoming
              Tab(text: 'Selesai'), // Past
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(bookingsNotifierProvider.notifier).fetchBookings(),
          child: bookingsAsyncValue.when(
            // Loading state
            loading: () => const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            ),

            // Error state
            error: (e, st) => _buildErrorWidget(context, ref, e.toString()),

            // Data state
            data: (allReservations) {
              final now = DateTime.now();

              // Filter: Mendatang
              final upcoming = allReservations
                  .where(
                    (b) =>
                        b.checkInDate.isAfter(now) &&
                        b.reservationStatus != 'cancelled',
                  )
                  .toList();
              // Filter: Selesai
              final past = allReservations
                  .where(
                    (b) =>
                        b.checkInDate.isBefore(now) ||
                        b.reservationStatus == 'cancelled',
                  )
                  .toList();

              return TabBarView(
                children: [
                  // Tab 1: Mendatang
                  _buildBookingList(upcoming, context, ref), // Lewatkan ref
                  // Tab 2: Selesai
                  _buildBookingList(past, context, ref), // Lewatkan ref
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}