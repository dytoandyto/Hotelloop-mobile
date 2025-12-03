import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'dart:async'; // Untuk fungsi Timer

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Menunda selama 3 detik sebelum navigasi
    await Future.delayed(const Duration(milliseconds: 3000), () {});

    // Navigasi ke halaman utama
    // Ganti 'NamaHalamanUtama' dengan nama kelas halaman utama Anda
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar logo Anda
            // Gunakan Image.asset jika logo ada di folder assets
            
            Image.asset(
              'assets/images/Logo_hotelloop-removebg.png', 
              width: 300,
              height: 300,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}