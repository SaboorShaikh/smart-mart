import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_icon.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(theme),
            const SizedBox(height: 24),

            // Quick Help Section
            _buildQuickHelpSection(theme),
            const SizedBox(height: 24),

            // Contact Support Section
            _buildContactSupportSection(theme),
            const SizedBox(height: 24),

            // FAQ Section
            _buildFAQSection(theme),
            const SizedBox(height: 24),

            // Resources Section
            _buildResourcesSection(theme),
            const SizedBox(height: 100), // Bottom padding for navigation
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return CustomCard(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIcon(
                    assetPath: AppIcons.help,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to SmartMart Support',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We\'re here to help you succeed with your business',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Help',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          color: Colors.grey[100],
          child: Column(
            children: [
              _buildHelpItem(
                theme,
                icon: Icons.shopping_cart,
                title: 'Managing Products',
                subtitle: 'Learn how to add, edit, and organize your products',
                onTap: () => _showProductHelp(theme),
              ),
              const Divider(height: 1),
              _buildHelpItem(
                theme,
                icon: Icons.analytics,
                title: 'Understanding Analytics',
                subtitle: 'Get insights from your sales data and trends',
                onTap: () => _showAnalyticsHelp(theme),
              ),
              const Divider(height: 1),
              _buildHelpItem(
                theme,
                icon: Icons.payment,
                title: 'Payment & Orders',
                subtitle: 'Handle payments and manage customer orders',
                onTap: () => _showPaymentHelp(theme),
              ),
              const Divider(height: 1),
              _buildHelpItem(
                theme,
                icon: Icons.store,
                title: 'Store Settings',
                subtitle: 'Configure your store information and policies',
                onTap: () => _showStoreSettingsHelp(theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupportSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Support',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          color: Colors.grey[100],
          child: Column(
            children: [
              _buildContactItem(
                theme,
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@smartmart.com',
                onTap: () => _launchEmail(),
              ),
              const Divider(height: 1),
              _buildContactItem(
                theme,
                icon: Icons.phone,
                title: 'Phone Support',
                subtitle: '+1 (555) 123-4567',
                onTap: () => _launchPhone(),
              ),
              const Divider(height: 1),
              _buildContactItem(
                theme,
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Available 24/7 for urgent issues',
                onTap: () => _showLiveChat(theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          color: Colors.grey[100],
          child: Column(
            children: [
              _buildFAQItem(
                theme,
                question: 'How do I add a new product?',
                answer:
                    'Go to Products → Add Product → Follow the 6-step wizard to create your product with all details.',
                onTap: () => _showFAQDetail(theme, 'Adding Products'),
              ),
              const Divider(height: 1),
              _buildFAQItem(
                theme,
                question: 'How can I track my sales?',
                answer:
                    'Visit the Analytics Dashboard to view your sales performance, top products, and trends.',
                onTap: () => _showFAQDetail(theme, 'Sales Tracking'),
              ),
              const Divider(height: 1),
              _buildFAQItem(
                theme,
                question: 'How do I set up discounts?',
                answer:
                    'In the Products screen, tap the discount icon on any product to set percentage or fixed discounts.',
                onTap: () => _showFAQDetail(theme, 'Setting Discounts'),
              ),
              const Divider(height: 1),
              _buildFAQItem(
                theme,
                question: 'Can I switch between customer and vendor mode?',
                answer:
                    'Yes! Use the role switching feature in your profile to access both customer and vendor features.',
                onTap: () => _showFAQDetail(theme, 'Role Switching'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourcesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resources',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          color: Colors.grey[100],
          child: Column(
            children: [
              _buildResourceItem(
                theme,
                icon: Icons.book,
                title: 'User Guide',
                subtitle: 'Complete guide to using SmartMart',
                onTap: () => _showUserGuide(theme),
              ),
              const Divider(height: 1),
              _buildResourceItem(
                theme,
                icon: Icons.video_library,
                title: 'Video Tutorials',
                subtitle: 'Watch step-by-step video guides',
                onTap: () => _showVideoTutorials(theme),
              ),
              const Divider(height: 1),
              _buildResourceItem(
                theme,
                icon: Icons.bug_report,
                title: 'Report a Bug',
                subtitle: 'Help us improve by reporting issues',
                onTap: () => _showBugReport(theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFAQItem(
    ThemeData theme, {
    required String question,
    required String answer,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.help_outline,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        question,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        answer,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildResourceItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  // Helper Methods
  void _showProductHelp(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Managing Products'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Adding Products:'),
              Text('1. Go to Products screen'),
              Text('2. Tap the + button'),
              Text('3. Follow the 6-step wizard'),
              Text('4. Review and save your product'),
              SizedBox(height: 16),
              Text('Editing Products:'),
              Text('1. Long-press any product'),
              Text('2. Select "Edit" from the menu'),
              Text('3. Make your changes'),
              Text('4. Save to update'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsHelp(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Understanding Analytics'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Analytics Dashboard provides:'),
              Text('• Today\'s sales summary'),
              Text('• Total sales overview'),
              Text('• Inventory count'),
              Text('• Top-selling products'),
              Text('• Sales trend charts'),
              SizedBox(height: 16),
              Text('Use the refresh button to update data in real-time.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaymentHelp(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Payment & Orders'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Managing Orders:'),
              Text('1. Go to Orders screen'),
              Text('2. View incoming orders'),
              Text('3. Update order status'),
              Text('4. Process payments'),
              SizedBox(height: 16),
              Text('POS System:'),
              Text('1. Go to POS screen'),
              Text('2. Add items to transaction'),
              Text('3. Process payment'),
              Text('4. Generate receipt'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStoreSettingsHelp(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Store Settings'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Configure your store:'),
              Text('• Store name and description'),
              Text('• Business hours'),
              Text('• Contact information'),
              Text('• Delivery policies'),
              Text('• Return policies'),
              SizedBox(height: 16),
              Text('Go to Profile → Store Settings to access these options.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@smartmart.com',
      query: 'subject=SmartMart Support Request',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch email client',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch email client',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch phone app',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch phone app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showLiveChat(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
            'Live chat support is coming soon! For now, please use email or phone support.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFAQDetail(ThemeData theme, String topic) {
    Get.dialog(
      AlertDialog(
        title: Text(topic),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'For more detailed help on this topic, please contact our support team.'),
              SizedBox(height: 16),
              Text('Email: support@smartmart.com'),
              Text('Phone: +1 (555) 123-4567'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserGuide(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('User Guide'),
        content: const Text(
            'The complete user guide is available online. We\'ll send you the link via email.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVideoTutorials(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Video Tutorials'),
        content: const Text(
            'Video tutorials are coming soon! Check back later for step-by-step video guides.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBugReport(ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text(
            'To report a bug, please email us at support@smartmart.com with details about the issue you encountered.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
