import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  // Removed unused private fields to silence analyzer warnings.

  Future<void> addTransaction({
    required double nominal,
    required String kategori,
    required String sumber,
    required DateTime tanggal,
    required String keterangan,
    required String type,
  }) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .add({
          "nominal": nominal,
          "kategori": kategori,
          "sumber": sumber,
          "tanggal": tanggal,
          "createdAt": DateTime.now(),
          "keterangan": keterangan,
          "type": type,
        });
  }
}
