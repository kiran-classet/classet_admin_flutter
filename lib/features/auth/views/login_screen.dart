import 'package:classet_admin/core/providers/filter_provider.dart';
import 'package:classet_admin/features/auth/providers/login_state.dart';
import 'package:classet_admin/features/auth/providers/admin_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:classet_admin/config/cognitoAuthService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController(text: 'aauramana');
  final passwordController = TextEditingController(text: 'Classet@123');
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');
    if (savedEmail != null) {
      emailController.text = savedEmail;
    }
    if (savedPassword != null) {
      passwordController.text = savedPassword;
    }
  }

  _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  void _signIn() async {
    ref.read(loginProvider.notifier).setLoading(true);
    final authService = CognitoAuthService();

    try {
      final session = await authService.login(
        emailController.text,
        passwordController.text,
      );

      if (session != null) {
        final String username =
            session.getIdToken().payload['cognito:username'] as String;
        final accessToken = session.getAccessToken().getJwtToken();
        final refreshToken = session.getRefreshToken()?.getToken();
        final idToken = session.getIdToken().getJwtToken();
        ref.read(loginProvider.notifier).setSessionData(
              idToken!,
              refreshToken!,
              accessToken!,
            );

        _saveCredentials();

        if (mounted) {
          await ref.read(adminUserProvider.notifier).fetchUserDetails(username);

          // await ref.read(academicYearProvider.notifier).fetchAcademicYears();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Welcome to Classet'),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }
                  },
                ),
              ),
            );

            ref.read(loginProvider.notifier).setLoading(false);

            context.go('/mainscreen');
          }
        }
      } else {
        ref.read(loginProvider.notifier).setLoading(false);
        ref
            .read(loginProvider.notifier)
            .setError('Login failed. Please try again.');
        context.go('/'); // Ensure this matches your login route

        final prefs = await SharedPreferences.getInstance();
        String? savedEmail = prefs.getString('email');
        String? savedPassword = prefs.getString('password');

        // Invalidate the providers correctly
        // await MyAppProviders.invalidateAllProviders(ref);

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
        context.go('/login');
      }
    } catch (e) {
      ref.read(loginProvider.notifier).setLoading(false);
      ref.read(loginProvider.notifier).setError('Error: $e');

      // Clear filter state
      ref.read(filterStateProvider.notifier).clearAllFilters();

      final prefs = await SharedPreferences.getInstance();
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');

      // Invalidate the providers correctly
      // await MyAppProviders.invalidateAllProviders(ref);

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
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final adminUserState = ref.watch(adminUserProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 246, 247, 248),
              const Color.fromARGB(255, 246, 247, 249)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'SIGN IN',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please sign in with your account',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: const Text('Remember Me'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (loginState.isLoading || adminUserState.isLoading)
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 1, 131, 238),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 1, 131, 238),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '© MELUHA TECHNOLOGIES PRIVATE LIMITED',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
