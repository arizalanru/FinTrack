import 'package:fintrack/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to get the AuthProvider instance
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Get initials for the avatar
        final initials = auth.userName.isNotEmpty
            ? auth.userName.split(' ').map((e) => e[0]).take(2).join()
            : "";

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profile",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  /// CARD PROFILE
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF0A2A5E),
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.userName, // Dynamic user name
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              auth.userEmail, // Dynamic user email
                              style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// MENU LIST - Using named routes
                  _menuItem(context, Icons.person, "Edit Profile", '/edit-profile'),
                  // These routes need to be created if you want to navigate
                  _menuItem(context, Icons.lock, "Change Password", '/change-password'),
                  _menuItem(context, Icons.account_balance_wallet, "Wallet", '/wallet'),
                  _menuItem(context, Icons.info, "About Us", '/about'),
                  _menuItem(context, Icons.description, "Terms & Conditions", '/terms'),
                  _menuItem(context, Icons.privacy_tip, "Privacy", '/privacy'),
                  _menuItem(context, Icons.email, "Contact", '/contact'),

                  const SizedBox(height: 20),

                  /// LOGOUT BUTTON
                  InkWell(
                    onTap: () {
                      // Use the provider to logout
                      auth.logout();
                      // The AuthWrapper will automatically handle navigation
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 12),
                          Text("Logout",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String routeName) {
    return InkWell(
      onTap: () {
        // Use named routes for navigation consistency
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0A2A5E)),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
