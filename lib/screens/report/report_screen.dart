import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isExpense = true;
  String selectedPeriod = "1 Bulan Terakhir";

  DateTime get _startDate {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case "Hari Ini":
        return DateTime(now.year, now.month, now.day);
      case "7 Hari Terakhir":
        return now.subtract(const Duration(days: 7));
      case "2 Minggu Terakhir":
        return now.subtract(const Duration(days: 14));
      case "1 Bulan Terakhir":
        return now.subtract(const Duration(days: 30));
      case "1 Tahun Terakhir":
        return now.subtract(const Duration(days: 365));
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  void _openPeriodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) {
        return StatefulBuilder(builder: (context, setStateModal) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pilih Periode",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...["Hari Ini", "7 Hari Terakhir", "2 Minggu Terakhir", "1 Bulan Terakhir", "1 Tahun Terakhir"]
                    .map((p) => RadioListTile(
                          value: p,
                          groupValue: selectedPeriod,
                          activeColor: const Color(0xFF0A2A5E),
                          onChanged: (val) {
                            setStateModal(() => selectedPeriod = val.toString());
                            setState(() {});
                          },
                          title: Text(p),
                        )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2A5E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text("Terapkan",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("transactions")
        .where('tanggal', isGreaterThanOrEqualTo: _startDate)
        .orderBy("tanggal", descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final docs = snapshot.data!.docs;

              Map<String, double> expenseCategoryTotals = {};
              Map<String, double> incomeCategoryTotals = {};
              List<DocumentSnapshot> expenseTransactions = [];
              List<DocumentSnapshot> incomeTransactions = [];

              for (var doc in docs) {
                final t = doc.data() as Map<String, dynamic>;
                final type = t['type'];
                final category = t['kategori'] as String;
                final nominal = (t['nominal'] as num).toDouble();

                if (type == 'expense') {
                  expenseTransactions.add(doc);
                  expenseCategoryTotals[category] = (expenseCategoryTotals[category] ?? 0) + nominal;
                } else if (type == 'income') {
                  incomeTransactions.add(doc);
                  incomeCategoryTotals[category] = (incomeCategoryTotals[category] ?? 0) + nominal;
                }
              }

              final currentCategoryTotals = isExpense ? expenseCategoryTotals : incomeCategoryTotals;
              final currentTransactions = isExpense ? expenseTransactions : incomeTransactions;
              final chartData = currentCategoryTotals.entries.map((e) => _ChartData(e.key, e.value)).toList();
              final total = currentCategoryTotals.values.fold(0.0, (sum, item) => sum + item);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildTypeToggle(),
                  const SizedBox(height: 20),
                  _buildChartCard(total, chartData),
                  const SizedBox(height: 16),
                  _buildTransactionList(currentTransactions),
                ]),
              );
            }),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Report Keuanganmu",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: _openPeriodSheet,
                icon: const Icon(Icons.calendar_month, size: 28))
          ],
        ),
        const SizedBox(height: 6),
        Center(
          child: Column(children: [
            const Text("Periode",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text(selectedPeriod,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2A5E))),
          ]),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildHeader(),
           const SizedBox(height: 16),
          _buildTypeToggle(),
          const Expanded(
            child: Center(
              child: Text(
                "Tidak ada transaksi pada periode ini.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isExpense = true),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isExpense ? const Color(0xFF0A2A5E) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text("Pengeluaran",
                  style: TextStyle(
                    color: isExpense ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isExpense = false),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: !isExpense ? const Color(0xFF0A2A5E) : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text("Pendapatan",
                  style: TextStyle(
                    color: !isExpense ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildChartCard(double total, List<_ChartData> chartData) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: [
        Text(isExpense ? "Total Pengeluaran" : "Total Pendapatan",
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(
          NumberFormat.currency(locale: 'id', symbol: "Rp ")
              .format(total)
              .replaceAll(",00", ""),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (chartData.isNotEmpty)
          SizedBox(
            height: 250,
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              series: <DoughnutSeries>[
                DoughnutSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data.label,
                  yValueMapper: (data, _) => data.value,
                  innerRadius: '55%',
                  radius: '75%',
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                  pointColorMapper: (_, index) {
                    List<Color> colors = [
                      const Color(0xFF062A61),
                      const Color(0xFF2C4F87),
                      const Color(0xFF567DB3),
                      const Color(0xFF8EB5D3),
                      const Color(0xFFC5DDF0),
                    ];
                    return colors[index % colors.length];
                  },
                )
              ],
            ),
          )
        else
          const SizedBox(
            height: 250,
            child: Center(child: Text("Tidak ada data untuk ditampilkan")),
          ),
      ]),
    );
  }

  Widget _buildTransactionList(List<DocumentSnapshot> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpense ? "Detail Pengeluaran" : "Detail Pemasukan",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (transactions.isNotEmpty)
          Column(
            children: transactions.map((doc) {
              final t = doc.data() as Map<String, dynamic>;
              return _transactionTile(t);
            }).toList(),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text("Tidak ada transaksi.",
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
      ],
    );
  }

  Widget _transactionTile(Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFEFF3F8),
              child: Icon(
                  t["type"] == 'income'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: const Color(0xFF0A2A5E))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t["kategori"],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    DateFormat('dd MMM yyyy', 'id_ID')
                        .format((t["tanggal"] as Timestamp).toDate()),
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
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

class _ChartData {
  final String label;
  final double value;

  _ChartData(this.label, this.value);
}
