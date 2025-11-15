import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/custom_icon.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/user.dart';
import 'vendor_home_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'pos/pos_screen.dart';
import 'profile_screen.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool _didCheckRole = false;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize screens
    _screens = [
      const VendorDashboardContent(),
      _VendorProductsContentWrapper(),
      _VendorOrdersContentWrapper(),
      _VendorPosContentWrapper(),
      _VendorProfileContentWrapper(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      debugPrint('VendorMainScreen: Initializing vendor main screen');

      if (authProvider.user != null) {
        debugPrint(
            'VendorMainScreen: Loading vendor data for user: ${authProvider.user!.id}');

        // Only load vendor products if not already loaded
        if (dataProvider.products.isEmpty) {
          await dataProvider.loadVendorProducts(authProvider.user!.id);
        }

        debugPrint(
            'VendorMainScreen: After loadVendorProducts, products count: ${dataProvider.products.length}');

        dataProvider.generateSalesData(authProvider.user!.id);
        dataProvider.generateVendorStats(authProvider.user!.id);
        debugPrint('VendorMainScreen: Vendor data loaded successfully');
      }

      // One-time role validation and potential navigation
      if (!_didCheckRole) {
        _didCheckRole = true;
        if (authProvider.user?.role != UserRole.vendor) {
          authProvider.switchToVendorRole().then((switched) {
            if (!switched && mounted) {
              Get.offAllNamed('/customer');
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            ),
          ),
          // Floating navbar overlay (does not block scrollable layout)
          Positioned(
            left: 12,
            right: 12,
            bottom: 0,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FloatingNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (index == _currentIndex) return;
                    setState(() => _currentIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  items: const [
                    NavItemData(
                      iconAsset: AppIcons.dashboard,
                      label: 'Dashboard',
                    ),
                    NavItemData(
                      iconAsset: AppIcons.products,
                      label: 'Products',
                    ),
                    NavItemData(
                      iconAsset: AppIcons.orders,
                      label: 'Orders',
                    ),
                    NavItemData(
                      iconAsset: AppIcons.pointOfSale,
                      label: 'POS',
                    ),
                    NavItemData(
                      iconAsset: AppIcons.profile,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Content wrapper widgets (without individual navbars)
class _VendorProductsContentWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Returns the ProductsScreen but we'll need to create a content-only version
    return const ProductsScreen();
  }
}

class _VendorOrdersContentWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const VendorOrdersScreen();
  }
}

class _VendorPosContentWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const POSScreen();
  }
}

class _VendorProfileContentWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const VendorProfileScreen();
  }
}
