import 'package:classet_admin/core/utils/my_app_providers.dart';
import 'package:flutter/material.dart';
import 'package:classet_admin/core/navigation/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(
      observers: [CustomProviderObserver()], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Classet Admin',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
