import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_input.dart';

class AddProductStep4Screen extends StatefulWidget {
  final String detailedDescription;
  final String features;
  final String storageInstructions;
  final String allergens;
  final Function(String, String, String, String) onDataChanged;

  const AddProductStep4Screen({
    super.key,
    required this.detailedDescription,
    required this.features,
    required this.storageInstructions,
    required this.allergens,
    required this.onDataChanged,
  });

  @override
  State<AddProductStep4Screen> createState() => _AddProductStep4ScreenState();
}

class _AddProductStep4ScreenState extends State<AddProductStep4Screen> {
  final _detailedDescriptionController = TextEditingController();
  final _featuresController = TextEditingController();
  final _storageInstructionsController = TextEditingController();
  final _allergensController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detailedDescriptionController.text = widget.detailedDescription;
    _featuresController.text = widget.features;
    _storageInstructionsController.text = widget.storageInstructions;
    _allergensController.text = widget.allergens;
  }

  @override
  void dispose() {
    _detailedDescriptionController.dispose();
    _featuresController.dispose();
    _storageInstructionsController.dispose();
    _allergensController.dispose();
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
            // Detailed Description
            _buildDetailedDescriptionSection(theme),
            const SizedBox(height: 24),

            // Features
            _buildFeaturesSection(theme),
            const SizedBox(height: 24),

            // Storage Instructions
            _buildStorageSection(theme),
            const SizedBox(height: 24),

            // Allergens
            _buildAllergensSection(theme),
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
                      'Detailed information helps customers understand your product better and builds trust.',
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

  Widget _buildDetailedDescriptionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide a comprehensive description of your product',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        CustomInput(
          value: _detailedDescriptionController.text,
          label: 'Detailed Description',
          hint:
              'Describe the product in detail, including quality, benefits, and unique selling points...',
          maxLines: 5,
          prefixIcon: Icon(LucideIcons.alignLeft),
          onChanged: (value) {
            _detailedDescriptionController.text = value;
            _notifyDataChanged();
          },
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'List the main features of your product',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        CustomInput(
          value: _featuresController.text,
          label: 'Features',
          hint:
              'e.g., Organic, Fresh, Local, Premium Quality (comma separated)',
          maxLines: 3,
          prefixIcon: Icon(LucideIcons.star),
          onChanged: (value) {
            _featuresController.text = value;
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
                LucideIcons.lightbulb,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Separate multiple features with commas',
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

  Widget _buildStorageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Instructions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell customers how to properly store the product',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        CustomInput(
          value: _storageInstructionsController.text,
          label: 'Storage Instructions',
          hint: 'e.g., Store in a cool, dry place. Refrigerate after opening.',
          maxLines: 3,
          prefixIcon: Icon(LucideIcons.thermometer),
          onChanged: (value) {
            _storageInstructionsController.text = value;
            _notifyDataChanged();
          },
        ),
      ],
    );
  }

  Widget _buildAllergensSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allergen Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'List any allergens present in the product',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        CustomInput(
          value: _allergensController.text,
          label: 'Allergens',
          hint: 'e.g., Contains nuts, dairy, gluten (comma separated)',
          maxLines: 2,
          prefixIcon: Icon(LucideIcons.alertTriangle),
          onChanged: (value) {
            _allergensController.text = value;
            _notifyDataChanged();
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.shield,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Important: Always list allergens for customer safety',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
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
      _detailedDescriptionController.text,
      _featuresController.text,
      _storageInstructionsController.text,
      _allergensController.text,
    );
  }
}
