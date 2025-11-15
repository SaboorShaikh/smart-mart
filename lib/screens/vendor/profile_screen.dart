import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/data_provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_icon.dart';
import '../../services/firestore_service.dart';
import '../../services/image_upload_service.dart';
import '../../supabase_config.dart';
import '../customer/notifications_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final dataProvider = Provider.of<DataProvider>(context, listen: true);
    final user = authProvider.user;
    final vendor = user is Vendor ? user : null;
    final vendorRating = vendor?.rating ?? 0;
    final shopName = vendor?.shopName ?? user?.name ?? 'Vendor';
    final shopLogo = vendor?.shopLogo;

    // Compute simple stats for header cards
    final vendorOrders =
        dataProvider.orders.where((o) => o.vendorId == user?.id).toList();
    final completedOrders =
        vendorOrders.where((o) => o.status == 'completed').toList();
    final totalRevenue =
        completedOrders.fold<double>(0.0, (sum, order) => sum + order.total);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Profile Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        debugPrint(
                            'Vendor Profile - Builder called with shopLogo: $shopLogo');
                        final logoToUse = shopLogo ?? user?.avatar;
                        final fallbackInitial = shopName.isNotEmpty
                            ? shopName[0].toUpperCase()
                            : 'V';
                        const double avatarRadius = 54;
                        const double avatarSize = avatarRadius * 2;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: avatarRadius,
                              backgroundColor: theme.colorScheme.primary,
                              child: logoToUse != null && logoToUse.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        _getCacheBustedUrl(logoToUse),
                                        width: avatarSize,
                                        height: avatarSize,
                                        fit: BoxFit.cover,
                                        headers: const {
                                          'Cache-Control': 'max-age=0',
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          debugPrint(
                                              'Vendor Profile - Logo load error: $error');
                                          return Text(
                                            fallbackInitial,
                                            style: theme
                                                .textTheme.headlineMedium
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
                                            width: avatarSize,
                                            height: avatarSize,
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
                                      fallbackInitial,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => _showLogoOptions(context),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE9EAED),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: CustomIcon(
                                      assetPath: AppIcons.camera,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      shopName,
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
                const SizedBox(height: 16),

                // Stats summary (Rating, Orders, Revenue)
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        label: 'Rating',
                        value: vendorRating.toStringAsFixed(1),
                        icon: LucideIcons.star,
                        iconColor: Colors.amber[700]!,
                        showIconNextToValue: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatChip(
                        label: 'Total Orders',
                        value: completedOrders.length.toString(),
                        icon: LucideIcons.shoppingCart,
                        iconColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                const SizedBox(height: 16),

                // Business Information
                if (vendor != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Business Information',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  CustomCard(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildKeyValueItem(
                          theme,
                          iconAsset: AppIcons.store,
                          label: 'Business Name',
                          value: vendor.shopName,
                          useOriginalIconColors: true,
                        ),
                        const Divider(
                            height: 1, thickness: 1, color: Colors.black12),
                        _buildKeyValueItem(
                          theme,
                          iconAsset: AppIcons.location,
                          label: 'Store Address',
                          value: vendor.shopAddress,
                          useOriginalIconColors: true,
                        ),
                        const Divider(
                            height: 1, thickness: 1, color: Colors.black12),
                        _buildKeyValueItem(
                          theme,
                          icon: LucideIcons.phone,
                          label: 'Contact Number',
                          value: vendor.shopPhone,
                        ),
                        const Divider(
                            height: 1, thickness: 1, color: Colors.black12),
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
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                CustomCard(
                  color: Colors.white,
                  child: Column(
                    children: [
                        _buildMenuItem(
                          theme,
                          iconAsset: AppIcons.profile,
                          title: 'Edit Profile',
                          onTap: () => Get.toNamed('/customer/edit-profile'),
                          useOriginalIconColors: true,
                        ),
                      const Divider(
                          height: 1, thickness: 1, color: Colors.black12),
                        _buildMenuItem(
                          theme,
                          iconAsset: AppIcons.products,
                          title: 'Manage Products',
                          onTap: () => Get.toNamed('/vendor/products'),
                          useOriginalIconColors: true,
                        ),
                      const Divider(
                          height: 1, thickness: 1, color: Colors.black12),
                        _buildMenuItem(
                          theme,
                          iconAsset: AppIcons.analytics,
                          title: 'View Earnings',
                          onTap: () => Get.toNamed('/vendor/analytics'),
                          useOriginalIconColors: true,
                        ),
                      const Divider(
                          height: 1, thickness: 1, color: Colors.black12),
                        _buildMenuItem(
                          theme,
                          iconAsset: AppIcons.bell,
                          title: 'Notifications',
                          useOriginalIconColors: true,
                          onTap: () {
                          debugPrint(
                              'VendorProfileScreen: Navigating to notifications screen');
                          debugPrint(
                              'VendorProfileScreen: Current route: ${Get.currentRoute}');
                          try {
                            Get.to(() => const NotificationsScreen());
                            debugPrint(
                                'VendorProfileScreen: Navigation successful');
                          } catch (e) {
                            debugPrint(
                                'VendorProfileScreen: Navigation error: $e');
                            // Fallback to named route
                            Get.toNamed('/vendor/notifications');
                          }
                        },
                      ),
                      const Divider(
                          height: 1, thickness: 1, color: Colors.black12),
                        _buildMenuItem(
                          theme,
                          iconAsset: AppIcons.store,
                          title: 'Store Settings',
                          onTap: () => Get.toNamed('/vendor/store-settings'),
                          useOriginalIconColors: true,
                        ),
                      const Divider(
                          height: 1, thickness: 1, color: Colors.black12),
                        _buildMenuItem(
                          theme,
                          iconAsset: AppIcons.analytics,
                          title: 'Analytics',
                          useOriginalIconColors: true,
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
                      const Divider(
                          height: 1, thickness: 1, color: Colors.black12),
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
                      const Divider(
                          height: 1, thickness: 1, color: Colors.black12),
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

  void _showLogoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Logo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    LucideIcons.image,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Change Logo'),
                  subtitle: const Text('Upload a new store logo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _handleChangeLogo(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    LucideIcons.trash2,
                    color: theme.colorScheme.error,
                  ),
                  title: const Text('Delete Logo'),
                  subtitle: const Text('Remove current logo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _handleDeleteLogo(context);
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleChangeLogo(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendor = authProvider.user;
    if (vendor is! Vendor) {
      _showSnack(context, 'Only vendors can update store logo', isError: true);
      return;
    }

    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    image ??= await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) {
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    _showLoadingDialog(context);

    try {
      final imageFile = File(image.path);

      if (vendor.shopLogo != null && vendor.shopLogo!.isNotEmpty) {
        await _deleteLogoFromStorage(vendor.shopLogo!);
      }

      final uploadedUrl = await ImageUploadService.uploadStoreLogo(
        imageFile: imageFile,
        storeId: vendor.id,
      );

      if (uploadedUrl == null) {
        throw Exception('Upload failed');
      }

      await FirestoreService.updateUser(vendor.id, {'shopLogo': uploadedUrl});
      await authProvider.loadCurrentUser();
      messenger.showSnackBar(
        const SnackBar(content: Text('Store logo updated successfully')),
      );
    } catch (e) {
      debugPrint('VendorProfileScreen: Error updating store logo: $e');
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to update store logo'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      navigator.pop();
    }
  }

  Future<void> _handleDeleteLogo(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendor = authProvider.user;
    if (vendor is! Vendor) {
      _showSnack(context, 'Only vendors can update store logo', isError: true);
      return;
    }

    if (vendor.shopLogo == null || vendor.shopLogo!.isEmpty) {
      _showSnack(context, 'No store logo to delete');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Store Logo'),
        content: const Text(
            'Are you sure you want to delete the current store logo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    _showLoadingDialog(context);

    try {
      await _deleteLogoFromStorage(vendor.shopLogo!);
      await FirestoreService.updateUser(vendor.id, {'shopLogo': null});
      await authProvider.loadCurrentUser();
      messenger.showSnackBar(
        const SnackBar(content: Text('Store logo deleted')),
      );
    } catch (e) {
      debugPrint('VendorProfileScreen: Error deleting store logo: $e');
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Failed to delete store logo'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      navigator.pop();
    }
  }

  Future<void> _deleteLogoFromStorage(String logoUrl) async {
    try {
      final filePath = _extractLogoFilePath(logoUrl);
      if (filePath == null) return;
      await Supabase.instance.client.storage
          .from(SupabaseConfig.storeLogosBucket)
          .remove([filePath]);
    } catch (e) {
      debugPrint('VendorProfileScreen: Error removing logo from storage: $e');
    }
  }

  String? _extractLogoFilePath(String logoUrl) {
    try {
      final uri = Uri.parse(logoUrl);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(SupabaseConfig.storeLogosBucket);
      if (bucketIndex != -1 && bucketIndex + 2 < segments.length) {
        final storeId = segments[bucketIndex + 1];
        final fileName = segments[bucketIndex + 2];
        return '$storeId/$fileName';
      }
    } catch (e) {
      debugPrint('VendorProfileScreen: Error parsing logo URL: $e');
    }
    return null;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnack(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Widget _buildMenuItem(
    ThemeData theme, {
    IconData? icon,
    String? iconAsset,
    required String title,
    required VoidCallback onTap,
    bool useOriginalIconColors = false,
  }) {
    return ListTile(
      leading: iconAsset != null
          ? CustomIcon(
              assetPath: iconAsset,
              size: 28,
              color:
                  useOriginalIconColors ? null : theme.colorScheme.onSurfaceVariant,
            )
          : Icon(
              icon,
              color:
                  useOriginalIconColors ? null : theme.colorScheme.onSurfaceVariant,
            ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      trailing: const SizedBox.shrink(),
      onTap: onTap,
    );
  }

  Widget _buildKeyValueItem(
    ThemeData theme, {
    IconData? icon,
    String? iconAsset,
    required String label,
    required String value,
    bool useOriginalIconColors = false,
  }) {
    return ListTile(
      leading: iconAsset != null
          ? CustomIcon(
              assetPath: iconAsset,
              size: 26,
              color:
                  useOriginalIconColors ? null : theme.colorScheme.onSurfaceVariant,
            )
          : Icon(
              icon,
              color:
                  useOriginalIconColors ? null : theme.colorScheme.onSurfaceVariant,
            ),
      title: Text(label,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      subtitle: Text(value,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
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
  final bool showIconNextToValue;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.showIconNextToValue = false,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      constraints: const BoxConstraints(minHeight: 96),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (showIconNextToValue)
                Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
