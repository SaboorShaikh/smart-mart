import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'custom_card.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/data_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final User? vendor;
  final bool showStock;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showAddButton;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? imagePadding;

  const ProductCard({
    super.key,
    required this.product,
    this.vendor,
    this.showStock = false,
    this.onTap,
    this.onAddToCart,
    this.showAddButton = true,
    this.onLongPress,
    this.imagePadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If vendor is provided, use it directly
    if (vendor != null && vendor!.role == UserRole.vendor && vendor is Vendor) {
      return _buildCard(context, theme);
    }

    // If no vendor provided, try to get it from DataProvider synchronously
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return _buildCard(context, theme);
      },
    );
  }

  Widget _buildCard(BuildContext context, ThemeData theme) {
    return CustomCard(
      onTap: onTap,
      onLongPress: onLongPress,
      isClickable: true,
      padding: EdgeInsets.zero,
      color: Colors.white,
      elevation: 6.0,
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.3),
        width: 1,
      ),
      child: SizedBox(
        height: 320, // Further decreased by 10px for more compact cards
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Discount Badge
            Padding(
              padding: imagePadding ?? EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    product.isDiscounted && product.discountBadgeText.isNotEmpty
                        ? Banner(
                            message: product.discountBadgeText.toUpperCase(),
                            location: BannerLocation.topEnd,
                            layoutDirection: TextDirection.ltr,
                            color: theme.colorScheme.primary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                            child: _buildProductImage(theme),
                          )
                        : _buildProductImage(theme),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _capitalize(product.name),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Description - removed to save space

                    // Price and Add Button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Current Price (discounted or original)
                              Builder(
                                builder: (context) {
                                  debugPrint(
                                      'ProductCard: Price display for ${product.name} - currentPrice: ${product.currentPrice}, originalPrice: ${product.originalPrice}, isDiscounted: ${product.isDiscounted}');
                                  return Text(
                                    '₨${product.currentPrice.toStringAsFixed(0)}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: product.isDiscounted
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                              // Original Price (if discounted)
                              if (product.isDiscounted &&
                                  product.currentPrice !=
                                      product.originalPrice) ...[
                                const SizedBox(height: 1),
                                Text(
                                  '₨${product.originalPrice.toStringAsFixed(0)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (showAddButton) ...[
                          const SizedBox(
                              width: 4), // Further reduced to prevent overflow
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (onAddToCart != null) {
                                  onAddToCart!();
                                } else {
                                  _showQuantitySheet(context);
                                }
                              },
                              customBorder: const CircleBorder(),
                              child: Ink(
                                width: 28, // Reduced from 32 to 28
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 3, // Reduced from 4 to 3
                                      offset: const Offset(0, 1), // Reduced
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    LucideIcons.plus,
                                    size: 14, // Reduced from 16 to 14
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Stock Info
                    if (showStock) ...[
                      const SizedBox(
                          height: 3), // Increased for larger card spacing
                      Text(
                        'Stock: ${product.stock}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: product.stock < 10
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 11, // Increased for larger card
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Widget _buildProductImage(ThemeData theme) {
    return CachedNetworkImage(
      imageUrl: product.images.isNotEmpty
          ? product.images.first
          : 'https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg?auto=compress&cs=tinysrgb&w=400',
      height: 135,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 135,
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint(
            'ProductCard: Image loading error for product ${product.name}: $error');
        debugPrint('ProductCard: Image URL: $url');
        return Container(
          height: 135,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Image Error',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuantitySheet(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<DataProvider>(context, listen: false);
    int qty = 1;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₨${product.currentPrice.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => setState(() => qty = qty > 1 ? qty - 1 : 1),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.minus,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$qty',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => setState(() => qty++),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.plus,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                        provider.addToCart(product, qty);
                        Get.back();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${product.name} x$qty added to cart'),
                          ),
                        );
                      } catch (e) {
                        debugPrint(
                            'Error adding to cart from quantity sheet: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error adding to cart. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
