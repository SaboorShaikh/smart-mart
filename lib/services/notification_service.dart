import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/frosted_notification_banner.dart';

class NotificationService {
  static OverlayEntry? _currentOverlay;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static void showFrostedNotification({
    required String message,
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove existing notification if any
    dismiss();

    // Use GetX overlay system which is more reliable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BuildContext? context;
      
      // Try GetX context first (most reliable for GetMaterialApp)
      try {
        if (Get.context != null) {
          context = Get.context;
          debugPrint('NotificationService: Using GetX context');
        }
      } catch (e) {
        debugPrint('NotificationService: GetX context not available: $e');
      }
      
      // Fallback to navigator key
      if (context == null && _navigatorKey?.currentContext != null) {
        context = _navigatorKey!.currentContext;
        debugPrint('NotificationService: Using navigator key context');
      }

      if (context == null) {
        debugPrint('NotificationService: No context available - retrying in 500ms');
        // Retry after a longer delay
        Future.delayed(const Duration(milliseconds: 500), () {
          showFrostedNotification(
            message: message,
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            textColor: textColor,
            duration: duration,
          );
        });
        return;
      }

      try {
        final overlay = Overlay.of(context);
        
        _currentOverlay = OverlayEntry(
          builder: (context) => FrostedNotificationBanner(
            message: message,
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            textColor: textColor,
            duration: duration,
            onDismiss: dismiss,
          ),
        );

        overlay.insert(_currentOverlay!);
        debugPrint('NotificationService: Notification shown successfully');
      } catch (e, stackTrace) {
        debugPrint('NotificationService: Error showing notification: $e');
        debugPrint('NotificationService: Stack trace: $stackTrace');
        // Retry once more
        Future.delayed(const Duration(milliseconds: 500), () {
          showFrostedNotification(
            message: message,
            title: title,
            icon: icon,
            backgroundColor: backgroundColor,
            textColor: textColor,
            duration: duration,
          );
        });
      }
    });
  }

  static void showSuccess({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    showFrostedNotification(
      message: message,
      title: title ?? 'Success',
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  static void showError({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    showFrostedNotification(
      message: message,
      title: title ?? 'Error',
      icon: Icons.error,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  static void showInfo({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    showFrostedNotification(
      message: message,
      title: title ?? 'Info',
      icon: Icons.info,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }

  static void showProductAdded(String productName) {
    showFrostedNotification(
      message: 'Successfully added product: $productName',
      title: 'Product Added',
      icon: Icons.add_shopping_cart,
      backgroundColor: Colors.green,
    );
  }

  static void showProductDeleted(String productName) {
    showFrostedNotification(
      message: 'Successfully deleted product: $productName',
      title: 'Product Deleted',
      icon: Icons.delete,
      backgroundColor: Colors.orange,
    );
  }

  static void showProductUpdated(String productName) {
    showFrostedNotification(
      message: 'Successfully updated product: $productName',
      title: 'Product Updated',
      icon: Icons.update,
      backgroundColor: Colors.blue,
    );
  }

  static void showAddedToCart(String productName) {
    showFrostedNotification(
      message: '$productName added to cart!',
      title: 'Added to Cart',
      icon: Icons.shopping_cart,
      backgroundColor: Colors.green,
    );
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

