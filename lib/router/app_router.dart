import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/customer_location_screen.dart';
import '../screens/auth/customer_account_screen.dart';
import '../screens/auth/customer_phone_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/browse_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/orders_screen.dart';
import '../screens/customer/profile_screen.dart';
import '../screens/customer/edit_profile_screen.dart';
import '../screens/customer/notifications_screen.dart';
import '../screens/vendor/vendor_main_screen.dart';
import '../screens/vendor/products_screen.dart';
import '../screens/vendor/add_product_screen.dart';
import '../screens/vendor/add_product_stepper_screen.dart';
import '../screens/vendor/test_stepper_screen.dart';
import '../screens/vendor/orders_screen.dart';
import '../screens/vendor/pos/pos_screen.dart';
import '../screens/vendor/profile_screen.dart';
import '../screens/vendor/store_settings_screen.dart';
import '../screens/vendor/vendor_analytics_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final user = authProvider.user;
      final path = state.uri.toString();

      debugPrint(
          'Router redirect - Path: $path, Authenticated: $isAuthenticated');

      // Allow splash and onboarding without authentication so we can initialize state
      if (path == '/splash' || path == '/onboarding') {
        debugPrint('Router redirect - Allowing splash/onboarding');
        return null;
      }

      // If not authenticated, allow all auth routes without any redirects
      if (!isAuthenticated) {
        if (path.startsWith('/auth')) {
          debugPrint('Router redirect - Allowing auth route: $path');
          return null;
        }
        debugPrint('Router redirect - Redirecting to login');
        return '/auth/login';
      }

      // If authenticated, redirect based on role
      if (isAuthenticated && user != null) {
        if (path == '/auth/login' ||
            path == '/auth/register' ||
            path == '/auth/role-selection' ||
            path == '/splash' ||
            path == '/onboarding') {
          final redirectPath = user.role.toString().split('.').last == 'vendor'
              ? '/vendor'
              : '/customer';
          debugPrint(
              'Router redirect - Authenticated user redirecting to: $redirectPath');
          return redirectPath;
        }
      }

      debugPrint('Router redirect - No redirect needed');
      return null;
    },
    routes: [
      // Splash and Onboarding
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: '/auth',
        redirect: (context, state) => '/auth/login',
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          // Customer multi-step register flow
          GoRoute(
            path: 'register/customer/location',
            builder: (context, state) => const CustomerLocationScreen(),
          ),
          GoRoute(
            path: 'register/customer/account',
            builder: (context, state) => CustomerAccountScreen(
              locationData: state.extra as Map<String, dynamic>?,
            ),
          ),
          GoRoute(
            path: 'register/customer/phone',
            builder: (context, state) => CustomerPhoneScreen(
              previousData: state.extra as Map<String, dynamic>?,
            ),
          ),
          GoRoute(
            path: 'role-selection',
            builder: (context, state) => const RoleSelectionScreen(),
          ),
        ],
      ),

      // Customer routes
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerHomeScreen(),
        routes: [
          GoRoute(
            path: 'browse',
            builder: (context, state) => const BrowseScreen(),
          ),
          GoRoute(
            path: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const CustomerOrdersScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const CustomerProfileScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            builder: (context, state) => const CustomerEditProfileScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
        ],
      ),

      // Vendor routes
      GoRoute(
        path: '/vendor',
        builder: (context, state) => const VendorMainScreen(),
        routes: [
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: 'add-product',
            builder: (context, state) => const AddProductScreen(),
          ),
          GoRoute(
            path: 'add-product-stepper',
            builder: (context, state) => const AddProductStepperScreen(),
          ),
          GoRoute(
            path: 'test-stepper',
            builder: (context, state) => const TestStepperScreen(),
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const VendorOrdersScreen(),
          ),
          GoRoute(
            path: 'pos',
            builder: (context, state) => const POSScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const VendorProfileScreen(),
          ),
          GoRoute(
            path: 'store-settings',
            builder: (context, state) => const StoreSettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const VendorAnalyticsScreen(),
          ),
        ],
      ),

      // Product detail (shared)
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
    ],
  );
}
