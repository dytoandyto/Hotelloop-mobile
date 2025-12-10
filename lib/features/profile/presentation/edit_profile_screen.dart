import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita gunakan desain form yang bersih dan modern
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Pengguna (dengan kemampuan ganti foto)
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF4285F4),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Color(0xFF4285F4),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Input Nama
            _buildTextField(label: 'Nama Lengkap', initialValue: 'Nama Pengguna'),
            const SizedBox(height: 16),
            
            // Form Input Email (Biasanya Read-only atau diubah melalui verifikasi)
            _buildTextField(label: 'Email', initialValue: 'email@contoh.com', isReadOnly: true),
            const SizedBox(height: 16),
            
            // Form Input Telepon
            _buildTextField(label: 'Nomor Telepon', initialValue: '+62 812 XXXX XXXX'),
            const SizedBox(height: 24),

            // Tombol Simpan
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Kembali setelah simpan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required String label,
    required String initialValue,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: isReadOnly,
          style: TextStyle(
            color: isReadOnly ? Colors.grey.shade600 : Colors.black87
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isReadOnly ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isReadOnly ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ],
    );
  }
}