import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

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
      await loadUserData(); // Load data on every auth state change
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

  // Smarter function to load and sync data
  Future<void> loadUserData() async {
    if (_user == null) return;
    try {
      final userDocRef = _db.collection("users").doc(_user!.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        _userName = data["name"] ?? "";
        _userPhone = data["phone"] ?? "";

        // Sync logic: Firebase Auth is the source of truth for the email.
        final authEmail = _user!.email ?? "";
        final firestoreEmail = data["email"] ?? "";

        if (authEmail.isNotEmpty && authEmail != firestoreEmail) {
          // If emails don't match, update Firestore with the verified email from Auth
          await userDocRef.update({'email': authEmail});
          _userEmail = authEmail;
        } else {
          _userEmail = firestoreEmail;
        }
      }
    } catch (e) {
      debugPrint("Error loading/syncing user data: $e");
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

  Future<String?> register(
    String name,
    String phone,
    String email,
    String password,
  ) async {
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
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return 'Password lama salah.';
      if (e.code == 'weak-password') return 'Password baru terlalu lemah.';
      return 'Terjadi kesalahan: ${e.message}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Corrected and safer email update logic
  Future<String?> updateEmail({
    required String newEmail,
    required String password,
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
      password: password,
    );
    try {
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);
      return null; // Success - Let user know to check their email
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Password Anda salah.';
      }
      if (e.code == 'email-already-in-use') {
        return 'Email ini sudah digunakan oleh akun lain.';
      }
      if (e.code == 'invalid-email') {
        return 'Format email tidak valid.';
      }
      return 'Terjadi kesalahan: ${e.message}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
