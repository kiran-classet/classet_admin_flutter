import 'package:classet_admin/core/utils/my_app_providers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await MyAppProviders.invalidateAllProviders(ref);
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    await prefs.clear();
    context.go('/');
    if (savedEmail != null) {
      await prefs.setString('email', savedEmail);
    }
    if (savedPassword != null) {
      await prefs.setString('password', savedPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref), // Logout on button press
          ),
        ],
      ),
      body: Center(
        child: Text('PRofile screen'),
      ),
    );
  }
}
