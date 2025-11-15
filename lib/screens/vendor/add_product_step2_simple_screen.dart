import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/category_picker.dart';

class AddProductStep2SimpleScreen extends StatefulWidget {
  final String selectedCategory;
  final String price;
  final String unit;
  final String stockQuantity;
  final List<String> categories;
  final Function(String, String, String, String) onDataChanged;

  const AddProductStep2SimpleScreen({
    super.key,
    required this.selectedCategory,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.categories,
    required this.onDataChanged,
  });

  @override
  State<AddProductStep2SimpleScreen> createState() =>
      _AddProductStep2SimpleScreenState();
}

class _AddProductStep2SimpleScreenState
    extends State<AddProductStep2SimpleScreen> {
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

    debugPrint(
        'SimpleStep2: Building with ${widget.categories.length} categories');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Step 2: Category & Pricing',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Product Category *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
              const SizedBox(height: 24),

              // Price
              Text(
                'Price *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: '0.00',
                  prefixIcon: const Icon(LucideIcons.dollarSign),
                ),
                onChanged: (value) {
                  _notifyDataChanged();
                },
              ),
              const SizedBox(height: 16),

              // Unit
              Text(
                'Unit *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'e.g., 1kg, 500g, 1 piece',
                  prefixIcon: const Icon(LucideIcons.package),
                ),
                onChanged: (value) {
                  _notifyDataChanged();
                },
              ),
              const SizedBox(height: 16),

              // Stock
              Text(
                'Stock Quantity *',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: '0',
                  prefixIcon: const Icon(LucideIcons.warehouse),
                ),
                onChanged: (value) {
                  _notifyDataChanged();
                },
              ),
            ],
          ),
        ),
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
