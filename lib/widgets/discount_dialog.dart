import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';

class DiscountDialog extends StatefulWidget {
  final Product product;
  final Function(Product) onDiscountApplied;

  const DiscountDialog({
    super.key,
    required this.product,
    required this.onDiscountApplied,
  });

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _percentageController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPercentageDiscount = true;
  bool _hasEndDate = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.product.isDiscounted) {
      _isPercentageDiscount = widget.product.discountPercentage != null;
      _percentageController.text =
          widget.product.discountPercentage?.toString() ?? '';
      _priceController.text = widget.product.discountPrice?.toString() ?? '';
      _startDate = widget.product.discountStartDate;
      _endDate = widget.product.discountEndDate;
      _hasEndDate = _endDate != null;
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyDiscount() {
    if (!_formKey.currentState!.validate()) return;

    final percentage = _isPercentageDiscount
        ? double.tryParse(_percentageController.text)
        : null;
    final discountPrice =
        !_isPercentageDiscount ? double.tryParse(_priceController.text) : null;

    if (_isPercentageDiscount &&
        (percentage == null || percentage <= 0 || percentage >= 100)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid percentage (1-99%)')),
      );
      return;
    }

    if (!_isPercentageDiscount &&
        (discountPrice == null ||
            discountPrice <= 0 ||
            discountPrice >= widget.product.price)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please enter a valid discount price (less than \$${widget.product.price.toStringAsFixed(2)})')),
      );
      return;
    }

    final updatedProduct = widget.product.copyWith(
      discountPercentage: percentage,
      discountPrice: discountPrice,
      discountStartDate: _startDate ?? DateTime.now(),
      discountEndDate: _hasEndDate ? _endDate : null,
      isDiscounted: true,
      updatedAt: DateTime.now(),
    );

    widget.onDiscountApplied(updatedProduct);
    Navigator.of(context).pop();
  }

  void _removeDiscount() {
    debugPrint(
        'DiscountDialog: Removing discount from product: ${widget.product.name}');
    debugPrint(
        'DiscountDialog: Original isDiscounted: ${widget.product.isDiscounted}');
    debugPrint(
        'DiscountDialog: Original discountPercentage: ${widget.product.discountPercentage}');

    final updatedProduct = widget.product.copyWith(
      discountPercentage: null,
      discountPrice: null,
      discountStartDate: null,
      discountEndDate: null,
      isDiscounted: false,
      updatedAt: DateTime.now(),
    );

    debugPrint(
        'DiscountDialog: Updated isDiscounted: ${updatedProduct.isDiscounted}');
    debugPrint(
        'DiscountDialog: Updated discountPercentage: ${updatedProduct.discountPercentage}');
    debugPrint(
        'DiscountDialog: Updated discountBadgeText: ${updatedProduct.discountBadgeText}');

    widget.onDiscountApplied(updatedProduct);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.local_offer, color: theme.primaryColor),
          const SizedBox(width: 8),
          const Text('Apply Discount'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Original Price: \$${widget.product.price.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Discount Type Selection
              Text(
                'Discount Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Percentage'),
                      value: true,
                      groupValue: _isPercentageDiscount,
                      onChanged: (value) {
                        setState(() {
                          _isPercentageDiscount = value!;
                          _percentageController.clear();
                          _priceController.clear();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Fixed Price'),
                      value: false,
                      groupValue: _isPercentageDiscount,
                      onChanged: (value) {
                        setState(() {
                          _isPercentageDiscount = value!;
                          _percentageController.clear();
                          _priceController.clear();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Discount Value Input
              if (_isPercentageDiscount) ...[
                TextFormField(
                  controller: _percentageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Discount Percentage',
                    hintText: 'e.g., 20',
                    suffixText: '%',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter discount percentage';
                    }
                    final percentage = double.tryParse(value);
                    if (percentage == null ||
                        percentage <= 0 ||
                        percentage >= 100) {
                      return 'Enter a valid percentage (1-99%)';
                    }
                    return null;
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Discount Price',
                    hintText: 'e.g., 15.99',
                    prefixText: '\$',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Must be less than \$${widget.product.price.toStringAsFixed(2)}',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter discount price';
                    }
                    final price = double.tryParse(value);
                    if (price == null ||
                        price <= 0 ||
                        price >= widget.product.price) {
                      return 'Enter a valid discount price';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Start Date
              Text(
                'Start Date',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Select start date',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date Toggle
              CheckboxListTile(
                title: const Text('Set end date'),
                value: _hasEndDate,
                onChanged: (value) {
                  setState(() {
                    _hasEndDate = value ?? false;
                    if (!_hasEndDate) {
                      _endDate = null;
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              // End Date
              if (_hasEndDate) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Select end date',
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Preview
              if (_isPercentageDiscount &&
                  _percentageController.text.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discount Preview',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Original: \$${widget.product.price.toStringAsFixed(2)}',
                      ),
                      Text(
                        'Discounted: \$${widget.product.currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'You save: \$${widget.product.savingsAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (widget.product.isDiscounted) ...[
          TextButton(
            onPressed: _removeDiscount,
            child: Text(
              'Remove Discount',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyDiscount,
          child: Text(widget.product.isDiscounted
              ? 'Update Discount'
              : 'Apply Discount'),
        ),
      ],
    );
  }
}
