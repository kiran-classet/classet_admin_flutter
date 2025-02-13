import 'package:classet_admin/core/utils/my_app_providers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');

      // Invalidate the providers correctly
      await MyAppProviders.invalidateAllProviders(ref);

      // Clear all preferences
      await prefs.clear();

      // Save the email and password if they exist
      if (savedEmail != null) {
        await prefs.setString('email', savedEmail);
      }
      if (savedPassword != null) {
        await prefs.setString('password', savedPassword);
      }

      // Navigate to the login screen (ensure your GoRouter setup is correct)
      context.go('/'); // Ensure this matches your login route
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: Center(
        child: Text('Home screen'),
      ),
    );
  }
}
