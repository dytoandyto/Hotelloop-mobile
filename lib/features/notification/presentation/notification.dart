import 'package:flutter/material.dart';

// --- KONSTANTA GAYA ---
const Color _googleBlue = Color(0xFF4285F4); 
const Color _secondaryColor = Color(0xFF6B6B6B);
const Color _accentRed = Color(0xFFEA4335); // Warna untuk notifikasi penting
const double _modernRadius = 16.0; 

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Data dummy untuk notifikasi
  final List<Map<String, dynamic>> todayNotifications = const [
    {
      'title': 'Booking Berhasil!',
      'message': 'Pemesanan kamar Anda di Sigma Hotel telah dikonfirmasi.',
      'time': '1 jam lalu',
      'icon': Icons.check_circle_rounded,
      'color': _googleBlue,
      'isRead': false,
    },
    {
      'title': 'Promo Baru Datang!',
      'message': 'Dapatkan diskon 20% untuk hotel di Bali bulan ini.',
      'time': '3 jam lalu',
      'icon': Icons.local_offer_rounded,
      'color': _accentRed,
      'isRead': false,
    },
  ];

  final List<Map<String, dynamic>> earlierNotifications = const [
    {
      'title': 'Reminder Check-out',
      'message': 'Besok adalah hari terakhir Anda menginap di XYZ Hotel.',
      'time': 'Kemarin',
      'icon': Icons.calendar_today_rounded,
      'color': _secondaryColor,
      'isRead': true,
    },
    {
      'title': 'Rating Anda Penting',
      'message': 'Bagikan pengalaman menginap Anda dan dapatkan poin!',
      'time': '2 hari lalu',
      'icon': Icons.star_rate_rounded,
      'color': Colors.amber,
      'isRead': true,
    },
    {
      'title': 'Perubahan Kebijakan',
      'message': 'Kami memperbarui syarat dan ketentuan layanan kami.',
      'time': '1 minggu lalu',
      'icon': Icons.info_outline_rounded,
      'color': _googleBlue,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'DMSans',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implementasi logika Mark All As Read (misalnya panggil Provider/State)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca.')),
              );
            },
            child: const Text(
              'Mark All As Read',
              style: TextStyle(color: _googleBlue, fontFamily: 'DMSans'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          // --- Bagian Notifikasi Hari Ini ---
          _buildSectionTitle(context, 'Hari Ini', showCount: true, count: todayNotifications.where((n) => !n['isRead']).length),
          ...todayNotifications.map((notif) => _buildNotificationItem(context, notif)),

          const SizedBox(height: 24),

          // --- Bagian Notifikasi Sebelumnya ---
          _buildSectionTitle(context, 'Sebelumnya'),
          ...earlierNotifications.map((notif) => _buildNotificationItem(context, notif)),
        ],
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildSectionTitle(BuildContext context, String title, {bool showCount = false, int count = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'DMSans',
              color: Colors.black87,
            ),
          ),
          if (showCount && count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _accentRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count New',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DMSans',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'];
    final Color iconColor = notification['color'] as Color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: isRead ? Colors.white : _googleBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(_modernRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_modernRadius),
          onTap: () {
            // TODO: Aksi saat notifikasi diklik (misalnya navigasi ke halaman booking/promo)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifikasi: ${notification['title']} diklik!')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isRead ? Border.all(color: Colors.grey.shade200) : null,
              borderRadius: BorderRadius.circular(_modernRadius),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] as String,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                          fontFamily: 'DMSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isRead ? _secondaryColor : Colors.black87,
                          fontFamily: 'DMSans',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontFamily: 'DMSans',
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4, left: 8),
                    decoration: const BoxDecoration(
                      color: _accentRed,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}