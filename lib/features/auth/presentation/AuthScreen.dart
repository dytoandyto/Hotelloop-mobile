import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

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
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: [
          // Bagian atas untuk logo, judul, dan tombol tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'lib/assets/images/Logo_hotelloop-removebg.png',
                  height: 160,
                  width: 160,
                ),
                const SizedBox(height: 10),
                const Text( 
                  'Get Started now',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create an account or log in to explore about our app',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                _buildAuthButtons(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          
          // PageView yang berisi halaman login dan register
          Expanded(
            child: PageView(
              controller: _pageController,
              children: const [
                LoginScreen(),
                RegisterScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAuthButtons() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 238, 238),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentPage == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _currentPage == 0
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: const Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _currentPage == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _currentPage == 1
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}