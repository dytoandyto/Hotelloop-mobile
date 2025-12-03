import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/home_screen.dart'; // Tetap dipertahankan
import '../../auth/providers/auth_providers.dart';
import '../../auth/presentation/login_screen.dart'; // Diperlukan untuk Logout

// --- KONSTANTA GAYA MODERN (GOOOGLE/MATERIAL 3) ---
const Color _googleBlue = Color(0xFF4285F4); // Biru Google
const Color _secondaryColor = Color(0xFF6B6B6B); // Abu-abu gelap untuk ikon/teks tidak aktif
const double _modernRadius = 16.0; 
const Color _backgroundColor = Color(0xFFFAFAFA); // Background yang lebih terang

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true, // Biarkan tombol back default berfungsi untuk navigasi ke Home
        title: const Text(
          'Profile', 
          style: TextStyle(
            fontFamily: 'DMSans', 
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Warna teks AppBar
          )
        ),
        elevation: 0,
        backgroundColor: _backgroundColor,
        titleSpacing: 24.0,
      ),
      body: FutureBuilder(
        // Catatan: Jika Anda menggunakan Riverpod state, sebaiknya gunakan ref.watch/read pada StateNotifierProvider
        // daripada memanggil metode Future langsung di sini.
        future: authRepo.getUser(),
        builder: (context, snapshot) {
          // Tangani loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _googleBlue));
          }

          final user = snapshot.data?.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(
                  user?.name ?? 'Pengguna',
                  user?.email ?? 'pengguna@example.com',
                ),
                const SizedBox(height: 32), // Jarak yang lebih besar

                _buildSectionHeader('Akun & Pengaturan'),
                const SizedBox(height: 12),
                _buildAccountSection(context, ref),
                
                const SizedBox(height: 32),
                _buildSectionHeader('Dukungan'),
                const SizedBox(height: 12),
                _buildOtherSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(24), // Padding yang lebih besar
      decoration: BoxDecoration(
        color: _googleBlue, // Menggunakan Google Blue
        borderRadius: BorderRadius.circular(_modernRadius), // Sudut membulat modern
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
          const CircleAvatar(
            radius: 30, // Avatar yang lebih besar
            // Anda mungkin perlu mengganti ini dengan NetworkImage jika menggunakan URL dari user
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 30, color: _googleBlue),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Font lebih besar
                    fontWeight: FontWeight.w700, // Lebih tebal
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
            onPressed: () {
              // TODO: Navigasi ke halaman Edit Profile
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white), // Ikon outlined
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16, // Ukuran Header Seksi yang lebih halus
        fontWeight: FontWeight.bold,
        fontFamily: 'DMSans',
        color: _secondaryColor,
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref) {
    // Fungsi logout yang sebenarnya
    void handleLogout() async {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      await authNotifier.logout();
      // Navigasi ke LoginScreen setelah logout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
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
              // TODO: Navigasi ke Account Info
            },
            isFirst: true, // Tambahkan ini untuk menghilangkan divider di item pertama
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan & Preferensi',
            subtitle: 'Atur preferensi Anda',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history_toggle_off_outlined, // Ikon outlined yang lebih modern
            title: 'Aktivitas Pengguna',
            subtitle: 'Lihat riwayat aktivitas Anda',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security_outlined, // Ikon keamanan
            title: 'Two-Factor Authentication',
            subtitle: 'Further secure your account for safety',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar (Log out)',
            subtitle: 'Sign out from your account',
            color: Colors.red.shade600, // Warna merah untuk logout
            onTap: handleLogout, // Gunakan fungsi logout
            isLast: true, // Tambahkan ini untuk menghilangkan divider di item terakhir
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
            icon: Icons.support_agent_outlined, // Ikon yang lebih spesifik
            title: 'Bantuan & Dukungan',
            onTap: () {},
            isFirst: true,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {},
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
    // Menggunakan InkWell/GestureDetector di sekitar ListTile untuk kontrol radius yang lebih baik
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Icon(
              icon, 
              color: color ?? _secondaryColor, 
              size: 24,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600, // Bold sedang
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
                        fontSize: 12),
                  )
                : null,
            trailing: color == Colors.red.shade600
                ? null // Hilangkan panah untuk tombol logout
                : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
  
  // Widget Divider Kustom
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}

// Catatan: Pastikan Anda memiliki LoginScreen di path '../../auth/presentation/login_screen.dart'
// dan Anda telah mengganti `const ProfileScreen()` dengan `const LoginScreen()` setelah logout.