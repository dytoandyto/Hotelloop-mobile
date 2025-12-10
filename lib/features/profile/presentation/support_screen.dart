import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & Dukungan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Layanan bantuan dan FAQ tersedia di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
          ),
        ),
      ),
    );
  }
}