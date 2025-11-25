import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/providers/auth_provider.dart' as MyAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _initials = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<MyAuth.AuthProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = authProvider.userName;
        _emailController.text = authProvider.userEmail;
        _phoneController.text = authProvider.userPhone;
        if (_nameController.text.isNotEmpty) {
          _initials = _nameController.text.split(' ').map((e) => e[0]).take(2).join();
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    final authProvider = Provider.of<MyAuth.AuthProvider>(context, listen: false);

    if (user != null) {
      try {
        // Update Firestore with the correct field 'name'
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
        });

        // Reload data in provider to reflect changes throughout the app
        await authProvider.loadUserData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.green,
                content: Text('Profil berhasil diperbarui')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red,
                content: Text('Gagal menyimpan perubahan: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFF0A2A5E),
                child: Text(
                  _initials,
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Nama Lengkap"),
              ),
              const SizedBox(height: 6),
              _inputField(_nameController),

              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Email"),
              ),
              const SizedBox(height: 6),
              _inputField(_emailController, readOnly: true),

              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Nomor HP"),
              ),
              const SizedBox(height: 6),
              _inputField(_phoneController),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A2A5E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
