import 'package:classet_admin/features/dashboard/views/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:classet_admin/features/auth/views/login_screen.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
}

final GoRouter router = GoRouter(
  initialLocation: Routes.login,
  routes: [
    GoRoute(path: Routes.login, builder: (context, state) => LoginScreen()),
    GoRoute(path: Routes.home, builder: (context, state) => HomeScreen()),
  ],
);
