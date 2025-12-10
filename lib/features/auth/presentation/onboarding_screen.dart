import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- IMPORT RIVEPOD
import 'package:learn_flutter_intermediate/features/auth/presentation/auth_screen.dart';
import '../../../core/storage/onboarding_storage.dart'; // <-- IMPORT STORAGE
import 'onboarding_model.dart';
// Asumsi: Anda juga perlu mengimpor OnboardingModel yang berisi List onboardingItems

// Ganti dari StatefulWidget menjadi ConsumerStatefulWidget
class OnboardingScreen extends ConsumerStatefulWidget { 
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Ganti State menjadi ConsumerState
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> { 
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
  
  // --- Fungsi yang ditambahkan: Selesai Onboarding ---
  void _onDonePressed() {
    // 1. Set status Onboarding menjadi TRUE di storage
    // Pastikan onboardingStorageProvider sudah didefinisikan di tempat yang benar
    ref.read(onboardingStorageProvider).setSeenOnboarding(true); 

    // 2. Navigasi ke AuthScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  // Widget untuk tombol NEXT/Selesai
  Widget _buildNextButton() {
    // Teks tombol akan berubah menjadi 'GET STARTED' di halaman terakhir
    final isLastPage = _currentPage == onboardingItems.length - 1;
    final buttonText = isLastPage ? 'GET STARTED' : 'NEXT';
    
    // Posisi tombol diatur lebih ke bawah
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (!isLastPage) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn,
              );
            } else {
              // Panggil fungsi yang sudah dimodifikasi
              _onDonePressed(); 
            }
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(-0.3),
            child: Container(
              width: 250, 
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFD1FF0F),
              ),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.skewX(0.3),
                  child: Text(
                    buttonText, // <-- Teks berubah
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2.0,
                      fontFamily: 'Oswald',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Metode build dan helper lainnya (indicator, content) tetap sama
  @override
  Widget build(BuildContext context) {
    // ... (kode build sama)
    return Scaffold(
      body: Stack(
        children: [
          // Background PageView dengan gambar
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingItems.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Image.asset(
                    onboardingItems[index].image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  Container(color: Colors.black.withOpacity(0.5)),
                  _buildContent(onboardingItems[index]),
                ],
              );
            },
          ),
          // Indikator halaman
          _buildPageIndicator(),
          // Tombol NEXT/Selesai
          _buildNextButton(),
        ],
      ),
    );
  }

  // (Kode _buildContent tetap sama)
  Widget _buildContent(OnboardingModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
              fontFamily: 'Oswald',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Oswald',
            ),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
  
  // (Kode _buildPageIndicator dan _indicator tetap sama)
  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 150, // Posisinya
      left: 0,
      right: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          onboardingItems.length,
          (index) => _indicator(index == _currentPage),
        ),
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFD1FF0F)
            : const Color(0xFFFFFFFF), // Warna putih untuk yang tidak aktif
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? null
            : Border.all(
                  color: const Color(0xFFFFFFFF),
              ), // Tambahkan border putih
      ),
    );
  }
}