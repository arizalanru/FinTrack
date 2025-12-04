import 'package:flutter/material.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  String selectedType = "Tunai";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text("Tambah Dompet",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pilih Jenis Dompet",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  typeButton("Cash"),
                  typeButton("Bank"),
                  typeButton("E-Wallet"),
                ],
              ),

              const SizedBox(height: 20),
              field("Wallet Name", "E.g. : BCA, DANA, Tunai"),
              field("Balance Amount", "Rp 0"),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2A5E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  child: const Text("Save", style: TextStyle(fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget typeButton(String title) {
    bool selected = selectedType == title;
    return GestureDetector(
      onTap: () => setState(() => selectedType = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0xFFDDEBFF) : Colors.grey.shade200,
          border: Border.all(
              color: selected ? const Color(0xFF0A2A5E) : Colors.transparent,
              width: 2),
        ),
        child: Text(title,
            style: TextStyle(
                color: selected ? const Color(0xFF0A2A5E) : Colors.grey)),
      ),
    );
  }

  Widget field(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
