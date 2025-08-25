import 'package:flutter/material.dart';
import 'package:learn_flutter_intermediate/features/auth/presentation/AuthScreen.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  @override
  Widget build(BuildContext context) {
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

  // Widget untuk konten teks
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
              // Ukuran font disesuaikan agar tidak terlalu besar
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
          // Jarak bawah disesuaikan agar tidak menimpa tombol dan indikator
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  // Widget untuk indikator halaman (titik-titik)
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

  // Widget untuk tombol NEXT/Selesai
  Widget _buildNextButton() {
    // Posisi tombol diatur lebih ke bawah
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (_currentPage < onboardingItems.length - 1) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn,
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            }
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(-0.3),
            child: Container(
              width: 250, // Lebar tombol diperlebar agar terlihat mirip desain
              height: 50,
              decoration: BoxDecoration(
                // Menggunakan warna D1FF0F
                color: const Color(0xFFD1FF0F),
              ),
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.skewX(0.3),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
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
}
