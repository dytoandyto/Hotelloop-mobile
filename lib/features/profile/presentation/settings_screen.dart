import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Notifikasi Email'),
            subtitle: Text('Atur apakah Anda ingin menerima notifikasi penawaran.'),
            trailing: Switch(value: true, onChanged: null),
          ),
          Divider(),
          ListTile(
            title: Text('Mode Gelap'),
            subtitle: Text('Aktifkan mode gelap untuk kenyamanan mata.'),
            trailing: Switch(value: false, onChanged: null),
          ),
        ],
      ),
    );
  }
}