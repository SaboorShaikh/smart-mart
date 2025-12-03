import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';

class AddProductStep4Screen extends StatefulWidget {
  final String detailedDescription;
  final String features;
  final String storageInstructions;
  final String allergens;
  final Function(String, String, String, String) onDataChanged;
  final VoidCallback? onStartOver;

  const AddProductStep4Screen({
    super.key,
    required this.detailedDescription,
    required this.features,
    required this.storageInstructions,
    required this.allergens,
    required this.onDataChanged,
    this.onStartOver,
  });

  @override
  State<AddProductStep4Screen> createState() => _AddProductStep4ScreenState();
}

class _AddProductStep4ScreenState extends State<AddProductStep4Screen> {
  final _detailedDescriptionController = TextEditingController();
  final _featuresController = TextEditingController();
  final _storageInstructionsController = TextEditingController();
  final _allergensController = TextEditingController();
  
  final List<String> _featuresList = [];
  final List<String> _storageList = [];
  final List<String> _allergensList = [];

  @override
  void initState() {
    super.initState();
    // Only fill detailed description text field
    _detailedDescriptionController.text = widget.detailedDescription;
    // Keep other text fields empty - only populate lists for display
    _featuresController.text = '';
    _storageInstructionsController.text = '';
    _allergensController.text = '';
    
    // Parse comma-separated features into list (for chips display)
    if (widget.features.isNotEmpty) {
      _featuresList.addAll(
        widget.features.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty),
      );
    }
    // Parse storage instructions (can be comma-separated) (for numbered list display)
    if (widget.storageInstructions.isNotEmpty) {
      _storageList.addAll(
        widget.storageInstructions.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
    }
    // Parse comma-separated allergens into list (for numbered list display)
    if (widget.allergens.isNotEmpty) {
      _allergensList.addAll(
        widget.allergens.split(',').map((a) => a.trim()).where((a) => a.isNotEmpty),
      );
    }
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
                            final isActive = index <= 3; // Stage 4 is index 3
                            final isCurrent = index == 3;
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
                    'Detailed Information',
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
                        'Stage 4 of 6',
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
                              widthFactor: 4 / 6, // 66.67% for stage 4
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
                    // Subtitle/Instructions
                    Text(
                      'Add descriptions, key features, storage instructions, and allergies.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: isDark
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Detailed Description
                    _buildDetailedDescriptionSection(theme, isDark),
                    const SizedBox(height: 24),

                    // Features
                    _buildFeaturesSection(theme, isDark),
                    const SizedBox(height: 24),

                    // Storage Instructions
                    _buildStorageSection(theme, isDark),
                    const SizedBox(height: 24),

                    // Allergens
                    _buildAllergensSection(theme, isDark),
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

  Widget _buildDetailedDescriptionSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _detailedDescriptionController,
          onChanged: (value) => _notifyDataChanged(),
          maxLines: 5,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF18181B),
          ),
          decoration: InputDecoration(
            hintText: 'Enter a full product description...',
            hintStyle: TextStyle(
              fontSize: 16,
              color: isDark
                  ? const Color(0xFF71717A)
                  : const Color(0xFFA1A1AA),
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
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 8),
        // Input field with arrow icon
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _featuresController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _featuresList.add(value.trim());
                    _featuresController.clear();
                    _notifyDataChanged();
                  });
                }
              },
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
              decoration: InputDecoration(
                hintText: 'e.g., \'Organic\', \'Handmade\'',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA1A1AA),
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
            Positioned(
              right: 12,
              child: IconButton(
                icon: Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF64748B),
                ),
                onPressed: () {
                  if (_featuresController.text.trim().isNotEmpty) {
                    setState(() {
                      _featuresList.add(_featuresController.text.trim());
                      _featuresController.clear();
                      _notifyDataChanged();
                    });
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        // Tags/Chips
        if (_featuresList.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _featuresList.map((feature) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFD4D4D8)
                            : const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _featuresList.remove(feature);
                          _notifyDataChanged();
                        });
                      },
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStorageSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Instructions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 8),
        // Input field with arrow icon
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _storageInstructionsController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _storageList.add(value.trim());
                    _storageInstructionsController.clear();
                    _notifyDataChanged();
                  });
                }
              },
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
              decoration: InputDecoration(
                hintText: 'e.g., \'Refrigerate after opening\'',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA1A1AA),
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
            Positioned(
              right: 12,
              child: IconButton(
                icon: Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF64748B),
                ),
                onPressed: () {
                  if (_storageInstructionsController.text.trim().isNotEmpty) {
                    setState(() {
                      _storageList.add(_storageInstructionsController.text.trim());
                      _storageInstructionsController.clear();
                      _notifyDataChanged();
                    });
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        // Numbered List
        if (_storageList.isNotEmpty) ...[
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _storageList.asMap().entries.map((entry) {
              final index = entry.key;
              final storage = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFD4D4D8)
                            : const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        storage,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFD4D4D8)
                              : const Color(0xFF18181B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _storageList.removeAt(index);
                          _notifyDataChanged();
                        });
                      },
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAllergensSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allergies Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 8),
        // Input field with arrow icon
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _allergensController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _allergensList.add(value.trim());
                    _allergensController.clear();
                    _notifyDataChanged();
                  });
                }
              },
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
              decoration: InputDecoration(
                hintText: 'e.g., \'Contains nuts\', \'Gluten-free\'',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA1A1AA),
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
            Positioned(
              right: 12,
              child: IconButton(
                icon: Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFF64748B),
                ),
                onPressed: () {
                  if (_allergensController.text.trim().isNotEmpty) {
                    setState(() {
                      _allergensList.add(_allergensController.text.trim());
                      _allergensController.clear();
                      _notifyDataChanged();
                    });
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        // Numbered List
        if (_allergensList.isNotEmpty) ...[
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _allergensList.asMap().entries.map((entry) {
              final index = entry.key;
              final allergen = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFD4D4D8)
                            : const Color(0xFF18181B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        allergen,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFD4D4D8)
                              : const Color(0xFF18181B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _allergensList.removeAt(index);
                          _notifyDataChanged();
                        });
                      },
                      child: Icon(
                        LucideIcons.x,
                        size: 16,
                        color: isDark
                            ? const Color(0xFF71717A)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _notifyDataChanged() {
    widget.onDataChanged(
      _detailedDescriptionController.text,
      _featuresList.join(', '),
      _storageList.join(', '),
      _allergensList.join(', '),
    );
  }
}
