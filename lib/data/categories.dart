import 'package:flutter/material.dart';

class Category {
  final String name;
  final String displayName;
  final String iconPath;
  final Color? color;

  const Category({
    required this.name,
    required this.displayName,
    required this.iconPath,
    this.color,
  });
}

class Categories {
  static const List<Category> allCategories = [
    // Food & Groceries
    Category(
      name: 'fruits_and_vegetables',
      displayName: 'Fruits & Vegetables',
      iconPath: 'assets/category_icons/fruits_and_vegetables.svg',
      color: Color(0xFF4CAF50),
    ),
    Category(
      name: 'dairy_and_eggs',
      displayName: 'Dairy & Eggs',
      iconPath: 'assets/category_icons/dairy_and_eggs.svg',
      color: Color(0xFFFFF3E0),
    ),
    Category(
      name: 'meat_and_seafood',
      displayName: 'Meat & Seafood',
      iconPath: 'assets/category_icons/meat_and_seafood.svg',
      color: Color(0xFFE57373),
    ),
    Category(
      name: 'bakery_and_snacks',
      displayName: 'Bakery & Snacks',
      iconPath: 'assets/category_icons/bakery_and_snacks.svg',
      color: Color(0xFF8D6E63),
    ),
    Category(
      name: 'beverages_and_juices',
      displayName: 'Beverages & Juices',
      iconPath: 'assets/category_icons/beverages_and_juices.svg',
      color: Color(0xFF2196F3),
    ),
    Category(
      name: 'frozen_foods',
      displayName: 'Frozen Foods',
      iconPath: 'assets/category_icons/frozen_foods.svg',
      color: Color(0xFF81C784),
    ),
    Category(
      name: 'rice_pulses_and_grains',
      displayName: 'Rice, Pulses & Grains',
      iconPath: 'assets/category_icons/rice_pulses_and_grains.svg',
      color: Color(0xFF8D6E63),
    ),
    Category(
      name: 'cooking_oils_and_ghee',
      displayName: 'Cooking Oils & Ghee',
      iconPath: 'assets/category_icons/cooking_oils_and_ghee.svg',
      color: Color(0xFFFFB74D),
    ),
    Category(
      name: 'spices_and_masalas',
      displayName: 'Spices & Masalas',
      iconPath: 'assets/category_icons/spices_and_masalas.svg',
      color: Color(0xFFD32F2F),
    ),
    Category(
      name: 'baby_food',
      displayName: 'Baby Food',
      iconPath: 'assets/category_icons/baby_food.svg',
      color: Color(0xFFFFE0B2),
    ),
    Category(
      name: 'health_supplements',
      displayName: 'Health Supplements',
      iconPath: 'assets/category_icons/health_supplements.svg',
      color: Color(0xFF4CAF50),
    ),

    // Personal Care & Beauty
    Category(
      name: 'personal_care',
      displayName: 'Personal Care',
      iconPath: 'assets/category_icons/personal_care.svg',
      color: Color(0xFFE1BEE7),
    ),
    Category(
      name: 'hair_care',
      displayName: 'Hair Care',
      iconPath: 'assets/category_icons/hair_care.svg',
      color: Color(0xFF9C27B0),
    ),
    Category(
      name: 'skin_care',
      displayName: 'Skin Care',
      iconPath: 'assets/category_icons/skin_care.svg',
      color: Color(0xFFFFB3BA),
    ),
    Category(
      name: 'makeup_and_cosmetics',
      displayName: 'Makeup & Cosmetics',
      iconPath: 'assets/category_icons/makeup_and_cosmetics.svg',
      color: Color(0xFFE91E63),
    ),
    Category(
      name: 'fragrances_and_deodorants',
      displayName: 'Fragrances & Deodorants',
      iconPath: 'assets/category_icons/fragrances_and_deodorants.svg',
      color: Color(0xFF9C27B0),
    ),
    Category(
      name: 'shaving_and_grooming',
      displayName: 'Shaving & Grooming',
      iconPath: 'assets/category_icons/shaving_and_grooming.svg',
      color: Color(0xFF607D8B),
    ),
    Category(
      name: 'dental_care',
      displayName: 'Dental Care',
      iconPath: 'assets/category_icons/dental_care.svg',
      color: Color(0xFFE0F2F1),
    ),
    Category(
      name: 'feminine_hygiene',
      displayName: 'Feminine Hygiene',
      iconPath: 'assets/category_icons/feminine_hygiene.svg',
      color: Color(0xFFF8BBD9),
    ),

    // Household & Cleaning
    Category(
      name: 'household_cleaning',
      displayName: 'Household Cleaning',
      iconPath: 'assets/category_icons/surface_cleaners.svg',
      color: Color(0xFF4CAF50),
    ),
    Category(
      name: 'laundry_detergents',
      displayName: 'Laundry Detergents',
      iconPath: 'assets/category_icons/laundry_detergents.svg',
      color: Color(0xFF2196F3),
    ),
    Category(
      name: 'bathroom_cleaners',
      displayName: 'Bathroom Cleaners',
      iconPath: 'assets/category_icons/bathroom_cleaners.svg',
      color: Color(0xFF00BCD4),
    ),
    Category(
      name: 'dishwashing_supplies',
      displayName: 'Dishwashing Supplies',
      iconPath: 'assets/category_icons/dishwashing_supplies.svg',
      color: Color(0xFF4CAF50),
    ),
    Category(
      name: 'air_fresheners',
      displayName: 'Air Fresheners',
      iconPath: 'assets/category_icons/air_fresheners.svg',
      color: Color(0xFF8BC34A),
    ),
    Category(
      name: 'pest_control',
      displayName: 'Pest Control',
      iconPath: 'assets/category_icons/pest_control.svg',
      color: Color(0xFF795548),
    ),

    // Kitchen & Dining
    Category(
      name: 'cookware',
      displayName: 'Cookware',
      iconPath: 'assets/category_icons/cookware.svg',
      color: Color(0xFF607D8B),
    ),
    Category(
      name: 'kitchen_appliances',
      displayName: 'Kitchen Appliances',
      iconPath: 'assets/category_icons/kitchen_appliances.svg',
      color: Color(0xFF9E9E9E),
    ),
    Category(
      name: 'kitchen_storage',
      displayName: 'Kitchen Storage',
      iconPath: 'assets/category_icons/kitchen_storage.svg',
      color: Color(0xFF795548),
    ),
    Category(
      name: 'dinnerware',
      displayName: 'Dinnerware',
      iconPath: 'assets/category_icons/dinnerware.svg',
      color: Color(0xFFFFF8E1),
    ),
    Category(
      name: 'utensils',
      displayName: 'Utensils',
      iconPath: 'assets/category_icons/utensils.svg',
      color: Color(0xFF607D8B),
    ),

    // Home & Living
    Category(
      name: 'home_appliances',
      displayName: 'Home Appliances',
      iconPath: 'assets/category_icons/home_appliances.svg',
      color: Color(0xFF9E9E9E),
    ),
    Category(
      name: 'paper_products',
      displayName: 'Paper Products',
      iconPath: 'assets/category_icons/paper_products.svg',
      color: Color(0xFFFFF3E0),
    ),

    // Electronics & Technology
    Category(
      name: 'mobiles_and_tablets',
      displayName: 'Mobiles & Tablets',
      iconPath: 'assets/category_icons/mobiles_and_tablets.svg',
      color: Color(0xFF2196F3),
    ),
    Category(
      name: 'computers_and_laptops',
      displayName: 'Computers & Laptops',
      iconPath: 'assets/category_icons/computers_and_laptops.svg',
      color: Color(0xFF607D8B),
    ),
    Category(
      name: 'tvs_and_home_entertainment',
      displayName: 'TVs & Home Entertainment',
      iconPath: 'assets/category_icons/tvs_and_home_entertainment.svg',
      color: Color(0xFF9C27B0),
    ),
    Category(
      name: 'cameras_and_accessories',
      displayName: 'Cameras & Accessories',
      iconPath: 'assets/category_icons/cameras_and_accessories.svg',
      color: Color(0xFF424242),
    ),
    Category(
      name: 'headphones_and_earphones',
      displayName: 'Headphones & Earphones',
      iconPath: 'assets/category_icons/headphones_and_earphones.svg',
      color: Color(0xFF9C27B0),
    ),
    Category(
      name: 'smartwatches',
      displayName: 'Smartwatches',
      iconPath: 'assets/category_icons/smartwatches.svg',
      color: Color(0xFF2196F3),
    ),
    Category(
      name: 'watches',
      displayName: 'Watches',
      iconPath: 'assets/category_icons/watches.svg',
      color: Color(0xFF424242),
    ),

    // Fashion & Accessories
    Category(
      name: 'mens_clothing',
      displayName: 'Men\'s Clothing',
      iconPath: 'assets/category_icons/mens_clothing.svg',
      color: Color(0xFF2196F3),
    ),
    Category(
      name: 'womens_clothing',
      displayName: 'Women\'s Clothing',
      iconPath: 'assets/category_icons/womens_clothing.svg',
      color: Color(0xFFE91E63),
    ),
    Category(
      name: 'kids_clothing',
      displayName: 'Kids Clothing',
      iconPath: 'assets/category_icons/kids_clothing.svg',
      color: Color(0xFFFF9800),
    ),
    Category(
      name: 'footwear',
      displayName: 'Footwear',
      iconPath: 'assets/category_icons/footwear.svg',
      color: Color(0xFF8D6E63),
    ),
    Category(
      name: 'bags_and_wallets',
      displayName: 'Bags & Wallets',
      iconPath: 'assets/category_icons/bags_and_ wallets.svg', // Note: filename has space
      color: Color(0xFF795548),
    ),
    Category(
      name: 'surface_cleaners',
      displayName: 'Surface Cleaners',
      iconPath: 'assets/category_icons/surface_cleaners.svg',
      color: Color(0xFF4CAF50),
    ),
    Category(
      name: 'jewelry',
      displayName: 'Jewelry',
      iconPath: 'assets/category_icons/jewelry.svg',
      color: Color(0xFFFFD700),
    ),
    Category(
      name: 'sunglasses',
      displayName: 'Sunglasses',
      iconPath: 'assets/category_icons/sunglasses.svg',
      color: Color(0xFF424242),
    ),
  ];

  // Get category by name
  static Category? getCategoryByName(String name) {
    try {
      return allCategories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get category by display name
  static Category? getCategoryByDisplayName(String displayName) {
    try {
      return allCategories
          .firstWhere((category) => category.displayName == displayName);
    } catch (e) {
      return null;
    }
  }

  // Get all category names
  static List<String> getAllCategoryNames() {
    return allCategories.map((category) => category.name).toList();
  }

  // Get all category display names
  static List<String> getAllCategoryDisplayNames() {
    return allCategories.map((category) => category.displayName).toList();
  }

  // Search categories by query
  static List<Category> searchCategories(String query) {
    if (query.isEmpty) return allCategories;

    final lowercaseQuery = query.toLowerCase();
    return allCategories.where((category) {
      return category.name.toLowerCase().contains(lowercaseQuery) ||
          category.displayName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get categories by main category group
  static List<Category> getCategoriesByGroup(String group) {
    switch (group.toLowerCase()) {
      case 'food':
        return allCategories
            .where((category) => [
                  'fruits_and_vegetables',
                  'dairy_and_eggs',
                  'meat_and_seafood',
                  'bakery_and_snacks',
                  'beverages_and_juices',
                  'frozen_foods',
                  'rice_pulses_and_grains',
                  'cooking_oils_and_ghee',
                  'spices_and_masalas',
                  'baby_food',
                  'health_supplements'
                ].contains(category.name))
            .toList();
      case 'personal_care':
        return allCategories
            .where((category) => [
                  'personal_care',
                  'hair_care',
                  'skin_care',
                  'makeup_and_cosmetics',
                  'fragrances_and_deodorants',
                  'shaving_and_grooming',
                  'dental_care',
                  'feminine_hygiene'
                ].contains(category.name))
            .toList();
      case 'household':
        return allCategories
            .where((category) => [
                  'household_cleaning',
                  'laundry_detergents',
                  'bathroom_cleaners',
                  'dishwashing_supplies',
                  'air_fresheners',
                  'pest_control'
                ].contains(category.name))
            .toList();
      case 'kitchen':
        return allCategories
            .where((category) => [
                  'cookware',
                  'kitchen_appliances',
                  'kitchen_storage',
                  'dinnerware',
                  'utensils'
                ].contains(category.name))
            .toList();
      case 'electronics':
        return allCategories
            .where((category) => [
                  'mobiles_and_tablets',
                  'computers_and_laptops',
                  'tvs_and_home_entertainment',
                  'cameras_and_accessories',
                  'headphones_and_earphones',
                  'smartwatches',
                  'watches'
                ].contains(category.name))
            .toList();
      case 'fashion':
        return allCategories
            .where((category) => [
                  'mens_clothing',
                  'womens_clothing',
                  'kids_clothing',
                  'footwear',
                  'bags_and_wallets',
                  'jewelry',
                  'sunglasses'
                ].contains(category.name))
            .toList();
      default:
        return allCategories;
    }
  }
}

// Widget for displaying category icon
class CategoryIcon extends StatelessWidget {
  final String categoryName;
  final double? size;
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.categoryName,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final category = Categories.getCategoryByName(categoryName);
    if (category == null) {
      return Icon(
        Icons.category,
        size: size ?? 24,
        color: color ?? Colors.grey,
      );
    }

    // Use appropriate Material icons based on category type
    IconData iconData = _getCategoryIcon(category.name);

    return Icon(
      iconData,
      size: size ?? 24,
      color: color ?? Colors.grey,
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      // Food & Groceries
      case 'fruits_and_vegetables':
        return Icons.apple;
      case 'dairy_and_eggs':
        return Icons.local_drink;
      case 'meat_and_seafood':
        return Icons.set_meal;
      case 'bakery_and_snacks':
        return Icons.bakery_dining;
      case 'beverages_and_juices':
        return Icons.local_bar;
      case 'frozen_foods':
        return Icons.ac_unit;
      case 'rice_pulses_and_grains':
        return Icons.grain;
      case 'cooking_oils_and_ghee':
        return Icons.oil_barrel;
      case 'spices_and_masalas':
        return Icons.spa;
      case 'baby_food':
        return Icons.child_care;
      case 'health_supplements':
        return Icons.medication;

      // Personal Care & Beauty
      case 'personal_care':
        return Icons.person;
      case 'hair_care':
        return Icons.content_cut;
      case 'skin_care':
        return Icons.face;
      case 'makeup_and_cosmetics':
        return Icons.face_retouching_natural;
      case 'fragrances_and_deodorants':
        return Icons.air;
      case 'shaving_and_grooming':
        return Icons.content_cut;
      case 'dental_care':
        return Icons.health_and_safety;
      case 'feminine_hygiene':
        return Icons.female;

      // Household & Cleaning
      case 'household_cleaning':
        return Icons.cleaning_services;
      case 'laundry_detergents':
        return Icons.local_laundry_service;
      case 'bathroom_cleaners':
        return Icons.bathroom;
      case 'dishwashing_supplies':
        return Icons.cleaning_services;
      case 'air_fresheners':
        return Icons.air;
      case 'pest_control':
        return Icons.bug_report;

      // Kitchen & Dining
      case 'cookware':
        return Icons.kitchen;
      case 'kitchen_appliances':
        return Icons.microwave;
      case 'kitchen_storage':
        return Icons.storage;
      case 'dinnerware':
        return Icons.dinner_dining;
      case 'utensils':
        return Icons.restaurant;

      // Home & Living
      case 'home_appliances':
        return Icons.home;
      case 'paper_products':
        return Icons.description;

      // Electronics & Technology
      case 'mobiles_and_tablets':
        return Icons.phone_android;
      case 'computers_and_laptops':
        return Icons.laptop;
      case 'tvs_and_home_entertainment':
        return Icons.tv;
      case 'cameras_and_accessories':
        return Icons.camera_alt;
      case 'headphones_and_earphones':
        return Icons.headphones;
      case 'smartwatches':
        return Icons.watch;
      case 'watches':
        return Icons.access_time;

      // Fashion & Accessories
      case 'mens_clothing':
        return Icons.man;
      case 'womens_clothing':
        return Icons.woman;
      case 'kids_clothing':
        return Icons.child_friendly;
      case 'footwear':
        return Icons.directions_walk;
      case 'bags_and_wallets':
        return Icons.shopping_bag;
      case 'jewelry':
        return Icons.diamond;
      case 'sunglasses':
        return Icons.visibility;

      default:
        return Icons.category;
    }
  }
}

// Widget for displaying category with icon and name
class CategoryCard extends StatelessWidget {
  final String categoryName;
  final VoidCallback? onTap;
  final bool isSelected;
  final double? iconSize;
  final EdgeInsets? padding;

  const CategoryCard({
    super.key,
    required this.categoryName,
    this.onTap,
    this.isSelected = false,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = Categories.getCategoryByName(categoryName);

    if (category == null) {
      return Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category,
              size: iconSize ?? 24,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              categoryName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon(
              categoryName: categoryName,
              size: iconSize ?? 24,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              category.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
