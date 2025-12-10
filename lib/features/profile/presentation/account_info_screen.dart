import 'package:flutter/material.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Akun', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Detail Nama, Email, dan Password Anda akan ditampilkan di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
          ),
        ),
      ),
    );
  }
}