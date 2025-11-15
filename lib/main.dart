import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/customer_location_screen.dart';
import 'screens/auth/customer_account_screen.dart';
import 'screens/auth/customer_phone_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/edit_profile_screen.dart';
import 'screens/customer/add_payment_method_screen.dart';
import 'screens/customer/browse_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/orders_screen.dart';
import 'screens/customer/profile_screen.dart';
import 'screens/customer/notifications_screen.dart';
import 'screens/vendor/vendor_main_screen.dart';
import 'screens/vendor/products_screen.dart';
import 'screens/vendor/orders_screen.dart';
import 'screens/vendor/pos/pos_screen.dart';
import 'screens/vendor/profile_screen.dart';
import 'screens/vendor/add_product_screen.dart';
import 'screens/vendor/add_product_stepper_screen.dart';
import 'screens/vendor/test_stepper_screen.dart';
import 'screens/vendor/store_settings_screen.dart';
import 'screens/vendor/vendor_analytics_screen.dart';
import 'screens/vendor/help_and_support_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/auth/vendor_register_screen.dart';
import 'screens/auth/vendor_location_screen.dart';
import 'screens/auth/vendor_delivery_screen.dart';
import 'screens/customer/addresses_screen.dart';
import 'screens/customer/add_edit_address_screen.dart';
import 'test_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'services/supabase_test_service.dart';
import 'services/bucket_test_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    debugPrint('Firebase app name: ${Firebase.app().name}');

    // Test Firebase Storage connection
    await StorageTest.testStorageConnection();

    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    debugPrint('Supabase initialized: ${Supabase.instance.client.rest.url}');

    // Test Supabase Storage buckets
    await SupabaseTestService.testAllBuckets();

    // Test specific bucket creation
    await BucketTestService.testAllBuckets();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    rethrow;
  }

  runApp(const SmartMartApp());
}

class SmartMartApp extends StatelessWidget {
  const SmartMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()..loadData()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return GetMaterialApp(
            title: 'SmartMart',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            useInheritedMediaQuery: true,
            builder: (context, child) {
              final theme = Theme.of(context);
              return Stack(
                children: [
                  Container(color: Colors.white),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-0.8, -1),
                            end: const Alignment(0.8, 1),
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.08),
                              Colors.white.withOpacity(0.0),
                              theme.colorScheme.secondary.withOpacity(0.06),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (child != null) child,
                ],
              );
            },
            home: const SplashScreen(),
            getPages: [
              GetPage(name: '/splash', page: () => const SplashScreen()),
              GetPage(
                  name: '/onboarding', page: () => const OnboardingScreen()),
              GetPage(name: '/auth/login', page: () => const LoginScreen()),
              GetPage(
                  name: '/auth/role-selection',
                  page: () => const RoleSelectionScreen()),
              GetPage(
                  name: '/auth/register', page: () => const RegisterScreen()),
              GetPage(
                  name: '/auth/register/vendor',
                  page: () => const VendorRegisterScreen()),
              GetPage(
                  name: '/auth/register/vendor/location',
                  page: () => const VendorLocationScreen()),
              GetPage(
                  name: '/auth/register/vendor/delivery',
                  page: () => const VendorDeliveryScreen()),
              GetPage(
                  name: '/auth/register/customer/location',
                  page: () => const CustomerLocationScreen()),
              GetPage(
                  name: '/auth/register/customer/account',
                  page: () =>
                      CustomerAccountScreen(locationData: Get.arguments)),
              GetPage(
                  name: '/auth/register/customer/phone',
                  page: () => CustomerPhoneScreen(previousData: Get.arguments)),
              GetPage(
                  name: '/customer', page: () => const CustomerHomeScreen()),
              GetPage(
                  name: '/customer/edit-profile',
                  page: () => const CustomerEditProfileScreen()),
              GetPage(
                  name: '/customer/browse', page: () => const BrowseScreen()),
              GetPage(name: '/customer/cart', page: () => const CartScreen()),
              GetPage(
                  name: '/customer/orders',
                  page: () => const CustomerOrdersScreen()),
              GetPage(
                  name: '/customer/profile',
                  page: () => const CustomerProfileScreen()),
              GetPage(
                  name: '/customer/payment-methods',
                  page: () => const AddPaymentMethodScreen()),
              GetPage(
                  name: '/customer/notifications',
                  page: () => const NotificationsScreen()),
              GetPage(
                  name: '/customer/addresses',
                  page: () => const AddressesScreen()),
              GetPage(
                  name: '/customer/address/add',
                  page: () => const AddEditAddressScreen()),
              GetPage(
                  name: '/customer/address/edit',
                  page: () => AddEditAddressScreen(address: Get.arguments)),
              GetPage(name: '/vendor', page: () => const VendorMainScreen()),
              GetPage(
                  name: '/vendor/products', page: () => const ProductsScreen()),
              GetPage(
                  name: '/vendor/orders',
                  page: () => const VendorOrdersScreen()),
              GetPage(name: '/vendor/pos', page: () => const POSScreen()),
              GetPage(
                  name: '/vendor/profile',
                  page: () => const VendorProfileScreen()),
              GetPage(
                  name: '/vendor/store-settings',
                  page: () => const StoreSettingsScreen()),
              GetPage(
                  name: '/vendor/notifications',
                  page: () => const NotificationsScreen()),
              GetPage(
                  name: '/vendor/analytics',
                  page: () => const VendorAnalyticsScreen()),
              GetPage(
                  name: '/vendor/help-support',
                  page: () => const HelpAndSupportScreen()),
              GetPage(
                  name: '/vendor/add-product',
                  page: () => const AddProductScreen()),
              GetPage(
                  name: '/vendor/add-product-stepper',
                  page: () => const AddProductStepperScreen()),
              GetPage(
                  name: '/vendor/test-stepper',
                  page: () => const TestStepperScreen()),
              GetPage(
                  name: '/product/:id',
                  page: () =>
                      ProductDetailScreen(productId: Get.parameters['id']!)),
            ],
          );
        },
      ),
    );
  }
}
