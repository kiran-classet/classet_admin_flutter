import 'package:classet_admin/config/CognitoAuthService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:classet_admin/features/auth/views/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to handle logout and clear SharedPreferences
  Future<void> _logout(BuildContext context) async {
    // final CognitoAuthService authService = CognitoAuthService();
    // await authService.logout();
    context.go('/'); // Go back to the LoginScreen
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all data stored in SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Logout on button press
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to Classet Admin!')),
    );
  }
}
