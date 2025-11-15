import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/data_provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_icon.dart';
import '../customer/notifications_screen.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final user = authProvider.user;
    final vendor = user is Vendor ? user : null;

    // Compute simple stats for header cards
    final vendorOrders = dataProvider.orders
        .where((o) => o.vendorId == user?.id)
        .toList();
    final completedOrders = vendorOrders
        .where((o) => o.status == 'completed')
        .toList();
    final totalRevenue = completedOrders.fold<double>(0.0, (sum, order) => sum + order.total);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                CustomCard(
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Builder(
                        builder: (context) {
                          debugPrint(
                              'Vendor Profile - Builder called with user?.avatar: ${user?.avatar}');
                          return CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.primary,
                            child: user?.avatar != null &&
                                    user!.avatar!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _getCacheBustedUrl(user.avatar!),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      headers: {
                                        'Cache-Control': 'max-age=0',
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        debugPrint(
                                            'Vendor Profile - Image load error: $error');
                                        return Text(
                                          user.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          width: 80,
                                          height: 80,
                                          color: theme.colorScheme.primary,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Text(
                                    user?.name.substring(0, 1).toUpperCase() ??
                                        'V',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Vendor',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats summary (Rating, Orders, Revenue)
                CustomCard(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          label: 'Rating',
                          value: '4.8', // Placeholder; hook to real ratings if available
                          icon: LucideIcons.star,
                          iconColor: Colors.amber[700]!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          label: 'Total Orders',
                          value: completedOrders.length.toString(),
                          icon: LucideIcons.shoppingCart,
                          iconColor: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatChip(
                          label: 'Revenue',
                          value: '₨${totalRevenue.toStringAsFixed(0)}',
                          icon: LucideIcons.banknote,
                          iconColor: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Business Information
                if (vendor != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Business Information',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  CustomCard(
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        _buildKeyValueItem(
                          theme,
                          iconAsset: AppIcons.store,
                          label: 'Business Name',
                          value: vendor.shopName,
                        ),
                        const Divider(height: 1, thickness: 1, color: Colors.black12),
                        _buildKeyValueItem(
                          theme,
                          iconAsset: AppIcons.location,
                          label: 'Store Address',
                          value: vendor.shopAddress,
                        ),
                        const Divider(height: 1, thickness: 1, color: Colors.black12),
                        _buildKeyValueItem(
                          theme,
                          icon: LucideIcons.phone,
                          label: 'Contact Number',
                          value: vendor.shopPhone,
                        ),
                        const Divider(height: 1, thickness: 1, color: Colors.black12),
                        _buildKeyValueItem(
                          theme,
                          icon: LucideIcons.mail,
                          label: 'Email Address',
                          value: vendor.email,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Buying section CTA
                _CustomerCtaCard(
                  title: 'Switch to Buying',
                  subtitle: 'Access customer features and start shopping',
                  buttonText: 'Start Shopping',
                  icon: LucideIcons.shoppingBag,
                  onPressed: () => _handleSwitchToCustomer(context),
                ),
                const SizedBox(height: 16),

                // Account Information
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Account Information',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                CustomCard(
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      _buildMenuItem(
                        theme,
                        iconAsset: AppIcons.profile,
                        title: 'Edit Profile',
                        onTap: () => Get.toNamed('/customer/edit-profile'),
                      ),
                      const Divider(height: 1, thickness: 1, color: Colors.black12),
                      _buildMenuItem(
                        theme,
                        iconAsset: AppIcons.products,
                        title: 'Manage Products',
                        onTap: () => Get.toNamed('/vendor/products'),
                      ),
                      const Divider(height: 1, thickness: 1, color: Colors.black12),
                      _buildMenuItem(
                        theme,
                        iconAsset: AppIcons.analytics,
                        title: 'View Earnings',
                        onTap: () => Get.toNamed('/vendor/analytics'),
                      ),
                      const Divider(height: 1, thickness: 1, color: Colors.black12),
                      _buildMenuItem(
                        theme,
                        iconAsset: AppIcons.bell,
                        title: 'Notifications',
                        onTap: () {
                          debugPrint('VendorProfileScreen: Navigating to notifications screen');
                          debugPrint('VendorProfileScreen: Current route: ${Get.currentRoute}');
                          try {
                            Get.to(() => const NotificationsScreen());
                            debugPrint('VendorProfileScreen: Navigation successful');
                          } catch (e) {
                            debugPrint('VendorProfileScreen: Navigation error: $e');
                            // Fallback to named route
                            Get.toNamed('/vendor/notifications');
                          }
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: Colors.black12),
                      _buildMenuItem(
                        theme,
                        iconAsset: AppIcons.store,
                        title: 'Store Settings',
                        onTap: () => Get.toNamed('/vendor/store-settings'),
                      ),
                      const Divider(height: 1, thickness: 1, color: Colors.black12),
                      _buildMenuItem(
                        theme,
                        iconAsset: AppIcons.analytics,
                        title: 'Analytics',
                        onTap: () {
                          debugPrint(
                              'VendorProfileScreen: Navigating to analytics screen');
                          try {
                            Get.toNamed('/vendor/analytics');
                            debugPrint(
                                'VendorProfileScreen: Analytics navigation successful');
                          } catch (e) {
                            debugPrint(
                                'VendorProfileScreen: Analytics navigation error: $e');
                          }
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: Colors.black12),
                      _buildMenuItem(
                        theme,
                        iconAsset: AppIcons.help,
                        title: 'Help & Support',
                        onTap: () {
                          debugPrint(
                              'VendorProfileScreen: Navigating to help and support screen');
                          try {
                            Get.toNamed('/vendor/help-support');
                            debugPrint(
                                'VendorProfileScreen: Help and support navigation successful');
                          } catch (e) {
                            debugPrint(
                                'VendorProfileScreen: Help and support navigation error: $e');
                          }
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: Colors.black12),
                      // Switch to Buying (also available as a tile)
                      _buildMenuItem(
                        theme,
                        icon: LucideIcons.shoppingBag,
                        title: 'Switch to Buying',
                        onTap: () => _handleSwitchToCustomer(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Logout Button
                CustomButton(
                  text: 'Logout',
                  onPressed: () => _logout(context),
                  isOutlined: true,
                  width: double.infinity,
                ),
                const SizedBox(height: 100), // Bottom padding for navigation
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    ThemeData theme, {
    IconData? icon,
    String? iconAsset,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: iconAsset != null
          ? CustomIcon(
              assetPath: iconAsset,
              size: 24,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : Icon(
              icon,
              color: theme.colorScheme.onSurfaceVariant,
            ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildKeyValueItem(
    ThemeData theme, {
    IconData? icon,
    String? iconAsset,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: iconAsset != null
          ? CustomIcon(
              assetPath: iconAsset,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      subtitle: Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  String _getCacheBustedUrl(String avatarUrl) {
    // Use a more stable cache busting approach
    // Only add cache busting if the URL doesn't already have parameters
    if (avatarUrl.contains('?')) {
      return avatarUrl;
    } else {
      // Add a simple cache busting parameter
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$avatarUrl?t=$timestamp';
    }
  }

  void _handleSwitchToCustomer(BuildContext context) async {
    debugPrint('Vendor Profile - _handleSwitchToCustomer called');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    debugPrint('Vendor Profile - Current user role: ${user?.role}');
    debugPrint('Vendor Profile - Current user email: ${user?.email}');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      debugPrint('Vendor Profile - Enabling customer mode for vendor...');

      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // For now, let's create a simple customer mode for vendors
      // We'll navigate directly to customer home and let the customer screens handle vendor users
      debugPrint(
          'Vendor Profile - Navigating to customer home in shopping mode...');
      Get.offAllNamed('/customer');
    } catch (error) {
      debugPrint('Vendor Profile - Error in _handleSwitchToCustomer: $error');
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _showErrorDialog(context, 'Error: ${error.toString()}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Provider.of<AuthProvider>(context, listen: false).logout();
              Get.offAllNamed('/auth/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _CustomerCtaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final VoidCallback onPressed;

  const _CustomerCtaCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.12),
            theme.colorScheme.secondary.withOpacity(0.10),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.12),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
