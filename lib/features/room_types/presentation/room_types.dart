import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/models/hotel_model.dart';
import '../provider/room_types_provider.dart'; // RoomType Provider
import '../data/models/room_type_model.dart'; // RoomType Model
import '../../booking_form/presentation/booking_form_screen.dart'; // BookingForm Screen
import '../../home/providers/home_providers.dart';

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
              // Jika HomeState sudah siap, cek RoomTypes
              loading: () => const Center(
                child: CircularProgressIndicator(color: _googleBlue),
              ),
              error: (err, stack) => Center(
                child: Text('Gagal memuat tipe kamar: ${err.toString()}'),
              ),
              data: (roomTypes) {
                // Ambil data HotelModel dari HomeState
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
                    // Meneruskan HotelModel dan RoomType
                    return _buildRoomCard(context, hotelData, roomType);
                  },
                );
              },
            ),
    );
  }

  // --- WIDGET ROOM CARD DENGAN DATA HOTEL ---
  Widget _buildRoomCard(
    BuildContext context,
    HotelModel hotel, // Data Hotel (sudah di-fetch)
    RoomTypeModel roomType,
  ) {
    return GestureDetector(
      onTap: () {
        // --- LOGIKA KLIK KARTU: Tampilkan detail room ---
        _showRoomDetailsBottomSheet(context, hotel, roomType);
      },
      child: Container(
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

                  // Fasilitas Ringkas
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: roomType.facilities
                        .take(3)
                        .map(
                          (f) => Text(
                            f,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        )
                        .toList(),
                  ),
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
                      ElevatedButton(
                        onPressed: () {
                          // NAVIGASI DARI TOMBOL PILIH
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Meneruskan RoomType dan Hotel ke BookingForm
                              builder: (context) => BookingFormScreen(
                                roomType: roomType,
                                hotell: hotel,
                              ),
                            ),
                          );
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
                          'Pilih',
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
      ),
    );
  }

  // --- FUNGSI BOTTOM SHEET DETAIL ROOM DENGAN DATA HOTEL ---
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
          height: MediaQuery.of(context).size.height * 0.85, // 85% dari layar
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_modernRadius),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header dan Tombol Tutup
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
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Deskripsi
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans',
                        ),
                      ),
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
                      const Text(
                        'Fasilitas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: roomType.facilities
                            .map((f) => _buildFacilityChip(f))
                            .toList(),
                      ),
                      const Divider(height: 30),

                      // Tipe Tempat Tidur
                      const Text(
                        'Tempat Tidur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: roomType.beds
                            .map(
                              (b) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.king_bed_outlined,
                                      color: _googleBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${b.quantity}x ${b.name}',
                                      style: const TextStyle(
                                        fontFamily: 'DMSans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 40), // Ruang ekstra di bawah
                    ],
                  ),
                ),
              ),

              // Bottom Bar Fixed di Dalam BottomSheet
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup detail sheet
                    // Navigasi ke form booking (Isi Data Tamu)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookingFormScreen(
                              roomType: roomType,
                              hotell: hotel,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _googleBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pesan Kamar Ini (${roomType.formattedPrice} / malam)',
                    style: const TextStyle(
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
  }

  // Helper untuk membuat Chip Fasilitas
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

  IconData _getFacilityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('parking')) return Icons.local_parking_rounded;
    if (lower.contains('wifi')) return Icons.wifi_rounded;
    if (lower.contains('ac')) return Icons.air_rounded;
    if (lower.contains('tv')) return Icons.tv_rounded;
    if (lower.contains('kasur')) return Icons.king_bed_outlined;
    if (lower.contains('mandi')) return Icons.bathtub_outlined;
    if (lower.contains('kolam renang')) return Icons.pool_rounded;
    if (lower.contains('gym')) return Icons.fitness_center_rounded;
    if (lower.contains('sarapan')) return Icons.free_breakfast_rounded;
    return Icons.check_circle_outline;
  }
}
