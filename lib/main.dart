import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/auth/presentation/auth_screen.dart';
// import 'package:learn_flutter_intermediate/features/auth/presentation/login_screen.dart'; // Tidak diperlukan di main.dart
import 'package:learn_flutter_intermediate/features/home/presentation/home_screen.dart'; // Penting
import 'features/auth/presentation/splash_screen.dart'; // Akan kita gunakan untuk routing
// Impor AuthNotifier agar bisa dibaca di SplashScreen jika diperlukan
import 'features/auth/providers/auth_providers.dart';


Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        ),
      title: 'Hotelloop',
      
      // GANTI DARI AuthScreen ke SplashScreen
      home: const SplashScreen(), 
    );
  }
}