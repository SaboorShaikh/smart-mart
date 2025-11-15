import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/custom_icon.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../../widgets/product_card.dart';
import '../../models/user.dart';
import 'browse_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const _HomeContent(),
    const BrowseScreen(),
    const CartScreen(),
    const CustomerOrdersScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      debugPrint('CustomerHomeScreen: Loading customer data');
      // Clear any vendor-specific data first
      dataProvider.clearAllData();
      // Clear all local storage to ensure cloud-only data
      await dataProvider.clearAllLocalData();
      // Then load fresh customer data
      await dataProvider.loadData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            ),
          ),
          // Floating navbar overlay (does not block scrollable layout)
          Positioned(
            left: 12,
            right: 12,
            bottom: 0,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FloatingNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    if (index == _currentIndex) return;
                    setState(() => _currentIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  items: const [
                    NavItemData(iconAsset: AppIcons.home, label: 'Home'),
                    NavItemData(iconAsset: AppIcons.search, label: 'Browse'),
                    NavItemData(iconAsset: AppIcons.cart, label: 'Cart'),
                    NavItemData(iconAsset: AppIcons.orders, label: 'Orders'),
                    NavItemData(iconAsset: AppIcons.profile, label: 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with TickerProviderStateMixin {
  String? _cityDisplay;
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController =
      PageController(viewportFraction: 0.88);
  int _currentBannerIndex = 0;
  final List<_PromoBanner> _promoBanners = const [
    _PromoBanner(
      title: 'Fresh Deals',
      subtitle: 'Get up to 40% off on seasonal produce',
      imageUrl:
          'https://images.unsplash.com/photo-1506806732259-39c2d0268443?w=600',
      backgroundColor: Color(0xFFEFF7F1),
      accentColor: Color(0xFF268854),
      textColor: Color(0xFF08392C),
      badge: '20% OFF',
    ),
    _PromoBanner(
      title: 'Local Favorites',
      subtitle: 'Discover top-rated marts near you',
      imageUrl:
          'https://images.unsplash.com/photo-1523475472560-d2df97ec485c?w=600',
      backgroundColor: Color(0xFFEAF2FF),
      accentColor: Color(0xFF3252D3),
      textColor: Color(0xFF0C1B3A),
      badge: 'Popular',
    ),
    _PromoBanner(
      title: 'Morning Essentials',
      subtitle: 'Coffee, bakery and more at special prices',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600',
      backgroundColor: Color(0xFFFFF3EB),
      accentColor: Color(0xFFB8622B),
      textColor: Color(0xFF3C1A09),
      badge: 'Freshly Roasted',
    ),
  ];
  final GlobalKey _notifIconKey = GlobalKey();
  final GlobalKey _cartIconKey = GlobalKey();
  OverlayEntry? _notifOverlay;
  OverlayEntry? _cartOverlay;
  late final AnimationController _notifAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<double> _notifScale = CurvedAnimation(
    parent: _notifAnimController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final AnimationController _cartAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<double> _cartScale = CurvedAnimation(
    parent: _cartAnimController,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _removeNotificationsPopup(animate: false);
    _removeCartPopup(animate: false);
    _notifAnimController.dispose();
    _cartAnimController.dispose();
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(theme),
                    const SizedBox(height: 20),
                    _buildSearchBar(theme),
                    const SizedBox(height: 20),
                    _buildPromoCarousel(theme),
                    const SizedBox(height: 28),
                    Consumer<DataProvider>(
                      builder: (_, dataProvider, __) {
                        return _buildMartNearMe(theme, dataProvider);
                      },
                    ),
                    const SizedBox(height: 28),
                    Consumer<DataProvider>(
                      builder: (_, dataProvider, __) {
                        return _buildFeaturedProducts(theme, dataProvider);
                      },
                    ),
                    const SizedBox(height: 28),
                    Consumer<DataProvider>(
                      builder: (_, dataProvider, __) {
                        return _buildBestSelling(theme, dataProvider);
                      },
                    ),
                    const SizedBox(height: 28),
                    Consumer<DataProvider>(
                      builder: (_, dataProvider, __) {
                        return _buildGroceries(theme, dataProvider);
                      },
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Location is now shown in the AppBar actions; inline widget used there.

  Future<void> _loadLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _cityDisplay = 'Location disabled');
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _cityDisplay = 'Turn on Location');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() => _cityDisplay =
            '${p.locality ?? p.subAdministrativeArea ?? 'Unknown'}, ${p.country ?? ''}'
                .trim());
      } else {
        setState(() => _cityDisplay = 'Unknown location');
      }
    } catch (e) {
      setState(() => _cityDisplay = 'Location error');
    }
  }

  void _onSearchTap() {
    Get.toNamed('/customer/browse');
  }

  Widget _buildSearchBar(ThemeData theme) {
    return GestureDetector(
      onTap: _onSearchTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CustomIcon(
              assetPath: AppIcons.search,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search for marts, products, or services.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomIcon(
                assetPath: AppIcons.location,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _cityDisplay ?? 'Loading location…',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _CartIconButton(
          key: _cartIconKey,
          onPressed: _toggleCartPopup,
        ),
        const SizedBox(width: 12),
        _NotificationsIconButton(
          key: _notifIconKey,
          onPressed: _toggleNotificationsPopup,
        ),
      ],
    );
  }

  Widget _buildPromoCarousel(ThemeData theme) {
    if (_promoBanners.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _promoBanners.length,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemBuilder: (context, index) {
              final banner = _promoBanners[index];
              final isActive = index == _currentBannerIndex;
              return AnimatedPadding(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  right: index == _promoBanners.length - 1 ? 0 : 16,
                ),
                child: _buildPromoCard(theme, banner, isActive),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoBanners.length,
            (index) => _buildPageIndicator(
              isActive: index == _currentBannerIndex,
              theme: theme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(ThemeData theme, _PromoBanner banner, bool isActive) {
    return InkWell(
      onTap: _onSearchTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: banner.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isActive
                  ? banner.accentColor.withOpacity(0.18)
                  : Colors.black.withOpacity(0.05)),
              blurRadius: isActive ? 32 : 16,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  width: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: banner.accentColor.withOpacity(0.08),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: banner.accentColor.withOpacity(0.08),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.storefront,
                      color: banner.accentColor.withOpacity(0.6),
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (banner.badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: banner.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        banner.badge!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: banner.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    banner.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: banner.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: banner.textColor.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Shop now',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: banner.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: banner.accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator({
    required bool isActive,
    required ThemeData theme,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 18 : 6,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedProducts(ThemeData theme, DataProvider dataProvider) {
    // Show only discounted products in Exclusive Offers
    final discountedProducts =
        dataProvider.realProducts.where((p) => p.isDiscounted).toList();

    if (discountedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Featured Products',
          onSeeAll: () => Get.toNamed('/customer/browse'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: discountedProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = discountedProducts[index];
              final vendor = dataProvider.users.firstWhere(
                (user) => user.id == product.vendorId,
                orElse: () => User(
                  id: '',
                  email: '',
                  name: '',
                  role: UserRole.vendor,
                  createdAt: DateTime.now(),
                ),
              );
              return SizedBox(
                width: 180,
                child: ProductCard(
                  product: product,
                  vendor: vendor,
                  onTap: () => Get.toNamed('/product/${product.id}'),
                  imagePadding: const EdgeInsets.all(12),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBestSelling(ThemeData theme, DataProvider dataProvider) {
    if (dataProvider.realProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Best Sellers',
          onSeeAll: () => Get.toNamed('/customer/browse'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: dataProvider.realProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = dataProvider.realProducts[index];
              final vendor = dataProvider.users.firstWhere(
                (user) => user.id == product.vendorId,
                orElse: () => User(
                  id: '',
                  email: '',
                  name: '',
                  role: UserRole.vendor,
                  createdAt: DateTime.now(),
                ),
              );
              return SizedBox(
                width: 180,
                child: ProductCard(
                  product: product,
                  vendor: vendor,
                  onTap: () => Get.toNamed('/product/${product.id}'),
                  imagePadding: const EdgeInsets.all(12),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroceries(ThemeData theme, DataProvider dataProvider) {
    if (dataProvider.realProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Explore More',
          onSeeAll: () => Get.toNamed('/customer/browse'),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:
                0.65, // Made consistent with browse screen (standard size)
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: dataProvider.realProducts.length,
          itemBuilder: (context, index) {
            final product = dataProvider.realProducts[index];
            return ProductCard(
              product: product,
              onTap: () => Get.toNamed('/product/${product.id}'),
              imagePadding: const EdgeInsets.all(12),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMartNearMe(ThemeData theme, DataProvider dataProvider) {
    // Get customer's current location for distance calculation
    double? customerLat;
    double? customerLon;

    // Try to get customer location from the current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.location != null) {
      customerLat = authProvider.user!.location!.latitude;
      customerLon = authProvider.user!.location!.longitude;
    }

    final nearbyVendors = dataProvider.searchNearbyVendorsWithDistance(
      customerLatitude: customerLat,
      customerLongitude: customerLon,
      maxDistanceKm: 10.0, // 10km radius for "near me"
    );

    // De-duplicate vendors by id in case of any data duplication upstream
    final dedupedVendorsMap = <String, Map<String, dynamic>>{};
    for (final v in nearbyVendors) {
      final id = (v['id'] ?? '').toString();
      if (id.isEmpty) continue;
      dedupedVendorsMap[id] = v;
    }
    final dedupedVendors = dedupedVendorsMap.values.toList();

    if (nearbyVendors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Marts Near You',
          onSeeAll: () => Get.toNamed('/customer/browse'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 4, right: 4),
            itemCount: dedupedVendors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final vendor = dedupedVendors[index];
              return _MartCard(vendor: vendor);
            },
          ),
        ),
      ],
    );
  }
}

extension on _HomeContentState {
  void _toggleNotificationsPopup() {
    if (_notifOverlay != null) {
      _removeNotificationsPopup();
      return;
    }

    // Mark all notifications as read when opening popup
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (authProvider.user != null) {
      dataProvider.markAllNotificationsAsRead(authProvider.user!.id);
    }

    // Position popup relative to the notification icon so it appears to expand from it
    final RenderBox? box =
        _notifIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset iconPos = box.localToGlobal(Offset.zero);
    final Size iconSize = box.size;

    _notifOverlay = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          // Blur backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeNotificationsPopup,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.12)),
              ),
            ),
          ),
          // Popup panel anchored to the notification icon, biased to the left so it clearly belongs to the bell
          Positioned(
            top: iconPos.dy + iconSize.height + 4,
            left: () {
              const double popupWidth = 260;
              // Place popup so its right edge is slightly left of the icon center
              final double iconCenterX = iconPos.dx + (iconSize.width / 2);
              double left =
                  iconCenterX - popupWidth + 8; // 8px overlap towards bell
              final screenW = MediaQuery.of(context).size.width;
              // Clamp to screen with margins
              if (left < 12) left = 12;
              if (left + popupWidth > screenW - 12) {
                left = screenW - popupWidth - 12;
              }
              return left;
            }(),
            child: ScaleTransition(
              scale: _notifScale,
              alignment: Alignment.topRight,
              child: _NotificationsPopup(
                width: 260,
                onClose: _removeNotificationsPopup,
              ),
            ),
          ),
        ],
      );
    });

    Overlay.of(context).insert(_notifOverlay!);
    _notifAnimController.forward(from: 0);
  }

  void _removeNotificationsPopup({bool animate = true}) {
    if (_notifOverlay == null) return;
    if (animate) {
      _notifAnimController.reverse().whenComplete(() {
        _notifOverlay?.remove();
        _notifOverlay = null;
      });
    } else {
      _notifOverlay?.remove();
      _notifOverlay = null;
    }
  }

  void _toggleCartPopup() {
    if (_cartOverlay != null) {
      _removeCartPopup();
      return;
    }
    final RenderBox? box =
        _cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset iconPos = box.localToGlobal(Offset.zero);
    final Size iconSize = box.size;

    _cartOverlay = OverlayEntry(builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeCartPopup,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.12)),
              ),
            ),
          ),
          Positioned(
            top: iconPos.dy + iconSize.height + 4,
            left: () {
              const double popupWidth = 260;
              final double iconCenterX = iconPos.dx + (iconSize.width / 2);
              double left = iconCenterX - popupWidth + 8;
              final screenW = MediaQuery.of(context).size.width;
              if (left < 12) left = 12;
              if (left + popupWidth > screenW - 12) {
                left = screenW - popupWidth - 12;
              }
              return left;
            }(),
            child: ScaleTransition(
              scale: _cartScale,
              alignment: Alignment.topRight,
              child: const _CartPopup(width: 260),
            ),
          ),
        ],
      );
    });

    Overlay.of(context).insert(_cartOverlay!);
    _cartAnimController.forward(from: 0);
  }

  void _removeCartPopup({bool animate = true}) {
    if (_cartOverlay == null) return;
    if (animate) {
      _cartAnimController.reverse().whenComplete(() {
        _cartOverlay?.remove();
        _cartOverlay = null;
      });
    } else {
      _cartOverlay?.remove();
      _cartOverlay = null;
    }
  }
}

class _NotificationsPopup extends StatelessWidget {
  final double width;
  final VoidCallback onClose;
  const _NotificationsPopup({this.width = 300, required this.onClose});

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    // If today, show only time (without seconds)
    if (notificationDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // If this week, show day name
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    if (notificationDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        notificationDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    }

    // If more than a week, show date only
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = Provider.of<DataProvider>(context, listen: false);
    final notifications = data.notifications;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxHeight: 480, minHeight: 260),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.bell,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Notifications',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    // Show notification count instead of close button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notifications.length.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(LucideIcons.bellOff,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text('No notifications',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Dismissible(
                        key: Key(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            LucideIcons.trash2,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return true; // Delete immediately without confirmation
                        },
                        onDismissed: (direction) {
                          final dataProvider =
                              Provider.of<DataProvider>(context, listen: false);
                          dataProvider.deleteNotification(n.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notification deleted'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (!n.isRead) {
                                final dataProvider = Provider.of<DataProvider>(
                                    context,
                                    listen: false);
                                dataProvider.markNotificationAsRead(n.id);
                              }
                              onClose();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    n.isRead
                                        ? LucideIcons.bell
                                        : LucideIcons.bellRing,
                                    color: n.isRead
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n.message,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatNotificationTime(n.createdAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
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
              // View All button
              if (notifications.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Close popup and navigate to notifications screen
                        onClose();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'View All Notifications',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPopup extends StatelessWidget {
  final double width;
  const _CartPopup({this.width = 300});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = Provider.of<DataProvider>(context);
    final cart = data.cart;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxHeight: 480, minHeight: 220),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.shoppingCart,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Cart',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${cart.length} items',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (cart.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(LucideIcons.shoppingBag,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text('Your cart is empty',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    shrinkWrap: true,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(item.product.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                              'x${item.quantity} • ₨${(item.product.currentPrice * item.quantity).toStringAsFixed(0)}'),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color backgroundColor;
  final Color accentColor;
  final Color textColor;
  final String? badge;

  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.accentColor,
    required this.textColor,
    this.badge,
  });
}

class _MartCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  const _MartCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String name = (vendor['name'] ?? 'Store').toString();
    final double rating =
        (vendor['rating'] is num) ? (vendor['rating'] as num).toDouble() : 0.0;
    final String distance = vendor['distanceText']?.toString() ??
        (vendor['distance'] != null
            ? '${(vendor['distance'] as num).toStringAsFixed(1)}km'
            : '—');

    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: vendor['shopLogo'] != null &&
                      vendor['shopLogo'].toString().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: vendor['shopLogo'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        alignment: Alignment.center,
                        child: CustomIcon(
                          assetPath: AppIcons.store,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      alignment: Alignment.center,
                      child: CustomIcon(
                        assetPath: AppIcons.store,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            distance,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                color: Colors.amber.shade600,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _CartIconButton({super.key, this.onPressed});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed ?? () => Get.toNamed('/customer/cart'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CustomIcon(
              assetPath: AppIcons.cart,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
            Positioned(
              right: -6,
              top: -6,
              child: _CartBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _NotificationsIconButton({super.key, this.onPressed});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed ?? () => Get.to(() => const NotificationsScreen()),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CustomIcon(
              assetPath: AppIcons.notification,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
            Positioned(
              right: -6,
              top: -6,
              child: _NotificationsBadge(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final count = dataProvider.cart.length;
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _NotificationsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final count = dataProvider.notifications.where((n) => !n.isRead).length;
    if (count == 0) return const SizedBox.shrink();

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
            color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// Legacy nav item and frosted nav bar classes were replaced by the reusable
// FloatingNavBar widget.

// Removed leftover AnimatedNavItem implementation; handled in FloatingNavBar.
