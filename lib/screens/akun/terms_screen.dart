import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Syarat & Ketentuan Penggunaan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Selamat datang di FinTrack. Dengan menggunakan aplikasi kami, Anda setuju untuk terikat dengan syarat dan ketentuan berikut:',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSection(
                '1. Penggunaan Aplikasi',
                'Anda setuju untuk menggunakan aplikasi FinTrack hanya untuk tujuan yang sah dan sesuai dengan semua hukum yang berlaku. Anda bertanggung jawab penuh atas semua data transaksi yang Anda masukkan.',
              ),
              _buildSection(
                '2. Akun Pengguna',
                'Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda, termasuk password. Segala aktivitas yang terjadi di bawah akun Anda adalah tanggung jawab Anda.',
              ),
              _buildSection(
                '3. Privasi Data',
                'Kami menghargai privasi Anda. Pengumpulan dan penggunaan data pribadi diatur oleh Kebijakan Privasi kami. Kami tidak akan membagikan data keuangan pribadi Anda kepada pihak ketiga tanpa persetujuan Anda.',
              ),
              _buildSection(
                '4. Pembatasan Tanggung Jawab',
                'Aplikasi ini disediakan \'sebagaimana adanya\'. Kami tidak menjamin keakuratan atau kelengkapan data. FinTrack tidak bertanggung jawab atas kerugian finansial atau non-finansial yang mungkin timbul dari penggunaan aplikasi ini.',
              ),
               _buildSection(
                '5. Perubahan Ketentuan',
                'Kami dapat mengubah Syarat & Ketentuan ini dari waktu ke waktu. Perubahan akan berlaku efektif segera setelah diposting di aplikasi. Anda disarankan untuk meninjau halaman ini secara berkala.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(content, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 12),
      ],
    );
  }
}
