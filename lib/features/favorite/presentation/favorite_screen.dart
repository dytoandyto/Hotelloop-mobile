import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Import model yang dibutuhkan
import '../../home/data/models/hotel_model.dart';
import '../../home/presentation/hotel_detail_screen.dart'; // Untuk navigasi ke detail

// --- KONSTANTA GAYA ---
const Color _primaryBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _modernRadius = 16.0;

// Data Dummy Simulasi Hotel Favorit (Biasanya diambil dari provider/state)
final List<HotelModel> dummyFavoriteHotels = [
  // Catatan: Gunakan constructor HotelModel yang sudah ada di proyek Anda
  // Saya menggunakan properti yang umum ditemukan di model Anda sebelumnya.
  HotelModel(
    id: 101,
    name: 'The Elite Residence',
    address: 'Jakarta Pusat',
    rating: 4.9,
    startPrice: 1800000,
    imageUrl: 'https://placehold.co/600x400/4285F4/white?text=FAV+A',
    description: 'Kamar suite dengan pemandangan kota yang menakjubkan.',
    // Asumsi properti ini ada di model Anda, meski nilainya dummy di sini
    fullAddressText: 'Jalan Thamrin No. 10', 
    facilities: ['Wi-Fi', 'Pool', 'Gym'],
    // Asumsi properti ini ada di model Anda (jika diperlukan oleh widget lama)
    // formattedPrice: 'Rp 1.800.000', 
  ),
  HotelModel(
    id: 102,
    name: 'Bali Green View Resort',
    address: 'Ubud, Bali',
    rating: 4.7,
    startPrice: 2500000,
    imageUrl: 'https://placehold.co/600x400/007AFF/white?text=FAV+B',
    description: 'Vila pribadi dengan kolam renang di tengah sawah.',
    fullAddressText: 'Jalan Raya Ubud', 
    facilities: ['Pool', 'Spa', 'Restaurant'],
    // formattedPrice: 'Rp 2.500.000',
  ),
  // Tambahkan lebih banyak data dummy jika diperlukan
];

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Di aplikasi nyata, di sini Anda akan menggunakan ref.watch(favoritesProvider)
    final favorites = dummyFavoriteHotels; 

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Daftar Favorit',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'DMSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final hotel = favorites[index];
                return _buildFavoriteHotelCard(context, hotel);
              },
            ),
    );
  }

  // --- WIDGET CARD HOTEL FAVORIT ---
  Widget _buildFavoriteHotelCard(BuildContext context, HotelModel hotel) {
    // Menggunakan NumberFormat untuk simulasi harga
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    final priceStr = formatter.format(hotel.startPrice);

    const _smallRadius = 12.0;

    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail Hotel
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => HotelDetailScreen(hotelId: hotel.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_modernRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(_smallRadius),
              child: Image.network(
                hotel.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 90, height: 90, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Hotel dan Ikon Favorit (Terisi)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Ikon Favorit Terisi
                      Icon(Icons.favorite, color: Colors.red.shade400, size: 20), 
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Lokasi
                  Text(
                    hotel.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _secondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Rating dan Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$priceStr /night',
                        style: const TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(
                            hotel.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
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

  // --- WIDGET EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Colors.red.shade200,
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada hotel di daftar favorit Anda.',
            style: TextStyle(
              fontSize: 18,
              color: _secondaryColor,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tekan ikon hati untuk menambahkan hotel.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'DMSans',
            ),
          ),
        ],
      ),
    );
  }
}