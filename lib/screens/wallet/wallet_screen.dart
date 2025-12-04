import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  // Helper function to get icon for each wallet type
  IconData _getWalletIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return Icons.account_balance;
      case 'e-wallet':
        return Icons.account_balance_wallet;
      case 'Cash':
        return Icons.money;
      default:
        return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Manage Wallet",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // First stream: get all wallets
        stream: FirebaseFirestore.instance
            .collection('users').doc(user.uid)
            .collection('wallets')
            .snapshots(),
        builder: (context, walletSnapshot) {
          if (walletSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!walletSnapshot.hasData || walletSnapshot.data!.docs.isEmpty) {
            return _buildEmptyWallet(context);
          }

          final wallets = walletSnapshot.data!.docs;
          
          // Second stream: get all transactions to calculate balances
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users').doc(user.uid)
                .collection('transactions')
                .snapshots(),
            builder: (context, transactionSnapshot) {

              Map<String, double> transactionAdjustments = {};
              if (transactionSnapshot.hasData) {
                 for (var doc in transactionSnapshot.data!.docs) {
                    final t = doc.data() as Map<String, dynamic>;
                    final walletName = t['sumber'] as String;
                    final amount = (t['nominal'] as num).toDouble();
                    final type = t['type'] as String;

                    if (type == 'income') {
                      transactionAdjustments[walletName] = (transactionAdjustments[walletName] ?? 0) + amount;
                    } else {
                      transactionAdjustments[walletName] = (transactionAdjustments[walletName] ?? 0) - amount;
                    }
                 }
              }

              double totalSaldo = 0;
              List<Map<String, dynamic>> walletDetails = [];

              for (var wallet in wallets) {
                final w = wallet.data() as Map<String, dynamic>;
                final initialBalance = (w['balance'] as num).toDouble();
                final walletName = w['name'] as String;
                final currentBalance = initialBalance + (transactionAdjustments[walletName] ?? 0);
                
                totalSaldo += currentBalance;
                walletDetails.add({
                  'name': walletName,
                  'type': w['type'] as String,
                  'balance': currentBalance,
                });
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildTotalSaldoCard(totalSaldo),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Wallet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: walletDetails.length,
                      itemBuilder: (context, index) {
                        final detail = walletDetails[index];
                        return _walletTile(
                          detail['name'],
                          detail['type'],
                          detail['balance'],
                        );
                      },
                    ),
                  ),
                  _buildAddWalletButton(context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTotalSaldoCard(double totalSaldo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2A5E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Balance Amount",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(locale: 'id', symbol: "Rp ")
                .format(totalSaldo)
                .replaceAll(",00", ""),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _walletTile(String name, String type, double balance) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFE6EDFF),
          child: Icon(_getWalletIcon(type), color: const Color(0xFF0A2A5E)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(type),
        trailing: Text(
          NumberFormat.currency(locale: 'id', symbol: "Rp ")
              .format(balance)
              .replaceAll(",00", ""),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAddWalletButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/add-wallet');
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Wallet"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A2A5E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWallet(BuildContext context) {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("You Dont Have Any Wallet Yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          _buildAddWalletButton(context),
        ],
      ),
    );
  }
}
