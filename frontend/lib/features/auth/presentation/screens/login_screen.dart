import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/auth_provider.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
         decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF7F9FC), Color(0xFFE8EAF6)],
            ),
         ),
         child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LogoWidget(size: 100),
                        const SizedBox(height: 16),
                        Text(
                          'SkillProof',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                         Text(
                          'Sign in to continue',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () async {
                              setState(() { _isLoading = true; });
                              try {
                                final auth = Provider.of<AuthProvider>(context, listen: false);
                                await auth.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                if (context.mounted && auth.isAuthenticated) {
                                  // Navigate based on role (unchanged logic)
                                  if (auth.user?.role == 'Employer') {
                                    Navigator.pushReplacementNamed(context, '/employer_dashboard');
                                  } else {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception:", "")}'))
                                  );
                                }
                              } finally {
                                if (mounted) setState(() { _isLoading = false; });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFF6C63FF),
                               foregroundColor: Colors.white,
                            ),
                            child: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text('New here? Create an account'),
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
}
