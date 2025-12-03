import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../../widgets/custom_icon.dart';

class AddProductStep3Screen extends StatefulWidget {
  final String brand;
  final String origin;
  final String expiryDate;
  final String barcode;
  final String manufacturer;
  final Function(String, String, String, String, String) onDataChanged;
  final VoidCallback? onStartOver;

  const AddProductStep3Screen({
    super.key,
    required this.brand,
    required this.origin,
    required this.expiryDate,
    required this.barcode,
    required this.manufacturer,
    required this.onDataChanged,
    this.onStartOver,
  });

  @override
  State<AddProductStep3Screen> createState() => _AddProductStep3ScreenState();
}

class _AddProductStep3ScreenState extends State<AddProductStep3Screen> {
  final _brandController = TextEditingController();
  final _originController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _manufacturerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _brandController.text = widget.brand;
    _originController.text = widget.origin;
    _expiryDateController.text = widget.expiryDate;
    _barcodeController.text = widget.barcode;
    _manufacturerController.text = widget.manufacturer;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _originController.dispose();
    _expiryDateController.dispose();
    _barcodeController.dispose();
    _manufacturerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF4F5F7), // Light gray background
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : Colors.white, // White background for light mode
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E293B).withOpacity(0.8)
                        : const Color(0xFFE2E8F0).withOpacity(0.8),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Back Button, Indicators, and Start Over
                  Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: Icon(
                          LucideIcons.arrowLeft,
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // Page Indicators (6 dots)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final isActive = index <= 2; // Stage 3 is index 2
                            final isCurrent = index == 2;
                            return Container(
                              width: isCurrent ? 12 : 8,
                              height: isCurrent ? 12 : 8,
                              margin: EdgeInsets.only(
                                right: index < 5 ? 8 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF225FEC)
                                    : (isDark
                                        ? const Color(0xFF3F3F46)
                                        : const Color(0xFFD4D4D8)),
                                shape: BoxShape.circle,
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF225FEC)
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                      // Start Over button
                      if (widget.onStartOver != null)
                        TextButton(
                          onPressed: widget.onStartOver,
                          child: Text(
                            'Start Over',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    'Product Details',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stage 3 of 6',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF71717A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Progress bar with equal padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 3 / 6, // 50% for stage 3
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF225FEC),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Form Fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand Information
                        _buildBrandSection(theme, isDark),
                        const SizedBox(height: 24),

                        // Origin Information
                        _buildOriginSection(theme, isDark),
                        const SizedBox(height: 24),

                        // Expiry Information
                        _buildExpirySection(theme, isDark),
                        const SizedBox(height: 24),

                        // Additional Details
                        _buildAdditionalDetailsSection(theme, isDark),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Helper Text
                    Center(
                      child: Text(
                        'These details help customers make informed decisions and build trust in your products.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF757575),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100), // Space for fixed bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand Information',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xFFD4D4D8)
                : const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _brandController,
          onChanged: (value) => _notifyDataChanged(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: 'Brand Name',
            hintStyle: TextStyle(
              color: isDark
                  ? const Color(0xFF71717A)
                  : const Color(0xFF757575),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: CustomIcon(
                assetPath: AppIcons.brandName,
                size: 22,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF225FEC),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Origin Information',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xFFD4D4D8)
                : const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _originController,
          onChanged: (value) => _notifyDataChanged(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: 'Origin / Country',
            hintStyle: TextStyle(
              color: isDark
                  ? const Color(0xFF71717A)
                  : const Color(0xFF757575),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: CustomIcon(
                assetPath: AppIcons.origin,
                size: 22,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF225FEC),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpirySection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Information',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xFFD4D4D8)
                : const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _expiryDateController,
          readOnly: true,
          onTap: () => _selectExpiryDate(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: 'Expiry Date',
            hintStyle: TextStyle(
              color: isDark
                  ? const Color(0xFF71717A)
                  : const Color(0xFF757575),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: CustomIcon(
                assetPath: AppIcons.date,
                size: 22,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF225FEC),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Info Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFA726).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.info,
                size: 16,
                color: const Color(0xFFFFA726),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Leave empty if product doesn\'t expire.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFA726),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xFFD4D4D8)
                : const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        // Barcode Field
        TextField(
          controller: _barcodeController,
          onChanged: (value) => _notifyDataChanged(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: 'Product barcode or SKU',
            hintStyle: TextStyle(
              color: isDark
                  ? const Color(0xFF71717A)
                  : const Color(0xFF757575),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                LucideIcons.scan,
                size: 22,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF225FEC),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Manufacturer Field
        TextField(
          controller: _manufacturerController,
          onChanged: (value) => _notifyDataChanged(),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: 'Manufacturer name',
            hintStyle: TextStyle(
              color: isDark
                  ? const Color(0xFF71717A)
                  : const Color(0xFF757575),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: CustomIcon(
                assetPath: AppIcons.manufacturer,
                size: 22,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0F172A)
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF225FEC),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      _expiryDateController.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      _notifyDataChanged();
    }
  }

  void _notifyDataChanged() {
    widget.onDataChanged(
      _brandController.text,
      _originController.text,
      _expiryDateController.text,
      _barcodeController.text,
      _manufacturerController.text,
    );
  }
}
