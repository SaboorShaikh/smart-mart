import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:ui';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/discount_dialog.dart';
import '../widgets/skeleton_loaders.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'vendor/add_product_stepper_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? productId;
  final Product? product; // For review mode
  final bool isReviewMode; // Flag to show Update button instead of Add to Cart
  final VoidCallback?
      onUpdate; // Callback when Update is pressed in review mode

  const ProductDetailScreen({
    super.key,
    this.productId,
    this.product,
    this.isReviewMode = false,
    this.onUpdate,
  }) : assert(productId != null || product != null,
            'Either productId or product must be provided');

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  int _quantity = 1;
  Product? _product;
  User? _vendor;
  bool _isLoading = true;
  String? _error;
  late PageController _imagePageController;
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  double? _userRating;
  AnimationController? _blurController;
  Animation<double>? _blurAnimation;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController(viewportFraction: 0.85);

    // Initialize blur animation controller
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _blurAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blurController!, curve: Curves.easeInOut),
    );

    if (widget.isReviewMode && widget.product != null) {
      // In review mode, use provided product directly
      _product = widget.product;
      _loadVendorForReview();
    } else {
      // Normal mode, load from Firestore
      _loadProduct();
    }
  }

  void _initializeUserRating() {
    if (!mounted || widget.isReviewMode || _product == null) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;
    final userId = authProvider.user?.id;
    if (userId == null) return;
    _loadUserRating(userId);
  }

  Future<void> _loadUserRating(String userId) async {
    if (_product == null) return;
    try {
      final rating = await FirestoreService.getUserProductRating(
        _product!.id,
        userId,
      );
      if (!mounted) return;
      setState(() {
        _userRating = rating;
      });
    } catch (e) {
      debugPrint('ProductDetailScreen: Error loading user rating: $e');
    }
  }

  Future<void> _handleRatingSelected(int star) async {
    if (_product == null || widget.isReviewMode) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      _showLoginRequiredMessage();
      return;
    }

    final previousRating = _userRating;
    final newRating = star.toDouble();

    setState(() {
      _userRating = newRating;
    });

    _submitRating(
      userId: user.id,
      newRating: newRating,
      previousRating: previousRating,
      star: star,
    );
  }

  void _handleUnauthenticatedRatingTap(int _) {
    _showLoginRequiredMessage();
  }

  void _showLoginRequiredMessage() {
    _showRatingSnackBar(
      message: 'Please sign in to rate this product.',
      isError: false,
    );
  }

  void _showRatingSnackBar({
    required String message,
    required bool isError,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              color: isError
                  ? colorScheme.error
                  : colorScheme.primary.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isError ? colorScheme.error : colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? LucideIcons.alertCircle : LucideIcons.star,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _submitRating({
    required String userId,
    required double newRating,
    required int star,
    double? previousRating,
  }) async {
    try {
      final updatedProduct = await FirestoreService.setProductRating(
        productId: _product!.id,
        userId: userId,
        rating: newRating,
      );

      Product? latestProduct = updatedProduct;
      latestProduct ??= await FirestoreService.getProductById(_product!.id);

      if (!mounted) return;

      if (latestProduct != null) {
        setState(() {
          _product = latestProduct;
        });

        final dataProvider = Provider.of<DataProvider>(context, listen: false);
        dataProvider.updateProductRatingCache(latestProduct);
        await dataProvider.refreshVendorRating(latestProduct.vendorId);
      }

      _showRatingSnackBar(
        message:
            'Thanks for rating ${_product!.name} $star star${star == 1 ? '' : 's'}!',
        isError: false,
      );
    } catch (e) {
      debugPrint('ProductDetailScreen: Error updating rating: $e');
      if (!mounted) return;
      setState(() {
        _userRating = previousRating;
      });
      _showRatingSnackBar(
        message: 'Unable to update rating. Please try again later.',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _blurController?.dispose();
    super.dispose();
  }

  Future<void> _loadVendorForReview() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load vendor information
      final vendor = await FirestoreService.getUser(_product!.vendorId);

      setState(() {
        _vendor = vendor;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ProductDetailScreen: Error loading vendor: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.productId == null) {
        throw Exception('Product ID is required');
      }

      debugPrint(
          'ProductDetailScreen: Loading product with ID: ${widget.productId}');

      // Load product from Firestore
      final product = await FirestoreService.getProductById(widget.productId!);
      if (product == null) {
        throw Exception('Product not found in database');
      }

      // Load vendor information
      final vendor = await FirestoreService.getUser(product.vendorId);
      if (vendor == null) {
        throw Exception('Vendor not found');
      }

      setState(() {
        _product = product;
        _vendor = vendor;
        _isLoading = false;
      });
      _initializeUserRating();

      debugPrint(
          'ProductDetailScreen: Product loaded successfully: ${product.name}');
    } catch (e) {
      debugPrint('ProductDetailScreen: Error loading product: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const ProductDetailSkeleton(),
      );
    }

    // Show error state
    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Product Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Product Not Found',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ??
                      'The product you are looking for does not exist or has been removed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(LucideIcons.arrowLeft),
                  label: const Text('Go Back'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _loadProduct();
                  },
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final product = _product!;
    final vendor = _vendor!;

    final primaryPrice = product.currentPrice;
    final hasDiscount =
        product.isDiscounted && product.discountBadgeText.isNotEmpty;
    final bool canRate = !widget.isReviewMode;
    final ValueChanged<int>? ratingHandler = canRate
        ? (authProvider.isAuthenticated
            ? _handleRatingSelected
            : _handleUnauthenticatedRatingTap)
        : null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF4F5F7),
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            title: Text(
                widget.isReviewMode ? 'Review Product' : 'Product Details'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
              child: IconButton(
                onPressed: () => _handleBack(context),
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: theme.colorScheme.onSurface,
                  size: 22,
                ),
                splashRadius: 24,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                child: IconButton(
                  onPressed: () {
                    // TODO: implement wishlist feature
                  },
                  icon: Icon(
                    LucideIcons.heart,
                    color: theme.colorScheme.onSurface,
                    size: 22,
                  ),
                  splashRadius: 24,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMediaSection(product, theme),
                  const SizedBox(height: 24),
                  _buildSummarySection(
                    product,
                    theme,
                    primaryPrice,
                    hasDiscount,
                    userRating: _userRating,
                    onRatingSelected: ratingHandler,
                  ),
                  const SizedBox(height: 24),
                  // Additional Product Information
                  _buildAdditionalInfoSection(product, theme, isDark),
                  const SizedBox(height: 16),
                  // Description
                  _buildDescriptionCard(product, theme, isDark),
                  const SizedBox(height: 16),
                  // Key Features
                  if (product.features != null && product.features!.isNotEmpty)
                    _buildKeyFeaturesSection(product, theme, isDark),
                  if (product.features != null && product.features!.isNotEmpty)
                    const SizedBox(height: 16),
                  // Nutrition Information
                  if (product.nutritionInfo != null &&
                      product.nutritionInfo!.isNotEmpty)
                    _buildNutritionInfoSection(product, theme, isDark),
                  if (product.nutritionInfo != null &&
                      product.nutritionInfo!.isNotEmpty)
                    const SizedBox(height: 16),
                  // Seller Information
                  _buildVendorCard(vendor, theme, isDark),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),

        // Floating blurred bottom action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomActionBar(
            context,
            product,
            authProvider,
            primaryPrice,
            isDark,
          ),
        ),

        // Blur overlay that animates when navigating to edit product
        if (_blurAnimation != null)
          AnimatedBuilder(
            animation: _blurAnimation!,
            builder: (context, child) {
              if (_blurAnimation!.value == 0) {
                return const SizedBox.shrink();
              }
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation!.value * 10,
                  sigmaY: _blurAnimation!.value * 10,
                ),
                child: Container(
                  color: Colors.white.withOpacity(_blurAnimation!.value * 0.3),
                ),
              );
            },
          ),
      ],
    );
  }

  void _handleBack(BuildContext context) {
    // Use Get.back() to ensure custom transition works properly
    Get.back();
  }

  bool _isVendorViewingOwnProduct(Product product, AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) return false;
    if (authProvider.user?.role != UserRole.vendor) return false;
    return product.vendorId == authProvider.user?.id;
  }

  void _showDiscountDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => DiscountDialog(
        product: product,
        onDiscountApplied: (updatedProduct) async {
          try {
            final dataProvider =
                Provider.of<DataProvider>(context, listen: false);
            await dataProvider.updateProduct(product.id, updatedProduct);

            // Reload the product to reflect the changes
            await _loadProduct();

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  updatedProduct.isDiscounted
                      ? 'Discount applied successfully!'
                      : 'Discount removed successfully!',
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } catch (e) {
            debugPrint('Error updating discount: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update discount: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _editProduct(Product product) async {
    debugPrint('Editing product: ${product.name}');

    // Start blur animation
    _blurController?.forward();

    // Wait a tiny bit for blur to start
    await Future.delayed(const Duration(milliseconds: 50));

    // Navigate to edit product screen
    await Get.to(
      () => AddProductStepperScreen(product: product),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );

    // Reverse blur animation when coming back
    _blurController?.reverse();
  }

  void _addToCart(Product product) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.addToCart(product, _quantity);
    NotificationService.showAddedToCart(product.name);
  }

  /// Floating blurred bottom action bar shown above the scrollable content.
  Widget _buildBottomActionBar(
    BuildContext context,
    Product product,
    AuthProvider authProvider,
    double primaryPrice,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isVendorView = _isVendorViewingOwnProduct(product, authProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E293B).withOpacity(0.8)
                      : const Color(0xFFE2E8F0).withOpacity(0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildBottomActionContent(
                context,
                product,
                authProvider,
                primaryPrice,
                isVendorView,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionContent(
    BuildContext context,
    Product product,
    AuthProvider authProvider,
    double primaryPrice,
    bool isVendorView,
  ) {
    // Scenario A: Review / preview mode
    if (widget.isReviewMode) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (widget.onUpdate != null) {
              widget.onUpdate!();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF225FEC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF225FEC).withOpacity(0.3),
          ),
          child: const Text(
            'Update Product',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Scenario C: Vendor viewing own product
    if (isVendorView) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showDiscountDialog(product),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(
                  color: Color(0xFF225FEC),
                  width: 1,
                ),
              ),
              child: const Text(
                'Add Discount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF225FEC),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _editProduct(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF225FEC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF225FEC).withOpacity(0.3),
              ),
              child: const Text(
                'Edit Product',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Scenario B: Customer view – quantity on the left, Add to Cart on the right
    return Row(
      children: [
        _buildBottomQuantityControl(),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _addToCart(product),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF225FEC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF225FEC).withOpacity(0.3),
            ),
            child: const Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Compact quantity controller used inside the bottom action bar.
  Widget _buildBottomQuantityControl() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: LucideIcons.minus,
            onTap: _quantity > 1
                ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                : null,
            isPrimary: false,
          ),
          const SizedBox(width: 12),
          Text(
            '$_quantity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          _buildQuantityButton(
            icon: LucideIcons.plus,
            onTap: () {
              setState(() {
                _quantity++;
              });
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(Product product, ThemeData theme) {
    final images = product.images;

    final height = MediaQuery.of(context).size.width * 0.77;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _imagePageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            clipBehavior: Clip.none,
            itemCount: images.isNotEmpty ? images.length : 1,
            itemBuilder: (context, index) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: index == _currentImageIndex ? 6 : 14,
                ),
                child: _buildImageCard(
                  theme: theme,
                  imageUrl: images.isNotEmpty ? images[index] : null,
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: index == _currentImageIndex ? 16 : 6,
                decoration: BoxDecoration(
                  color: index == _currentImageIndex
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummarySection(
    Product product,
    ThemeData theme,
    double primaryPrice,
    bool hasDiscount, {
    double? userRating,
    ValueChanged<int>? onRatingSelected,
  }) {
    final rating = userRating ?? product.rating ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.category,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStarRating(
                  rating,
                  theme,
                  userRating: userRating,
                  onRatingSelected: onRatingSelected,
                  iconSize: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  '${rating.toStringAsFixed(1)} / 5',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          _capitalize(product.name),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasDiscount) ...[
              Row(
                children: [
                  Text(
                    '₨${product.originalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.discountBadgeText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₨${primaryPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/${product.unit}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard({
    required ThemeData theme,
    String? imageUrl,
  }) {
    Widget child;

    if (imageUrl == null) {
      child = Container(
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    } else if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      child = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      child = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: theme.colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: child,
    );
  }

  Widget _buildAdditionalInfoSection(
      Product product, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Product Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              if (product.unit.isNotEmpty)
                _buildInfoItem('Measurement', product.unit, theme, isDark),
              if (product.brand != null && product.brand!.isNotEmpty)
                _buildInfoItem('Brand Name', product.brand!, theme, isDark),
              if (product.origin != null && product.origin!.isNotEmpty)
                _buildInfoItem('Origin', product.origin!, theme, isDark),
              if (product.expiryDate != null && product.expiryDate!.isNotEmpty)
                _buildInfoItem(
                    'Expiry Date', product.expiryDate!, theme, isDark),
              if (product.manufacturer != null &&
                  product.manufacturer!.isNotEmpty)
                _buildInfoItem(
                    'Manufacturer', product.manufacturer!, theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, ThemeData theme, bool isDark) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 72) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Product product, ThemeData theme, bool isDark) {
    final description = product.detailedDescription ?? product.description;
    final isLong = description.length > 220;

    String displayText = description;
    if (!_isDescriptionExpanded && isLong) {
      displayText = '${description.substring(0, 220).trim()}...';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayText,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF71717A),
            ),
          ),
          if (isLong)
            TextButton(
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isDescriptionExpanded ? 'Show less' : 'View Details',
                style: TextStyle(
                  color: const Color(0xFF225FEC),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyFeaturesSection(
      Product product, ThemeData theme, bool isDark) {
    final features = product.features ?? [];
    if (features.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.checkCircle,
                      size: 20,
                      color: const Color(0xFF225FEC),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFFD4D4D8)
                              : const Color(0xFF18181B),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNutritionInfoSection(
      Product product, ThemeData theme, bool isDark) {
    final nutrition = product.nutritionInfo;
    if (nutrition == null || nutrition.isEmpty) return const SizedBox.shrink();

    // Extract nutrition tags from the map
    final nutritionTags = nutrition.keys.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: nutritionTags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF225FEC),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(
      Product product, ThemeData theme, double primaryPrice, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 12),
        _buildQuantityCard(product, theme, primaryPrice, isDark),
      ],
    );
  }

  Widget _buildDescriptionSection(Product product, ThemeData theme) {
    final description = product.detailedDescription ?? product.description;
    final isLong = description.length > 220;
    final hasNutrition =
        product.nutritionInfo != null && product.nutritionInfo!.isNotEmpty;
    final nutritionText = hasNutrition ? _formatNutritionInfo(product) : null;

    String displayText = description;
    if (!_isDescriptionExpanded && isLong) {
      displayText = '${description.substring(0, 220).trim()}...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayText,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (isLong)
          TextButton(
            onPressed: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? 'Show less' : 'Read more',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (nutritionText != null) ...[
          const SizedBox(height: 18),
          Text(
            'Nutrition (per 100g)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nutritionText,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuantityCard(
      Product product, ThemeData theme, double primaryPrice, bool isDark) {
    final totalPrice = primaryPrice * _quantity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              _buildQuantityButton(
                icon: LucideIcons.minus,
                onTap: _quantity > 1
                    ? () {
                        setState(() {
                          _quantity--;
                        });
                      }
                    : null,
                isPrimary: false,
              ),
              const SizedBox(width: 16),
              Text(
                '$_quantity',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 16),
              _buildQuantityButton(
                icon: LucideIcons.plus,
                onTap: () {
                  setState(() {
                    _quantity++;
                  });
                },
                isPrimary: true,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Price',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₨${totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(User vendor, ThemeData theme, bool isDark) {
    final isVendor = vendor is Vendor;
    final vendorModel = isVendor ? vendor : null;
    final shopName = isVendor ? vendorModel!.shopName : vendor.name;
    final logoUrl = isVendor ? vendorModel!.shopLogo : vendor.avatar;
    final shopCity = vendorModel?.city?.trim();
    final shopCountry = vendorModel?.country?.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      constraints: const BoxConstraints(minHeight: 72),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildVendorLogo(theme, logoUrl, shopName),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sold by',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    shopName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if ((shopCity != null && shopCity.isNotEmpty) ||
                    (shopCountry != null && shopCountry.isNotEmpty)) ...[
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _joinLocation(shopCity, shopCountry),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          CustomButton(
            text: 'View Store',
            onPressed: () {
              debugPrint('View store tapped for ${vendor.id}');
            },
            isOutlined: true,
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorLogo(ThemeData theme, String? logoUrl, String shopName) {
    final size = 52.0;
    final trimmedName = shopName.trim();
    final fallbackLetter =
        trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : '?';

    Widget content;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: theme.colorScheme.primary.withOpacity(0.08),
          alignment: Alignment.center,
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: theme.colorScheme.primary.withOpacity(0.08),
          alignment: Alignment.center,
          child: Text(
            fallbackLetter,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    } else {
      content = Container(
        width: size,
        height: size,
        color: theme.colorScheme.primary.withOpacity(0.08),
        alignment: Alignment.center,
        child: Text(
          fallbackLetter,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.white : theme.colorScheme.onSurface,
          size: 18,
        ),
      ),
    );
  }

  void _buyNow(Product product) {
    _addToCart(product);
    Navigator.of(context).pushNamed('/customer/cart');
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return text;
    final leadingSpaces = text.length - trimmed.length;
    final prefix = text.substring(0, leadingSpaces);
    return '$prefix${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  String _joinLocation(String? city, String? country) {
    final parts = [
      if (city != null && city.isNotEmpty) city,
      if (country != null && country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  String? _formatNutritionInfo(Product product) {
    final nutrition = product.nutritionInfo;
    if (nutrition == null || nutrition.isEmpty) return null;

    final entries = nutrition.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return entries
        .map((entry) => '${entry.key}: ${_formatGrams(entry.value)}')
        .join('\n');
  }

  String _formatGrams(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}g';
    }
    return '${value.toStringAsFixed(1)}g';
  }

  Widget _buildStarRating(
    double rating,
    ThemeData theme, {
    double? userRating,
    ValueChanged<int>? onRatingSelected,
    double iconSize = 16,
  }) {
    final effectiveRating =
        (onRatingSelected != null && userRating != null && userRating > 0)
            ? userRating
            : rating;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final difference = effectiveRating - index;

        IconData iconData;
        Color iconColor;

        if (difference >= 1) {
          iconData = Icons.star_rounded;
          iconColor = theme.colorScheme.primary;
        } else if (difference > 0 && difference < 1) {
          iconData = Icons.star_half_rounded;
          iconColor = theme.colorScheme.primary;
        } else {
          iconData = Icons.star_outline_rounded;
          iconColor = theme.colorScheme.outline;
        }

        if (onRatingSelected != null) {
          final isFilled =
              userRating != null ? starIndex <= userRating : difference >= 1;
          if (isFilled) {
            iconData = Icons.star_rounded;
            iconColor = theme.colorScheme.primary;
          } else if (userRating != null && userRating < starIndex) {
            iconData = Icons.star_outline_rounded;
            iconColor = theme.colorScheme.outline;
          }

          return GestureDetector(
            onTap: () => onRatingSelected(starIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                iconData,
                size: iconSize,
                color: iconColor,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            iconData,
            size: iconSize,
            color: iconColor,
          ),
        );
      }),
    );
  }
}
