import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              // Header
              Text(
                'Choose Your Role',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Select how you want to use the app',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Role Cards
              Expanded(
                child: Column(
                  children: [
                    // Customer Card
                    _buildRoleCard(
                      context,
                      role: UserRole.customer,
                      assetIcon: 'assets/icons/customer.png',
                      title: 'I\'m a Customer',
                      subtitle:
                          'Browse, discover, and purchase amazing products.',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 16),

                    // Vendor Card
                    _buildRoleCard(
                      context,
                      role: UserRole.vendor,
                      assetIcon: 'assets/icons/vendor.png',
                      title: 'I\'m a Vendor',
                      subtitle: 'Set up your shop and sell to our community.',
                      color: const Color(0xFF22C55E),
                    ),
                  ],
                ),
              ),

              // Continue Button
              CustomButton(
                text: 'Continue',
                onPressed: _selectedRole != null ? _continue : null,
                width: double.infinity,
                isDisabled: _selectedRole == null,
              ),
              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint(
                          'Sign In link tapped - navigating back to login');
                      Get.back();
                    },
                    child: Text(
                      'Sign In',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required UserRole role,
    required String assetIcon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      assetIcon,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() {
    debugPrint('Continue button pressed - Selected role: $_selectedRole');
    if (_selectedRole == UserRole.customer) {
      debugPrint('Navigating to customer location screen');
      Get.toNamed('/auth/register/customer/location');
    } else if (_selectedRole == UserRole.vendor) {
      debugPrint('Navigating to vendor register screen');
      Get.toNamed('/auth/register');
    }
  }
}

enum UserRole {
  customer,
  vendor,
}
