import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                'FinTrack Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your privacy is important to us. This policy explains the types of information we collect and how we use it.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildSection(
                '1. Information We Collect',
                'We collect information you provide when registering, such as name, email address, and phone number. We also store financial transaction data (income and expenses) that you enter into the application.'
                ,
              ),
              _buildSection(
                '2. Use of Information',
                'Your information is used to provide the core services of the application, including displaying transaction history, financial reports, and managing your account. We will never sell or share your personal data with third parties for marketing purposes.',
              ),

              _buildSection(
                '3. Data Security',
                'We take reasonable security measures to protect your information from unauthorized access, alteration, or destruction. All data is transmitted through encrypted (SSL) connections and stored on secure servers.',
              ),

              _buildSection(
                '4. Your Rights',
                'You have the right to access, correct, or delete your personal data at any time through the settings within the application.',
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
