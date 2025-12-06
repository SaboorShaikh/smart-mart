import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      iconPath: 'assets/animations/Shop_smart.gif',
      title: 'Shop Smart',
      description:
          'Connect with local vendors and discover exclusive deals near you.',
      color: const Color(0xFF53B175),
      isGif: true,
    ),
    OnboardingPage(
      iconPath: 'assets/animations/Sell_easy.gif',
      title: 'Sell Easy',
      description:
          'Manage your store, track sales, and grow your business with our vendor tools.',
      color: const Color(0xFF2563EB),
      isGif: true,
    ),
    OnboardingPage(
      iconPath: 'assets/icons/fast_delivery.png',
      title: 'Fast Delivery',
      description:
          'Quick and reliable delivery service to ensure your orders reach you fresh.',
      color: const Color(0xFFF59E0B),
      isGif: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    debugPrint('_nextPage called, currentPage: $_currentPage, totalPages: ${_pages.length}');
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('Navigating to login screen');
      Get.offAllNamed('/auth/login');
    }
  }

  void _skipOnboarding() {
    Get.offAllNamed('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next/Get Started Button
                  CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _nextPage,
                    width: double.infinity,
                    borderRadius: 24,
                    icon: _currentPage == _pages.length - 1
                        ? null
                        : const Icon(
                            Icons.arrow_forward,
                            size: 20,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration/GIF
              SizedBox(
                width: double.infinity,
                height: 280,
                child: page.isGif
                    ? Image.asset(
                        page.iconPath,
                        fit: BoxFit.contain,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(40),
                        child: Image.asset(
                          page.iconPath,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                page.title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF333333),
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                page.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF666666),
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String iconPath;
  final String title;
  final String description;
  final Color color;
  final bool isGif;

  OnboardingPage({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.color,
    this.isGif = false,
  });
}
