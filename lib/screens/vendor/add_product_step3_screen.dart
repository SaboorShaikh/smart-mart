import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_input.dart';

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

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    LucideIcons.package,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 3: Product Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Add brand, origin, expiry date and other details',
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

            // Brand Information
            _buildBrandSection(theme),
            const SizedBox(height: 24),

            // Origin Information
            _buildOriginSection(theme),
            const SizedBox(height: 24),

            // Expiry Date
            _buildExpirySection(theme),
            const SizedBox(height: 24),

            // Barcode & Manufacturer
            _buildAdditionalDetailsSection(theme),
            const SizedBox(height: 24),

            // Help text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                      'These details help customers make informed decisions and build trust in your products.',
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
    );
  }

  Widget _buildBrandSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          value: _brandController.text,
          label: 'Brand Name',
          hint: 'e.g., Naturel, Fresh Farm, Premium',
          prefixIcon: Icon(LucideIcons.award),
          onChanged: (value) {
            _brandController.text = value;
            _notifyDataChanged();
          },
        ),
      ],
    );
  }

  Widget _buildOriginSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Origin Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          value: _originController.text,
          label: 'Origin/Country',
          hint: 'e.g., Pakistan, India, Local',
          prefixIcon: Icon(LucideIcons.mapPin),
          onChanged: (value) {
            _originController.text = value;
            _notifyDataChanged();
          },
        ),
      ],
    );
  }

  Widget _buildExpirySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          value: _expiryDateController.text,
          label: 'Expiry Date',
          hint: 'DD/MM/YYYY',
          prefixIcon: Icon(LucideIcons.calendar),
          readOnly: true,
          onTap: () => _selectExpiryDate(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Leave empty if product doesn\'t expire',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          value: _barcodeController.text,
          label: 'Barcode',
          hint: 'Product barcode or SKU',
          prefixIcon: Icon(LucideIcons.scan),
          onChanged: (value) {
            _barcodeController.text = value;
            _notifyDataChanged();
          },
        ),
        const SizedBox(height: 16),
        CustomInput(
          value: _manufacturerController.text,
          label: 'Manufacturer',
          hint: 'Manufacturer name',
          prefixIcon: Icon(LucideIcons.factory),
          onChanged: (value) {
            _manufacturerController.text = value;
            _notifyDataChanged();
          },
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
