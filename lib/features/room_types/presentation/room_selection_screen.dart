import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/models/hotel_model.dart';
import '../provider/room_types_provider.dart'; 
import '../data/models/room_type_model.dart'; 
import '../../booking_form/presentation/booking_form_screen.dart'; 
import '../../home/providers/home_providers.dart';
// import '../data/models/bed_model.dart'; // Tidak diperlukan di sini karena hanya menampilkan

// --- KONSTANTA GAYA ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _modernRadius = 24.0;
const double _smallRadius = 12.0;

class RoomSelectionScreen extends ConsumerWidget {
  final int hotelId;

  const RoomSelectionScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil list tipe kamar
    final roomTypesAsync = ref.watch(roomTypeNotifierProvider(hotelId));
    // 2. Ambil state Hotel list dari Home (Cache)
    final homeState = ref.watch(homeNotifierProvider);

    // Helper untuk mendapatkan HotelModel dari cache HomeState
    HotelModel? getHotelDetail(List<HotelModel> hotels) {
      try {
        return hotels.firstWhere((h) => h.id == hotelId);
      } catch (e) {
        return null;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Pilih Kamar',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // --- KONDISIONAL BERLAPIS UNTUK MENGAMBIL DATA ---
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator(color: _googleBlue))
          : roomTypesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: _googleBlue),
              ),
              error: (err, stack) => Center(
                child: Text('Gagal memuat tipe kamar: ${err.toString()}'),
              ),
              data: (roomTypes) {
                // Ambil data HotelModel dari cache HomeState
                final HotelModel? hotelData = getHotelDetail(homeState.hotels);

                if (hotelData == null) {
                  return const Center(
                    child: Text('Detail hotel tidak ditemukan di cache.'),
                  );
                }
                if (roomTypes.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada kamar tersedia untuk hotel ini.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: roomTypes.length,
                  itemBuilder: (context, index) {
                    final roomType = roomTypes[index];
                    return _buildRoomCard(context, hotelData, roomType);
                  },
                );
              },
            ),
    );
  }

  // --- WIDGET ROOM CARD (Tampilan List) ---
  Widget _buildRoomCard(
    BuildContext context,
    HotelModel hotel, // Data Hotel (sudah di-fetch)
    RoomTypeModel roomType,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Kamar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.network(
              roomType.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomType.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DMSans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  roomType.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Konfigurasi Kasur (Ditampilkan sebagai fasilitas)
                _buildBedConfiguration(roomType), 
                
                const Divider(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga per Malam',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'DMSans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          roomType.formattedPrice, // Harga dari BE
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ],
                    ),
                    
                    // TOMBOL AKSI UTAMA (Langsung ke Bottom Sheet untuk Detail dan Pesan)
                    ElevatedButton(
                      onPressed: () {
                        // --- LOGIKA KLIK KARTU: Tampilkan detail room ---
                        _showRoomDetailsBottomSheet(context, hotel, roomType);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _googleBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Lihat Detail', 
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // --- WIDGET BARU: TAMPILAN KONFIGURASI TEMPAT TIDUR ---
  Widget _buildBedConfiguration(RoomTypeModel roomType) {
    if (roomType.beds.isEmpty) return const SizedBox.shrink();

    // Menggabungkan semua konfigurasi bed menjadi string
    final bedDetails = roomType.beds.map((b) => '${b.quantity}x ${b.name}').join(', ');

    return Row(
      children: [
        const Icon(Icons.king_bed_outlined, color: Colors.grey, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$bedDetails (Kapasitas ${roomType.capacity} orang)',
            style: const TextStyle(
              color: _secondaryColor,
              fontSize: 13,
              fontFamily: 'DMSans',
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  // --- FUNGSI BOTTOM SHEET DETAIL ROOM (Dengan Fixed Bottom Bar) ---
  void _showRoomDetailsBottomSheet(
    BuildContext context,
    HotelModel hotel,
    RoomTypeModel roomType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_modernRadius),
            ),
          ),
          child: Column(
            children: [
              // Header dan Handle
              _buildModalHeader(context, hotel, roomType),

              // Isi Konten Detail Kamar
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Kamar (Besar)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(_smallRadius),
                        child: Image.network(
                          roomType.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Detail Tempat Tidur (Fasilitas)
                      _buildSectionHeader('Konfigurasi Tempat Tidur & Kapasitas'),
                      const SizedBox(height: 12),
                      _buildBedDetailsList(roomType),
                      
                      const SizedBox(height: 20),

                      // Deskripsi
                      _buildSectionHeader('Deskripsi'),
                      const SizedBox(height: 8),
                      Text(
                        roomType.description,
                        style: const TextStyle(
                          color: _secondaryColor,
                          fontFamily: 'DMSans',
                          height: 1.5,
                        ),
                      ),
                      const Divider(height: 30),

                      // Fasilitas Kamar Lengkap
                      _buildSectionHeader('Fasilitas Kamar'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: roomType.facilities
                            .map((f) => _buildFacilityChip(f))
                            .toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // BOTTOM BAR (FIXED) DENGAN TOMBOL PESAN
              _buildFixedBottomBar(context, hotel, roomType),
            ],
          ),
        );
      },
    );
  }

  // Helper untuk Header Modal
  Widget _buildModalHeader(BuildContext context, HotelModel hotel, RoomTypeModel roomType) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomType.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'DMSans',
                      ),
                    ),
                    Text(
                      hotel.name, // Tampilkan nama hotel
                      style: const TextStyle(
                        fontSize: 14,
                        color: _secondaryColor,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
  
  // Helper untuk Header Section di Modal
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

  // --- WIDGET LIST DETAIL TEMPAT TIDUR DI MODAL ---
  Widget _buildBedDetailsList(RoomTypeModel roomType) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
                children: [
                    const Icon(Icons.person_outline, size: 18, color: _googleBlue),
                    const SizedBox(width: 8),
                    Text('Maks. ${roomType.capacity} orang', style: const TextStyle(fontSize: 15)),
                ],
            ),
            const SizedBox(height: 12),
            Column(
                children: roomType.beds.map((bed) {
                    final bedConfig = '${bed.quantity}x ${bed.name}';
                    return Padding(
                        padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                        child: Row(
                            children: [
                                const Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                    bedConfig,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                            ],
                        ),
                    );
                }).toList(),
            ),
        ],
    );
  }


  // --- BOTTOM BAR FIXED UNTUK TOMBOL PESAN ---
  Widget _buildFixedBottomBar(
    BuildContext context,
    HotelModel hotel,
    RoomTypeModel roomType,
  ) {
    // Karena tidak ada pilihan kasur, kita kirimkan kasur pertama sebagai default
    final selectedBed = roomType.beds.isNotEmpty ? roomType.beds.first : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Harga
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mulai dari',
                  style: TextStyle(fontSize: 12, color: _secondaryColor),
                ),
                Text(
                  roomType.formattedPrice,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _googleBlue,
                  ),
                ),
              ],
            ),
            
            // Tombol Pesan
            ElevatedButton(
              onPressed: selectedBed == null 
                ? null // Disable jika tidak ada konfigurasi kasur
                : () {
                    Navigator.pop(context); // Tutup detail sheet
                    // NAVIGASI FINAL: Meneruskan RoomType dan BedModel yang dipilih ke BookingForm
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingFormScreen(
                          roomType: roomType,
                          hotel: hotel,
                          selectedBed: selectedBed, 
                        ),
                      ),
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedBed == null ? Colors.grey : _googleBlue,
                minimumSize: const Size(150, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                selectedBed == null ? 'Kamar Tidak Tersedia' : 'Pesan Sekarang',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Helper untuk membuat Chip Fasilitas (sama seperti di input)
  Widget _buildFacilityChip(String name) {
    return Chip(
      avatar: Icon(_getFacilityIcon(name), color: _googleBlue, size: 18),
      label: Text(
        name,
        style: const TextStyle(fontFamily: 'DMSans', fontSize: 13),
      ),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
    );
  }

  // Helper untuk Icon Fasilitas (sama seperti di input)
  IconData _getFacilityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('ac')) return Icons.air_rounded;
    if (lower.contains('tv')) return Icons.tv_rounded;
    if (lower.contains('kasur') || lower.contains('bed')) return Icons.king_bed_outlined;
    if (lower.contains('mandi') || lower.contains('bath')) return Icons.bathtub_outlined;
    if (lower.contains('kolam renang') || lower.contains('pool')) return Icons.pool_rounded;
    if (lower.contains('gym')) return Icons.fitness_center_rounded;
    if (lower.contains('sarapan')) return Icons.free_breakfast_rounded;
    return Icons.check_circle_outline;
  }
}