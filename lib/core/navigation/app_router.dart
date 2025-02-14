import 'package:classet_admin/features/dashboard/views/home_screen.dart';
import 'package:classet_admin/core/navigation/main_screen.dart';
import 'package:classet_admin/features/settings/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classet_admin/features/auth/views/login_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return FutureBuilder<bool>(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == true) {
              return MainScreen(); // Use MainScreen here
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) =>
          HomeScreen(), // MainScreen handles navigation
    ),
    GoRoute(
      path: '/mainscreen',
      builder: (context, state) =>
          MainScreen(), // MainScreen handles navigation
    ),
    GoRoute(
      path: '/setting',
      builder: (context, state) =>
          SettingsScreen(), // MainScreen handles navigation
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          LoginScreen(), // MainScreen handles navigation
    ),
  ],
);

Future<bool> _checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final idToken = prefs.getString('idToken');
  return idToken != null;
}
