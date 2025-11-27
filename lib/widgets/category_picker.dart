import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/categories.dart';

class CategoryPicker extends StatefulWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final String hintText;

  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    this.hintText = 'Select Category',
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCategories = [];
  StateSetter? _bottomSheetSetState;

  @override
  void initState() {
    super.initState();
    _filteredCategories = List<String>.from(widget.categories);

    // Live search: filter immediately on every keystroke
    _searchController.addListener(() {
      final value = _searchController.text;
      debugPrint('CategoryPicker: controller listener value = "$value"');
      _filterCategories(value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bottomSheetSetState = null;
    super.dispose();
  }

  void _filterCategories(String query) {
    debugPrint('CategoryPicker: _filterCategories called with: "$query"');

    // Helper to update list and rebuild bottom sheet
    void applyUpdate(List<String> updated) {
      _filteredCategories = updated;
      if (_bottomSheetSetState != null) {
        _bottomSheetSetState!(() {});
      } else {
        setState(() {});
      }
    }

    if (query.isEmpty || query.trim().isEmpty) {
      final all = List<String>.from(widget.categories);
      debugPrint('CategoryPicker: Showing all ${all.length} categories');
      applyUpdate(all);
      return;
    }

    final lowercaseQuery = query.toLowerCase().trim();

    List<String> startsWithQuery = [];
    List<String> containsQuery = [];

    for (String category in widget.categories) {
      final lowercaseCategory = category.toLowerCase();

      if (lowercaseCategory.startsWith(lowercaseQuery)) {
        startsWithQuery.add(category);
      } else if (lowercaseCategory.contains(lowercaseQuery)) {
        containsQuery.add(category);
      }
    }

    startsWithQuery.sort();
    containsQuery.sort();

    final result = List<String>.from([...startsWithQuery, ...containsQuery]);
    debugPrint(
        'CategoryPicker: Filtered to ${result.length} categories (starts: ${startsWithQuery.length}, contains: ${containsQuery.length})');
    applyUpdate(result);
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              _bottomSheetSetState = setModalState;
              return _buildCategoryPickerModal();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPickerModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterCategories('');
                        },
                        icon: const Icon(LucideIcons.x),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white, // White background for search field
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Categories list
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.search,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories found',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    key: ValueKey(
                        '${_filteredCategories.length}_${_searchController.text}'), // Force rebuild when list or search changes
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected = category == widget.selectedCategory;
                      final searchQuery = _searchController.text.toLowerCase();
                      final matchType = _getMatchType(category, searchQuery);

                      debugPrint(
                          'CategoryPicker: Building item $index: "$category"');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onCategorySelected(category);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1)
                                    : _getBackgroundColor(context, matchType),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        width: 1,
                                      )
                                    : _getBorderColor(context, matchType),
                              ),
                              child: Row(
                                children: [
                                  // Category SVG Icon (always in original color)
                                  _buildCategoryIcon(
                                    category,
                                    size:
                                        24, // Increased by 20% (20 * 1.2 = 24)
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : _getTextColor(
                                                    context, matchType),
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : _getFontWeight(matchType),
                                          ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      LucideIcons.check,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper methods for match type styling
  String _getMatchType(String category, String query) {
    if (query.isEmpty) return 'none';

    final lowercaseCategory = category.toLowerCase();
    final lowercaseQuery = query.toLowerCase();

    if (lowercaseCategory == lowercaseQuery) return 'exact';
    if (lowercaseCategory.startsWith(lowercaseQuery)) return 'starts';
    if (lowercaseCategory
        .split(' ')
        .any((word) => word.startsWith(lowercaseQuery))) {
      return 'word_starts';
    }
    if (lowercaseCategory.contains(lowercaseQuery)) return 'contains';
    return 'none';
  }

  Color _getBackgroundColor(BuildContext context, String matchType) {
    final theme = Theme.of(context);
    switch (matchType) {
      case 'exact':
        return theme.colorScheme.primary.withOpacity(0.15);
      case 'starts':
        return theme.colorScheme.primary.withOpacity(0.08);
      case 'word_starts':
        return theme.colorScheme.primary.withOpacity(0.05);
      default:
        return Colors.transparent;
    }
  }

  Border? _getBorderColor(BuildContext context, String matchType) {
    final theme = Theme.of(context);
    switch (matchType) {
      case 'exact':
        return Border.all(
            color: theme.colorScheme.primary.withOpacity(0.4), width: 1);
      case 'starts':
        return Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2), width: 1);
      default:
        return null;
    }
  }

  Color _getTextColor(BuildContext context, String matchType) {
    final theme = Theme.of(context);
    switch (matchType) {
      case 'exact':
      case 'starts':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  FontWeight _getFontWeight(String matchType) {
    switch (matchType) {
      case 'exact':
      case 'starts':
        return FontWeight.w600;
      default:
        return FontWeight.normal;
    }
  }

  // Helper function to get SVG path from category display name
  String _getCategorySvgPath(String categoryDisplayName) {
    final category = Categories.getCategoryByDisplayName(categoryDisplayName);
    if (category != null && category.iconPath.isNotEmpty) {
      return category.iconPath;
    }
    // Fallback: try to construct path from display name
    final normalizedName = categoryDisplayName
        .toLowerCase()
        .replaceAll(' & ', '_and_')
        .replaceAll(' ', '_')
        .replaceAll(',', '')
        .replaceAll("'", '');
    return 'assets/category_icons/$normalizedName.svg';
  }

  // Build category SVG icon widget (always in original color)
  Widget _buildCategoryIcon(String categoryDisplayName, {double? size}) {
    final svgPath = _getCategorySvgPath(categoryDisplayName);
    final iconSize = size ?? 24.0; // Default increased by 20% (20 * 1.2 = 24)

    try {
      return SvgPicture.asset(
        svgPath,
        width: iconSize,
        height: iconSize,
        // No colorFilter - keep original SVG colors
        placeholderBuilder: (context) => Icon(
          LucideIcons.tag,
          size: iconSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    } catch (e) {
      // Fallback to Lucide icon if SVG fails to load
      return Icon(
        LucideIcons.tag,
        size: iconSize,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _showCategoryPicker,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Category SVG Icon (always in original color)
              widget.selectedCategory.isNotEmpty
                  ? _buildCategoryIcon(
                      widget.selectedCategory,
                      size: 24, // Increased by 20% (20 * 1.2 = 24)
                    )
                  : Icon(
                      LucideIcons.tag,
                      color: theme.colorScheme.primary,
                      size: 24, // Increased by 20% (20 * 1.2 = 24)
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.selectedCategory.isNotEmpty
                      ? widget.selectedCategory
                      : widget.hintText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.selectedCategory.isNotEmpty
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronDown,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
