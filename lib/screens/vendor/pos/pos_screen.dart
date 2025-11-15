import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pos_controller.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> with TickerProviderStateMixin {
  late final POSController controller;
  final TextEditingController _searchCtrl = TextEditingController();
  AnimationController? _blurController;
  AnimationController? _searchController;
  Animation<double> _blurAnimation = const AlwaysStoppedAnimation(0.0);
  Animation<double> _searchAnimation = const AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    controller = Get.put(POSController(context));

    // Initialize animation controllers
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _blurController!, curve: Curves.easeInOut),
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController!, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadVendorProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _blurController?.dispose();
    _searchController?.dispose();
    Get.delete<POSController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.history),
            tooltip: 'Order History',
            onPressed: () => Get.toNamed('/vendor/analytics'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            tooltip: 'Clear Cart',
            onPressed: controller.clearCart,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: AnimatedBuilder(
                      animation: _searchAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -20 * _searchAnimation.value),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openSearchOverlay,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.search,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Search product name or scan barcode',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      LucideIcons.scanLine,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 18,
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
                  // Products list (hidden when search is focused)
                  Obx(() {
                    if (controller.isSearchFocused.value) {
                      return const SizedBox.shrink();
                    }
                    final products = controller.availableProducts;
                    return Expanded(
                      child: products.isEmpty
                          ? Center(
                              child: Text(
                                'No products available',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, i) {
                                final p = products[i];
                                return _ProductTile(
                                  product: p,
                                  onAdd: () => controller.addToCart(p),
                                );
                              },
                            ),
                    );
                  }),
                ],
              );
            },
          ),
          // Floating cart panel with draggable expansion
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              controller.panelExtent.value = n.extent;
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.25,
              minChildSize: 0.15,
              maxChildSize: 0.85,
              snap: true,
              snapSizes: [0.25, 0.85],
              builder: (context, scrollController) {
                return _FloatingCartPanel(
                  controller: controller,
                  scrollController: scrollController,
                );
              },
            ),
          ),
          // Blur overlay
          if (_blurAnimation.value > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5 * _blurAnimation.value,
                  sigmaY: 5 * _blurAnimation.value,
                ),
                child: GestureDetector(
                  onTap: () {
                    controller.setSearchFocus(false);
                    _blurController?.reverse();
                    _searchController?.reverse();
                    _searchCtrl.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.3 * _blurAnimation.value),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openSearchOverlay() {
    controller.searchResults.clear();
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Popup card with search field and results
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 480),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                              child: SizedBox(
                                height: 44, // match POS search bar height
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  // Remove background
                                  decoration: null,
                                  child: Center(
                                    child: TextField(
                                      autofocus: true,
                                      controller: _searchCtrl,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Search products…',
                                        border: InputBorder.none,
                                        prefixIcon: const Icon(
                                            LucideIcons.search,
                                            size: 18),
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                                minWidth: 32, minHeight: 32),
                                        suffixIcon: IconButton(
                                          icon: const Icon(LucideIcons.x,
                                              size: 18),
                                          tooltip: 'Close',
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                      ),
                                      onChanged: controller.searchProducts,
                                      onSubmitted: controller.searchProducts,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            // Popup body
                            Expanded(
                              child: Obx(() {
                                final query = _searchCtrl.text;
                                if (query.isEmpty) {
                                  final recents = controller.recentSearches;
                                  if (recents.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Text('Start typing to search'),
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    padding: const EdgeInsets.all(12),
                                    itemCount: recents.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (c, i) {
                                      final q = recents[i];
                                      return ListTile(
                                        leading: const Icon(LucideIcons.clock,
                                            size: 18),
                                        title: Text(q),
                                        trailing: IconButton(
                                          icon: const Icon(LucideIcons.x,
                                              size: 16),
                                          onPressed: () =>
                                              controller.removeRecentSearch(q),
                                        ),
                                        onTap: () {
                                          _searchCtrl.text = q;
                                          controller.searchProducts(q);
                                        },
                                      );
                                    },
                                  );
                                }
                                if (controller.isSearching.value) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final results = controller.searchResults;
                                if (results.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text('No products found'),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: results.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (c, i) {
                                    final p = results[i];
                                    final theme = Theme.of(c);
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface
                                            .withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 20, sigmaY: 20),
                                          child: ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: p.images.isNotEmpty
                                                    ? p.images.first
                                                    : 'https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg?auto=compress&cs=tinysrgb&w=400',
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: theme.colorScheme
                                                      .surfaceContainerHighest,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  width: 56,
                                                  height: 56,
                                                  color: theme.colorScheme
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Text(p.name,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            subtitle: Text(
                                                '₨${p.currentPrice.toStringAsFixed(0)}'),
                                            trailing: IconButton(
                                              icon:
                                                  const Icon(LucideIcons.plus),
                                              onPressed: () {
                                                controller.addToCart(p);
                                                _searchCtrl.clear();
                                                controller.searchProducts('');
                                                Navigator.of(ctx).pop();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingCartPanel extends StatelessWidget {
  final POSController controller;
  final ScrollController? scrollController;
  const _FloatingCartPanel({required this.controller, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final items = List.of(controller.cartItems);
      final hasItems = items.isNotEmpty;
      final extent = controller.panelExtent.value;
      final isCollapsed =
          extent < 0.4; // show compact bar when mostly collapsed
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: isCollapsed
              ? ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  children: [
                    _CollapsedBar(
                      theme: theme,
                      controller: controller,
                      hasItems: hasItems,
                      onProceed: () => _showPaymentDialog(context),
                    ),
                  ],
                )
              : ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Header
                    Row(
                      children: [
                        Text(
                          'Your Cart',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          hasItems ? '${items.length} Items' : '0 Items',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Items list
                    if (hasItems)
                      ...List.generate(items.length * 2 - 1, (index) {
                        if (index.isOdd) {
                          return const Divider(height: 16);
                        }
                        final itemIndex = index ~/ 2;
                        final item = items[itemIndex];
                        final lineTotal =
                            item.product.currentPrice * item.quantity;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Stepper
                            _QtyStepper(
                              quantity: item.quantity,
                              onDec: () => controller.updateQuantity(
                                  item.product, item.quantity - 1),
                              onInc: () => controller.updateQuantity(
                                  item.product, item.quantity + 1),
                            ),
                            const SizedBox(width: 12),
                            // Price
                            Text(
                              '₨${lineTotal.toStringAsFixed(0)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      })
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No items yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Subtotal row
                    _KVRow(
                      label: 'Subtotal',
                      value: '₨${controller.subtotal.value.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 8),
                    // Discount row (disabled style)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount', style: theme.textTheme.bodyMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₨${controller.discount.value.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Total row
                    _KVRow(
                      label: 'Total',
                      value: '₨${controller.total.value.toStringAsFixed(0)}',
                      isEmphasis: true,
                    ),
                    const SizedBox(height: 12),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            hasItems ? () => _showPaymentDialog(context) : null,
                        icon: const Icon(LucideIcons.creditCard, size: 18),
                        label: const Text('Process Sale'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.banknote),
              title: const Text('Cash'),
              onTap: () {
                Navigator.pop(ctx);
                controller.processSale();
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.creditCard),
              title: const Text('Card'),
              onTap: () {
                Navigator.pop(ctx);
                controller.processSale();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedBar extends StatelessWidget {
  final ThemeData theme;
  final POSController controller;
  final bool hasItems;
  final VoidCallback onProceed;
  const _CollapsedBar(
      {required this.theme,
      required this.controller,
      required this.hasItems,
      required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      '₨${controller.total.value.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: hasItems ? onProceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Proceed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDec;
  final VoidCallback onInc;
  const _QtyStepper(
      {required this.quantity, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIconButton(
          icon: LucideIcons.minus,
          onPressed: onDec,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$quantity', style: theme.textTheme.bodyMedium),
        ),
        _CircleIconButton(
          icon: LucideIcons.plus,
          onPressed: onInc,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  const _CircleIconButton(
      {required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 16, color: color ?? theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasis;
  const _KVRow(
      {required this.label, required this.value, this.isEmphasis = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isEmphasis
              ? theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isEmphasis
              ? theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  final dynamic product; // using dynamic to avoid re-import lines here
  final VoidCallback onAdd;
  const _ProductTile({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Left square image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.images != null && product.images.isNotEmpty
                    ? product.images.first
                    : 'https://images.pexels.com/photos/264537/pexels-photo-264537.jpeg?auto=compress&cs=tinysrgb&w=400',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 64,
                  height: 64,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 64,
                  height: 64,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₨${product.currentPrice.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Add button
            TextButton(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                foregroundColor: theme.colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
