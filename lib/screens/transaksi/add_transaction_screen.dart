import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? selectedCategory;
  String? selectedWallet;
  DateTime selectedDate = DateTime.now();

  final List<String> dummyWallets = ['BCA', 'DANA', 'GOPAY', 'Lainnya'];

  final List<String> expenseCategories = [
    'Makanan & Minuman',
    'Belanja',
    'Transportasi',
    'Hiburan',
    'Tagihan',
    'Kesehatan',
    'Lainnya',
  ];

  final List<String> incomeCategories = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Lainnya',
  ];

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Tambah Transaksi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ===== SWITCH TAB =====
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        isExpense = true;
                        selectedCategory = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: isExpense ? const Color(0xFF0A2A5E) : Colors.transparent,
                        ),
                        child: Text(
                          "Pengeluaran",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isExpense ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        isExpense = false;
                        selectedCategory = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: isExpense ? Colors.transparent : const Color(0xFF0A2A5E),
                        ),
                        child: Text(
                          "Pendapatan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isExpense ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ===== CARD INPUT FORM =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// NOMINAL
                  const Text("Nominal"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: "Rp ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text("Pilih Kategori"),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              decoration: inputStyle(),
              hint: const Text("Pilih kategori"),
              value: selectedCategory,
              items: (isExpense ? expenseCategories : incomeCategories)
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),

            const SizedBox(height: 16),
            const Text("Pilih Sumber Keuangan"),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              decoration: inputStyle(),
              hint: const Text("Pilih sumber"),
              value: selectedWallet,
              items: dummyWallets
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => selectedWallet = value),
            ),

            const SizedBox(height: 16),
            const Text("Tanggal"),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat("dd/MM/yyyy").format(selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("Keterangan"),

            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Tambahkan keterangan (opsional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_amountController.text.isEmpty ||
                      selectedCategory == null ||
                      selectedWallet == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Harap isi semua data")),
                    );
                    return;
                  }

                  final provider = Provider.of<TransactionProvider>(context, listen: false);

                  String? result = await provider.addTransaction(
                    nominal: double.parse(_amountController.text.replaceAll('.', '')),
                    kategori: selectedCategory!,
                    sumber: selectedWallet!,
                    tanggal: selectedDate,
                    keterangan: _noteController.text,
                    type: isExpense ? "expense" : "income",
                  );

                  if (result == null && mounted) {
                    Navigator.pop(context);
                  } else if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar( // CORRECTED THIS LINE
                      SnackBar(content: Text(result ?? "Terjadi kesalahan"))
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2A5E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: transactionProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Tambah", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputStyle() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  );
}
