import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Jika provider AuthScreen tidak membutuhkannya, bisa dihapus
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

  void _updateCurrentPage() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateCurrentPage);
    _pageController.dispose();
    super.dispose();
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
                    'assets/images/Logo_hotelloop-removebg.png', // Logo Anda
                    height: 120, // Ukuran logo sedikit lebih kecil
                    width: 120,
                  ),
                  const SizedBox(height: 20), // Spasi setelah logo
                  const Text(
                    'Get Started Now',
                    style: TextStyle(
                      fontSize: 26, // Ukuran font sedikit lebih besar dari sebelumnya
                      fontWeight: FontWeight.bold,
                      color: _primaryTextColor,
                      fontFamily: 'DMSans', // Gunakan font yang konsisten
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8), // Spasi lebih kecil
                  const Text(
                    'Create an account or log in to explore our amazing app features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryTextColor,
                      fontSize: 15,
                      fontFamily: 'DMSans',
                    ),
                  ),
                  const SizedBox(height: 30), // Spasi sebelum tombol tab
                  _buildAuthTabButtons(), // Tombol tab Login/Register
                  const SizedBox(height: 30), // Spasi setelah tombol tab
                ],
              ),
            ),
            
            // PageView yang berisi halaman login dan register
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(), // Untuk mencegah "overscroll" efek
                children: const [
                  LoginScreen(), // Pastikan ini mengacu pada widget login Anda
                  RegisterScreen(), // Pastikan ini mengacu pada widget register Anda
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
        color: const Color(0xFFF0F0F0), // Warna latar belakang tab yang lebih soft
        borderRadius: BorderRadius.circular(_largeRadius), // Radius yang konsisten
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildTabItem(
              text: 'Log In',
              index: 0,
              isSelected: _currentPage == 0,
              onTap: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut, // Kurva animasi yang lebih halus
                );
              },
            ),
          ),
          Expanded(
            child: _buildTabItem(
              text: 'Sign Up',
              index: 1,
              isSelected: _currentPage == 1,
              onTap: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut, // Kurva animasi yang lebih halus
                );
              },
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
        padding: const EdgeInsets.symmetric(vertical: 14), // Padding vertikal yang lebih ringkas
        decoration: BoxDecoration(
          color: isSelected ? _backgroundColor : Colors.transparent, // Latar belakang putih saat terpilih
          borderRadius: BorderRadius.circular(_largeRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), // Shadow yang lebih halus
                    blurRadius: 10,
                    offset: const Offset(0, 4), // Offset ke bawah
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16, // Ukuran teks tab yang konsisten
              color: isSelected ? _primaryTextColor : _secondaryTextColor, // Warna teks berbeda
              fontFamily: 'DMSans',
            ),
          ),
        ),
      ),
    );
  }
}
// https://googleusercontent.com/image_generation_content/1