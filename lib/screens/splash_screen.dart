import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _panelController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _panelHeightAnimation;
  bool _locationRationaleHandled = false;
  bool _loadingComplete = false;

  // Color constants
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color subtitleGray = Color(0xFF4A4A4A);
  static const Color panelGray = Color(0xFFF2F2F2);
  static const Color blurOverlay = Color(0x4DFFFFFF); // White with 30% opacity
  static const Color white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    
    // Fade animation for top content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Panel slide-up animation
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _panelHeightAnimation = Tween<double>(
      begin: 0.4, // 40% of screen
      end: 1.0, // Full screen
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeInOutCubic,
    ));

    _fadeController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // First-launch location rationale + permission
    await _ensureLocationPermissionWithRationale();

    // Load current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadCurrentUser(emit: false);

    // Mark loading as complete
    if (mounted) {
      setState(() {
        _loadingComplete = true;
      });

      // Start panel expansion animation
      await _panelController.forward();

      // Small delay before navigation
      await Future.delayed(const Duration(milliseconds: 300));

      // Ensure at least one frame has fully completed
      try {
        await WidgetsBinding.instance.endOfFrame;
      } catch (_) {}

      if (!mounted) return;

      // Navigate based on authentication status
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
  }

  Future<void> _ensureLocationPermissionWithRationale() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('smartmart_location_rationale_shown') ?? false;

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
    _fadeController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          // Top Section (60% of screen initially) - Branding
          AnimatedBuilder(
            animation: _panelHeightAnimation,
            builder: (context, child) {
              // Panel starts at 40% (0.4) → top is 60% (0.6)
              // Panel ends at 100% (1.0) → top is 0% (0.0)
              final screenHeight = MediaQuery.of(context).size.height;
              final topHeight = screenHeight * (1.0 - _panelHeightAnimation.value);
              
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topHeight,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    color: white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Icon
                          Image.asset(
                            'assets/animations/Logo_animation.gif',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          // App Name
                          Text(
                            'SmartMart',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Subtitle
                          Text(
                            'Local Marketplace. Smarter Shopping.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: subtitleGray,
                              height: 1.5,
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

          // Bottom Sliding Panel (40% of screen)
          AnimatedBuilder(
            animation: _panelHeightAnimation,
            builder: (context, child) {
              final panelHeight = MediaQuery.of(context).size.height * 
                  _panelHeightAnimation.value;

              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: panelHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: panelGray,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_panelHeightAnimation.value < 0.99 ? 24 : 0),
                      topRight: Radius.circular(_panelHeightAnimation.value < 0.99 ? 24 : 0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Frosted blur overlay
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(_panelHeightAnimation.value < 0.99 ? 24 : 0),
                            topRight: Radius.circular(_panelHeightAnimation.value < 0.99 ? 24 : 0),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: blurOverlay,
                            ),
                          ),
                        ),
                      ),
                      
                      // Thin top border
                      if (_panelHeightAnimation.value < 0.99)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            color: blurOverlay,
                          ),
                        ),

                      // Bottom sheet handle
                      if (_panelHeightAnimation.value < 0.99 && !_loadingComplete)
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                      // Shimmer effect on panel (loading preview)
                      if (!_loadingComplete)
                        Positioned.fill(
                          child: _ShimmerPanel(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Shimmer effect for the bottom panel
class _ShimmerPanel extends StatefulWidget {
  @override
  State<_ShimmerPanel> createState() => _ShimmerPanelState();
}

class _ShimmerPanelState extends State<_ShimmerPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            color: Colors.white.withOpacity(0.1),
          ),
        );
      },
    );
  }
}
