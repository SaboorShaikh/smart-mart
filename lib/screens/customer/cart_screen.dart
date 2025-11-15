import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_icon.dart';
import '../../models/order.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final cart = dataProvider.cart;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(theme)
          : Stack(
              children: [
                // Scrollable cart items with bottom padding to reveal floating panel
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 220),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 24,
                        thickness: 0.6,
                        color: theme.dividerColor.withOpacity(0.4),
                      ),
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return _buildCartItem(theme, item, dataProvider);
                      },
                    ),
                  ),
                ),

                // Floating checkout panel above the bottom nav bar
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      // Lift above the floating navbar in CustomerHomeScreen
                      padding: const EdgeInsets.only(bottom: 84),
                      child: _buildCheckoutSection(theme, cart),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIcon(
            assetPath: AppIcons.cart,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Start Shopping',
            onPressed: () => Get.toNamed('/customer/browse'),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      ThemeData theme, CartItem cartItem, DataProvider dataProvider) {
    final product = cartItem.product;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: product.images.isNotEmpty
                  ? product.images.first
                  : 'https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg?auto=compress&cs=tinysrgb&w=400',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80,
                height: 80,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.category}, Price',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          color: theme.colorScheme.onSurfaceVariant, size: 18),
                      onPressed: () => dataProvider.removeFromCart(product.id),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity controls styled like the Figma
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (cartItem.quantity > 1) {
                              dataProvider.updateCartQuantity(
                                  product.id, cartItem.quantity - 1);
                            } else {
                              dataProvider.removeFromCart(product.id);
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.minus,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${cartItem.quantity}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => dataProvider.updateCartQuantity(
                              product.id, cartItem.quantity + 1),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.plus,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₨${product.currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // trailing column removed (duplicate controls)
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(ThemeData theme, List<CartItem> cart) {
    final subtotal = cart.fold<double>(
        0.0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
    final deliveryFee = 50.0;
    final tax = subtotal * 0.1;
    final total = subtotal + deliveryFee + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Price Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                '₨${subtotal.toStringAsFixed(0)}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                '₨${deliveryFee.toStringAsFixed(0)}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                '₨${tax.toStringAsFixed(0)}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₨${total.toStringAsFixed(0)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout Button styled like Figma
          GestureDetector(
            onTap: () => _proceedToCheckout(total),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF53B175),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Go to Checkout',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '₨${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(double total) {
    // In a real app, this would navigate to a checkout screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Checkout functionality would be implemented here. Total: ₨${total.toStringAsFixed(0)}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
