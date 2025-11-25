import 'package:fintrack/screens/akun/about_screen.dart';
import 'package:fintrack/screens/akun/change_password_screen.dart';
import 'package:fintrack/screens/akun/contact_screen.dart';
import 'package:fintrack/screens/akun/edit_profile_screen.dart';
import 'package:fintrack/screens/akun/privacy_screen.dart';
import 'package:fintrack/screens/akun/terms_screen.dart';
import 'package:fintrack/screens/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/screens/auth/login_screen.dart';
import 'package:fintrack/screens/auth/register_screen.dart';
import '../navigation/bottom_nav.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const BottomNav());

      case '/wallet':
        return MaterialPageRoute(builder: (_) => const WalletScreen());

      case '/edit-profile':
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case '/change-password':
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case '/about':
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      case '/terms':
        return MaterialPageRoute(builder: (_) => const TermsScreen());

      case '/privacy':
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());

      case '/contact':
        return MaterialPageRoute(builder: (_) => const ContactScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route Not Found")),
          ),
        );
    }
  }
}
