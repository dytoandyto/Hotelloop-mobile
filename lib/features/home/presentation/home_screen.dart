import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/bookings/presentation/booking_screen.dart';
import 'package:learn_flutter_intermediate/features/favorite/presentation/favorite_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../profile/presentation/profile_screen.dart';
import 'hotel_detail_screen.dart';
import '../data/models/hotel_model.dart';
import '../providers/home_providers.dart';
// Tambahkan import Room Type Provider
import '../../room_types/provider/room_types_provider.dart';
import '../../room_types/data/models/room_type_model.dart'; // Import RoomTypeModel
import '../../notification/presentation/notification.dart';

// --- KONSTANTA GAYA MODERN ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _modernRadius = 16.0;
const int _maxPriceFilter = 2000000;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // --- STATE UNTUK SEARCH DAN FILTER ---
  final _locationController = TextEditingController();
  String _searchText = '';
  // Pastikan RangeValues memiliki tipe double
  RangeValues _priceRange = RangeValues(0.0, _maxPriceFilter.toDouble());
  List<String> _selectedFacilities = [];
  int _selectedStarRating = 0; // 0 berarti semua rating
  // ------------------------------------

  int _selectedCategoryIndex = 0;
  int _navBarCurrentIndex = 0; // State untuk NavigationBar

  final List<String> _categories = [
    'All',
    'Single',
    'Double',
    'Queen',
    'King',
    'Twin',
  ];

  final List<String> _availableFacilities = [
    'Wi-Fi',
    'Kolam Renang',
    'Parkir',
    'Restoran',
    'Gym',
    'Sarapan Gratis',
  ];

  @override
  void initState() {
    super.initState();
    ref.read(authNotifierProvider.notifier).getUser();
    ref.read(homeNotifierProvider.notifier).fetchHotels();

    _locationController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _locationController.removeListener(_onSearchChanged);
    _locationController.dispose();
    super.dispose();
  }

  // --- Fungsi Search/Filter Logika ---
  void _onSearchChanged() {
    final newText = _locationController.text;
    if (_searchText != newText) {
      setState(() {
        _searchText = newText;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    // Fungsi ini memicu rebuild (setState)
    // yang akan memfilter daftar hotel di _buildHomeBody.
    setState(() {});
  }

  // --- Fungsi Navigasi Baru untuk Material 3 ---
  void _onNavBarTapped(int index) {
   if (index != 0) {
    
    Widget screen;
    if (index == 1) {
      screen = const BookingsScreen();
    } else if (index == 2) {
      screen = const FavoritesScreen();
    } else if (index == 3) {
      screen = const ProfileScreen();
    } else {
      return;
    }

    // PENTING: Lakukan push dan tunggu sampai halaman tersebut di-pop (ditutup)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) {
      // Setelah halaman ditutup (tekan tombol back), reset index ke Home
      setState(() {
        _navBarCurrentIndex = 0; // Kembalikan ke index Home
      });
    });

  } else {
    // Jika index adalah 0 (Home), kita set state ke 0
    setState(() {
      _navBarCurrentIndex = 0;
    });
  }
}

  // --- LOGIKA UTAMA: Cek apakah ada filter aktif ---
  bool get _isFilterActive {
    return _searchText.isNotEmpty ||
        _selectedStarRating != 0 ||
        _selectedFacilities.isNotEmpty ||
        _priceRange.start != 0.0 ||
        _priceRange.end != _maxPriceFilter.toDouble();
  }

  // --- LOGIKA UTAMA: Filter Hotel Lokal ---
  List<HotelModel> _filterHotels(List<HotelModel> hotels) {
    if (!_isFilterActive && _selectedCategoryIndex == 0) {
      return hotels;
    }

    // Ini adalah tempat logika filter yang sebenarnya bekerja
    return hotels.where((hotel) {
      final matchesSearch =
          hotel.name.toLowerCase().contains(_searchText.toLowerCase()) ||
          hotel.address.toLowerCase().contains(_searchText.toLowerCase());

      // *TODO: Implementasi filter harga, rating, fasilitas, dan kategori di sini
      // Karena kita hanya punya data HotelModel, contoh filter sisa akan di-skip
      // jika tidak ada properti harga/fasilitas yang bisa diakses dengan mudah.

      // Mengembalikan hasil filtering (hanya teks yang aktif di demo ini)
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: _buildHomeBody(
          context,
          userState.user?.name ?? 'Guest',
          homeState,
        ),
      ),
      bottomNavigationBar: _buildModernNavigationBar(context),
    );
  }

  Widget _buildHomeBody(
    BuildContext context,
    String userName,
    HomeState homeState,
  ) {
    if (homeState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (homeState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Gagal memuat data hotel: ${homeState.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(homeNotifierProvider.notifier).fetchHotels();
                },
                style: ElevatedButton.styleFrom(backgroundColor: _googleBlue),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hotels = homeState.hotels;

    // Terapkan filter ke daftar hotel
    final filteredHotels = _filterHotels(hotels);

    // Cek apakah mode tampilan adalah hasil pencarian/filter
    final isViewingSearchResults =
        _isFilterActive || _selectedCategoryIndex != 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userName),
            const SizedBox(height: 24),
            _buildSearchAndFilter(context),
            const SizedBox(height: 24),
            _buildCategories(),
            const SizedBox(height: 24),

            if (filteredHotels.isNotEmpty) ...[
              if (homeState.message != null && homeState.message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Status API: ${homeState.message!}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Bagian 1: Trending Hotel / Hasil Pencarian
              _buildSectionHeader(
                isViewingSearchResults
                    ? 'Hasil Pencarian (${filteredHotels.length})'
                    : 'Trending Hotel', // Perubahan nama di sini
              ),
              const SizedBox(height: 16),
              // Jika mode pencarian, tampilkan dalam format vertikal (list scroll ke bawah)
              // Jika mode idle, tampilkan format horizontal
              if (isViewingSearchResults)
                _buildVerticalHotelList(filteredHotels)
              else
                _buildHorizontalHotelList(filteredHotels),

              const SizedBox(height: 24),

              // Bagian 2: Popular Hotel (Hanya tampil jika mode IDLE)
              if (!isViewingSearchResults) ...[
                _buildSectionHeader('Popular Hotel'),
                const SizedBox(height: 16),
                _buildVerticalHotelList(
                  hotels,
                ), // Menampilkan semua hotel lagi di mode idle
              ],
            ] else
              const Center(
                child: Text(
                  'Tidak ada hotel ditemukan yang cocok dengan kriteria.',
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET IMPLEMENTATIONS ---

  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Hai, $userName 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'DMSans',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: _secondaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: Icon(Icons.circle, size: 8, color: _googleBlue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_modernRadius),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Cari hotel...',
                hintStyle: const TextStyle(
                  color: _secondaryColor,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: _secondaryColor),
                suffixIcon: _locationController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: _secondaryColor),
                        onPressed: () {
                          _locationController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            _showFilterBottomSheet(context);
          },
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: _isFilterActive ? _googleBlue : Colors.white,
              borderRadius: BorderRadius.circular(_modernRadius),
              border: Border.all(
                color: _isFilterActive
                    ? Colors.transparent
                    : Colors.grey.shade300,
              ),
              boxShadow: [
                BoxShadow(
                  color: _googleBlue.withOpacity(_isFilterActive ? 0.3 : 0),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.tune_sharp,
              color: _isFilterActive ? Colors.white : _secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    RangeValues tempPriceRange = _priceRange;
    List<String> tempSelectedFacilities = List.from(_selectedFacilities);
    int tempSelectedStarRating = _selectedStarRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_modernRadius + 4),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Hotel',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'DMSans',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text(
                          'Rentang Harga',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rp ${tempPriceRange.start.round()}'),
                            Text('Rp ${tempPriceRange.end.round()}'),
                          ],
                        ),
                        RangeSlider(
                          values: tempPriceRange,
                          min: 0,
                          max: _maxPriceFilter.toDouble(),
                          divisions: 40,
                          onChanged: (values) {
                            setStateModal(() {
                              tempPriceRange = values;
                            });
                          },
                          activeColor: _googleBlue,
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Fasilitas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availableFacilities.map((label) {
                            final isSelected = tempSelectedFacilities.contains(
                              label,
                            );
                            return FilterChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (selected) {
                                setStateModal(() {
                                  if (selected) {
                                    tempSelectedFacilities.add(label);
                                  } else {
                                    tempSelectedFacilities.remove(label);
                                  }
                                });
                              },
                              selectedColor: _googleBlue.withOpacity(0.1),
                              checkmarkColor: _googleBlue,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? _googleBlue
                                    : _secondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? _googleBlue
                                      : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Rating Bintang',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (index) => _buildStarFilterModal(
                              index + 1,
                              tempSelectedStarRating,
                              (star) {
                                setStateModal(() {
                                  tempSelectedStarRating =
                                      tempSelectedStarRating == star ? 0 : star;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Terapkan filter ke state utama (Widget State)
                          setState(() {
                            _priceRange = tempPriceRange;
                            _selectedFacilities = tempSelectedFacilities;
                            _selectedStarRating = tempSelectedStarRating;
                          });
                          _applyFilters();
                          Navigator.pop(context); // Tutup bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _googleBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Terapkan Filter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              _applyFilters();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _googleBlue : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    index == 0 ? Icons.home_work_outlined : Icons.bed_outlined,
                    size: 18,
                    color: isSelected ? Colors.white : _secondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : _secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
          ),
        ),
        // Sembunyikan 'Lihat Semua' saat mode pencarian aktif
        if (!_isFilterActive)
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: _googleBlue,
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStarFilterModal(
    int star,
    int selectedStar,
    Function(int) onTap,
  ) {
    final isSelected = star == selectedStar;
    return GestureDetector(
      onTap: () => onTap(star),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _googleBlue.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? _googleBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.star,
              color: isSelected ? _googleBlue : Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              star.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? _googleBlue : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Bagian Hotel List (Tidak ada perubahan signifikan di sini) ---
  Widget _buildHorizontalHotelList(List<HotelModel> hotels) {
    if (hotels.isEmpty) {
      return const Center(child: Text("Tidak ada hotel tersedia"));
    }
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return _buildHotelPriceCard(hotel, context);
        },
      ),
    );
  }

  Widget _buildHotelPriceCard(HotelModel hotel, BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final roomTypesAsync = ref.watch(roomTypeNotifierProvider(hotel.id));

        return roomTypesAsync.when(
          loading: () => Container(
            width: 260,
            margin: const EdgeInsets.only(right: 16),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (err, stack) => _buildHotelCard(
            hotel,
            context,
            roomTypePrice: hotel.formattedPrice,
          ),
          data: (roomTypes) {
            final String price = roomTypes.isNotEmpty
                ? roomTypes.first.formattedPrice
                : hotel.formattedPrice;

            return _buildHotelCard(hotel, context, roomTypePrice: price);
          },
        );
      },
    );
  }

  Widget _buildHotelCard(
    HotelModel hotel,
    BuildContext context, {
    required String roomTypePrice,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => HotelDetailScreen(hotelId: hotel.id),
          ),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_modernRadius),
              ),
              child: Image.network(
                hotel.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${roomTypePrice} /night',
                        style: const TextStyle(
                          color: _googleBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
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

  Widget _buildVerticalHotelList(List<HotelModel> hotels) {
    if (hotels.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        return _buildVerticalHotelCard(hotel, context);
      },
    );
  }

  Widget _buildVerticalHotelCard(HotelModel hotel, BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final roomTypesAsync = ref.watch(roomTypeNotifierProvider(hotel.id));

        return roomTypesAsync.when(
          loading: () => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            height: 114,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (err, stack) => _buildVerticalHotelCardContent(
            hotel,
            context,
            roomTypePrice: hotel.formattedPrice,
          ),
          data: (roomTypes) {
            final String price = roomTypes.isNotEmpty
                ? roomTypes.first.formattedPrice
                : hotel.formattedPrice;

            return _buildVerticalHotelCardContent(
              hotel,
              context,
              roomTypePrice: price,
            );
          },
        );
      },
    );
  }

  Widget _buildVerticalHotelCardContent(
    HotelModel hotel,
    BuildContext context, {
    required String roomTypePrice,
  }) {
    return GestureDetector(
      onTap: () {
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                  Text(
                    '${roomTypePrice} /night',
                    style: const TextStyle(
                      color: _googleBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                Text(
                  hotel.rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: _navBarCurrentIndex,
      onDestinationSelected: _onNavBarTapped,
      elevation: 3,
      backgroundColor: Colors.white,
      indicatorColor: _googleBlue.withOpacity(0.1),
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: _secondaryColor),
          selectedIcon: const Icon(Icons.home_filled, color: _googleBlue),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined, color: _secondaryColor),
          selectedIcon: const Icon(Icons.calendar_month, color: _googleBlue),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border, color: _secondaryColor),
          selectedIcon: const Icon(Icons.favorite, color: _googleBlue),
          label: 'Favorites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: _secondaryColor),
          selectedIcon: const Icon(Icons.person, color: _googleBlue),
          label: 'Profile',
        ),
      ],
    );
  }
}
