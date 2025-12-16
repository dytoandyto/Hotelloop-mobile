import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/booking_form/provider/reservation_provider.dart';
import 'package:learn_flutter_intermediate/features/home/data/models/hotel_model.dart';
import 'package:learn_flutter_intermediate/features/room_types/data/models/room_type_model.dart';
import 'package:learn_flutter_intermediate/features/room_types/data/models/bed_model.dart'; // WAJIB: Import BedModel
import '../../payment/presentation/payment_screen.dart'; // Asumsi path PaymentSummaryScreen
import 'package:intl/intl.dart';
import 'dart:async';
import '../data/models/reservation_model.dart';

// --- KONSTANTA GAYA ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _modernRadius = 24.0;
const double _smallRadius = 12.0;

class BookingFormScreen extends ConsumerStatefulWidget {
  final RoomTypeModel roomType;
  final HotelModel hotel;
  final BedModel? selectedBed;

  const BookingFormScreen({
    super.key,
    required this.roomType,
    required this.hotel,
    this.selectedBed,
  });

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Rincian Durasi
  int _numberOfNights = 1;
  int _numberOfGuests = 1;
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime get _checkOutDate =>
      _checkInDate.add(Duration(days: _numberOfNights));

  // Detail Tamu
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Harga dinamis dari RoomTypeModel
  final double _taxAndFees = 0.0;
  final double _promoDiscount = 0.0;

  // --- LOGIKA HARGA DINAMIS (WEEKDAY/WEEKEND) ---
  double get _roomSubtotal {
    double total = 0.0;

    for (int i = 0; i < _numberOfNights; i++) {
      final nightDate = _checkInDate.add(Duration(days: i));

      final double weekdayPrice = widget.roomType.price.weekdayPrice;
      final double weekendPrice = widget.roomType.price.weekendPrice;

      if (nightDate.weekday == DateTime.saturday ||
          nightDate.weekday == DateTime.sunday) {
        total += weekendPrice;
      } else {
        total += weekdayPrice;
      }
    }
    return total;
  }

  double get _totalPrice => _roomSubtotal + _taxAndFees - _promoDiscount;
  // ---------------------------------------------

  @override
  void initState() {
    super.initState();
    _numberOfGuests = widget.roomType.capacity >= 2 ? 2 : 1;
    _checkInDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _notesController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- LOGIKA DATE PICKER ---
  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstSelectableDate = DateTime(
      now.year,
      now.month,
      now.day,
    ); // Hari ini 00:00:00

    // Tentukan initialDate agar tidak sebelum hari ini
    final DateTime initialDate = _checkInDate.isBefore(firstSelectableDate)
        ? firstSelectableDate
        : _checkInDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstSelectableDate, // Batasi ke hari ini
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _googleBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_numberOfNights < 1) {
          _numberOfNights = 1;
        }
      });
    }
  }

  // --- LOGIKA SUBMIT RESERVASI ---
  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    // FIX: Gunakan .notifier untuk mengakses method submitReservation
    final notifier = ref.read(reservationNotifierProvider.notifier);

    final dialogContext = context;
    // Tampilkan loading dialog
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: _googleBlue)),
    );

    try {
      final checkInDateStr = DateFormat('yyyy-MM-dd').format(_checkInDate);

      // Panggil submitReservation dengan parameter yang sudah disesuaikan
      final ReservationModel? reservations = await notifier.submitReservation(
        hotelId: widget.hotel.id,
        roomType: widget.roomType,
        nights: _numberOfNights,
        checkInDate: checkInDateStr,
        guestName: _fullNameController.text.trim(),
        guestEmail: _emailController.text.trim(),
        guestPhone: _phoneController.text.trim(),
        guests: _numberOfGuests,
        // roomNumber dan notes tidak dikirim ke Notifier karena tidak dibutuhkan BE di payload minimal
      );

      if (dialogContext.mounted) Navigator.pop(dialogContext); // Tutup loading

      if (reservations != null && dialogContext.mounted) {
        // Reservasi berhasil dibuat, lanjut ke halaman summary pembayaran
        Navigator.pushReplacement(
          dialogContext,
          MaterialPageRoute(
            builder: (context) => PaymentSummaryScreen(
              reservation: reservations,
              hotel: widget.hotel,
              roomType: widget.roomType,
            ),
          ),
        );
      } else if (dialogContext.mounted) {
        // Reservasi gagal (Notifier mengembalikan null)
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text(
              // Ambil error message dari state jika ada
              ref.read(reservationNotifierProvider).error ??
                  'Gagal membuat reservasi. Coba lagi.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (dialogContext.mounted) Navigator.pop(dialogContext); // Tutup loading
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text('Reservasi Gagal: ${e.toString()}')),
      );
    }
  }

  // --- WIDGET BUILD ---
  @override
  Widget build(BuildContext context) {
    // Format tanggal & harga (TETAP SAMA)
    final String totalPriceStr = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(_totalPrice);
    final String subtotalStr = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(_roomSubtotal);
    final String taxStr = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(_taxAndFees);
    final String checkInStr = DateFormat('EEE, MMM dd').format(_checkInDate);
    final String checkOutStr = DateFormat('EEE, MMM dd').format(_checkOutDate);

    // Tonton state reservasi untuk status loading
    final reservationState = ref.watch(reservationNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pemesanan',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'DMSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Detail Tamu & Kontak'),
                          const SizedBox(height: 16),
                          _buildContactInput(
                            controller: _fullNameController,
                            label: 'Nama Lengkap Tamu Utama',
                            icon: Icons.person_outline_rounded,
                            inputType: TextInputType.name,
                            hint: 'Sesuai KTP/Paspor',
                          ),
                          const SizedBox(height: 16),
                          _buildContactInput(
                            controller: _emailController,
                            label: 'Email Konfirmasi',
                            icon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                            hint: 'contoh@gmail.com',
                          ),
                          const SizedBox(height: 16),
                          _buildContactInput(
                            controller: _phoneController,
                            label: 'Nomor Telepon (WA/Aktif)',
                            icon: Icons.phone_outlined,
                            inputType: TextInputType.phone,
                            hint: '+62 8xx xxxx xxxx',
                          ),
                          const SizedBox(height: 32),

                          _buildSectionHeader('Detail Menginap'),
                          const SizedBox(height: 16),
                          _buildRevisedStayDetails(checkInStr, checkOutStr),
                          const SizedBox(height: 32),

                          if (widget.selectedBed != null) ...[
                            _buildSectionHeader('Konfigurasi Tempat Tidur'),
                            const SizedBox(height: 16),
                            _buildBedDetailCard(),
                            const SizedBox(height: 32),
                          ],

                          _buildNotesInput(),
                          const SizedBox(height: 32),

                          _buildSectionHeader('Detail Hotel & Kamar'),
                          const SizedBox(height: 16),
                          _buildHotelRoomHeader(
                            widget.hotel.name,
                            widget.roomType.name,
                            widget.roomType.imageUrl,
                          ),
                          const SizedBox(height: 32),

                          _buildSectionHeader('Rincian Pembayaran'),
                          const SizedBox(height: 16),
                          _buildSummaryCard(subtotalStr, taxStr),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildBottomBar(context, totalPriceStr, reservationState.isLoading),
          ],
        ),
      ),
    );
  }
  // --- SUB-WIDGETS (SAMA SEPERTI SEBELUMNYA) ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'DMSans',
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBedDetailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.king_bed_outlined, color: _googleBlue),
          const SizedBox(width: 12),
          Text(
            '${widget.selectedBed!.quantity}x ${widget.selectedBed!.name}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'DMSans',
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            '(${widget.roomType.capacity} Tamu Max)',
            style: const TextStyle(color: _secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelRoomHeader(
    String hotelName,
    String roomName,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_modernRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_smallRadius),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: _secondaryColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DMSans',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _googleBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    roomName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _googleBlue,
                      fontFamily: 'DMSans',
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

  Widget _buildContactInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType inputType,
    String hint = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'DMSans',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          style: const TextStyle(fontFamily: 'DMSans'),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: _secondaryColor),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_smallRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_smallRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_smallRadius),
              borderSide: const BorderSide(color: _googleBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kolom ini wajib diisi.';
            }
            if (inputType == TextInputType.emailAddress &&
                !value.contains('@')) {
              return 'Masukkan alamat email yang valid.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Additional Notes',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
              ),
            ),
            const Text(
              ' (Optional)',
              style: TextStyle(color: _secondaryColor, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'DMSans'),
          decoration: InputDecoration(
            hintText:
                'Masukkan permintaan khusus Anda (e.g. kamar non-smoking, bantal tambahan)...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color(0xFFF5F5F5),
            filled: true,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String subtotalStr, String taxStr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Harga',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Harga Kamar ($_numberOfNights malam)', subtotalStr),
          const SizedBox(height: 12),
          _buildSummaryRow('Pajak & Biaya Layanan', taxStr),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total Pembayaran',
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            ).format(_totalPrice),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black87 : _secondaryColor,
            fontFamily: 'DMSans',
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
            fontFamily: 'DMSans',
            color: isTotal ? _googleBlue : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRevisedStayDetails(String checkInStr, String checkOutStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Jumlah Tamu & Jumlah Malam (Interaktif)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoField(
                label: 'Jumlah Tamu',
                value: '$_numberOfGuests Tamu',
                icon: Icons.people_alt_rounded,
                onTap: () {
                  _showNumberPicker(
                    context,
                    'Pilih Jumlah Tamu',
                    _numberOfGuests,
                    (value) => setState(() => _numberOfGuests = value),
                    max: widget.roomType.capacity,
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildInfoField(
                label: 'Jumlah Malam',
                value: '$_numberOfNights Malam',
                icon: Icons.nightlight_round,
                onTap: () {
                  _showNumberPicker(
                    context,
                    'Pilih Jumlah Malam',
                    _numberOfNights,
                    (value) => setState(() => _numberOfNights = value),
                    max: 10,
                  );
                },
              ),
            ],
          ),

          const Divider(height: 32),

          // Row 2: Check-in, Check-out
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildInfoField(
                  label: 'Check-in',
                  value: checkInStr,
                  icon: Icons.login_rounded,
                  onTap: () => _selectCheckInDate(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoField(
                  label: 'Check-out',
                  value: checkOutStr,
                  icon: Icons.logout_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ubah Check-out dengan mengubah Jumlah Malam atau Check-in.',
                        ),
                      ),
                    );
                  },
                  showArrow: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: _googleBlue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _secondaryColor,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'DMSans',
                    ),
                  ),
                  if (showArrow)
                    const Icon(
                      Icons.keyboard_arrow_right,
                      color: _secondaryColor,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNumberPicker(
    BuildContext context,
    String title,
    int currentValue,
    Function(int) onSelected, {
    required int max,
  }) {
    int tempValue = currentValue;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 250,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DMSans',
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: _googleBlue,
                            ),
                            iconSize: 30,
                            onPressed: tempValue > 1
                                ? () => setModalState(() => tempValue--)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            tempValue.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DMSans',
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: _googleBlue,
                            ),
                            iconSize: 30,
                            onPressed: tempValue < max
                                ? () => setModalState(() => tempValue++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onSelected(tempValue);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _googleBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pilih',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    String totalPriceStr,
    bool isLoading,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 12,
                      color: _secondaryColor,
                      fontFamily: 'DMSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalPriceStr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DMSans',
                      color: _googleBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _googleBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Pesan Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
