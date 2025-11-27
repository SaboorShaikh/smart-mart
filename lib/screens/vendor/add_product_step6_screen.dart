import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/custom_input.dart';

class AddProductStep6Screen extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onDataChanged;

  const AddProductStep6Screen({
    super.key,
    required this.tags,
    required this.onDataChanged,
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
