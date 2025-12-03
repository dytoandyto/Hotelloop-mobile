import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'forgot_password_screen.dart'; // Asumsi path ini valid
import '../../home/presentation/home_screen.dart'; // Asumsi path ini valid
import '../providers/auth_providers.dart'; // Asumsi path ini valid

// --- KONSTANTA GAYA MODERN ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _primaryTextColor = Color(0xFF333333);
const Color _secondaryTextColor = Color(0xFF6B6B6B);
const Color _inputFillColor = Color(0xFFF5F5F5);
const double _largeRadius = 12.0;
// --- KONSTANTA SPASI LEBIH KECIL ---
const double _smallSpacing = 16.0; 
const double _buttonPadding = 14.0; 

// Karena widget ini dipanggil di PageView (AuthScreen), 
// kita tidak perlu Scaffold, hanya SingleChildScrollView yang berisi form.
// Nama class diubah menjadi LoginScreen agar cocok dengan import AuthScreen

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isRememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Logika navigasi setelah login berhasil
  void _handleAuthListener(BuildContext context, AuthState? previous, AuthState next) {
    if (next.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(next.error!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    if (next.user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (Route<dynamic> route) => false, // Menghapus semua rute sebelumnya
      );
    }
  }

  // Logika saat tombol Login ditekan
  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listener untuk navigasi dan pesan error
    // Menggunakan ref.listen di dalam build hanya jika widget ini tidak di-rebuild
    // atau jika Anda ingin memastikan listener di-setup setiap saat.
    ref.listen(authNotifierProvider, (previous, next) => _handleAuthListener(context, previous, next));

    return SingleChildScrollView(
      // Padding dihilangkan karena AuthScreen sudah memberikan padding di sekitarnya
      // atau biarkan padding 24.0 untuk konsistensi form.
      padding: const EdgeInsets.symmetric(horizontal: 24.0), 
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // --- Input Email ---
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hintText: 'user@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your email' : null,
            ),
            const SizedBox(height: _smallSpacing),

            // --- Input Password ---
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hintText: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: _secondaryTextColor,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
            ),
            const SizedBox(height: 10),

            // --- Checkbox dan Forgot Password ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isRememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _isRememberMe = value ?? false;
                        });
                      },
                      activeColor: _googleBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    const Text(
                      'Remember me', 
                      style: TextStyle(color: _secondaryTextColor, fontFamily: 'DMSans', fontSize: 14)
                    ),
                  ],
                ),
                // Forgot Password Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?', 
                    style: TextStyle(color: _googleBlue, fontWeight: FontWeight.w600, fontFamily: 'DMSans', fontSize: 14)
                  ),
                ),
              ],
            ),
            const SizedBox(height: _smallSpacing + 10),

            // --- Tombol Login Utama ---
            ElevatedButton(
              onPressed: authState.isLoading ? null : _onLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: _buttonPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_largeRadius),
                ),
                elevation: 5,
                shadowColor: _googleBlue.withOpacity(0.4),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Log In', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DMSans'
                      )
                    ),
            ),
            const SizedBox(height: _smallSpacing),

            // --- Divider 'Or' ---
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1.5)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('OR', style: TextStyle(color: _secondaryTextColor, fontSize: 14, fontFamily: 'DMSans')),
                ),
                const Expanded(child: Divider(color: Color(0xFFE0E0E0), thickness: 1.5)),
              ],
            ),
            const SizedBox(height: _smallSpacing),

            // --- Tombol Google Sign-In ---
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Logika untuk login dengan Google
              },
              icon: Image.asset('assets/images/google_logo.png', height: 20),
              label: const Text(
                'Continue with Google', 
                style: TextStyle(color: _primaryTextColor, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'DMSans')
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: _buttonPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_largeRadius),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700, 
        fontSize: 14, 
        color: _primaryTextColor,
        fontFamily: 'DMSans'
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: _primaryTextColor, fontFamily: 'DMSans', fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _secondaryTextColor, fontFamily: 'DMSans'),
        prefixIcon: Icon(icon, color: _secondaryTextColor),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_largeRadius),
          borderSide: const BorderSide(color: _googleBlue, width: 2),
        ),
        fillColor: _inputFillColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}