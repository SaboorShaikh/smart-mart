import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../../widgets/category_picker.dart';
import '../../widgets/custom_icon.dart';

class AddProductStep2Screen extends StatefulWidget {
  final String selectedCategory;
  final String price;
  final String unit;
  final String stockQuantity;
  final List<String> categories;
  final Function(String, String, String, String) onDataChanged;
  final VoidCallback? onStartOver;

  const AddProductStep2Screen({
    super.key,
    required this.selectedCategory,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.categories,
    required this.onDataChanged,
    this.onStartOver,
  });

  @override
  State<AddProductStep2Screen> createState() => _AddProductStep2ScreenState();
}

class _AddProductStep2ScreenState extends State<AddProductStep2Screen> {
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _priceController.text = widget.price;
    _unitController.text = widget.unit;
    _stockController.text = widget.stockQuantity;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _unitController.dispose();
    _stockController.dispose();
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
                // Header Row with Back Button, Indicators, and Spacer
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
                          final isActive = index <= 1; // Stage 2 is index 1
                          final isCurrent = index == 1;
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
                  'Category & Pricing',
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
                      'Stage 2 of 6',
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
                            widthFactor: 2 / 6, // 33% for stage 2
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
                  // Product Category Section
                  _buildCategorySection(theme, isDark),
                  const SizedBox(height: 24),

                  // Pricing Information Section
                  _buildPricingSection(theme, isDark),
                  const SizedBox(height: 24),

                  // Stock Information Section
                  _buildStockSection(theme, isDark),
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

  Widget _buildCategorySection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : const Color(0xFFE2E8F0).withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Category',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the category that best describes your product.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: isDark
                  ? const Color(0xFFA1A1AA)
                  : const Color(0xFF71717A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFD4D4D8)
                      : const Color(0xFF3F3F46),
                ),
              ),
              const SizedBox(height: 8),
              CategoryPicker(
                selectedCategory: _selectedCategory,
                categories: widget.categories,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _notifyDataChanged();
                },
                hintText: 'Select Category',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : const Color(0xFFE2E8F0).withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Price and Unit vertically aligned in a single column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price *',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFD4D4D8)
                          : const Color(0xFF3F3F46),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => _notifyDataChanged(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFFA1A1AA),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Text(
                          'Rs',
                          style: TextStyle(
                            fontSize: 19.2, // 20% larger than 16
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF225FEC),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Unit Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit *',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFD4D4D8)
                          : const Color(0xFF3F3F46),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _unitController,
                    onChanged: (value) => _notifyDataChanged(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., 1kg',
                      hintStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFFA1A1AA),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: CustomIcon(
                          assetPath: AppIcons.productUnit,
                          size: 22,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF225FEC),
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withOpacity(0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : const Color(0xFFE2E8F0).withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock Quantity *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFD4D4D8)
                      : const Color(0xFF3F3F46),
                ),
              ),
              const SizedBox(height: 8),
                  TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                onChanged: (value) => _notifyDataChanged(),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF71717A)
                        : const Color(0xFFA1A1AA),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: CustomIcon(
                      assetPath: AppIcons.stockQuantity,
                      size: 24.2, // 10% larger than 22
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF225FEC),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF225FEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.info,
                  size: 20,
                  color: const Color(0xFF225FEC),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Higher stock quantities can improve product visibility.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFD4D4D8)
                          : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _notifyDataChanged() {
    widget.onDataChanged(
      _selectedCategory,
      _priceController.text,
      _unitController.text,
      _stockController.text,
    );
  }
}
