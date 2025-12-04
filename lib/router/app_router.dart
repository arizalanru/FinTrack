import 'package:fintrack/screens/akun/about_screen.dart';
import 'package:fintrack/screens/akun/change_password_screen.dart';
import 'package:fintrack/screens/akun/contact_screen.dart';
import 'package:fintrack/screens/akun/edit_profile_screen.dart';
import 'package:fintrack/screens/akun/privacy_screen.dart';
import 'package:fintrack/screens/akun/terms_screen.dart';
import 'package:fintrack/screens/wallet/add_wallet_screen.dart';
import 'package:fintrack/screens/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/screens/auth/login_screen.dart';
import 'package:fintrack/screens/auth/register_screen.dart';
import '../navigation/bottom_nav.dart';

// Helper function to create a smooth fade transition.
Route<dynamic> _smoothFadeRoute(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _smoothFadeRoute(const LoginScreen(), settings);

      case '/register':
        return _smoothFadeRoute(const RegisterScreen(), settings);

      case '/home':
        return _smoothFadeRoute(const BottomNav(), settings);

      case '/wallet':
        return _smoothFadeRoute(const WalletScreen(), settings);

      case '/add-wallet': // New route for adding a wallet
        return _smoothFadeRoute(const AddWalletScreen(), settings);

      case '/edit-profile':
        return _smoothFadeRoute(const EditProfileScreen(), settings);

      case '/change-password':
        return _smoothFadeRoute(const ChangePasswordScreen(), settings);

      case '/about':
        return _smoothFadeRoute(const AboutScreen(), settings);

      case '/terms':
        return _smoothFadeRoute(const TermsScreen(), settings);

      case '/privacy':
        return _smoothFadeRoute(const PrivacyScreen(), settings);

      case '/contact':
        return _smoothFadeRoute(const ContactScreen(), settings);

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route Not Found")),
          ),
        );
    }
  }
}
