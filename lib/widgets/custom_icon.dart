import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;
  final BoxFit fit;

  const CustomIcon({
    super.key,
    required this.assetPath,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
      fit: fit,
      // Ensure high quality rendering in release builds
      filterQuality: FilterQuality.high,
      // Prevent pixelation by not forcing specific cache dimensions
      isAntiAlias: true,
      // Ensure proper color blending
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      // Add error handling for release builds
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.error_outline,
          size: size,
          color: color ?? Colors.red,
        );
      },
    );
  }
}

// Icon constants for easy access
class AppIcons {
  // Navigation icons (using available icons only)
  static const String home = 'assets/icons/home.png';
  static const String dashboard = 'assets/icons/dashboard.png';
  static const String products = 'assets/icons/products.png';
  static const String cart = 'assets/icons/cart.png';
  static const String orders = 'assets/icons/orders.png';
  static const String profile = 'assets/icons/profile_avatar.png';

  // Feature icons
  static const String search = 'assets/icons/search.png';
  static const String notification = 'assets/icons/notification.png';
  static const String location = 'assets/icons/location.png';
  static const String map = 'assets/icons/map_icon.png';
  static const String add = 'assets/icons/add.png';
  static const String edit = 'assets/icons/edit_icon.png';
  static const String camera = 'assets/icons/camera.png';

  // Menu icons
  static const String help = 'assets/icons/help.png';
  static const String about = 'assets/icons/about.png';
  static const String paymentMethods = 'assets/icons/payment_methods.png';
  static const String promo = 'assets/icons/promo.png';
  static const String pointOfSale = 'assets/icons/point_of_sale.png';

  // Analytics icons
  static const String totalSale = 'assets/icons/total_sale.png';
  static const String averageOrderValue =
      'assets/icons/average_order_value.png';

  // Store and Analytics icons (now available)
  static const String store = 'assets/icons/store settings.png';
  static const String analytics = 'assets/icons/analytics.png';

  // Fallback icons (using available icons for missing ones)
  static const String logout =
      'assets/icons/help.png'; // Using help as logout fallback
  static const String tag =
      'assets/icons/promo.png'; // Using promo as tag fallback
  static const String mapPin =
      'assets/icons/location.png'; // Using location as mapPin fallback
  static const String creditCard =
      'assets/icons/payment_methods.png'; // Using payment_methods as creditCard fallback
  static const String info =
      'assets/icons/about.png'; // Using about as info fallback
  static const String bell =
      'assets/icons/notification.png'; // Using notification as bell fallback
}
