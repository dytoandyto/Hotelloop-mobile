import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aplikasi Pemesanan Hotel V1.0',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Dikembangkan oleh Tim Hoteloop tugas UKK. ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
              ),

              SizedBox(height: 20),
              Text(
                'Dikembangkan oleh:\n- Backend: Adrian, Damar\n- Frontend: Adrian, Damar, Dimas?\n- Mobile : Andyto \n- UI/UX: \n- Manajer Proyek:  \n- QA: \n- Tester: ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
              ),

              SizedBox(height: 20),
              Text(
                'Dipublikasikan oleh:\n- Tim Publikasi Hoteloop',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
              ),

              SizedBox(height: 20),
              Text(
                'Diperiksa oleh:\n- Bu Hesti',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
