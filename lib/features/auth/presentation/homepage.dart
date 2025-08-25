import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import 'ProfileScreen.dart';
import 'package:learn_flutter_intermediate/features/home/domain/entities/hotel.dart';
import 'HotelDetailScreen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _locationController = TextEditingController(text: '');
  final _checkInDateController = TextEditingController(text: '');
  final _checkOutDateController = TextEditingController(text: '');
  final _guestsController = TextEditingController(text: '');

  late Future<dynamic> userFuture = Future.value(null);

  @override
  void initState() {
    super.initState();
    final authRepo = ref.read(authRepositoryProvider);
    userFuture = authRepo.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load user data.'));
          }

          final user = snapshot.data?.user;

          return SingleChildScrollView(
            // Widget utama yang membuat layar bisa digulir
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user?.name ?? 'Guest'),
                  const SizedBox(height: 20),
                  _buildSearchForm(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Populer di Sekitar Anda'),
                  const SizedBox(height: 10),
                  _buildHorizontalHotelList(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Hotel Populer'),
                  const SizedBox(height: 10),
                  _buildVerticalHotelList(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Destinasi Populer'),
                  const SizedBox(height: 10),
                  _buildPopularDestinations(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader(String userName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.location_on_outlined, color: Color(0xFF0088FF)),
                SizedBox(width: 8),
                Text(
                  'Surakarta, Jawa Tengah',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Hai, $userName 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(hint: 'Cari lokasi', icon: Icons.search),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSearchField(
                    hint: 'Sat, Aug 02',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSearchField(
                    hint: 'Sat, Aug 02',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSearchField(
              hint: '1 room 2 adults',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D61E7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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

  Widget _buildSearchField({required String hint, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(hint, style: const TextStyle(color: Colors.grey)),
          ),
        ],
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
        TextButton(
          onPressed: () {},
          child: const Text(
            'Lihat Semua',
            style: TextStyle(color: Color(0xFF0088FF)),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalHotelList() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          // Data contoh
          final name = 'The Aston Vill Hotel';
          final location = 'Alice Springs NT 0870, Australia';
          final price = 'Rp 200.000';
          final rating = '5.0';

          return GestureDetector(
            // Gunakan GestureDetector
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HotelDetailScreen(),
                ), // Navigasi ke HotelDetailScreen
              );
            },
            child: Container(
              width: 250,
              margin: const EdgeInsets.only(right: 15),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.asset(
                        'lib/assets/images/hotels/hotel1.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$price / night',
                                style: const TextStyle(
                                  color: Color(0xFF0601B4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Text(rating),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotelCard(
    String name,
    String location,
    String price,
    double rating,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(right: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/hotels/hotel3.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating.toString()),
                    ],
                  ),
                  Text(
                    '$price / night',
                    style: const TextStyle(
                      color: Color(0xFF0601B4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalHotelList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index) {
        final name = 'Sigma Hotel';
        final location = 'Wilora NT 0872, Ngawi';
        final price = 'Rp 750.000';
        final rating = '4.5';

        return GestureDetector(
          // Gunakan GestureDetector
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HotelDetailScreen(),
              ), // Navigasi ke HotelDetailScreen
            );
          },
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(
                          'lib/images/hotels/hotel3.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(rating.toString()),
                          ],
                        ),
                        Text(
                          '$price / night',
                          style: const TextStyle(
                            color: Color(0xFF0601B4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalHotelCard(
    String name,
    String location,
    String price,
    double rating,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/hotels/hotel3.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating.toString()),
                    ],
                  ),
                  Text(
                    '$price / night',
                    style: const TextStyle(
                      color: Color(0xFF0601B4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDestinations() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          final destinations = ['Bandung', 'Bali', 'Surabaya', 'Yogyakarta'];
          return _buildDestinationCard(destinations[index]);
        },
      ),
    );
  }

  Widget _buildDestinationCard(String name) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(right: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: 140,
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/hotels/hotel1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue[700],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: 0,
      onTap: (index) {
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
    );
  }
}
