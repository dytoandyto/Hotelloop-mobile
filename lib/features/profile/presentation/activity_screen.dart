import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Riwayat Login, Perubahan Password, dan Aktivitas Penting lainnya tercatat di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
          ),
        ),
      ),
    );
  }
}