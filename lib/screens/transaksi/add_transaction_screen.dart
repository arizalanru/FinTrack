import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final List<String> expenseCategories = [
    'Food & Drinks',
    'Shopping',
    'Transportation',
    'Entertainment',
    'Bills',
    'Health',
    'Others',
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Bonus',
    'Investment',
    'Others',
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
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Add Transaction",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSwitch(),
            const SizedBox(height: 20),
            _buildAmountCard(),
            const SizedBox(height: 20),
            const Text("Select Category"),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            const Text("Select Wallet"),
            const SizedBox(height: 8),
            _buildWalletDropdown(user.uid),
            const SizedBox(height: 16),
            const Text("Date"),
            const SizedBox(height: 8),
            _buildDatePicker(),
            const SizedBox(height: 16),
            const Text("Notes"),
            const SizedBox(height: 8),
            _buildNoteField(),
            const SizedBox(height: 20),
            _buildSaveButton(transactionProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSwitch() {
    return Container(
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
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: isExpense
                      ? const Color(0xFF0A2A5E)
                      : Colors.transparent,
                ),
                child: Text(
                  "Expense",
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
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: !isExpense
                      ? const Color(0xFF0A2A5E)
                      : Colors.transparent,
                ),
                child: Text(
                  "Income",
                  style: TextStyle(
                    color: !isExpense ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Amount"),
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
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(),
      hint: const Text("Choose category"),
      initialValue: selectedCategory,
      items: (isExpense ? expenseCategories : incomeCategories)
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) => setState(() => selectedCategory = value),
    );
  }

  Widget _buildWalletDropdown(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('wallets')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Failed to load wallets');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyWalletDropdown();
        }

        List<DropdownMenuItem<String>> walletItems = snapshot.data!.docs.map((
          doc,
        ) {
          final walletName = doc['name'] as String;
          return DropdownMenuItem(value: walletName, child: Text(walletName));
        }).toList();

        return DropdownButtonFormField<String>(
          decoration: _inputDecoration(),
          hint: const Text("Choose wallet"),
          initialValue: selectedWallet,
          items: walletItems,
          onChanged: (value) => setState(() => selectedWallet = value),
        );
      },
    );
  }

  Widget _buildEmptyWalletDropdown() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/add-wallet');
      },
      child: InputDecorator(
        decoration: _inputDecoration().copyWith(hintText: 'No wallets found'),
        child: const Text(
          'Tap to add a new wallet',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
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
            Text(DateFormat("dd MMMM yyyy").format(selectedDate)),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        hintText: "Add a note (optional)",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSaveButton(TransactionProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (_amountController.text.isEmpty ||
              selectedCategory == null ||
              selectedWallet == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please fill out all fields")),
            );
            return;
          }

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
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result ?? "An error occurred")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A2A5E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: provider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Add",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  );
}
