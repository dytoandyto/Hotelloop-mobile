import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_intermediate/features/booking_form/data/models/reservation_model.dart';
import 'package:learn_flutter_intermediate/features/bookings/provider/booking_provider.dart';
import 'package:learn_flutter_intermediate/features/home/data/models/hotel_detail_model.dart';

// --- CONSTANTS ---
const double _mediumRadius = 12.0;
const Color _primaryColor = Color(0xFF1E88E5); // Blue
const Color _secondaryColor = Colors.grey;
const Color _successColor = Colors.green;
const Color _pendingColor = Colors.orange;

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

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
            'Boo',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'DMSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            // Tabs di App Bar
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
          // Memungkinkan swipe ke bawah untuk refresh
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

              // Filter berdasarkan tanggal Check-in
              final upcoming = allReservations
                  .where(
                    (b) =>
                        b.checkInDate.isAfter(now) &&
                        b.reservationStatus != 'cancelled',
                  )
                  .toList();
              final past = allReservations
                  .where(
                    (b) =>
                        b.checkInDate.isBefore(now) ||
                        b.reservationStatus == 'cancelled',
                  )
                  .toList();

              return TabBarView(
                // Konten bisa digeser (swipeable)
                children: [
                  // Tab 1: Mendatang
                  _buildBookingList(upcoming, context),
                  // Tab 2: Selesai
                  _buildBookingList(past, context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET LIST VIEW UNTUK TAB ---
  Widget _buildBookingList(
    List<ReservationModel> bookings,
    BuildContext context,
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
        return _buildBookingCard(bookings[index], context);
      },
    );
  }

  // --- WIDGET CARD UNTUK PESANAN INDIVIDUAL (ROBUST) ---
  Widget _buildBookingCard(ReservationModel booking, BuildContext context) {
    String formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);

    final bool isUpcoming = booking.checkInDate.isAfter(DateTime.now());
    final Color statusColor = _getStatusColor(booking.paymentStatus);

    final String hotelName =
        booking.room.roomType.name ?? 'Hotel Tidak Diketahui';
    final String imageUrl = booking.room.roomType.imageUrl ?? '';
    final String roomTypeName =
        booking.room.roomType.name ?? 'Tipe Tidak Diketahui';

    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final String formattedPrice = currencyFormatter.format(booking.totalPrice);

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
                // Hotel Name
                Text(
                  ('Hotel sigma'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DMSans',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Room Type Name & Code
                Text(
                  '$roomTypeName | ${booking.reservationCode}',
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

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigasi ke Halaman Detail Reservasi
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Detail untuk Reservasi ID ${booking.id}',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUpcoming
                          ? _primaryColor
                          : _secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isUpcoming ? 'Lihat Detail / Kelola' : 'Sudah Selesai',
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

  // --- HELPER METHODS ---

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'settlement':
        return _successColor;
      case 'pending':
      case 'booked': // Menggunakan booked/pending untuk warna orange
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
                // Panggil ulang fetchBookings()
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
}
