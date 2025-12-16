import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/onboarding_storage.dart';
import 'auth_providers.dart';
import '../data/models/user_model.dart'; // Import UserModel

class StartupState {
  final bool isLoading;
  final bool hasSeenOnboarding;
  final UserModel? user; // Ambil dari AuthState

  const StartupState({
    this.isLoading = true,
    this.hasSeenOnboarding = false,
    this.user,
  });

  StartupState copyWith({
    bool? isLoading,
    bool? hasSeenOnboarding,
    UserModel? user,
  }) {
    return StartupState(
      isLoading: isLoading ?? this.isLoading,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      user: user ?? this.user,
    );
  }
}

class StartupNotifier extends StateNotifier<StartupState> {
  final AuthNotifier authNotifier;
  final OnboardingStorage onboardingStorage;
  // Kita butuh ref agar bisa watch AuthState
  final Ref ref; 

  StartupNotifier(this.authNotifier, this.onboardingStorage, this.ref) 
      : super(const StartupState()) {
    // Mulai memuat semua state saat notifier dibuat
    _loadAllInitialData();
  }

  Future<void> _loadAllInitialData() async {
    state = state.copyWith(isLoading: true);

    // 1. Cek status Onboarding
    final hasSeen = await onboardingStorage.hasSeenOnboarding();
    
    // 2. AuthNotifier secara otomatis sudah mencoba auto-login di constructor-nya
    // Kita tunggu sampai authNotifier selesai loading
    
    // Kita bisa menunggu sebentar agar UI SplashScreen terlihat stabil 
    // (Misalnya, total durasi 1.5 detik, termasuk waktu AuthNotifier bekerja)
    // Walaupun idealnya, Riverpod hanya perlu menunggu async call selesai.
    await Future.wait([
        // Memastikan AuthNotifier sudah menyelesaikan loadAuthState()
        ref.read(authNotifierProvider.notifier).loadAuthState(), 
        // Tambahkan delay minimal 1 detik untuk pengalaman splash screen
        // Future.delayed(const Duration(milliseconds: 1000)),
    ]);


    // 3. Ambil hasil status user dari AuthNotifier
    final authState = ref.read(authNotifierProvider);

    // 4. Update final state
    state = state.copyWith(
      isLoading: false,
      hasSeenOnboarding: hasSeen,
      user: authState.user,
    );
  }
}

// Provider untuk OnboardingStorage
final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return OnboardingStorage();
});

// Provider untuk StartupNotifier
final startupNotifierProvider = StateNotifierProvider<StartupNotifier, StartupState>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);
  final onboardingStorage = ref.read(onboardingStorageProvider);
  return StartupNotifier(authNotifier, onboardingStorage, ref);
});