import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _bgController;
  late Animation<double> _bgShift;
  bool _locationRationaleHandled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOutCubic));

    // Subtle animated background shift
    _bgController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _bgShift = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start animation
    _animationController.forward();

    // First-launch location rationale + permission
    await _ensureLocationPermissionWithRationale();

    // Load current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Load current user without emitting during build
    await authProvider.loadCurrentUser(emit: false);

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    // Ensure at least one frame has fully completed and Navigator has size
    try {
      await WidgetsBinding.instance.endOfFrame;
    } catch (_) {}

    if (!mounted) return;
    // Navigate based on authentication status (no setState involved)
    if (authProvider.isAuthenticated) {
      final user = authProvider.user!;
      if (user.role.toString().split('.').last == 'vendor') {
        Get.offAllNamed('/vendor');
      } else {
        Get.offAllNamed('/customer');
      }
    } else {
      Get.offAllNamed('/onboarding');
    }
  }

  Future<void> _ensureLocationPermissionWithRationale() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('smartmart_location_rationale_shown') ?? false;

    // To prevent startup crashes on some devices, skip showing a dialog here.
    // Just request permission silently and record that the rationale was shown.
    if (!shown && mounted && !_locationRationaleHandled) {
      _locationRationaleHandled = true;
      await prefs.setBool('smartmart_location_rationale_shown', true);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + _bgShift.value, -1),
                end: Alignment(1 + _bgShift.value, 1),
                colors: [
                  theme.colorScheme.primary.withOpacity(0.95),
                  theme.colorScheme.primary.withOpacity(0.75),
                  theme.colorScheme.secondary.withOpacity(0.65),
                ],
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo tile
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // App name with subtle shimmer
                      _ShimmerText(
                        text: 'Smart Mart',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Smart Marketplace',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 42),
                      // Thin progress line
                      SizedBox(
                        width: 140,
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const _ShimmerText({required this.text, this.style});

  @override
  State<_ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<_ShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

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
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white,
                Colors.white.withOpacity(0.2),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}
