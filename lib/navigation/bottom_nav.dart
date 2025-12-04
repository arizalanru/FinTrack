import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/transaksi/transaksi_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/akun/akun_screen.dart';
import '../screens/transaksi/add_transaction_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransaksiScreen(),
    SizedBox(),
    ReportScreen(),
    AkunScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF0A2A5E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            );
          },
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,        // Warna navbar putih
        elevation: 0,                         // Hilangkan shadow ungu
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0A2A5E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Transaction"),
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ""), // posisi untuk FAB
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
