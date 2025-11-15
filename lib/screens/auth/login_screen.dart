import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint(
        'Login attempt - Email: "$email", Password length: ${password.length}');
    debugPrint('Email controller text: "${_emailController.text}"');
    debugPrint(
        'Password controller text length: ${_passwordController.text.length}');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.login(
      email,
      password,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      final user = authProvider.user!;
      debugPrint('Login successful - User role: ${user.role}');
      if (user.role.toString().split('.').last == 'vendor') {
        debugPrint('Navigating to vendor screen');
        Get.offAllNamed('/vendor');
      } else {
        debugPrint('Navigating to customer screen');
        Get.offAllNamed('/customer');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Login failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header
              Text(
                'Welcome to SmartMart',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Sign in to your account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Login Form
              CustomCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      CustomInput(
                        label: 'Email',
                        hint: 'Enter your email',
                        value: _emailController.text,
                        onChanged: (value) {
                          setState(() {
                            _emailController.text = value;
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        prefixIcon: Icon(
                          LucideIcons.mail,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        errorText: _emailController.text.isNotEmpty &&
                                !_emailController.text.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      CustomInput(
                        label: 'Password',
                        hint: 'Enter your password',
                        value: _passwordController.text,
                        onChanged: (value) {
                          setState(() {
                            _passwordController.text = value;
                          });
                        },
                        obscureText: true,
                        prefixIcon: Icon(
                          LucideIcons.lock,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        errorText: _passwordController.text.isNotEmpty &&
                                _passwordController.text.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      CustomButton(
                        text: 'Sign In',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register Link
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        debugPrint(
                            'Signup button tapped - using GetX navigation');
                        Get.toNamed('/auth/role-selection');
                        debugPrint('GetX navigation completed');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Sign up',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
