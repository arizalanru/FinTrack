import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Terms & Condition'),
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
                'Terms & Conditions of Use',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome to FinTrack. By using our application, you agree to be bound by the following terms and conditions:',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSection(
                '1. Penggunaan Aplikasi',
                'Anda setuju untuk menggunakan aplikasi FinTrack hanya untuk tujuan yang sah dan sesuai dengan semua hukum yang berlaku. Anda bertanggung jawab penuh atas semua data transaksi yang Anda masukkan.',
              ),
              _buildSection(
                '2. User Account',
                'You are responsible for maintaining the confidentiality of your account information, including your password. Any activity that occurs under your account is your responsibility.',
              ),
              _buildSection(
                '3. Data Privacy',
                'We respect your privacy. The collection and use of personal data are governed by our Privacy Policy. We will not share your personal financial data with third parties without your consent.',
              ),
              _buildSection(
                '4. Limitation of Liability',
                'This application is provided "as is". We do not guarantee the accuracy or completeness of the data. FinTrack is not responsible for any financial or non-financial losses that may arise from the use of this application.',
              ),
              _buildSection(
                '5. Changes to Terms',
                'We may modify these Terms & Conditions from time to time. Changes will take effect immediately once posted in the application. You are advised to review this page periodically.',
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
