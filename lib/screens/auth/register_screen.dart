import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_card.dart';
import '../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _businessLicenseController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _bankAccountController = TextEditingController();

  bool _isLoading = false;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get role from GetX arguments
    if (_userRole == null) {
      final roleParam = Get.arguments?['role'] as String?;
      if (roleParam == 'customer') {
        _userRole = UserRole.customer;
      } else if (roleParam == 'vendor') {
        _userRole = UserRole.vendor;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _shopAddressController.dispose();
    _shopPhoneController.dispose();
    _businessLicenseController.dispose();
    _taxIdController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() || _userRole == null) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final registerData = RegisterData(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _userRole!,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      shopName: _shopNameController.text.trim().isNotEmpty
          ? _shopNameController.text.trim()
          : null,
      shopDescription: _shopDescriptionController.text.trim().isNotEmpty
          ? _shopDescriptionController.text.trim()
          : null,
      shopAddress: _shopAddressController.text.trim().isNotEmpty
          ? _shopAddressController.text.trim()
          : null,
      shopPhone: _shopPhoneController.text.trim().isNotEmpty
          ? _shopPhoneController.text.trim()
          : null,
      businessLicense: _businessLicenseController.text.trim().isNotEmpty
          ? _businessLicenseController.text.trim()
          : null,
      taxId: _taxIdController.text.trim().isNotEmpty
          ? _taxIdController.text.trim()
          : null,
      bankAccount: _bankAccountController.text.trim().isNotEmpty
          ? _bankAccountController.text.trim()
          : null,
    );

    final result = await authProvider.register(registerData);

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      final user = authProvider.user!;
      if (user.role.toString().split('.').last == 'vendor') {
        Get.offAllNamed('/vendor');
      } else {
        Get.offAllNamed('/customer');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Registration failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Create Your Account',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Join SmartMart as a ${_userRole?.toString().split('.').last ?? 'user'}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Basic Information
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      CustomInput(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        value: _nameController.text,
                        onChanged: (value) => setState(() {}),
                        prefixIcon: Icon(
                          LucideIcons.user,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        errorText: _nameController.text.isEmpty && _isLoading
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      CustomInput(
                        label: 'Email',
                        hint: 'Enter your email',
                        value: _emailController.text,
                        onChanged: (value) => setState(() {}),
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        prefixIcon: Icon(
                          LucideIcons.mail,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        errorText: _emailController.text.isNotEmpty &&
                                !_emailController.text.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone (moved to separate step for customers)
                      if (_userRole == UserRole.vendor) ...[
                        CustomInput(
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          value: _phoneController.text,
                          onChanged: (value) => setState(() {}),
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(
                            LucideIcons.phone,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Address moved to dedicated screen for customers

                      // Password
                      CustomInput(
                        label: 'Password',
                        hint: 'Enter your password',
                        value: _passwordController.text,
                        onChanged: (value) => setState(() {}),
                        obscureText: true,
                        prefixIcon: Icon(
                          LucideIcons.lock,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        errorText: _passwordController.text.isNotEmpty &&
                                _passwordController.text.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      CustomInput(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        value: _confirmPasswordController.text,
                        onChanged: (value) => setState(() {}),
                        obscureText: true,
                        prefixIcon: Icon(
                          LucideIcons.lock,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        errorText: _confirmPasswordController.text.isNotEmpty &&
                                _confirmPasswordController.text !=
                                    _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                    ],
                  ),
                ),

                // Vendor-specific fields
                if (_userRole == UserRole.vendor) ...[
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store Information',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Shop Name
                        CustomInput(
                          label: 'Shop Name',
                          hint: 'Enter your shop name',
                          value: _shopNameController.text,
                          onChanged: (value) => setState(() {}),
                          prefixIcon: Icon(
                            LucideIcons.store,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          errorText:
                              _shopNameController.text.isEmpty && _isLoading
                                  ? 'Shop name is required'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // Shop Description
                        CustomInput(
                          label: 'Shop Description',
                          hint: 'Describe your shop',
                          value: _shopDescriptionController.text,
                          onChanged: (value) => setState(() {}),
                          maxLines: 3,
                          prefixIcon: Icon(
                            LucideIcons.fileText,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Shop Address
                        CustomInput(
                          label: 'Shop Address',
                          hint: 'Enter your shop address',
                          value: _shopAddressController.text,
                          onChanged: (value) => setState(() {}),
                          maxLines: 2,
                          prefixIcon: Icon(
                            LucideIcons.mapPin,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Shop Phone
                        CustomInput(
                          label: 'Shop Phone',
                          hint: 'Enter your shop phone number',
                          value: _shopPhoneController.text,
                          onChanged: (value) => setState(() {}),
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(
                            LucideIcons.phone,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Business License
                        CustomInput(
                          label: 'Business License',
                          hint: 'Enter your business license number',
                          value: _businessLicenseController.text,
                          onChanged: (value) => setState(() {}),
                          prefixIcon: Icon(
                            LucideIcons.fileCheck,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tax ID
                        CustomInput(
                          label: 'Tax ID (Optional)',
                          hint: 'Enter your tax ID',
                          value: _taxIdController.text,
                          onChanged: (value) => setState(() {}),
                          prefixIcon: Icon(
                            LucideIcons.receipt,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bank Account
                        CustomInput(
                          label: 'Bank Account (Optional)',
                          hint: 'Enter your bank account details',
                          value: _bankAccountController.text,
                          onChanged: (value) => setState(() {}),
                          prefixIcon: Icon(
                            LucideIcons.creditCard,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Register Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  width: double.infinity,
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
                      onTap: () => Get.toNamed('/auth/login'),
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
      ),
    );
  }
}
