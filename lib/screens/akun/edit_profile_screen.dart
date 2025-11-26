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
  final _formKey = GlobalKey<FormState>();
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

  void _loadUserData() {
    final authProvider = Provider.of<MyAuth.AuthProvider>(context, listen: false);
    setState(() {
      _nameController.text = authProvider.userName;
      _emailController.text = authProvider.userEmail;
      _phoneController.text = authProvider.userPhone;
      if (authProvider.userName.isNotEmpty) {
        _initials = authProvider.userName.split(' ').map((e) => e[0]).take(2).join();
      }
    });
  }

  // Reverted to the simpler save logic
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    
    setState(() => _isLoading = true);

    final authProvider = Provider.of<MyAuth.AuthProvider>(context, listen: false);

    try {
      await FirebaseFirestore.instance.collection('users').doc(authProvider.user!.uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
      });

      await authProvider.loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
       if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                  child: Text(_initials, style: const TextStyle(fontSize: 28, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "Nama Lengkap"),
                const SizedBox(height: 14),
                // Email field is now read-only
                _buildTextField(_emailController, "Email", readOnly: true),
                const SizedBox(height: 14),
                _buildTextField(_phoneController, "Nomor HP"),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2A5E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text("Simpan Perubahan", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: (value) {
             if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
          },
          decoration: InputDecoration(
            filled: true,
            // Change color if read-only to give a visual cue
            fillColor: readOnly ? Colors.grey.shade200 : const Color(0xFFF2F2F2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
