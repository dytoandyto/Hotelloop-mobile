import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/auth/providers/startup_provider.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart'; 
import '../../home/presentation/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  // Logika navigasi berdasarkan StartupState
  void _handleNavigation(BuildContext context, StartupState? previous, StartupState next) {
    // Navigasi hanya dilakukan setelah loading selesai
    if (previous != null && previous.isLoading && !next.isLoading) {
      if (next.user != null) {
        // 1. Sudah Login: Langsung ke Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (!next.hasSeenOnboarding) {
        // 2. Belum Login DAN Belum Lihat Onboarding: Arahkan ke Onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()), 
        );
        // Penting: Set status Onboarding menjadi 'true' setelah user melihatnya (di OnboardingScreen)
      } else {
        // 3. Belum Login TAPI Sudah Lihat Onboarding: Arahkan ke AuthScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Amati (watch) state penentu rute
    final startupState = ref.watch(startupNotifierProvider);

    // Listener untuk memicu navigasi setelah semua data (Auth + Onboarding) dimuat.
    ref.listen<StartupState>(startupNotifierProvider, (previous, next) {
      _handleNavigation(context, previous, next);
    });

    // Tampilan Splash Screen
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logo_hotelloop-removebg.png', 
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            // Tunjukkan loading indicator saat StartupNotifier sedang bekerja
            if (startupState.isLoading)
              const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 10),
            if (startupState.isLoading)
              const Text(
                'Initializing app...', 
                style: TextStyle(color: Colors.blueGrey, fontSize: 16)
              ),
          ],
        ),
      ),
    );
  }
}