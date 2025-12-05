import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Animated Logo
              _AnimatedLogo(
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 24),

              // Header
              Text(
                'Welcome Back',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Log in to continue.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF666666),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    CustomInput(
                      label: 'Email Address',
                      hint: 'example@gmail.com',
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
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 12),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Navigate to forgot password screen
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    CustomButton(
                      text: 'Log In',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OR Separator
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFE0E0E0),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: const Color(0xFFE0E0E0),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Social Login Buttons
              // Google Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Google login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/google.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Facebook Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Facebook login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/facebook.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Facebook',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF666666),
                      fontSize: 14,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      debugPrint(
                          'Signup button tapped - using GetX navigation');
                      Get.toNamed('/auth/role-selection');
                      debugPrint('GetX navigation completed');
                    },
                    child: Text(
                      'Sign Up',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  final double width;
  final double height;

  const _AnimatedLogo({
    required this.width,
    required this.height,
  });

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _tilt;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.94, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _tilt = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _tilt.value,
          child: Transform.scale(
            scale: _scale.value,
            child: ClipOval(
              child: Image.asset(
                'assets/icons/logo_bg_removed.png',
                width: widget.width,
                height: widget.height,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
