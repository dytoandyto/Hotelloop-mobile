class OnboardingModel {
  final String image;
  final String title;
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnboardingModel> onboardingItems = [
  OnboardingModel(
    image: 'lib/assets/images/onboarding1.png',
    title: 'Destinasi di Ujung Jari',
    description: 'Temukan hotel, vila, atau apartemen idealmu dari ribuan pilihan di seluruh dunia dalam hitungan detik.',
  ),
  OnboardingModel(
    image: 'lib/assets/images/onboarding2.png',
    title: 'Hemat Tanpa Ribet',
    description: 'Nikmati liburan lebih lama dengan penawaran spesial yang ramah di kantong.',
  ),
  OnboardingModel(
    image: 'lib/assets/images/onboarding3.png',
    title: 'Satu Klik Siap Liburan!',
    description: 'Kami jaga datamu dengan enkripsi terbaik, jadi kamu bisa fokus merencanakan hal-hal seru.',
  ),
];