import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/custom_button.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_icon.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import 'add_product_stepper_screen.dart';

enum ProductFilter { all, active, outOfStock, onSale }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _didInitialRefresh = false;
  VoidCallback? _authListener;
  bool _hasTimedOut = false;
  ProductFilter _selectedFilter = ProductFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Blue color for selected tabs and badges (matching the design)
  static const Color _blueColor = Color(0xFF3B82F6); // blue-500

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.user != null) {
        debugPrint(
            'ProductsScreen: Loading vendor products for user: ${authProvider.user!.id}');

        if (dataProvider.products.isEmpty) {
          await dataProvider.loadVendorProducts(authProvider.user!.id);
        }

        debugPrint(
            'ProductsScreen: After loadVendorProducts, products count: ${dataProvider.products.length}');

        _didInitialRefresh = true;

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && !_hasTimedOut) {
            setState(() {
              _hasTimedOut = true;
            });
            debugPrint('ProductsScreen: Timeout reached, showing empty state');
          }
        });
      }

      _authListener = () async {
        final user = authProvider.user;
        if (mounted && user != null) {
          debugPrint(
              'ProductsScreen: Auth changed, checking if products need reload for user: ${user.id}');
          final currentVendorProducts = dataProvider.products
              .where((p) => p.vendorId == user.id)
              .toList();
          if (currentVendorProducts.isEmpty) {
            await dataProvider.loadVendorProducts(user.id);
          }
        }
      };
      authProvider.addListener(_authListener!);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!_didInitialRefresh && authProvider.user != null) {
        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        if (dataProvider.products.isEmpty) {
          dataProvider.loadVendorProducts(authProvider.user!.id);
        }
        _didInitialRefresh = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    final authProvider = Provider.of<AuthProvider>(context);
    if (_authListener != null) {
      authProvider.removeListener(_authListener!);
    }
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            product.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case ProductFilter.all:
        break;
      case ProductFilter.active:
        filtered = filtered.where((p) => p.isActive && p.stock > 0).toList();
        break;
      case ProductFilter.outOfStock:
        filtered = filtered.where((p) => p.stock == 0).toList();
        break;
      case ProductFilter.onSale:
        filtered = filtered.where((p) => p.isDiscounted).toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(context, theme),

            // Filter Tabs
            _buildFilterTabs(theme),

            // Products Grid
            Expanded(
              child: authProvider.user == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: () async {
                        debugPrint('ProductsScreen: Manual refresh triggered');
                        final dataProvider =
                            Provider.of<DataProvider>(context, listen: false);
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        if (authProvider.user != null) {
                          await dataProvider.forceRefreshVendorProducts(
                              authProvider.user!.id);
                          debugPrint(
                              'ProductsScreen: Manual refresh completed');
                        }
                      },
                      child: Consumer<DataProvider>(
                        builder: (context, dataProvider, child) {
                          final allProducts = dataProvider.products;
                          final filteredProducts = _filterProducts(allProducts);

                          debugPrint(
                              'ProductsScreen: Consumer rebuilding - Products count: ${allProducts.length}, Filtered: ${filteredProducts.length}');

                          if (allProducts.isEmpty && !_hasTimedOut) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Loading products...'),
                                ],
                              ),
                            );
                          }

                          if (allProducts.isEmpty && _hasTimedOut) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIcon(
                                    assetPath: AppIcons.products,
                                    size: 80,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No products found',
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start by adding your first product',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  CustomButton(
                                    text: 'Add Product',
                                    onPressed: () {
                                      Get.toNamed(
                                          '/vendor/add-product-stepper');
                                    },
                                    icon: const Icon(LucideIcons.plus),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (filteredProducts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.search,
                                    size: 64,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products match your filters',
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final sortedProducts = [
                            ...filteredProducts
                          ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  0.67, // Reduced to increase card height by 7%
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: sortedProducts.length,
                            itemBuilder: (context, index) {
                              final product = sortedProducts[index];
                              return _buildProductCard(context, theme, product);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -72),
        child: FloatingActionButton(
          onPressed: () {
            Get.toNamed('/vendor/add-product-stepper');
          },
          backgroundColor: _blueColor,
          elevation: 6,
          child: const Icon(LucideIcons.plus, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back arrow
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Text(
                  'My Products',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              // Search icon
              IconButton(
                icon: Icon(
                  _isSearching ? LucideIcons.x : LucideIcons.search,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                      _searchController.clear();
                    }
                  });
                },
              ),
            ],
          ),
          // Search Bar (appears when searching)
          if (_isSearching) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterTab(theme, 'All Products', ProductFilter.all),
          const SizedBox(width: 8),
          _buildFilterTab(theme, 'Active', ProductFilter.active),
          const SizedBox(width: 8),
          _buildFilterTab(theme, 'Out of Stock', ProductFilter.outOfStock),
          const SizedBox(width: 8),
          _buildFilterTab(theme, 'On Sale', ProductFilter.onSale),
        ],
      ),
    );
  }

  Widget _buildFilterTab(ThemeData theme, String label, ProductFilter filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _blueColor : const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, ThemeData theme, Product product) {
    final isOutOfStock = product.stock == 0;
    final productImage = CachedNetworkImage(
      imageUrl: product.images.isNotEmpty
          ? product.images.first
          : 'https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg?auto=compress&cs=tinysrgb&w=400',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFFF5F5F5),
        child: const Icon(Icons.image_not_supported),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 130, // reduced slightly (was 140)
                  width: double.infinity,
                  child: product.isDiscounted &&
                          product.discountBadgeText.isNotEmpty
                      ? Banner(
                          message: product.discountBadgeText.toUpperCase(),
                          location: BannerLocation.topEnd,
                          color: const Color(0xFF3B82F6),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                          child: productImage,
                        )
                      : productImage,
                ),
              ),
              // Product Info
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${product.currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOutOfStock ? 'Out of Stock' : 'In Stock',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOutOfStock
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Action Icons
                        InkWell(
                          onTap: () => _editProduct(context, product),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/icons/edit_card.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _confirmDelete(
                              context, product.id, product.name),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              'assets/icons/delete_card.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProductDetails(Product product) {
    final encodedId = Uri.encodeComponent(product.id);
    Get.toNamed('/product/$encodedId');
  }

  void _editProduct(BuildContext context, Product product) {
    debugPrint('Editing product: ${product.name}');
    Get.to(
      () => AddProductStepperScreen(product: product),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String productId, String name) async {
    final theme = Theme.of(context);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              LucideIcons.trash2,
              color: theme.colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Delete Product'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this product?',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    color: theme.colorScheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '"$name"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone and will permanently remove the product and its images.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text('Deleting "$name"...'),
            ],
          ),
          backgroundColor: theme.colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );

      try {
        debugPrint('Starting product deletion for ID: $productId');
        await dataProvider.deleteProduct(productId);
        debugPrint('Product deletion completed successfully');

        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.checkCircle,
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text('Successfully deleted "$name"'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        if (authProvider.user != null) {
          await dataProvider.loadVendorProducts(authProvider.user!.id);
        }
      } catch (e) {
        debugPrint('Error deleting product: $e');
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: theme.colorScheme.onError,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Failed to delete product: ${e.toString()}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: theme.colorScheme.onError,
              onPressed: () => _confirmDelete(context, productId, name),
            ),
          ),
        );
      }
    }
  }
}
