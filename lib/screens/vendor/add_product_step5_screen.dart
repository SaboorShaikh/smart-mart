import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../../widgets/custom_input.dart';

class AddProductStep5Screen extends StatefulWidget {
  final String nutritionInfo;
  final Function(String) onDataChanged;
  final VoidCallback? onStartOver;

  const AddProductStep5Screen({
    super.key,
    required this.nutritionInfo,
    required this.onDataChanged,
    this.onStartOver,
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
                            final isActive = index <= 4; // Stage 5 is index 4
                            final isCurrent = index == 4;
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
                    'Nutrition Information',
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
                        'Stage 5 of 6',
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
                              widthFactor: 5 / 6, // 83.33% for stage 5
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
