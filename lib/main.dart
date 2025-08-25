import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/splash_screen.dart';

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
      home: const SplashScreen(),
    );
  }
}
