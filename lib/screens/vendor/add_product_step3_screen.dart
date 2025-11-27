import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddProductStep3Screen extends StatefulWidget {
  final String brand;
  final String origin;
  final String expiryDate;
  final String barcode;
  final String manufacturer;
  final Function(String, String, String, String, String) onDataChanged;

  const AddProductStep3Screen({
    super.key,
    required this.brand,
    required this.origin,
    required this.expiryDate,
    required this.barcode,
    required this.manufacturer,
    required this.onDataChanged,
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Extra bottom padding for floating buttons
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const SizedBox(height: 24),
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
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                LucideIcons.award,
                size: 20,
                color: isDark
                    ? const Color(0xFF71717A)
                    : const Color(0xFF757575),
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
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                LucideIcons.mapPin,
                size: 20,
                color: isDark
                    ? const Color(0xFF71717A)
                    : const Color(0xFF757575),
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
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                LucideIcons.calendar,
                size: 20,
                color: isDark
                    ? const Color(0xFF71717A)
                    : const Color(0xFF757575),
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
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                LucideIcons.scan,
                size: 20,
                color: isDark
                    ? const Color(0xFF71717A)
                    : const Color(0xFF757575),
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
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                LucideIcons.factory,
                size: 20,
                color: isDark
                    ? const Color(0xFF71717A)
                    : const Color(0xFF757575),
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
