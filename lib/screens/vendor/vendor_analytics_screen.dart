import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_icon.dart';
import '../../models/analytics.dart';
import '../../theme/app_theme.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      if (authProvider.user != null) {
        // Generate analytics data for the current vendor
        dataProvider.generateSalesData(authProvider.user!.id);
        dataProvider.generateVendorStats(authProvider.user!.id);

        // Simulate loading time for better UX
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
    } finally {
      setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  Future<void> _refreshData() async {
    await _loadAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(theme)
          : FadeTransition(
              opacity: _fadeAnimation,
              child: _buildAnalyticsContent(theme),
            ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Analytics...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(ThemeData theme) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final vendorStats = dataProvider.vendorStats;
        final salesData = dataProvider.salesData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildSummaryCards(theme, vendorStats),
              const SizedBox(height: 24),

              // Top Selling Products
              _buildTopSellingProducts(theme, vendorStats),
              const SizedBox(height: 24),

              // Sales Trend Chart
              _buildSalesTrendChart(theme, salesData),
              const SizedBox(height: 100), // Bottom padding for navigation
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(ThemeData theme, VendorStats? vendorStats) {
    final todaySales = _calculateTodaySales();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                title: "Today's Sales",
                value: '\$${_formatCurrency(todaySales)}',
                icon: AppIcons.totalSale,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                title: "Total Sales",
                value: '\$${_formatCurrency(vendorStats?.totalSales ?? 0.0)}',
                icon: AppIcons.averageOrderValue,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          theme,
          title: "Inventory",
          value: '${vendorStats?.activeProducts ?? 0} products',
          icon: AppIcons.products,
          color: AppTheme.warningColor,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required String icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIcon(
                    assetPath: icon,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+12%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingProducts(ThemeData theme, VendorStats? vendorStats) {
    final topProducts = vendorStats?.topSellingProducts ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Selling Products',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (topProducts.isEmpty)
          _buildEmptyState(theme, 'No sales data available yet')
        else
          CustomCard(
            color: Colors.grey[100],
            child: Column(
              children: topProducts.take(5).map((product) {
                return _buildProductItem(theme, product);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildProductItem(ThemeData theme, TopSellingProduct product) {
    final maxQuantity =
        product.quantity > 0 ? product.quantity : 1; // Prevent division by zero

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          size: 24,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.image,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.product.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.quantity} units sold',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Revenue
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_formatCurrency(product.revenue)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: product.quantity / maxQuantity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTrendChart(ThemeData theme, List<SalesData> salesData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Trend',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (salesData.isEmpty)
          _buildEmptyState(theme, 'No sales trend data available yet')
        else
          CustomCard(
            color: Colors.grey[100],
            child: Column(
              children: [
                // Simple bar chart representation
                SizedBox(
                  height: 200,
                  child: _buildSimpleChart(theme, salesData),
                ),
                const SizedBox(height: 16),
                // Chart legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(theme, 'Sales', AppTheme.primaryColor),
                    _buildLegendItem(theme, 'Orders', AppTheme.secondaryColor),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSimpleChart(ThemeData theme, List<SalesData> salesData) {
    final maxAmount = salesData.isNotEmpty
        ? salesData.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 1.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: salesData.take(7).map((data) {
        final height = maxAmount > 0 ? (data.amount / maxAmount) : 0.0;
        final date = DateTime.tryParse(data.date);
        final dayName = date != null
            ? DateFormat('E').format(date)
            : data.date.substring(5); // Show MM-DD if parsing fails

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '\$${_formatCurrency(data.amount)}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: (height * 120).clamp(8.0, 120.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayName,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return CustomCard(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTodaySales() {
    final today = DateTime.now();
    final todayString = today.toIso8601String().split('T')[0];

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final todayData = dataProvider.salesData
        .where((data) => data.date == todayString)
        .toList();

    return todayData.fold(0.0, (sum, data) => sum + data.amount);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }
}
