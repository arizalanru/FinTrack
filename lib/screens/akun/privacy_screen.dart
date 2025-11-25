import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
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
                'Kebijakan Privasi FinTrack',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Privasi Anda penting bagi kami. Kebijakan ini menjelaskan jenis informasi yang kami kumpulkan dan bagaimana kami menggunakannya.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSection(
                '1. Informasi yang Kami Kumpulkan',
                'Kami mengumpulkan informasi yang Anda berikan saat mendaftar, seperti nama, alamat email, dan nomor telepon. Kami juga menyimpan data transaksi keuangan (pemasukan dan pengeluaran) yang Anda masukkan ke dalam aplikasi.',
              ),
              _buildSection(
                '2. Penggunaan Informasi',
                'Informasi Anda digunakan untuk menyediakan layanan inti aplikasi, termasuk menampilkan riwayat transaksi, laporan keuangan, dan mengelola akun Anda. Kami tidak akan pernah menjual atau membagikan data pribadi Anda kepada pihak ketiga untuk tujuan pemasaran.',
              ),
              _buildSection(
                '3. Keamanan Data',
                'Kami mengambil langkah-langkah keamanan yang wajar untuk melindungi informasi Anda dari akses, pengubahan, atau penghancuran yang tidak sah. Semua data ditransmisikan melalui koneksi terenkripsi (SSL) dan disimpan di server yang aman.',
              ),
              _buildSection(
                '4. Hak Anda',
                'Anda memiliki hak untuk mengakses, memperbaiki, atau menghapus data pribadi Anda kapan saja melalui pengaturan di dalam aplikasi.',
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
