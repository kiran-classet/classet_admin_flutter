import 'package:go_router/go_router.dart';
import 'package:classet_admin/features/auth/views/login_screen.dart';
import 'package:classet_admin/features/dashboard/views/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
