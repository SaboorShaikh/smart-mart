import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_input.dart';

class AddProductStep5Screen extends StatefulWidget {
  final String nutritionInfo;
  final Function(String) onDataChanged;

  const AddProductStep5Screen({
    super.key,
    required this.nutritionInfo,
    required this.onDataChanged,
  });

  @override
  State<AddProductStep5Screen> createState() => _AddProductStep5ScreenState();
}

class _AddProductStep5ScreenState extends State<AddProductStep5Screen> {
  final _nutritionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nutritionController.text = widget.nutritionInfo;
  }

  @override
  void dispose() {
    _nutritionController.dispose();
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
                    LucideIcons.activity,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 5: Nutrition Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Add nutritional information for your product',
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

            // Nutrition Input
            _buildNutritionInputSection(theme),
            const SizedBox(height: 24),

            // Quick Add Nutrition
            _buildQuickAddSection(theme),
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
                      'Enter nutrition information in the format: "Nutrient: Value, Nutrient: Value" (e.g., "Calories: 100, Protein: 5g, Fat: 2g")',
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

  Widget _buildNutritionInputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter nutritional values separated by commas',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        CustomInput(
          value: _nutritionController.text,
          label: 'Nutrition Details',
          hint: 'e.g., Calories: 100, Protein: 5g, Fat: 2g, Carbs: 15g',
          prefixIcon: Icon(LucideIcons.activity),
          onChanged: (value) {
            _nutritionController.text = value;
            widget.onDataChanged(value);
          },
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildQuickAddSection(ThemeData theme) {
    final commonNutrition = [
      'Calories: 100',
      'Protein: 5g',
      'Fat: 2g',
      'Carbs: 15g',
      'Fiber: 3g',
      'Sugar: 8g',
      'Sodium: 200mg',
      'Vitamin C: 20mg',
      'Iron: 2mg',
      'Calcium: 100mg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add Common Nutrients',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add common nutritional values',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonNutrition.map((nutrition) {
            return FilterChip(
              label: Text(nutrition),
              onSelected: (selected) {
                if (selected) {
                  _addNutrition(nutrition);
                }
              },
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addNutrition(String nutrition) {
    final currentText = _nutritionController.text.trim();
    if (currentText.isEmpty) {
      _nutritionController.text = nutrition;
    } else {
      _nutritionController.text = '$currentText, $nutrition';
    }
    widget.onDataChanged(_nutritionController.text);
  }
}
