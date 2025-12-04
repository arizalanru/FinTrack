import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/providers/auth_provider.dart' as MyAuth;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MyAuth.AuthProvider>(context);
    final user = FirebaseAuth.instance.currentUser!;
    final userName = auth.userName.isEmpty ? "User" : auth.userName;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ===== HEADER USER =====
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF0A2A5E),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, ${userName.split(' ').first}", 
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2A5E),
                        ),
                      ),
                      const Text(
                        "Let's manage your financial transactions!",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ===== SALDO & DOMPET (REFACTORED) =====
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('wallets').snapshots(),
                builder: (context, walletSnapshot) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('transactions').snapshots(),
                    builder: (context, transactionSnapshot) {
                      
                      if (walletSnapshot.connectionState == ConnectionState.waiting || transactionSnapshot.connectionState == ConnectionState.waiting) {
                        return _loadingCard();
                      }

                      // Calculate total initial balance from wallets
                      double totalInitialBalance = 0;
                      int walletCount = 0;
                      if (walletSnapshot.hasData) {
                        walletCount = walletSnapshot.data!.docs.length;
                        for (var doc in walletSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          totalInitialBalance += (data['balance'] as num).toDouble();
                        }
                      }

                      // Calculate income and expense from transactions
                      double income = 0;
                      double expense = 0;
                      if (transactionSnapshot.hasData) {
                        for (var doc in transactionSnapshot.data!.docs) {
                          final t = doc.data() as Map<String, dynamic>;
                          if (t["type"] == "income") {
                            income += (t["nominal"] as num).toDouble();
                          } else {
                            expense += (t["nominal"] as num).toDouble();
                          }
                        }
                      }

                      // Final, correct total saldo
                      double totalSaldo = totalInitialBalance + income - expense;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildExpenseCard(expense),
                          const SizedBox(height: 20),
                          const Text(
                              "Balance Amount & Your Wallets",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/wallet'),
                                  child: _infoCard(
                                    icon: Icons.account_balance_wallet,
                                    title: "Balance Amount",
                                    value: NumberFormat.currency(locale: 'id', symbol: "Rp ")
                                        .format(totalSaldo)
                                        .replaceAll(",00", ""),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/wallet'),
                                  child: _infoCard(
                                    icon: Icons.wallet,
                                    title: "Your Wallets",
                                    value: "$walletCount Wallets",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                "Expense Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildCategoryChart(user.uid),
              const SizedBox(height: 24),
              const Text(
                "Latest Transaction",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildRecentTransactions(user.uid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(double expense) {
    return Container(
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
            "This Months Expenses",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            NumberFormat.currency(locale: 'id', symbol: "Rp ")
                .format(expense)
                .replaceAll(",00", ""),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryChart(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .where('type', isEqualTo: 'expense')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _noTransactionBox("No Expenses Yet");
        }

        Map<String, double> categoryTotals = {};
        for (var d in snapshot.data!.docs) {
          final t = d.data() as Map<String, dynamic>;
          final nominal = (t["nominal"] as num).toDouble();
          final kategori = t["kategori"];
          categoryTotals[kategori] = (categoryTotals[kategori] ?? 0) + nominal;
        }

        final data = categoryTotals.entries
            .map((e) => _CategoryChart(e.key, e.value))
            .toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            series: <DoughnutSeries<_CategoryChart, String>>[
              DoughnutSeries<_CategoryChart, String>(
                dataSource: data,
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                innerRadius: '55%',
                radius: '75%',
                strokeWidth: 3,                      
                strokeColor: Colors.white,           
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                ),
                pointColorMapper: (d, index) {
                  final colors = [
                    const Color(0xFF062A61),
                    const Color(0xFF2C4F87),
                    const Color(0xFF567DB3),
                    const Color(0xFF8EB5D3),
                    const Color(0xFFC5DDF0),
                  ];
                  return colors[index % colors.length];
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions(String uid) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("transactions")
          .orderBy("tanggal", descending: true)
          .limit(7)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _noTransactionBox("No Transactions Yet");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final t = doc.data() as Map<String, dynamic>;
            return _transactionItem(t);
          }).toList(),
        );
      },
    );
  }

  Widget _loadingCard() => Container(
    padding: const EdgeInsets.all(20),
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFF0A2A5E),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const SizedBox(
      height: 150, // Adjusted height for the whole section
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    ),
  );

  Widget _infoCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0A2A5E)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  t["kategori"] ?? "Unknown",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(DateFormat('dd MMM yyyy', 'id_ID').format((t["tanggal"] as Timestamp).toDate())),
            ],
          ),
          Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: t["type"] == "income" ? "Rp " : "-Rp ",
            ).format(t["nominal"]).replaceAll(",00", ""),
            style: TextStyle(
              color: t["type"] == "income" ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noTransactionBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _CategoryChart {
  final String label;
  final double value;

  _CategoryChart(this.label, this.value);
}
