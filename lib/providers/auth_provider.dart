import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  bool _isAuth = false;
  bool get isAuthenticated => _isAuth;

  bool _isLoadingInitial = true;
  bool get isLoadingInitial => _isLoadingInitial;

  bool isLoading = false;

  String _userName = "";
  String get userName => _userName;

  String _userPhone = "";
  String get userPhone => _userPhone;

  String _userEmail = "";
  String get userEmail => _userEmail;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await loadUserData();
      _isAuth = true;
    } else {
      _isAuth = false;
      _userName = "";
      _userPhone = "";
      _userEmail = "";
    }
    if (_isLoadingInitial) {
      _isLoadingInitial = false;
    }
    notifyListeners();
  }

  Future<void> loadUserData() async {
    if (_user == null) return;
    try {
      final userDoc = await _db.collection("users").doc(_user!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _userName = data["name"] ?? "";
        _userPhone = data["phone"] ?? "";
        _userEmail = data["email"] ?? "";
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String name, String phone, String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection("users").doc(credential.user!.uid).set({
        "uid": credential.user!.uid,
        "name": name,
        "phone": phone,
        "email": email,
        "createdAt": DateTime.now(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isLoading = true;
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      isLoading = false;
      notifyListeners();
      return "Tidak ada pengguna yang sedang login.";
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      if (e.code == 'wrong-password') {
        return 'Password lama salah.';
      } else if (e.code == 'weak-password') {
        return 'Password baru terlalu lemah.';
      } else {
        return 'Terjadi kesalahan: ${e.message}';
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
