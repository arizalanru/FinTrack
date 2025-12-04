import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Contact Us'),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildContactCard(
              'Office Address',
              'Jalan Teknologi No. 1, Kota Cerdas, Indonesia',
              Icons.location_on,
            ),
            _buildContactCard(
              'Email Support',
              'support@fintrack.app',
              Icons.email,
            ),
            _buildContactCard(
              'Phone',
              '+62 21 1234 5678',
              Icons.phone,
            ),
             _buildContactCard(
              'Website',
              'www.fintrack.app',
              Icons.web,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String title, String subtitle, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF0A2A5E),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
