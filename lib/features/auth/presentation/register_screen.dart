import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '/features/home/presentation/home_screen.dart';

// --- KONSTANTA GAYA MODERN ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _primaryTextColor = Color(0xFF333333);
const Color _secondaryTextColor = Color(0xFF6B6B6B);
const Color _inputFillColor = Color(0xFFF5F5F5);
const double _largeRadius = 12.0;
// --- KONSTANTA SPASI RINGKAS ---
const double _smallSpacing = 16.0;
const double _buttonPadding = 14.0;

// Karena widget ini dipanggil di PageView (AuthScreen),
// kita tidak perlu Scaffold.

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Logika listener autentikasi
  void _handleAuthListener(
    BuildContext context,
    AuthState? previous,
    AuthState next,
  ) {
    if (next.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.error!), backgroundColor: Colors.redAccent),
      );
    }
    if (next.user != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      // Navigasi ke Home Screen setelah pendaftaran berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // Logika pendaftaran
  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authNotifierProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Listener untuk navigasi dan pesan error
    ref.listen(
      authNotifierProvider,
      (previous, next) => _handleAuthListener(context, previous, next),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Input Nama ---
            _buildLabel('Full Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'Enter your name',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                if (!nameRegex.hasMatch(value)) {
                  return 'Please enter a valid name';
                }
                return null;
              },
            ),
            const SizedBox(height: _smallSpacing),

            // --- Input Email ---
            _buildLabel('Email Address'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              hintText: 'user@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your email'
                  : null,
            ),
            const SizedBox(height: _smallSpacing),

            // --- Input Password ---
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordController,
              hintText: 'Create a strong password',
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
              validator: (value) => value == null || value.isEmpty
                  ? 'Please create a password'
                  : null,
            ),
            const SizedBox(
              height: _smallSpacing * 2,
            ), // Spasi yang lebih besar sebelum tombol
            // --- Tombol Register Utama ---
            ElevatedButton(
              onPressed: authState.isLoading ? null : _onRegisterPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _googleBlue,
                padding: const EdgeInsets.symmetric(
                  vertical: _buttonPadding,
                ), // Padding ringkas
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
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Ukuran teks tombol disesuaikan
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DMSans',
                      ),
                    ),
            ),
            const SizedBox(height: _smallSpacing), // Spasi ringkas
            // --- Divider 'Or' ---
            Row(
              children: [
                const Expanded(
                  child: Divider(color: Color(0xFFE0E0E0), thickness: 1.5),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: _secondaryTextColor,
                      fontSize: 14,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Color(0xFFE0E0E0), thickness: 1.5),
                ),
              ],
            ),
            const SizedBox(height: _smallSpacing), // Spasi ringkas
            // --- Tombol Google Sign-In ---
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Logika untuk register dengan Google
              },
              icon: Image.asset('assets/images/google_logo.png', height: 20),
              label: const Text(
                'Sign up with Google',
                style: TextStyle(
                  color: _primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DMSans',
                ),
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
        fontFamily: 'DMSans',
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
      style: const TextStyle(
        color: _primaryTextColor,
        fontFamily: 'DMSans',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _secondaryTextColor,
          fontFamily: 'DMSans',
        ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ), // Padding ringkas
      ),
      validator: validator,
    );
  }
}
