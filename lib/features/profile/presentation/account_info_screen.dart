import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_intermediate/features/profile/provider/profile_provider.dart';
import '../../auth/providers/auth_providers.dart'; 
import '../../auth/data/models/user_model.dart'; 

// --- KONSTANTA GAYA ---
const Color _googleBlue = Color(0xFF4285F4);
const Color _secondaryTextColor = Color(0xFF6B6B6B);
const double _modernRadius = 12.0;
const Color _backgroundColor = Color(0xFFFAFAFA);

class AccountInfoScreen extends ConsumerWidget { 
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil Auth State
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    
    // 2. Cek ID User. Jika null, tampilkan error view segera.
    final currentUserId = user?.id;

    if (currentUserId == null || authState.isLoading) {
      // Tampilkan loader jika sedang fetching, atau Error View jika id benar-benar null
      return Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Informasi Akun', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Center(
          child: currentUserId == null
              ? _buildErrorView(
                  'User ID tidak ditemukan. Silakan login ulang.',
                  context,
                  ref,
                )
              : const CircularProgressIndicator(color: _googleBlue),
        ),
      );
    }
    
    // 3. Tonton FutureProvider dengan ID yang pasti INT
    final userDetailsAsync = ref.watch(userDetailsProvider(currentUserId));

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Informasi Akun',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'DMSans',
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      // 4. Tangani state AsyncValue (Loading, Error, Data)
      body: userDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _googleBlue)),
        error: (err, stack) => _buildErrorView(
            'Gagal memuat detail akun: ${err.toString().split('Exception: ').last}',
            context,
            ref),
        data: (user) {
          // Data user berhasil dimuat
          return _buildAccountDetails(context, user);
        },
      ),
    );
  }

  // --- Widget Tampilan Detail Akun ---
  Widget _buildAccountDetails(BuildContext context, UserModel user) {
    final name = user.name ?? 'Tidak Ada Nama';
    final email = user.email ?? 'Tidak Ada Email';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Akun Dasar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _secondaryTextColor,
              fontFamily: 'DMSans',
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
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
                _buildInfoTile(
                  icon: Icons.person_outline,
                  title: 'Nama Lengkap',
                  value: name,
                  isFirst: true,
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Alamat Email',
                  value: email,
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.vpn_key_outlined,
                  title: 'Kata Sandi',
                  value: '************',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigasi ke halaman Ubah Password')),
                    );
                  },
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Silahkan gunakan halaman Edit Profile untuk mengubah data.')),
                    );
                 }
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Ubah Data Akun', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _googleBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_modernRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Error dan Retry ---
  Widget _buildErrorView(String message, BuildContext context, WidgetRef ref) {
    // Ambil ID lagi untuk retry
    final currentUserId = ref.watch(authNotifierProvider).user?.id;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: _secondaryTextColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Invalidate provider untuk memicu refresh data, hanya jika ID ada
                if (currentUserId != null) {
                    ref.invalidate(userDetailsProvider(currentUserId));
                } else {
                    // Jika ID pun null, panggil refresh auth data
                    ref.read(authNotifierProvider.notifier).getUser();
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: _googleBlue),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk item list informasi (sama seperti sebelumnya)
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(_modernRadius) : Radius.zero,
        bottom: isLast ? const Radius.circular(_modernRadius) : Radius.zero,
      ),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            leading: Icon(icon, color: _googleBlue, size: 24),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'DMSans',
              ),
            ),
            subtitle: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'DMSans',
                fontSize: 13,
              ),
            ),
            trailing: onTap != null
                ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _secondaryTextColor)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72.0, right: 16.0),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}