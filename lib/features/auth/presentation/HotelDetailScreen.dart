import 'package:flutter/material.dart';

class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({super.key});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> hotelImages = [
    'lib/assets/images/hotels/hotel1.png',
    'lib/assets/images/hotels/hotel2.png',
    'lib/assets/images/hotels/hotel3.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildImageCarousel(),
          // Konten detail hotel yang bisa digulir
          _buildDetailContent(),
          // Widget harga dan tombol yang posisinya fixed di bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPriceAndBookingButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: hotelImages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                hotelImages[index],
                fit: BoxFit.cover,
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(hotelImages.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.white54,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    return DraggableScrollableSheet(
      initialChildSize: 0.65, // Mengurangi ukuran agar tidak menutupi bottom bar
      minChildSize: 0.65,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            // Bungkus konten dalam Column untuk mencegah overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                _buildHotelInfo(),
                const SizedBox(height: 20),
                _buildFacilities(),
                // Tambahkan SizedBox untuk memberi ruang kosong di atas bottom bar
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotelInfo() {
    // Konten tetap sama
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sigma Hotel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            const Text('Jakarta Timur', style: TextStyle(color: Colors.grey)),
            const Spacer(),
            Row(
              children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Jl.Sultan Agung No.29, Sisir, Kec. Batu, Kota, Sisir, Kecamatan Batu, Kota Batu, Jawa Timur, 65314', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Terletak strategis di jantung distrik bisnis, Sigma Hotel menawarkan perpaduan sempurna antara kenyamanan modern dan efisiensi. Read More...', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFacilities() {
    // Konten tetap sama
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fasilitas Populer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _FacilityItem(icon: Icons.wifi, label: 'Free Wi-fi'),
            _FacilityItem(icon: Icons.pool, label: 'Swimming pool'),
            _FacilityItem(icon: Icons.local_parking, label: 'Free parking'),
            _FacilityItem(icon: Icons.spa, label: 'Spa'),
            _FacilityItem(icon: Icons.desk, label: 'Front desk [24-hour]'),
          ],
        ),
      ],
    );
  }
  
  // Widget harga dan tombol yang sekarang posisinya fixed
  Widget _buildPriceAndBookingButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Start at', style: TextStyle(color: Colors.grey)),
              Text('Rp 4,703,871', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigasi ke halaman pemilihan kamar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D61E7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Pilih Kamar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FacilityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FacilityItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}