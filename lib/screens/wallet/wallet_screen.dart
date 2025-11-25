import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  // Helper function to get icon for each wallet source
  IconData _getWalletIcon(String source) {
    switch (source.toLowerCase()) {
      case 'bca':
        return Icons.account_balance;
      case 'dana':
        return Icons.account_balance_wallet;
      case 'gopay':
        return Icons.payment; // Using a generic payment icon
      default:
        return Icons.credit_card; // Default icon
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Dompet Saya",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("transactions")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Belum ada transaksi untuk menampilkan dompet."));
          }

          final docs = snapshot.data!.docs;

          // Calculate total balance and balance per source
          double totalSaldo = 0;
          Map<String, double> walletBalances = {};

          for (var doc in docs) {
            final t = doc.data() as Map<String, dynamic>;
            final nominal = (t['nominal'] as num).toDouble();
            final type = t['type'] as String;
            final source = t['sumber'] as String;

            if (type == 'income') {
              totalSaldo += nominal;
              walletBalances[source] = (walletBalances[source] ?? 0) + nominal;
            } else if (type == 'expense') {
              totalSaldo -= nominal;
              walletBalances[source] = (walletBalances[source] ?? 0) - nominal;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2A5E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Saldo Kamu",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        NumberFormat.currency(locale: 'id', symbol: "Rp ")
                            .format(totalSaldo)
                            .replaceAll(",00", ""),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // List of Wallets
                const Text(
                  "Rincian Dompet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (walletBalances.isEmpty)
                  const Center(child: Text("Tidak ada dompet ditemukan."))
                else
                  Column(
                    children: walletBalances.entries.map((entry) {
                      final source = entry.key;
                      final balance = entry.value;
                      return _walletTile(source, balance);
                    }).toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _walletTile(String source, double balance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEFF3F8),
            child: Icon(_getWalletIcon(source), color: const Color(0xFF0A2A5E)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                 Text(
                  "Saldo",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'id', symbol: "Rp ")
                .format(balance)
                .replaceAll(",00", ""),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2A5E),
            ),
          ),
        ],
      ),
    );
  }
}
