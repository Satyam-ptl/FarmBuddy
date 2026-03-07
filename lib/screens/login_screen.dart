import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'app_shell.dart';
import 'register_farmer_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('unable to log in') || lower.contains('invalid')) {
      return 'Invalid username or password.';
    }
    if (lower.contains('connection') || lower.contains('socketexception')) {
      return 'Cannot reach server. Check your internet connection.';
    }
    return 'Login failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo / branding
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.agriculture, size: 44, color: Color(0xFF2ECC71)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'AgroAssist',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to manage your farm',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),

                      // Error banner
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Username is required';
                          if (v.trim().length < 3) return 'At least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password field with toggle
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Register link
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(builder: (_) => const RegisterFarmerScreen()),
                                ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                            children: const [
                              TextSpan(text: 'New farmer? '),
                              TextSpan(
                                text: 'Create account',
                                style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
