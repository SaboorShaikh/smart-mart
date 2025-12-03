import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../../widgets/custom_input.dart';

class AddProductStep6Screen extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onDataChanged;
  final VoidCallback? onStartOver;

  const AddProductStep6Screen({
    super.key,
    required this.tags,
    required this.onDataChanged,
    this.onStartOver,
  });

  @override
  State<AddProductStep6Screen> createState() => _AddProductStep6ScreenState();
}

class _AddProductStep6ScreenState extends State<AddProductStep6Screen> {
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tags.addAll(widget.tags);
  }

  @override
  void dispose() {
    _tagController.dispose();
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
                            final isActive = index <= 5; // Stage 6 is index 5
                            final isCurrent = index == 5;
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
                    'Product Tags',
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
                        'Stage 6 of 6',
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
                              widthFactor: 6 / 6, // 100% for stage 6
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
                    // Tag Input
                    _buildTagInputSection(theme),
                    const SizedBox(height: 24),

                    // Quick Add Tags
                    _buildQuickAddSection(theme),
                    const SizedBox(height: 24),

                    // Tags Display
                    if (_tags.isNotEmpty) ...[
                      _buildTagsDisplaySection(theme),
                      const SizedBox(height: 24),
                    ],

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
                              'Tags help customers discover your product through search and filtering.',
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

  Widget _buildTagInputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Product Tags',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter tags separated by commas or press Enter to add individual tags',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        CustomInput(
          value: _tagController.text,
          label: 'Product Tags',
          hint: 'e.g., organic, fresh, local, premium',
          prefixIcon: Icon(LucideIcons.hash),
          onChanged: (value) {
            _tagController.text = value;
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addTag(value.trim());
            }
          },
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final text = _tagController.text.trim();
                  if (text.isNotEmpty) {
                    _addTag(text);
                  }
                },
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add Tag'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                final text = _tagController.text.trim();
                if (text.isNotEmpty) {
                  _addMultipleTags(text);
                }
              },
              icon: const Icon(LucideIcons.list, size: 16),
              label: const Text('Add All'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddSection(ThemeData theme) {
    final commonTags = [
      'organic',
      'fresh',
      'local',
      'premium',
      'healthy',
      'natural',
      'farm-fresh',
      'seasonal',
      'artisanal',
      'sustainable',
      'gluten-free',
      'dairy-free',
      'vegan',
      'vegetarian',
      'low-sugar',
      'high-protein',
      'low-fat',
      'no-preservatives',
      'handpicked',
      'quality-assured',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add Common Tags',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to add popular tags',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonTags.map((tag) {
            final isSelected = _tags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _addTag(tag);
                } else {
                  _removeTag(tag);
                }
              },
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsDisplaySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Tags (${_tags.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_tags.isNotEmpty)
              TextButton.icon(
                onPressed: _clearAllTags,
                icon: const Icon(LucideIcons.trash2, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () => _removeTag(tag),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              deleteIconColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag.toLowerCase())) {
      setState(() {
        _tags.add(tag.toLowerCase());
      });
      _tagController.clear();
      widget.onDataChanged(_tags);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag "$tag" added successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (tag.isNotEmpty && _tags.contains(tag.toLowerCase())) {
      // Show message if tag already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tag "$tag" already exists!'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addMultipleTags(String text) {
    final tags = text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    int addedCount = 0;
    for (final tag in tags) {
      if (!_tags.contains(tag.toLowerCase())) {
        _tags.add(tag.toLowerCase());
        addedCount++;
      }
    }

    setState(() {});
    _tagController.clear();
    widget.onDataChanged(_tags);

    // Show success message
    if (addedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '$addedCount tag${addedCount > 1 ? 's' : ''} added successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All tags already exist!'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onDataChanged(_tags);
  }

  void _clearAllTags() {
    setState(() {
      _tags.clear();
    });
    widget.onDataChanged(_tags);
  }
}
