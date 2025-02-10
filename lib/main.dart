import 'package:flutter/material.dart';
import 'package:classet_admin/core/navigation/app_router.dart'; // Import your app router

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Classet Admin',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: appRouter, // Connect GoRouter here
    );
  }
}
