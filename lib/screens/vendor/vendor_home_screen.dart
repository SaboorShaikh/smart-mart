import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/custom_icon.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/user.dart';
import '../customer/notifications_screen.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen>
    with TickerProviderStateMixin {
  bool _didCheckRole = false;
  final GlobalKey _notifIconKey = GlobalKey();
  OverlayEntry? _notifOverlay;
  late final AnimationController _notifAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<double> _notifScale = CurvedAnimation(
    parent: _notifAnimController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      debugPrint('VendorHomeScreen: Initializing vendor home screen');

      if (authProvider.user != null) {
        debugPrint(
            'VendorHomeScreen: Loading vendor data for user: ${authProvider.user!.id}');

        // Only load vendor products if not already loaded
        if (dataProvider.products.isEmpty) {
          await dataProvider.loadVendorProducts(authProvider.user!.id);
        }

        // Debug: Check if products were loaded
        debugPrint(
            'VendorHomeScreen: After loadVendorProducts, products count: ${dataProvider.products.length}');

        dataProvider.generateSalesData(authProvider.user!.id);
        dataProvider.generateVendorStats(authProvider.user!.id);
        debugPrint('VendorHomeScreen: Vendor data loaded successfully');
      }

      // One-time role validation and potential navigation
      if (!_didCheckRole) {
        _didCheckRole = true;
        if (authProvider.user?.role != UserRole.vendor) {
          authProvider.switchToVendorRole().then((switched) {
            if (!switched) {
              Get.offAllNamed('/customer');
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _removeNotificationsPopup(animate: false);
    _notifAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);

    // Role validation is handled once in initState to avoid scheduling during build

    final user = authProvider.user?.role == UserRole.vendor &&
            authProvider.user is Vendor
        ? authProvider.user as Vendor
        : null;
    final vendorOrders =
        dataProvider.orders.where((o) => o.vendorId == user?.id).toList();
    final vendorPOSTransactions = dataProvider.posTransactions
        .where((t) => t.vendorId == user?.id)
        .toList();
    final vendorNotifications =
        dataProvider.notifications.where((n) => n.userId == user?.id).toList();
    final loginNotifications = vendorNotifications
        .where((n) => n.type.toString().split('.').last == 'login')
        .toList();
    final productNotifications = vendorNotifications
        .where((n) => ['product_added', 'product_deleted', 'product_discount']
            .contains(n.type.toString().split('.').last))
        .toList();

    final totalRevenue = vendorOrders
        .where((order) => order.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.total);

    // Counts computed from realtime stream below for accuracy

    final today = DateTime.now();
    final todayOrders = vendorOrders
        .where((o) =>
            o.createdAt.day == today.day &&
            o.createdAt.month == today.month &&
            o.createdAt.year == today.year)
        .length;

    final todayRevenue = vendorOrders
        .where((o) =>
            o.status == 'completed' &&
            o.createdAt.day == today.day &&
            o.createdAt.month == today.month &&
            o.createdAt.year == today.year)
        .fold(0.0, (sum, order) => sum + order.total);

    final unreadNotifications =
        vendorNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              key: _notifIconKey,
              onTap: _toggleNotificationsPopup,
              child: Stack(
                children: [
                  CustomIcon(
                    assetPath: AppIcons.notification,
                    size: 24,
                  ),
                  if (unreadNotifications > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Text(
                  'Welcome back, ${user?.shopName ?? 'Vendor'}!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Grid (Active Products from DataProvider)
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    final providerProducts = dataProvider.products;
                    final streamedTotal = providerProducts.length;
                    final streamedActive =
                        providerProducts.where((p) => p.isActive).length;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isSmallScreen ? 2 : 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isSmallScreen ? 1.2 : 1.5,
                          children: [
                            _buildStatCard(
                              theme,
                              title: 'Total Revenue',
                              value: '₨${totalRevenue.toStringAsFixed(0)}',
                              icon: CustomIcon(
                                assetPath: AppIcons.totalSale,
                                size: 28,
                              ),
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              theme,
                              title: 'Today\'s Orders',
                              value: todayOrders.toString(),
                              icon: CustomIcon(
                                assetPath: AppIcons.orders,
                                size: 28,
                              ),
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              theme,
                              title: 'Today\'s Revenue',
                              value: '₨${todayRevenue.toStringAsFixed(0)}',
                              icon: CustomIcon(
                                assetPath: AppIcons.averageOrderValue,
                                size: 28,
                              ),
                              color: Colors.orange,
                            ),
                            _buildStatCard(
                              theme,
                              title: 'Active Products',
                              value: '$streamedActive/$streamedTotal',
                              icon: CustomIcon(
                                assetPath: AppIcons.products,
                                size: 28,
                              ),
                              color: Colors.purple,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildQuickActionItem(
                      theme,
                      icon: CustomIcon(
                        assetPath: AppIcons.add,
                        size: 24,
                      ),
                      title: 'Add Product',
                      onTap: () => Get.toNamed('/vendor/add-product-stepper'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      theme,
                      icon: CustomIcon(
                        assetPath: AppIcons.products,
                        size: 24,
                      ),
                      title: 'Manage Products',
                      onTap: () => Get.toNamed('/vendor/products'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickActionItem(
                      theme,
                      icon: CustomIcon(
                        assetPath: AppIcons.orders,
                        size: 24,
                      ),
                      title: 'View Orders',
                      onTap: () => Get.toNamed('/vendor/orders'),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionItem(
                      theme,
                      icon: CustomIcon(
                        assetPath: AppIcons.pointOfSale,
                        size: 24,
                      ),
                      title: 'POS System',
                      onTap: () => Get.toNamed('/vendor/pos'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (vendorOrders.isEmpty &&
                    vendorPOSTransactions.isEmpty &&
                    loginNotifications.isEmpty &&
                    productNotifications.isEmpty)
                  _buildEmptyActivity(theme)
                else
                  Column(
                    children: [
                      // Show login notifications first (security alerts)
                      if (loginNotifications.isNotEmpty)
                        ...loginNotifications
                            .take(2)
                            .map((notification) => _buildActivityItem(
                                  theme,
                                  title: notification.title,
                                  subtitle: notification.message,
                                  time: _formatTime(notification.createdAt),
                                  icon: Icons.security,
                                )),
                      // Show product activity notifications
                      if (productNotifications.isNotEmpty)
                        ...productNotifications.take(3).map((notification) =>
                            _buildActivityItem(
                              theme,
                              title: notification.title,
                              subtitle: notification.message,
                              time: _formatTime(notification.createdAt),
                              icon: _getProductActivityIcon(
                                  notification.type.toString().split('.').last),
                            )),
                      if (vendorOrders.isNotEmpty)
                        ...vendorOrders
                            .take(3)
                            .map((order) => _buildActivityItem(
                                  theme,
                                  title:
                                      'New Order #${order.id.substring(0, 8)}',
                                  subtitle:
                                      '${order.items.length} items - ₨${order.total.toStringAsFixed(0)}',
                                  time: _formatTime(order.createdAt),
                                  icon: Icons.shopping_cart,
                                )),
                      if (vendorPOSTransactions.isNotEmpty)
                        ...vendorPOSTransactions
                            .take(3)
                            .map((transaction) => _buildActivityItem(
                                  theme,
                                  title: 'POS Transaction',
                                  subtitle:
                                      '${transaction.items.length} items - ₨${transaction.total.toStringAsFixed(0)}',
                                  time: _formatTime(transaction.createdAt),
                                  icon: Icons.point_of_sale,
                                )),
                    ],
                  ),
                const SizedBox(height: 100), // Space for floating nav bar
              ],
            ),
          ),
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
                  currentIndex: 0,
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        // Already on dashboard
                        break;
                      case 1:
                        Get.toNamed('/vendor/products');
                        break;
                      case 2:
                        Get.toNamed('/vendor/orders');
                        break;
                      case 3:
                        Get.toNamed('/vendor/pos');
                        break;
                      case 4:
                        Get.toNamed('/vendor/profile');
                        break;
                    }
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

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required Widget icon,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final valueFontSize = cardWidth * 0.18;
        final titleFontSize = cardWidth * 0.09;
        final iconSize = cardWidth * 0.24;

        return Container(
          padding: EdgeInsets.all(cardWidth * 0.08),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: IconTheme(
                      data: IconThemeData(color: color, size: iconSize),
                      child: icon,
                    ),
                  ),
                  SizedBox(width: cardWidth * 0.08),
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: valueFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: cardWidth * 0.08),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: titleFontSize,
                ),
                maxLines: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(
    ThemeData theme, {
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyActivity(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent orders and activities will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  IconData _getProductActivityIcon(String notificationType) {
    switch (notificationType) {
      case 'product_added':
        return Icons.add_circle;
      case 'product_deleted':
        return Icons.delete;
      case 'product_discount':
        return Icons.local_offer;
      default:
        return Icons.inventory;
    }
  }

  void _toggleNotificationsPopup() {
    if (_notifOverlay != null) {
      _removeNotificationsPopup();
      return;
    }

    // Mark all notifications as read when opening popup
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (authProvider.user != null) {
      dataProvider.markAllNotificationsAsRead(authProvider.user!.id);
    }

    // Position popup relative to the notification icon so it appears to expand from it
    final RenderBox? box =
        _notifIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset iconPos = box.localToGlobal(Offset.zero);
    final Size iconSize = box.size;

    _notifOverlay = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          // Blur backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeNotificationsPopup,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.12)),
              ),
            ),
          ),
          // Popup panel anchored to the notification icon, biased to the left so it clearly belongs to the bell
          Positioned(
            top: iconPos.dy + iconSize.height + 4,
            left: () {
              const double popupWidth = 260;
              // Place popup so its right edge is slightly left of the icon center
              final double iconCenterX = iconPos.dx + (iconSize.width / 2);
              double left =
                  iconCenterX - popupWidth + 8; // 8px overlap towards bell
              final screenW = MediaQuery.of(context).size.width;
              // Clamp to screen with margins
              if (left < 12) left = 12;
              if (left + popupWidth > screenW - 12) {
                left = screenW - popupWidth - 12;
              }
              return left;
            }(),
            child: ScaleTransition(
              scale: _notifScale,
              alignment: Alignment.topRight,
              child: _VendorNotificationsPopup(
                width: 260,
                onClose: _removeNotificationsPopup,
              ),
            ),
          ),
        ],
      );
    });

    Overlay.of(context).insert(_notifOverlay!);
    _notifAnimController.forward(from: 0);
  }

  void _removeNotificationsPopup({bool animate = true}) {
    if (_notifOverlay == null) return;
    if (animate) {
      _notifAnimController.reverse().whenComplete(() {
        _notifOverlay?.remove();
        _notifOverlay = null;
      });
    } else {
      _notifOverlay?.remove();
      _notifOverlay = null;
    }
  }
}

// Content-only widget for use in PageView (no navbar)
class VendorDashboardContent extends StatefulWidget {
  const VendorDashboardContent({super.key});

  @override
  State<VendorDashboardContent> createState() => _VendorDashboardContentState();
}

class _VendorDashboardContentState extends State<VendorDashboardContent>
    with TickerProviderStateMixin {
  final GlobalKey _notifIconKey = GlobalKey();
  OverlayEntry? _notifOverlay;
  late final AnimationController _notifAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<double> _notifScale = CurvedAnimation(
    parent: _notifAnimController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void dispose() {
    _removeNotificationsPopup(animate: false);
    _notifAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);

    final user = authProvider.user?.role == UserRole.vendor &&
            authProvider.user is Vendor
        ? authProvider.user as Vendor
        : null;
    final vendorOrders =
        dataProvider.orders.where((o) => o.vendorId == user?.id).toList();
    final vendorPOSTransactions = dataProvider.posTransactions
        .where((t) => t.vendorId == user?.id)
        .toList();
    final vendorNotifications =
        dataProvider.notifications.where((n) => n.userId == user?.id).toList();
    final loginNotifications = vendorNotifications
        .where((n) => n.type.toString().split('.').last == 'login')
        .toList();
    final productNotifications = vendorNotifications
        .where((n) => ['product_added', 'product_deleted', 'product_discount']
            .contains(n.type.toString().split('.').last))
        .toList();

    final totalRevenue = vendorOrders
        .where((order) => order.status == 'completed')
        .fold(0.0, (sum, order) => sum + order.total);

    final today = DateTime.now();
    final todayOrders = vendorOrders
        .where((o) =>
            o.createdAt.day == today.day &&
            o.createdAt.month == today.month &&
            o.createdAt.year == today.year)
        .length;

    final todayRevenue = vendorOrders
        .where((o) =>
            o.status == 'completed' &&
            o.createdAt.day == today.day &&
            o.createdAt.month == today.month &&
            o.createdAt.year == today.year)
        .fold(0.0, (sum, order) => sum + order.total);

    final unreadNotifications =
        vendorNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              key: _notifIconKey,
              onTap: _toggleNotificationsPopup,
              child: Stack(
                children: [
                  CustomIcon(
                    assetPath: AppIcons.notification,
                    size: 24,
                  ),
                  if (unreadNotifications > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Welcome back, ${user?.shopName ?? 'Vendor'}!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                final providerProducts = dataProvider.products;
                final streamedTotal = providerProducts.length;
                final streamedActive =
                    providerProducts.where((p) => p.isActive).length;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isSmallScreen ? 2 : 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isSmallScreen ? 1.2 : 1.5,
                      children: [
                        _VendorStatCard(
                          theme: theme,
                          title: 'Total Revenue',
                          value: '₨${totalRevenue.toStringAsFixed(0)}',
                          icon: CustomIcon(
                            assetPath: AppIcons.totalSale,
                            size: 28,
                          ),
                          color: Colors.green,
                        ),
                        _VendorStatCard(
                          theme: theme,
                          title: 'Today\'s Orders',
                          value: todayOrders.toString(),
                          icon: CustomIcon(
                            assetPath: AppIcons.orders,
                            size: 28,
                          ),
                          color: Colors.blue,
                        ),
                        _VendorStatCard(
                          theme: theme,
                          title: 'Today\'s Revenue',
                          value: '₨${todayRevenue.toStringAsFixed(0)}',
                          icon: CustomIcon(
                            assetPath: AppIcons.averageOrderValue,
                            size: 28,
                          ),
                          color: Colors.orange,
                        ),
                        _VendorStatCard(
                          theme: theme,
                          title: 'Active Products',
                          value: '$streamedActive/$streamedTotal',
                          icon: CustomIcon(
                            assetPath: AppIcons.products,
                            size: 28,
                          ),
                          color: Colors.purple,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Quick Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  children: [
                    _VendorQuickActionLink(
                      theme: theme,
                      icon: CustomIcon(assetPath: AppIcons.add, size: 24),
                      title: 'Add Product',
                      onTap: () => Get.toNamed('/vendor/add-product-stepper'),
                    ),
                    const SizedBox(width: 12),
                    _VendorQuickActionLink(
                      theme: theme,
                      icon: CustomIcon(assetPath: AppIcons.products, size: 24),
                      title: 'Manage Products',
                      onTap: () => Get.toNamed('/vendor/products'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _VendorQuickActionLink(
                      theme: theme,
                      icon: CustomIcon(assetPath: AppIcons.orders, size: 24),
                      title: 'View Orders',
                      onTap: () => Get.toNamed('/vendor/orders'),
                    ),
                    const SizedBox(width: 12),
                    _VendorQuickActionLink(
                      theme: theme,
                      icon: CustomIcon(assetPath: AppIcons.pointOfSale, size: 24),
                      title: 'POS System',
                      onTap: () => Get.toNamed('/vendor/pos'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Activities',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    try {
                      Get.to(() => const NotificationsScreen());
                    } catch (_) {
                      Get.toNamed('/vendor/notifications');
                    }
                  },
                  child: const Text('View All'),
                )
              ],
            ),
            const SizedBox(height: 16),
            () {
              // Build a unified activity list and take only the 3 most recent
              final List<_VendorActivity> activities = [];

              for (final n in loginNotifications) {
                activities.add(
                  _VendorActivity(
                    createdAt: n.createdAt,
                    title: n.title,
                    subtitle: n.message,
                    icon: Icons.security,
                  ),
                );
              }

              for (final n in productNotifications) {
                activities.add(
                  _VendorActivity(
                    createdAt: n.createdAt,
                    title: n.title,
                    subtitle: n.message,
                    icon: _getVendorProductActivityIcon(
                        n.type.toString().split('.').last),
                  ),
                );
              }

              for (final order in vendorOrders) {
                activities.add(
                  _VendorActivity(
                    createdAt: order.createdAt,
                    title: 'New Order #${order.id.substring(0, 8)}',
                    subtitle:
                        '${order.items.length} items - ₨${order.total.toStringAsFixed(0)}',
                    icon: Icons.shopping_cart,
                  ),
                );
              }

              for (final t in vendorPOSTransactions) {
                activities.add(
                  _VendorActivity(
                    createdAt: t.createdAt,
                    title: 'POS Transaction',
                    subtitle:
                        '${t.items.length} items - ₨${t.total.toStringAsFixed(0)}',
                    icon: Icons.point_of_sale,
                  ),
                );
              }

              activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final top3 = activities.take(3).toList();

              if (top3.isEmpty) return _VendorEmptyActivity(theme: theme);

              return Column(
                children: top3
                    .map((a) => _VendorActivityItem(
                          theme: theme,
                          title: a.title,
                          subtitle: a.subtitle,
                          time: _formatVendorTime(a.createdAt),
                          icon: a.icon,
                        ))
                    .toList(),
              );
            }(),
            const SizedBox(height: 100), // Space for floating nav bar
          ],
        ),
      ),
    );
  }

  void _toggleNotificationsPopup() {
    if (_notifOverlay != null) {
      _removeNotificationsPopup();
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (authProvider.user != null) {
      dataProvider.markAllNotificationsAsRead(authProvider.user!.id);
    }

    final RenderBox? box =
        _notifIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset iconPos = box.localToGlobal(Offset.zero);
    final Size iconSize = box.size;

    _notifOverlay = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeNotificationsPopup,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.12)),
              ),
            ),
          ),
          Positioned(
            top: iconPos.dy + iconSize.height + 4,
            left: () {
              const double popupWidth = 260;
              final double iconCenterX = iconPos.dx + (iconSize.width / 2);
              double left = iconCenterX - popupWidth + 8;
              final screenW = MediaQuery.of(context).size.width;
              if (left < 12) left = 12;
              if (left + popupWidth > screenW - 12) {
                left = screenW - popupWidth - 12;
              }
              return left;
            }(),
            child: ScaleTransition(
              scale: _notifScale,
              alignment: Alignment.topRight,
              child: _VendorNotificationsPopup(
                width: 260,
                onClose: _removeNotificationsPopup,
              ),
            ),
          ),
        ],
      );
    });

    Overlay.of(context).insert(_notifOverlay!);
    _notifAnimController.forward(from: 0);
  }

  void _removeNotificationsPopup({bool animate = true}) {
    if (_notifOverlay == null) return;
    if (animate) {
      _notifAnimController.reverse().whenComplete(() {
        _notifOverlay?.remove();
        _notifOverlay = null;
      });
    } else {
      _notifOverlay?.remove();
      _notifOverlay = null;
    }
  }
}

// Helper widgets for dashboard content
class _VendorStatCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String value;
  final Widget icon;
  final Color color;

  const _VendorStatCard({
    required this.theme,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title on top, single line
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(color: color, size: 22),
                child: icon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    // Slightly larger than before
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// (Old _VendorQuickActionItem removed in favor of tile layout)

class _VendorQuickActionLink extends StatelessWidget {
  final ThemeData theme;
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  const _VendorQuickActionLink({
    required this.theme,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              IconTheme(
                data: IconThemeData(
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                child: icon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorEmptyActivity extends StatelessWidget {
  final ThemeData theme;

  const _VendorEmptyActivity({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent orders and activities will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VendorActivityItem extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  const _VendorActivityItem({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatVendorTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}

IconData _getVendorProductActivityIcon(String notificationType) {
  switch (notificationType) {
    case 'product_added':
      return Icons.add_circle;
    case 'product_deleted':
      return Icons.delete;
    case 'product_discount':
      return Icons.local_offer;
    default:
      return Icons.inventory;
  }
}

class _VendorActivity {
  final DateTime createdAt;
  final String title;
  final String subtitle;
  final IconData icon;

  _VendorActivity({
    required this.createdAt,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _VendorNotificationsPopup extends StatelessWidget {
  final double width;
  final VoidCallback onClose;
  const _VendorNotificationsPopup({this.width = 300, required this.onClose});

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    // If today, show only time (without seconds)
    if (notificationDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // If this week, show day name
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    if (notificationDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        notificationDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    }

    // If more than a week, show date only
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Filter notifications for the current vendor
    final vendorNotifications = data.notifications
        .where((n) => n.userId == authProvider.user?.id)
        .toList();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxHeight: 480, minHeight: 260),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.bell,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Notifications',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    // Show notification count instead of close button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vendorNotifications.length.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (vendorNotifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(LucideIcons.bellOff,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text('No notifications',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: vendorNotifications.length,
                    itemBuilder: (context, index) {
                      final n = vendorNotifications[index];
                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            LucideIcons.trash2,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return true; // Delete immediately without confirmation
                        },
                        onDismissed: (direction) {
                          final dataProvider =
                              Provider.of<DataProvider>(context, listen: false);
                          dataProvider.deleteNotification(n.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notification deleted'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Mark notification as read if it's unread
                              if (!n.isRead) {
                                final dataProvider = Provider.of<DataProvider>(
                                    context,
                                    listen: false);
                                dataProvider.markNotificationAsRead(n.id);
                              }
                              // Close popup and navigate to full notifications screen
                              onClose();
                              debugPrint(
                                  'VendorHomeScreen: Navigating to notifications screen from popup');
                              debugPrint(
                                  'VendorHomeScreen: Current route: ${Get.currentRoute}');
                              try {
                                Get.to(() => const NotificationsScreen());
                                debugPrint(
                                    'VendorHomeScreen: Navigation successful from popup');
                              } catch (e) {
                                debugPrint(
                                    'VendorHomeScreen: Navigation error from popup: $e');
                                // Fallback to named route
                                Get.toNamed('/vendor/notifications');
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    n.isRead
                                        ? LucideIcons.bell
                                        : LucideIcons.bellRing,
                                    color: n.isRead
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title - horizontal layout
                                        Text(
                                          n.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Message - horizontal layout
                                        Text(
                                          n.message,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Optimized date formatting
                                  Text(
                                    _formatNotificationTime(n.createdAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 11,
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
                ),
              // View All button
              if (vendorNotifications.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Close popup and navigate to notifications screen
                        onClose();
                        debugPrint(
                            'VendorHomeScreen: View All Notifications button pressed');
                        debugPrint(
                            'VendorHomeScreen: Current route: ${Get.currentRoute}');
                        try {
                          Get.to(() => const NotificationsScreen());
                          debugPrint(
                              'VendorHomeScreen: View All navigation successful');
                        } catch (e) {
                          debugPrint(
                              'VendorHomeScreen: View All navigation error: $e');
                          // Fallback to named route
                          Get.toNamed('/vendor/notifications');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'View All Notifications',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
