import 'package:flutter/material.dart';
import 'package:classet_admin/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  void _signIn() async {
    setState(() => isLoading = true);

    bool success = await authService.signIn(
      emailController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      // TODO: Navigate to Home Screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const Text('Password', style: TextStyle(fontSize: 16)),
            TextField(controller: passwordController, obscureText: false),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
