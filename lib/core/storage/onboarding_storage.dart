import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingStorage {
  static const _keySeenOnboarding = 'seen_onboarding';

  // Menyimpan status bahwa Onboarding sudah dilihat
  Future<void> setSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySeenOnboarding, value);
  }

  // Mengambil status. Defaultnya adalah FALSE (belum pernah dilihat)
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySeenOnboarding) ?? false; 
  }
}

final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});