import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";
  String filter = "Semua tanggal";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchKeyword = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime? get _startDate {
    final now = DateTime.now();
    switch (filter) {
      case "Hari ini":
        return DateTime(now.year, now.month, now.day);
      case "1 minggu terakhir":
        return now.subtract(const Duration(days: 7));
      case "1 bulan terakhir":
        return now.subtract(const Duration(days: 30));
      default: // "Semua tanggal"
        return null;
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Filter Tanggal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Column(
                  children: [
                    _filterOption(setModalState, "Semua tanggal"),
                    _filterOption(setModalState, "Hari ini"),
                    _filterOption(setModalState, "1 minggu terakhir"),
                    _filterOption(setModalState, "1 bulan terakhir"),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2A5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Terapkan",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _filterOption(Function setModalState, String value) {
    return RadioListTile(
      value: value,
      groupValue: filter,
      activeColor: const Color(0xFF0A2A5E),
      title: Text(value),
      onChanged: (val) {
        setModalState(() => filter = val.toString());
        setState(() {}); // Update the main screen to rebuild with the new filter
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Base query
    Query query = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("transactions")
        .orderBy("tanggal", descending: true);

    // Apply date filter to the query
    if (_startDate != null) {
      query = query.where('tanggal', isGreaterThanOrEqualTo: _startDate);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // We use a separate StreamBuilder for the summary cards that might have a different date range in the future.
              StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(), // Use the filtered query
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildSummaryLoading();
                  }

                  final docs = snapshot.data!.docs;

                  double incomeTotal = 0;
                  double expenseTotal = 0;

                  for (var d in docs) {
                    final data = d.data() as Map<String, dynamic>;
                    if (data["type"] == "income") {
                      incomeTotal += (data["nominal"] as num).toDouble();
                    } else {
                      expenseTotal += (data["nominal"] as num).toDouble();
                    }
                  }

                  double saldo = incomeTotal - expenseTotal;

                  return _buildSummarySection(saldo, incomeTotal, expenseTotal);
                },
              ),
              const SizedBox(height: 16),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: query.snapshots(), // Use the same filtered query
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Belum ada transaksi",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      );
                    }

                    var docs = snapshot.data!.docs;

                    // Apply search keyword filter
                    if (_searchKeyword.isNotEmpty) {
                      docs = docs.where((doc) {
                        final t = doc.data() as Map<String, dynamic>;
                        final kategori = t['kategori'].toString().toLowerCase();
                        return kategori.contains(_searchKeyword.toLowerCase());
                      }).toList();
                    }

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text("Tidak ada transaksi yang cocok",
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final t = doc.data() as Map<String, dynamic>;
                        return _transactionTile(t);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLoading() {
    return Column(
      children: const [
        Text("Transaksi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text("Sisa uang kamu", style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(height: 4),
        CircularProgressIndicator(),
        SizedBox(height: 18),
        // You can add skeleton loaders for summary cards as well
      ],
    );
  }

  Widget _buildSummarySection(double saldo, double incomeTotal, double expenseTotal) {
    return Column(
      children: [
        const Text("Transaksi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("Sisa uang kamu", style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(locale: 'id', symbol: "Rp ")
              .format(saldo)
              .replaceAll(",00", ""),
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2A5E)),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _summaryCard("Pemasukan", incomeTotal, Colors.green),
            const SizedBox(width: 12),
            _summaryCard("Pengeluaran", expenseTotal, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Cari transaksi...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _openFilterSheet,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.filter_list),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              NumberFormat.currency(locale: 'id', symbol: "Rp ")
                  .format(amount)
                  .replaceAll(",00", ""),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> t) {
    final keterangan = t['keterangan'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEFEFEF),
            child: Icon(
              t["type"] == "income" ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t["kategori"],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                if (keterangan != null && keterangan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(keterangan,
                        style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ),
                Text("${t["sumber"]} • ${DateFormat('dd MMM yyyy').format((t["tanggal"] as Timestamp).toDate())}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
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
}
