import 'package:classet_admin/core/utils/my_app_providers.dart';
import 'package:classet_admin/features/auth/providers/login_state.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await MyAppProviders.invalidateAllProviders(ref);
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    await prefs.clear();
    if (savedEmail != null) {
      await prefs.setString('email', savedEmail);
    }
    if (savedPassword != null) {
      await prefs.setString('password', savedPassword);
    }
    context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the access token from the provider
    final loginState = ref.watch(loginProvider);
    final accessToken =
        loginState.accessToken; // Access token from state management

    // Retrieve the ID token from SharedPreferences
    Future<String?> _getIdToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(
          'idToken'); // Assuming you stored the ID token with this key
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref), // Logout on button press
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _getIdToken(), // Fetch the ID token
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No ID Token found.'));
          } else {
            final idToken = snapshot.data; // ID token from local storage

            return Center(
                child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ID Token:\n$idToken',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Access Token:\n$accessToken',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ));
          }
        },
      ),
    );
  }
}
