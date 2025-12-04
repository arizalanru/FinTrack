import 'package:flutter/material.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _service = TransactionService();
  bool isLoading = false;

  Future<String?> addTransaction({
    required double nominal,
    required String kategori,
    required String sumber,
    required DateTime tanggal,
    required String keterangan,
    required String type,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.addTransaction(
        nominal: nominal,
        kategori: kategori,
        sumber: sumber,
        tanggal: tanggal,
        keterangan: keterangan,
        type: type,
      );

      isLoading = false;
      notifyListeners();
      return null; // success → no error
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString(); // return the error message
    }
  }
}
