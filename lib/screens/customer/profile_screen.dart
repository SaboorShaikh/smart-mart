import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_icon.dart';
import 'my_details_screen.dart';
import 'add_payment_method_screen.dart';
import 'notifications_screen.dart';
import '../../widgets/custom_card.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _hasVendorAccount = false;

  @override
  void initState() {
    super.initState();
    _checkVendorAccount();
  }

  Future<void> _checkVendorAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final hasVendor = await authProvider.hasVendorAccount();
      if (mounted) {
        setState(() {
          _hasVendorAccount = hasVendor;
        });
      }
    } catch (e) {
      debugPrint('Error checking vendor account: $e');
      if (mounted) {
        setState(() {
          _hasVendorAccount = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final user = authProvider.user;

    // Debug print to check user data
    debugPrint('User in profile: $user');
    debugPrint('User name: ${user?.name}');
    debugPrint('User email: ${user?.email}');
    debugPrint('User role: ${user?.role}');
    debugPrint('User avatar: ${user?.avatar}');
    debugPrint('Avatar is null: ${user?.avatar == null}');
    debugPrint('Avatar is empty: ${user?.avatar?.isEmpty}');
    if (user?.avatar != null) {
      debugPrint(
          'Avatar starts with http: ${user!.avatar!.startsWith('http')}');
      debugPrint('Avatar starts with /: ${user.avatar!.startsWith('/')}');
    }

    const lightGreyBackground = Color(0xFFF5F5F5);

    // Show loading if user is not loaded yet
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: lightGreyBackground,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error if user is not found
    if (user == null) {
      return Scaffold(
        backgroundColor: lightGreyBackground,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.userX,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'User not found',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Please login again',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Go to Login',
                onPressed: () => Get.toNamed('/auth/login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightGreyBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(LucideIcons.pencil),
              onPressed: () => Get.toNamed('/customer/edit-profile'),
              tooltip: 'Edit Profile',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Builder(
                  builder: (context) {
                    debugPrint(
                        'Customer Profile - Builder called with user.avatar: ${user.avatar}');
                    return CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary,
                      child: user.avatar != null && user.avatar!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                _getCacheBustedUrl(user.avatar!),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                headers: {
                                  'Cache-Control': 'max-age=0',
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                      'Customer Profile - Image load error: $error');
                                  return Text(
                                    _getInitials(user.name),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 56,
                                    height: 56,
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
                              _getInitials(user.name),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty == true ? (user.name) : 'User',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (user is Customer &&
                          (user.address?.isNotEmpty ?? false)) ...[
                        const SizedBox(height: 2),
                        Text(
                          (user).address!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Vendor CTA - Show different text based on vendor account status
            _VendorCtaCard(
              title: _hasVendorAccount
                  ? 'Manage your store'
                  : 'Start your business',
              subtitle: _hasVendorAccount
                  ? 'Go to your vendor dashboard to add products and manage orders'
                  : 'Join thousands of sellers and start earning by registering your mart today',
              buttonText: _hasVendorAccount
                  ? 'Open Vendor Panel'
                  : 'Register Your Mart',
              icon: LucideIcons.shoppingBag,
              onPressed: () {
                debugPrint(
                    'Customer Profile - Button pressed, calling _handleSwitchToVendor');
                _handleSwitchToVendor(context);
              },
            ),
            const SizedBox(height: 16),

            // Menu groups
            _buildMenuGroup(
              context,
              items: [
                _MenuItem(
                    iconAsset: AppIcons.orders,
                    title: 'Orders',
                    onTap: () => Get.toNamed('/customer/orders')),
                _MenuItem(
                    iconAsset: AppIcons.profile,
                    title: 'My Details',
                    onTap: () => Get.to(() => const MyDetailsScreen())),
                _MenuItem(
                    iconAsset: AppIcons.mapPin,
                    title: 'Delivery Address',
                    onTap: () => Get.toNamed('/customer/addresses')),
                _MenuItem(
                    iconAsset: AppIcons.creditCard,
                    title: 'Payment Methods',
                    onTap: () => Get.to(() => const AddPaymentMethodScreen())),
                _MenuItem(
                    iconAsset: AppIcons.tag, title: 'Promo Code', onTap: () {}),
                _MenuItem(
                    iconAsset: AppIcons.bell,
                    title: 'Notifications',
                    onTap: () => Get.to(() => const NotificationsScreen())),
                _MenuItem(
                    iconAsset: AppIcons.help, title: 'Help', onTap: () {}),
                _MenuItem(
                    iconAsset: AppIcons.info, title: 'About', onTap: () {}),
              ],
            ),

            const SizedBox(height: 24),

            // Logout pill button
            _LogoutPillButton(onPressed: () => _logout(context)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  bool _shouldPreserveOriginalColor(String iconAsset) {
    // Preserve original colors for delivery address and promocode icons
    return iconAsset == AppIcons.mapPin || iconAsset == AppIcons.tag;
  }

  Widget _buildMenuGroup(BuildContext context,
      {required List<_MenuItem> items}) {
    final theme = Theme.of(context);
    return CustomCard(
      color: Colors.white,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            ListTile(
              tileColor: Colors.white,
              leading: items[i].iconAsset != null
                  ? CustomIcon(
                      assetPath: items[i].iconAsset!,
                      size: 24,
                      color: _shouldPreserveOriginalColor(items[i].iconAsset!)
                          ? null
                          : theme.colorScheme.onSurfaceVariant,
                    )
                  : const SizedBox.shrink(),
              title: Text(
                items[i].title,
                style: theme.textTheme.bodyLarge,
              ),
              onTap: items[i].onTap,
            ),
            if (i != items.length - 1)
              Divider(height: 1, color: theme.dividerColor.withOpacity(0.4)),
          ]
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U';
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'U';
    }

    // Get first character of each word
    final words = trimmedName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return trimmedName[0].toUpperCase();
    }
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

  void _handleSwitchToVendor(BuildContext context) async {
    debugPrint('Customer Profile - _handleSwitchToVendor called');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    debugPrint('Customer Profile - Current user role: ${user?.role}');
    debugPrint('Customer Profile - Current user email: ${user?.email}');
    debugPrint('Customer Profile - Has vendor account: $_hasVendorAccount');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      if (_hasVendorAccount) {
        debugPrint('Customer Profile - Switching to vendor role...');
        // Switch to vendor role and go to dashboard
        final switchSuccess = await authProvider.switchToVendorRole();
        debugPrint('Customer Profile - Switch success: $switchSuccess');

        // Close loading dialog first
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        if (switchSuccess) {
          debugPrint('Customer Profile - Navigating to vendor home...');
          // Navigate to vendor home
          Get.offAllNamed('/vendor');
        } else {
          debugPrint('Customer Profile - Failed to switch to vendor role');
          _showErrorDialog(context, 'Failed to switch to vendor account');
        }
      } else {
        debugPrint(
            'Customer Profile - No vendor account, going to registration...');

        // Close loading dialog first
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // No vendor account, go to vendor registration
        Get.toNamed('/auth/register/vendor');
      }
    } catch (error) {
      debugPrint('Customer Profile - Error in _handleSwitchToVendor: $error');
      // Close loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
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

class _VendorCtaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final VoidCallback onPressed;
  const _VendorCtaCard({
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

class _MenuItem {
  final String? iconAsset;
  final String title;
  final VoidCallback onTap;
  const _MenuItem({
    this.iconAsset,
    required this.title,
    required this.onTap,
  });
}

class _LogoutPillButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutPillButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.logOut, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
