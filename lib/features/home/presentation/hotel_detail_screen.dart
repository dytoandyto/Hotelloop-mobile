import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Asumsi path import ini benar:
import 'package:learn_flutter_intermediate/features/room_types/provider/room_types_provider.dart';
import '../../room_types/presentation/room_types.dart'; // Mengarah ke RoomSelectionScreen
import '../../home/data/models/hotel_model.dart'; // Import HotelModel
import '../../home/providers/detail_provider.dart';
import 'dart:math';

// --- KONSTANTA GAYA MODERN ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _modernRadius = 24.0;
const double _smallRadius = 12.0;

class HotelDetailScreen extends ConsumerWidget {
  final int hotelId; // Harus menerima ID hotel dari HomeScreen

  const HotelDetailScreen({super.key, required this.hotelId});

  // --- WIDGET UTAMA BUILD ---
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Menggunakan HotelModel sebagai tipe data
    final detailAsyncValue = ref.watch(hotelDetailNotifierProvider(hotelId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: detailAsyncValue.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _googleBlue),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gagal memuat detail hotel: ${err.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(hotelDetailNotifierProvider(hotelId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _googleBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
          data: (hotelDetail) {
            // Data hotel sudah siap (bertipe HotelModel)

            // Menggunakan imageUrls jika tersedia, jika tidak, gunakan imageUrl
            final List<String> images = hotelDetail.imageUrls.isNotEmpty
                ? hotelDetail.imageUrls
                : [hotelDetail.imageUrl];

            return Stack(
              children: [
                // 1. Konten Scrollable (Gambar + Detail)
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MENGGUNAKAN ImageHeaderCarousel (StatefulWidget)
                      ImageHeaderCarousel(imageUrls: images),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndRating(hotelDetail),
                            const SizedBox(height: 16),
                            _buildAddress(hotelDetail),
                            const SizedBox(height: 24),
                            // MENGGUNAKAN GRID FASILITAS BARU (Hanya Teks)
                            _buildFacilitiesGrid(hotelDetail.facilities),
                            const SizedBox(height: 32),
                            _buildDescription(hotelDetail),
                            const SizedBox(height: 32),
                            _buildPriceCard(hotelDetail),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Tombol Back & Action di atas gambar (Fixed position)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 24,
                  right: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      _buildCircleButton(
                        icon: Icons.favorite_border_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // 3. Bottom Bar (Fixed position)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomBar(context, hotelDetail),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET IMPLEMENTATIONS ---

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildTitleAndRating(HotelModel hotelDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotelDetail.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              children: List.generate(
                hotelDetail.rating.floor(),
                (index) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'DMSans',
                ),
                children: [
                  TextSpan(
                    text: '${hotelDetail.rating} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _googleBlue,
                    ),
                  ),
                  const TextSpan(
                    text: '(1,234 reviews)',
                    style: TextStyle(color: _secondaryColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddress(HotelModel hotelDetail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_outlined, color: _googleBlue, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hotelDetail.fullAddressText,
            style: const TextStyle(fontSize: 14, color: _secondaryColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- REVISI: _buildFacilitiesGrid (Hanya Teks Menggunakan Wrap) ---
  Widget _buildFacilitiesGrid(List<String> facilities) {
    if (facilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Facilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0, // Jarak horizontal antar chip
          runSpacing: 8.0, // Jarak vertikal antar baris chip
          children: facilities
              .map(
                (name) => _FacilityTextButton(
                  label: name,
                  // TODO: Implementasi navigasi ke halaman kategori fasilitas
                  onTap: () {
                    debugPrint('Fasilitas $name diklik!'); 
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // Fungsi ini tidak digunakan lagi karena fasilitas hanya berupa teks
  /*
  IconData _getFacilityIcon(String name) {
    // ... (logic ikon lama)
  }
  */

  Widget _buildDescription(HotelModel hotelDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this hotel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hotelDetail.description,
          style: const TextStyle(
            color: _secondaryColor,
            height: 1.6,
            fontSize: 14,
            fontFamily: 'DMSans',
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(HotelModel hotelDetail) {
    return Consumer(
      builder: (context, ref, child) {
        final roomTypesAsync = ref.watch(
          roomTypeNotifierProvider(hotelDetail.id),
        );

        return roomTypesAsync.when(
          loading: () => Container(
            height: 150,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              color: _googleBlue,
              strokeWidth: 2,
            ),
          ),
          error: (err, stack) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(_modernRadius),
            ),
            child: const Text(
              'Gagal ambil harga kamar.',
              style: TextStyle(color: Colors.red),
            ),
          ),
          data: (roomTypes) {
            final String price = roomTypes.isNotEmpty
                ? roomTypes.first.formattedPrice
                : hotelDetail.formattedPrice;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_modernRadius),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga per Malam mulai dari',
                    style: TextStyle(
                      color: _secondaryColor,
                      fontFamily: 'DMSans',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price, // HARGA DARI ROOM TYPE
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'DMSans',
                      color: _googleBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: _googleBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sudah termasuk pajak dan biaya. Pembatalan gratis hingga 24 jam sebelum check-in.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, HotelModel hotelDetail) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_modernRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Navigasi ke RoomSelectionScreen dan kirim hotelId
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RoomSelectionScreen(hotelId: hotelDetail.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _googleBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 8,
                shadowColor: _googleBlue.withOpacity(0.4),
              ),
              child: const Text(
                'Pesan Kamar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET BARU: _FacilityTextButton (Pengganti _ModernFacilityCard) ---
class _FacilityTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FacilityTextButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100, // Background card
      borderRadius: BorderRadius.circular(_smallRadius),
      child: InkWell(
        onTap: onTap, // Sekarang bisa diklik
        borderRadius: BorderRadius.circular(_smallRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'DMSans',
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGET CAROUSEL LAMA (_ModernFacilityCard) DIHAPUS ---

// --- WIDGET BARU: ImageHeaderCarousel (PENGGANTI _buildImageHeader) ---
class ImageHeaderCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageHeaderCarousel({
    super.key,
    required this.imageUrls,
  });

  @override
  State<ImageHeaderCarousel> createState() => _ImageHeaderCarouselState();
}

class _ImageHeaderCarouselState extends State<ImageHeaderCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.imageUrls.isEmpty ? 1 : widget.imageUrls.length;

    return SizedBox(
      height: 350,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(_modernRadius),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: itemCount,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final url = widget.imageUrls.isEmpty
                    ? 'https://placehold.co/600x350/E0E0E0/grey?text=No+Image'
                    : widget.imageUrls[index];

                return GestureDetector(
                  onTap: () {
                    // Ketika gambar di-tap, navigasi ke FullScreenImageViewer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          initialImageIndex: index, // Tampilkan gambar yang sedang aktif
                          imageUrls: widget.imageUrls, // Kirim semua URL gambar
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(itemCount, (index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET BARU: FullScreenImageViewer (untuk detail gambar dan zoom) ---
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialImageIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialImageIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _fullScreenPageController;
  late int _currentFullScreenPageIndex;

  @override
  void initState() {
    super.initState();
    _currentFullScreenPageIndex = widget.initialImageIndex;
    _fullScreenPageController =
        PageController(initialPage: widget.initialImageIndex);
  }

  @override
  void dispose() {
    _fullScreenPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam untuk tampilan gambar
      body: Stack(
        children: [
          // PageView untuk beralih antar gambar di mode full screen
          PageView.builder(
            controller: _fullScreenPageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentFullScreenPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.imageUrls[index];
              return Center(
                child: InteractiveViewer(
                  // Mengizinkan zoom dan pan
                  panEnabled: true, // Izinkan geser
                  boundaryMargin: const EdgeInsets.all(20), // Margin agar tidak keluar layar
                  minScale: 0.8, // Skala minimum
                  maxScale: 4.0, // Skala maksimum
                  child: Image.network(
                    url,
                    fit: BoxFit.contain, // Gambar akan menyesuaikan layar tanpa terpotong
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Tombol Close di pojok kiri atas
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Indikator halaman di bagian bawah (opsional, jika ada banyak gambar)
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (index) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentFullScreenPageIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}