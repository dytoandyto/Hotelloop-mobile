import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'forgot_password_screen.dart';
import 'homepage.dart';
import '../providers/auth_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
      if (next.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Email
            const Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color(0xFFF0F0F0),
                filled: true,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Masukkan email Anda' : null,
            ),
            const SizedBox(height: 20),

            // Input Password
            const Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: '********',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color(0xFFF0F0F0),
                filled: true,
              ),
              validator: (value) => value == null || value.isEmpty ? 'Masukkan password Anda' : null,
            ),
            const SizedBox(height: 10),

            // Checkbox dan Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _isRememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _isRememberMe = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: Colors.blue,
                    ),
                    const Text('Remember me'),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text('Forgot Password ?', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Login
            authState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authNotifierProvider.notifier).login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
            const SizedBox(height: 20),

            // Divider 'Or'
            Row(
              children: [
                const Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Or', style: TextStyle(color: Colors.grey[700])),
                ),
                const Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Google
            OutlinedButton.icon(
              onPressed: () {
                // Logika untuk login dengan Google
              },
              icon: Image.asset('lib/assets/images/google_logo.png', height: 24),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}