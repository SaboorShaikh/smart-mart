import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    _startDate = DateTime.now();
  }

  void _initializeFields() {
    if (widget.product.isDiscounted) {
      _isPercentageDiscount = widget.product.discountPercentage != null;
      _percentageController.text =
          widget.product.discountPercentage?.toString() ?? '';
      // For Fixed Amount, calculate discount amount from stored discounted price
      if (widget.product.discountPrice != null && !_isPercentageDiscount) {
        final discountAmount = widget.product.price - widget.product.discountPrice!;
        _priceController.text = discountAmount.toStringAsFixed(2);
      } else {
        _priceController.text = widget.product.discountPrice?.toString() ?? '';
      }
      _startDate = widget.product.discountStartDate ?? DateTime.now();
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

  double? _calculateNewPrice() {
    if (_isPercentageDiscount) {
      final percentage = double.tryParse(_percentageController.text);
      if (percentage != null && percentage > 0 && percentage < 100) {
        return widget.product.price * (1 - percentage / 100);
      }
    } else {
      final discountAmount = double.tryParse(_priceController.text);
      if (discountAmount != null && discountAmount > 0 && discountAmount < widget.product.price) {
        // Subtract the discount amount from original price
        return widget.product.price - discountAmount;
      }
    }
    return null;
  }

  double? _calculateSavings() {
    final newPrice = _calculateNewPrice();
    if (newPrice != null) {
      return widget.product.price - newPrice;
    }
    return null;
  }

  void _applyDiscount() {
    if (!_formKey.currentState!.validate()) return;

    final percentage = _isPercentageDiscount
        ? double.tryParse(_percentageController.text)
        : null;
    final discountAmount =
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
        (discountAmount == null ||
            discountAmount <= 0 ||
            discountAmount >= widget.product.price)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please enter a valid discount amount (less than ₨${_formatPrice(widget.product.price)})')),
      );
      return;
    }

    // Calculate the final discounted price for Fixed Amount mode
    final discountPrice = !_isPercentageDiscount
        ? widget.product.price - discountAmount!
        : null;

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return text;
    final leadingSpaces = text.length - trimmed.length;
    final prefix = text.substring(0, leadingSpaces);
    return '$prefix${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    }
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final newPrice = _calculateNewPrice();
    final savings = _calculateSavings();
    final hasValidDiscount = newPrice != null && savings != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                children: [
                  Text(
                    'Add Discount',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set discount for this product',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Product Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: widget.product.images.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.product.images.first,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 48,
                                        height: 48,
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 48,
                                        height: 48,
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: theme.colorScheme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Product Name and Price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _capitalize(widget.product.name),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Original Price: ₨${_formatPrice(widget.product.price)}',
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

                      // Discount Type
                      Text(
                        'Discount Type',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Sliding background indicator
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                              alignment: _isPercentageDiscount
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                heightFactor: 1.0,
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            // Buttons Row
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isPercentageDiscount = true;
                                        _percentageController.clear();
                                        _priceController.clear();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      alignment: Alignment.center,
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: _isPercentageDiscount
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ) ?? const TextStyle(),
                                        child: const Text(
                                          'Percentage (%)',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isPercentageDiscount = false;
                                        _percentageController.clear();
                                        _priceController.clear();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      alignment: Alignment.center,
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: !_isPercentageDiscount
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ) ?? const TextStyle(),
                                        child: const Text(
                                          'Fixed Amount',
                                          textAlign: TextAlign.center,
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
                      const SizedBox(height: 16),

                      // Discount Value
                      Row(
                        children: [
                          Text(
                            'Discount Value',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.3, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOut,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            child: !_isPercentageDiscount
                                ? Text(
                                    'Must be less than ₨${_formatPrice(widget.product.price)}',
                                    key: const ValueKey('helper-text'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : const SizedBox.shrink(key: ValueKey('empty')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: _isPercentageDiscount
                            ? TextFormField(
                                key: const ValueKey('percentage'),
                                controller: _percentageController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                onChanged: (_) => setState(() {}),
                                style: theme.textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: '20',
                                  prefixText: '% ',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
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
                              )
                            : TextFormField(
                                key: const ValueKey('fixed-amount'),
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                onChanged: (_) => setState(() {}),
                                style: theme.textTheme.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: '100',
                                  prefixText: '₨ ',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter discount amount';
                                  }
                                  final discountAmount = double.tryParse(value);
                                  if (discountAmount == null ||
                                      discountAmount <= 0 ||
                                      discountAmount >= widget.product.price) {
                                    return 'Enter a valid discount amount';
                                  }
                                  return null;
                                },
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Start Date
                      Text(
                        'Start Date',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _startDate != null
                                    ? _formatDate(_startDate!)
                                    : 'Select start date',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Set End Date Toggle
                      Row(
                        children: [
                          Text(
                            'Set End Date?',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _hasEndDate,
                            onChanged: (value) {
                              setState(() {
                                _hasEndDate = value;
                                if (!_hasEndDate) {
                                  _endDate = null;
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      // End Date
                      if (_hasEndDate) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color:
                                    theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _endDate != null
                                      ? _formatDate(_endDate!)
                                      : 'Select end date',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Discount Preview
                      if (hasValidDiscount) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'New Price: ₨${newPrice.toStringAsFixed(2)} (You save ₨${savings.toStringAsFixed(2)})',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This discount will automatically apply during the selected dates.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyDiscount,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.product.isDiscounted
                            ? 'Update Discount'
                            : 'Apply Discount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
