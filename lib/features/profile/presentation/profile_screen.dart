import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/auth/presentation/auth_screen.dart';
import 'package:learn_flutter_intermediate/features/profile/presentation/about_screen.dart';
import 'package:learn_flutter_intermediate/features/profile/presentation/edit_profile_screen.dart';
import 'package:learn_flutter_intermediate/features/profile/presentation/support_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/presentation/login_screen.dart';

// Import halaman dummy:
import 'account_info_screen.dart';
import 'settings_screen.dart';
import 'activity_screen.dart';

// --- KONSTANTA GAYA MODERN (GOOOGLE/MATERIAL 3) ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _secondaryColor = Color(0xFF6B6B6B);
const double _modernRadius = 16.0;
const Color _backgroundColor = Color(0xFFFAFAFA);
const Color _skeletonColor = Color(
  0xFFE0E0E0,
); // Warna abu-abu muda untuk loader

// URL Ngrok dari HotelModel (ASUMSI KONSTAN INI ADA DI FILE KONSTAN GLOBAL)
// const String _mediaBaseUrl = 'https://9eb2ea56402f.ngrok-free.app/storage/';
const String _defaultAvatarUrl =
    'https://placehold.co/100x100/4285F4/white?text=U';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH the Auth StateNotifier to get the current user data
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    // Fallback data
    final name = user?.name ?? 'Guest User';
    final email = user?.email ?? 'Silahkan Login';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: _backgroundColor,
        titleSpacing: 24.0,
      ),
      // Memicu Skeleton jika loading
      body: _buildBody(context, ref, authState.isLoading, name, email),
    );
  }

  // --- Implementasi Skeleton Loader ---
  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Skeleton Header
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: _skeletonColor,
              borderRadius: BorderRadius.circular(_modernRadius),
            ),
          ),
          const SizedBox(height: 32),
          // Skeleton Section 1
          _buildSectionHeader('Akun & Pengaturan'),
          const SizedBox(height: 12),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: _skeletonColor,
              borderRadius: BorderRadius.circular(_modernRadius),
            ),
          ),
          const SizedBox(height: 32),
          // Skeleton Section 2
          _buildSectionHeader('Dukungan'),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: _skeletonColor,
              borderRadius: BorderRadius.circular(_modernRadius),
            ),
          ),
        ],
      ),
    );
  }

  // --- Bagian Body Utama (Menggunakan State Cache) ---
  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    bool isLoading,
    String name,
    String email,
  ) {
    // KONDISI UTAMA: Hanya tampilkan skeleton jika benar-benar loading di awal
    if (isLoading && name == 'Guest User') {
      return _buildSkeletonLoader();
    }

    // Jika tidak loading, tampilkan konten sesungguhnya
    return RefreshIndicator(
      // Tambahkan Refresh Indicator agar user bisa manual refresh data user jika ada masalah
      onRefresh: () => ref.read(authNotifierProvider.notifier).getUser(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(name, email, context),
            const SizedBox(height: 32),

            _buildSectionHeader('Akun & Pengaturan'),
            const SizedBox(height: 12),
            _buildAccountSection(context, ref),

            const SizedBox(height: 32),
            _buildSectionHeader('Dukungan'),
            const SizedBox(height: 12),
            _buildOtherSection(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- Implementasi Widget lainnya ---

  Widget _buildProfileHeader(String name, String email, BuildContext context) {
    final effectiveName = name.isEmpty ? 'Guest User' : name;
    final effectiveEmail = email.isEmpty ? 'Silahkan Login' : email;
    // Asumsi: Kita tidak memiliki profileImageUrl di UserModel, jadi pakai placeholder.
    final profileImageUrl = _defaultAvatarUrl;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _googleBlue,
        borderRadius: BorderRadius.circular(_modernRadius),
        boxShadow: [
          BoxShadow(
            color: _googleBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            // FIX: Menggunakan Gambar Network dari Storage atau Placeholder
            backgroundImage: NetworkImage(profileImageUrl),
            child: effectiveName == 'Guest User'
                ? const Icon(Icons.person, size: 30, color: _googleBlue)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effectiveName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DMSans',
                  ),
                ),
                Text(
                  effectiveEmail,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'DMSans',
                  ),
                ),
              ],
            ),
          ),
          // Hanya tampilkan tombol edit jika user sudah login
          if (effectiveName != 'Guest User')
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'DMSans',
        color: _secondaryColor,
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    void handleLogout() async {
      final authNotifier = ref.read(authNotifierProvider.notifier);

      // PENTING: Periksa apakah widget masih terpasang
      if (!context.mounted) return;

      // 1. Tampilkan loader/snack bar sementara sebelum proses logout
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging out...')),
      );

      // 2. Lakukan proses logout (Hapus token)
      await authNotifier.logout();

      // 3. Pastikan konteks masih valid sebelum navigasi
      if (context.mounted) {
         // Navigasi ke Login Screen dan hapus semua rute sebelumnya
         Navigator.of(context).pushAndRemoveUntil(
           MaterialPageRoute(builder: (context) => const AuthScreen()),
           (Route<dynamic> route) => false,
         );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_modernRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Informasi Akun',
            subtitle: 'Detail info akun Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountInfoScreen(),
                ),
              );
            },
            isFirst: true,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan & Preferensi',
            subtitle: 'Atur preferensi Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history_toggle_off_outlined,
            title: 'Aktivitas Pengguna',
            subtitle: 'Lihat riwayat aktivitas Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActivityScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Further secure your account for safety',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar (Log out)',
            subtitle: 'Sign out from your account',
            color: Colors.red.shade600,
            onTap: handleLogout,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_modernRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.support_agent_outlined,
            title: 'Bantuan & Dukungan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
            },
            isFirst: true,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            isLast: true,
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
    bool isFirst = false,
    bool isLast = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? Radius.circular(_modernRadius) : Radius.zero,
        bottom: isLast ? Radius.circular(_modernRadius) : Radius.zero,
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Icon(icon, color: color ?? _secondaryColor, size: 24),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'DMSans',
                color: color ?? Colors.black87,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(
                      color: color ?? Colors.grey[600],
                      fontFamily: 'DMSans',
                      fontSize: 12,
                    ),
                  )
                : null,
            trailing: color == Colors.red.shade600
                ? null
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
