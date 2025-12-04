import 'package:fintrack/navigation/bottom_nav.dart';
import 'package:fintrack/providers/auth_provider.dart';
import 'package:fintrack/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // While checking the auth state, show a loading screen
    if (authProvider.isLoadingInitial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If authenticated, go to the main app, otherwise to login
    if (authProvider.isAuthenticated) {
      return const BottomNav();
    } else {
      return const LoginScreen();
    }
  }
}
