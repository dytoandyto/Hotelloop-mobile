// lib/features/auth/screens/verify_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../providers/auth_providers.dart';
import 'reset_password_screen.dart';

class VerifyOTPScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyOTPScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends ConsumerState<VerifyOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Verify your account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the 6-digit code sent to ${widget.email}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Input OTP
              PinCodeTextField(
                appContext: context,
                controller: _otpController,
                length: 6,
                keyboardType: TextInputType.number,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.grey[200],
                  inactiveFillColor: Colors.grey[200],
                  selectedFillColor: Colors.grey[200],
                  borderWidth: 0,
                  inactiveColor: Colors.transparent,
                  selectedColor: Colors.blue,
                  activeColor: Colors.blue,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                validator: (value) =>
                    value == null || value.isEmpty || value.length < 6 ? '' : null,
                onChanged: (value) {},
              ),
              const SizedBox(height: 40),
              // Tombol Verify
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Panggil API verifikasi OTP
                          final data = await ref
                              .read(authNotifierProvider.notifier)
                              .verifyOTP(widget.email, _otpController.text.trim());
                          if (context.mounted && data != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResetPasswordScreen(
                                  email: data['email'],
                                  token: data['token'],
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E59FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}