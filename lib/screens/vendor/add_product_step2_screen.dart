import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/category_picker.dart';

class AddProductStep2Screen extends StatefulWidget {
  final String selectedCategory;
  final String price;
  final String unit;
  final String stockQuantity;
  final List<String> categories;
  final Function(String, String, String, String) onDataChanged;

  const AddProductStep2Screen({
    super.key,
    required this.selectedCategory,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.categories,
    required this.onDataChanged,
  });

  @override
  State<AddProductStep2Screen> createState() => _AddProductStep2ScreenState();
}

class _AddProductStep2ScreenState extends State<AddProductStep2Screen> {
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.tag,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step 2: Category & Pricing',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Set category, price, unit and stock quantity',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Category Selection
                _buildCategorySection(theme),
                const SizedBox(height: 24),

                // Pricing Section
                _buildPricingSection(theme),
                const SizedBox(height: 24),

                // Stock Section
                _buildStockSection(theme),
                const SizedBox(height: 24),

                // Help text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Choose the appropriate category and set competitive pricing. Stock quantity helps customers know availability.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Category *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the category that best describes your product',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
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
    );
  }

  Widget _buildPricingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Information *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomInput(
                value: _priceController.text,
                label: 'Price *',
                hint: '0.00',
                keyboardType: TextInputType.number,
                prefixIcon: Icon(LucideIcons.dollarSign),
                onChanged: (value) {
                  _priceController.text = value;
                  _notifyDataChanged();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: CustomInput(
                value: _unitController.text,
                label: 'Unit *',
                hint: 'e.g., 1kg, 500g, 1 piece',
                prefixIcon: Icon(LucideIcons.package),
                onChanged: (value) {
                  _unitController.text = value;
                  _notifyDataChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Information *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          value: _stockController.text,
          label: 'Stock Quantity *',
          hint: '0',
          keyboardType: TextInputType.number,
          prefixIcon: Icon(LucideIcons.warehouse),
          onChanged: (value) {
            _stockController.text = value;
            _notifyDataChanged();
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Higher stock quantities can improve product visibility',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
