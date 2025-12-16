import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Dihapus karena tidak digunakan langsung
import 'login_screen.dart'; // Pastikan ini mengacu pada LoginScreenContent Anda
import 'register_screen.dart'; // Pastikan ini mengacu pada RegisterScreenContent Anda

// --- KONSTANTA GAYA MODERN ---
const Color _googleBlue = Color(0xFF4285F4); // Warna aksen utama
const Color _primaryTextColor = Color(0xFF333333); // Teks gelap
const Color _secondaryTextColor = Color(0xFF6B6B6B); // Teks abu-abu
const Color _backgroundColor = Colors.white; // Latar belakang putih
const double _largeRadius = 12.0; // Radius umum untuk elemen UI

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updateCurrentPage);
  }

  // Mengupdate state saat PageView berganti halaman (swipe atau tombol)
  void _updateCurrentPage() {
    // Pastikan page terdefinisi sebelum mengambil round()
    if (_pageController.hasClients && _pageController.page != null) {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateCurrentPage);
    _pageController.dispose();
    super.dispose();
  }

  // Navigasi dengan tombol tab
  void _onTabTapped(int index) {
    if (_currentPage != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea( // Memastikan konten tidak tumpang tindih dengan status bar/notch
        child: Column(
          children: [
            // Bagian atas untuk logo, judul, dan deskripsi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Spasi atas
                  Image.asset(
                    'assets/images/Logo_hotelloop-removebg.png', // Ganti dengan path aset yang benar
                    height: 120, 
                    width: 120,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.hotel, 
                      size: 80, 
                      color: _googleBlue.withOpacity(0.7),
                    ), // Fallback jika logo tidak ditemukan
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Get Started Now',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _primaryTextColor,
                      fontFamily: 'DMSans',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create an account or log in to explore our amazing app features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryTextColor,
                      fontSize: 15,
                      fontFamily: 'DMSans',
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildAuthTabButtons(), // Tombol tab Login/Register
                  const SizedBox(height: 30),
                ],
              ),
            ),
            
            // PageView yang berisi halaman login dan register
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(), // Mencegah overscroll
                children: const [
                  LoginScreen(), // Halaman Login
                  RegisterScreen(), // Halaman Register
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget untuk tombol tab Login / Sign Up
  Widget _buildAuthTabButtons() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(_largeRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildTabItem(
              text: 'Log In',
              index: 0,
              isSelected: _currentPage == 0,
              onTap: () => _onTabTapped(0),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              text: 'Sign Up',
              index: 1,
              isSelected: _currentPage == 1,
              onTap: () => _onTabTapped(1),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat item tab
  Widget _buildTabItem({
    required String text,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _backgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(_largeRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? _primaryTextColor : _secondaryTextColor,
              fontFamily: 'DMSans',
            ),
          ),
        ),
      ),
    );
  }
}