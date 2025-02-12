import 'package:classet_admin/features/auth/providers/login_state.dart';
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false; // State for the Remember Me checkbox

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load saved credentials if available
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

  // Save credentials if Remember Me is checked
  _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
    } else {
      // Clear saved credentials if not remembering
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  void _signIn() async {
    ref.read(loginProvider.notifier).setLoading(true); // Set loading state

    final authService = CognitoAuthService();

    try {
      final session = await authService.login(
        emailController.text,
        passwordController.text,
      );

      ref.read(loginProvider.notifier).setLoading(false); // Reset loading state

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

        // Save credentials if Remember Me is checked
        _saveCredentials();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        context.go('/mainscreen');
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

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider); // Access the login state

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'SIGN IN',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'please sign in with your account',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
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
                        _rememberMe = !_rememberMe; // Toggle the checkbox state
                      });
                    },
                    child: const Text('Remember Me'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (loginState.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        const Color.fromARGB(255, 1, 131, 238), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0), // Vertical padding
                    minimumSize:
                        const Size(200, 50), // Minimum width and height
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18, // Font size
                      fontWeight: FontWeight.bold, // Bold text
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
    );
  }
}
