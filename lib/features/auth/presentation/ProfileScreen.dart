import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/auth/presentation/homepage.dart';
import '../providers/auth_providers.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: true, // ilangin tombol back/menu
        title: const Text('Profile', style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.bold)),
        elevation: 0, // optional biar flat
        backgroundColor: const Color(
          0xFFF5F5F5,
        ), // Menyesuaikan warna dengan body
        titleSpacing: 24.0,
      ),
      body: FutureBuilder(
        future: authRepo.getUser(),
        builder: (context, snapshot) {
          final user = snapshot.data?.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(
                  user?.name ?? 'User',
                  user?.email ?? 'user@example.com',
                ),
                const SizedBox(height: 20),

                _buildAccountSection(context),
                const SizedBox(height: 20),
                _buildSectionHeader('Lainnya'),
                _buildOtherSection(context, ref, authRepo),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0601B4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('lib/assets/images/default_profile.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DMSans',
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'DMSans',
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Informasi Akun',
            subtitle: 'Detail info akun Anda',
            onTap: () {
              // Tambahkan navigasi
            },
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan & Preferensi',
            subtitle: 'Atur preferensi Anda',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Aktivitas Pengguna',
            subtitle: 'Lihat riwayat aktivitas Anda',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Two-Factor Authentication',
            subtitle: 'Further secure your account for safety',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Log out',
            subtitle: 'Sign out from your account',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(
    BuildContext context,
    WidgetRef ref,
    dynamic authRepo,
  ) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan & Dukungan',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'DMSans',
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontFamily: 'DMSans'),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
