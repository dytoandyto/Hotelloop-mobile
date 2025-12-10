import 'dart:ui'; // Coba tambahkan ini
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_intermediate/features/home/data/models/hotel_detail_model.dart';
import 'package:learn_flutter_intermediate/features/home/providers/detail_provider.dart';
import 'package:learn_flutter_intermediate/features/room_types/data/models/price_model.dart';
import 'package:learn_flutter_intermediate/features/room_types/data/models/room_type_model.dart';
import 'package:learn_flutter_intermediate/features/room_types/presentation/room_selection_screen.dart';
import 'package:learn_flutter_intermediate/features/room_types/provider/room_types_provider.dart';



// --- KONSTANTA GAYA MODERN ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _modernRadius = 24.0;
const double _smallRadius = 12.0;

// =======================================================
//                    HOTEL DETAIL SCREEN
// =======================================================

class HotelDetailScreen extends ConsumerWidget {
  final int hotelId;

  const HotelDetailScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pastikan hotelDetailNotifierProvider mengembalikan HotelDetailModel
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

                // 2. Tombol Back & Action (Fixed position)
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

  // --- IMPLEMENTASI WIDGET HELPER ---

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

  Widget _buildTitleAndRating(HotelDetailModel hotelDetail) {
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

  Widget _buildAddress(HotelDetailModel hotelDetail) {
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

  Widget _buildFacilitiesGrid(List<String> facilities) {
    if (facilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          spacing: 8.0,
          runSpacing: 8.0,
          children: facilities
              .map(
                (name) => _FacilityTextButton(
                  label: name,
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

  Widget _buildDescription(HotelDetailModel hotelDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tentang Hotel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
          ),
        ),
        const SizedBox(height: 8),
        ExpandableText(
          text: hotelDetail.description,
          trimLines: 3, 
        ),
      ],
    );
  }
  
  // =======================================================
  //                  LOGIKA PRICE CARD 
  // =======================================================
  Widget _buildPriceCard(HotelDetailModel hotelDetail) {
    return Consumer(
      builder: (context, ref, child) {
        // Asumsi: roomTypeNotifierProvider mengembalikan List<RoomTypeModel>
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
          data: (List<RoomTypeModel> roomTypes) {
            String priceDisplay;
            
            if (roomTypes.isEmpty) {
              priceDisplay = hotelDetail.formattedPrice;
            } else {
              // 1. Kumpulkan semua harga (weekdayPrice dan weekendPrice) yang > 0
              final List<int> validPrices = [];
              
              for (var roomType in roomTypes) {
                final PriceModel priceModel = roomType.price; 
                
                // Ambil nilai floor (integer) dari harga
                if (priceModel.weekdayPrice > 0) {
                  validPrices.add(priceModel.weekdayPrice.floor());
                }
                if (priceModel.weekendPrice > 0) {
                  validPrices.add(priceModel.weekendPrice.floor());
                }
              }

              if (validPrices.isEmpty) {
                priceDisplay = hotelDetail.formattedPrice;
              } else {
                // 2. Cari harga terendah dan tertinggi
                final int minPrice = validPrices.reduce(Math.min);
                final int maxPrice = validPrices.reduce(Math.max);
                
                // Konversi ke format Rupiah
                final formatter = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp',
                  decimalDigits: 0,
                );
                
                final String formattedMin = formatter.format(minPrice);
                final String formattedMax = formatter.format(maxPrice);
                
                if (minPrice == maxPrice) {
                  priceDisplay = formattedMin;
                } else {
                  priceDisplay = '$formattedMin - $formattedMax';
                }
              }
            }

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
                    'Harga per Malam',
                    style: TextStyle(
                      color: _secondaryColor,
                      fontFamily: 'DMSans',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceDisplay, 
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

  Widget _buildBottomBar(BuildContext context, HotelDetailModel hotelDetail) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // RoomSelectionScreen harus diimpor di atas
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


// =======================================================
//                  WIDGET PENDUKUNG
// =======================================================

// --- WIDGET: _FacilityTextButton ---
class _FacilityTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FacilityTextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade100, 
      borderRadius: BorderRadius.circular(_smallRadius),
      child: InkWell(
        onTap: onTap, 
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

// --- WIDGET: ImageHeaderCarousel ---
class ImageHeaderCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageHeaderCarousel({super.key, required this.imageUrls});

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
    final int itemCount = widget.imageUrls.isEmpty
        ? 1
        : widget.imageUrls.length;

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          initialImageIndex: index, 
                          imageUrls: widget.imageUrls, 
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


// --- WIDGET: FullScreenImageViewer ---
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
    _fullScreenPageController = PageController(
      initialPage: widget.initialImageIndex,
    );
  }

  @override
  void dispose() {
    _fullScreenPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: Stack(
        children: [
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
                  panEnabled: true, 
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.8, 
                  maxScale: 4.0, 
                  child: Image.network(
                    url,
                    fit: BoxFit.contain, 
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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


// --- WIDGET: ExpandableText ---
class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText({super.key, required this.text, this.trimLines = 2});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  static const Color _secondaryColor = Color(0xFF6B6B6B);
  static const Color _googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      maxLines: _isExpanded ? null : widget.trimLines,
      overflow: TextOverflow.fade, 
      style: const TextStyle(
        color: _secondaryColor,
        height: 1.6,
        fontSize: 14,
        fontFamily: 'DMSans',
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textWidget.style),
          maxLines: widget.trimLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return textWidget;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            textWidget,
            if (!_isExpanded)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Lihat Selengkapnya',
                    style: TextStyle(
                      color: _googleBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
              ),
            if (_isExpanded)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Sembunyikan',
                    style: TextStyle(
                      color: _googleBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}