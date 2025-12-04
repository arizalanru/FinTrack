import 'package:fintrack/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscureOld = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Password Successfully Changed.'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Old Password"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _isObscureOld,
                  decoration: _inputDecoration('Enter Old Password', () {
                    setState(() => _isObscureOld = !_isObscureOld);
                  }, _isObscureOld),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Old Password Cannot Be Empty.';
                    }
                    if (value.length < 6) {
                      return 'Old Password Must Be At Least 6 Characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("New Password"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _isObscureNew,
                  decoration: _inputDecoration('Enter New Password', () {
                    setState(() => _isObscureNew = !_isObscureNew);
                  }, _isObscureNew),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New Password Cannot Be Empty';
                    }
                    if (value.length < 6) {
                      return 'Password Minimum 6 Characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text("Confirm New Password"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isObscureConfirm,
                  decoration: _inputDecoration('Confirm New Password', () {
                    setState(() => _isObscureConfirm = !_isObscureConfirm);
                  }, _isObscureConfirm),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Password Confirmation Does Not Match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2A5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Apply Changes",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String hint, VoidCallback toggleObscure, bool isObscure) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
        onPressed: toggleObscure,
      ),
    );
  }
}
