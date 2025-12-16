import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _primaryColor = Color(0xFF4285F4);
  static const Color _textSecondary = Color(0xFF6B6B6B);
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            _buildSection(
              title: 'Tentang Hoteloop',
              content:
                  'Hoteloop adalah aplikasi pemesanan hotel yang dikembangkan sebagai bagian dari tugas UKK. Aplikasi ini dirancang untuk memberikan pengalaman pemesanan yang cepat, sederhana, dan modern.',
            ),

            const SizedBox(height: 24),
            _buildSection(
              title: 'Tim Pengembang',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _RoleItem(role: 'Backend', name: 'Adrian, Damar'),
                  _RoleItem(role: 'Frontend', name: 'Adrian, Damar, Dimas??'),
                  _RoleItem(role: 'Mobile', name: 'Andyto'),
                  _RoleItem(role: 'UI/UX', name: '-'),
                  _RoleItem(role: 'Project Manager', name: '-'),
                  _RoleItem(role: 'QA & Tester', name: '-'),
                  Text(
                    'ada yang mau ditulisin gakk',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSection(
              title: 'Publikasi & Review',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _RoleItem(
                    role: 'Dipublikasikan oleh',
                    name: 'Tim Kelompok Hoteloop',
                  ),
                  _RoleItem(role: 'Diperiksa oleh', name: 'Bu Hesti'),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // logo hoteloo
          Image.asset(
            'assets/images/Logo_hotelloop-removebg.png', // Ganti dengan path aset yang benar
            height: 150,
            width: 150,
          ),

          const Text(
            'Hoteloop',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aplikasi Pemesanan Hotel\nVersi 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: const TextStyle(color: _textSecondary, height: 1.5),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2025 Hoteloop',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
    );
  }
}

class _RoleItem extends StatelessWidget {
  final String role;
  final String name;

  const _RoleItem({required this.role, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$role:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: const TextStyle(color: Color(0xFF6B6B6B))),
          ),
        ],
      ),
    );
  }
}
