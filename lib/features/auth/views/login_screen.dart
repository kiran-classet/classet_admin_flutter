import 'package:classet_admin/features/auth/providers/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:classet_admin/config/cognitoAuthService.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider); // Access the login state
    final emailController = TextEditingController(text: 'aauadmin');
    final passwordController = TextEditingController(text: "Classet@123");
    bool _isPasswordVisible = false;

    void _signIn() async {
      ref.read(loginProvider.notifier).setLoading(true); // Set loading state

      final authService = CognitoAuthService();

      try {
        final session = await authService.login(
          emailController.text,
          passwordController.text,
        );

        ref
            .read(loginProvider.notifier)
            .setLoading(false); // Reset loading state

        if (session != null) {
          // Assuming session contains idToken, refreshToken, and accessToken
          final accessToken = session.getAccessToken().getJwtToken();
          final refreshToken = session.getRefreshToken()?.getToken();
          final idToken = session.getIdToken().getJwtToken();
          ref.read(loginProvider.notifier).setSessionData(
                idToken!, // Replace with actual data
                refreshToken!, // Replace with actual data
                accessToken!, // Replace with actual session data
              );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
          context.go('/home');
        } else {
          ref
              .read(loginProvider.notifier)
              .setError('Login failed. Please try again.');
        }
      } catch (e) {
        ref.read(loginProvider.notifier).setLoading(false);
        ref.read(loginProvider.notifier).setError('Error: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email', style: TextStyle(fontSize: 16)),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const Text('Password', style: TextStyle(fontSize: 16)),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    _isPasswordVisible = !_isPasswordVisible;
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (loginState.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Login'),
              ),
              if (loginState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    loginState.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
