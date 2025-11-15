import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    debugPrint('CategoryPicker: _filterCategories called with: "$query"');
    debugPrint('CategoryPicker: Current filtered categories count: ${_filteredCategories.length}');
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
        debugPrint('CategoryPicker: Showing all ${widget.categories.length} categories');
      } else {
        final lowercaseQuery = query.toLowerCase();
        
        // Create a list of categories with their priority scores
        List<MapEntry<String, int>> categoryScores = [];
        
        for (String category in widget.categories) {
          final lowercaseCategory = category.toLowerCase();
          int score = 0;
          
          // Priority 1: Exact match
          if (lowercaseCategory == lowercaseQuery) {
            score = 1000;
          }
          // Priority 2: Starts with query
          else if (lowercaseCategory.startsWith(lowercaseQuery)) {
            score = 500;
          }
          // Priority 3: Word starts with query (space-separated words)
          else if (lowercaseCategory.split(' ').any((word) => word.startsWith(lowercaseQuery))) {
            score = 300;
          }
          // Priority 4: Contains query at the beginning of a word
          else if (lowercaseCategory.split(' ').any((word) => word.contains(lowercaseQuery) && word.indexOf(lowercaseQuery) == 0)) {
            score = 200;
          }
          // Priority 5: Contains query anywhere
          else if (lowercaseCategory.contains(lowercaseQuery)) {
            score = 100;
          }
          
          // Only add categories that match the query
          if (score > 0) {
            categoryScores.add(MapEntry(category, score));
          }
        }
        
        // Sort by score (highest first), then alphabetically
        categoryScores.sort((a, b) {
          if (a.value != b.value) {
            return b.value.compareTo(a.value); // Higher score first
          }
          return a.key.compareTo(b.key); // Alphabetical for same score
        });
        
        _filteredCategories = categoryScores.map((entry) => entry.key).toList();
        debugPrint('CategoryPicker: Found ${_filteredCategories.length} matching categories');
        debugPrint('CategoryPicker: Filtered categories: ${_filteredCategories.take(5).join(", ")}${_filteredCategories.length > 5 ? "..." : ""}');
      }
    });
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
          child: _buildCategoryPickerModal(),
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
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
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
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: const CircleBorder(),
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
              textInputAction: TextInputAction.search,
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
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ),
              onChanged: (value) {
                debugPrint('CategoryPicker: onChanged called with: "$value"');
                _filterCategories(value);
                setState(() {}); // Force rebuild to update suffix icon
              },
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    key: ValueKey(_filteredCategories.length), // Force rebuild when list changes
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected = category == widget.selectedCategory;
                      final searchQuery = _searchController.text.toLowerCase();
                      final matchType = _getMatchType(category, searchQuery);
                      
                      debugPrint('CategoryPicker: Building item $index: "$category"');

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
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                    : _getBackgroundColor(context, matchType),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        width: 1,
                                      )
                                    : _getBorderColor(context, matchType),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getMatchIcon(matchType),
                                    size: 20,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : _getIconColor(context, matchType),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : _getTextColor(context, matchType),
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
                                      color: Theme.of(context).colorScheme.primary,
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
    if (lowercaseCategory.split(' ').any((word) => word.startsWith(lowercaseQuery))) return 'word_starts';
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
        return Border.all(color: theme.colorScheme.primary.withOpacity(0.4), width: 1);
      case 'starts':
        return Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 1);
      default:
        return null;
    }
  }

  Color _getIconColor(BuildContext context, String matchType) {
    final theme = Theme.of(context);
    switch (matchType) {
      case 'exact':
      case 'starts':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurfaceVariant;
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

  IconData _getMatchIcon(String matchType) {
    switch (matchType) {
      case 'exact':
        return LucideIcons.star;
      case 'starts':
        return LucideIcons.arrowRight;
      case 'word_starts':
        return LucideIcons.search;
      default:
        return LucideIcons.tag;
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
              Icon(
                LucideIcons.tag,
                color: theme.colorScheme.primary,
                size: 20,
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
