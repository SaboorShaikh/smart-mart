import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../models/order.dart' show CartItem;
import '../../../models/analytics.dart' as analytics
    show POSTransaction, PaymentMethod;
import '../../../providers/data_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class POSController extends GetxController {
  final BuildContext context;
  POSController(this.context);

  // Source products and cart state
  final RxList<Product> availableProducts = <Product>[].obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxDouble discount = 0.0.obs; // flat discount for now
  final RxList<Product> searchResults = <Product>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isSearchFocused = false.obs;
  final RxList<String> recentSearches = <String>[].obs;
  // Draggable panel extent (0.0 - 1.0)
  final RxDouble panelExtent = 0.25.obs;

  String? get vendorId {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return auth.user?.id;
  }

  Future<void> loadVendorProducts() async {
    final data = Provider.of<DataProvider>(context, listen: false);
    // For POS, show ALL products in the mart, regardless of vendor filter
    if (data.products.isEmpty) {
      await data.loadRealProducts();
    }
    // Ensure we have the fullest set: if still small, try force refresh
    if (data.products.length < 4 && vendorId != null) {
      await data.forceRefreshVendorProducts(vendorId!);
      if (data.products.isEmpty) {
        await data.loadRealProducts();
      }
    }
    availableProducts.assignAll(data.products);
  }

  Future<void> searchProducts(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    isSearching.value = true;
    try {
      // Ensure we have a local catalog to search in
      if (availableProducts.isEmpty) {
        await loadVendorProducts();
      }
      // Local search across currently available products
      final lower = q.toLowerCase();
      final filtered = availableProducts.where((p) {
        final inName = p.name.toLowerCase().contains(lower);
        final inDesc = p.description.toLowerCase().contains(lower);
        final inSku = (p.sku ?? '').toLowerCase().contains(lower);
        final inBarcode = (p.barcode ?? '').toLowerCase().contains(lower);
        return inName || inDesc || inSku || inBarcode;
      }).toList();
      searchResults.assignAll(filtered);

      // Add to recent searches if not already present
      if (q.isNotEmpty && !recentSearches.contains(q)) {
        recentSearches.insert(0, q);
        if (recentSearches.length > 5) {
          recentSearches.removeLast();
        }
      }
    } catch (_) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void setSearchFocus(bool focused) {
    isSearchFocused.value = focused;
    if (!focused) {
      searchResults.clear();
    }
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }

  void removeRecentSearch(String query) {
    recentSearches.remove(query);
  }

  void addToCart(Product product) {
    final index = cartItems.indexWhere((c) => c.product.id == product.id);
    if (index == -1) {
      cartItems.add(CartItem(product: product, quantity: 1));
    } else {
      final current = cartItems[index];
      cartItems[index] = current.copyWith(quantity: current.quantity + 1);
    }
    calculateTotals();
  }

  void removeFromCart(Product product) {
    cartItems.removeWhere((c) => c.product.id == product.id);
    calculateTotals();
  }

  void updateQuantity(Product product, int quantity) {
    final index = cartItems.indexWhere((c) => c.product.id == product.id);
    if (index == -1) return;
    if (quantity <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems[index] = cartItems[index].copyWith(quantity: quantity);
    }
    calculateTotals();
  }

  void applyDiscount(double value) {
    discount.value = value.clamp(0, double.infinity);
    calculateTotals();
  }

  void clearCart() {
    cartItems.clear();
    discount.value = 0;
    calculateTotals();
  }

  void calculateTotals() {
    final sub = cartItems.fold<double>(
        0.0, (sum, item) => sum + (item.product.currentPrice * item.quantity));
    subtotal.value = sub;
    total.value = (sub - discount.value).clamp(0.0, double.infinity);
  }

  Future<void> processSale(
      {analytics.PaymentMethod method = analytics.PaymentMethod.cash}) async {
    if (cartItems.isEmpty) {
      Get.snackbar('Cart Empty', 'Add items to cart before processing');
      return;
    }
    final vId = vendorId;
    if (vId == null) {
      Get.snackbar('Vendor Missing', 'You must be logged in as vendor');
      return;
    }

    final data = Provider.of<DataProvider>(context, listen: false);
    final transaction = analytics.POSTransaction(
      id: 'pos_${DateTime.now().millisecondsSinceEpoch}',
      vendorId: vId,
      items: cartItems.toList(),
      total: total.value,
      paymentMethod: method,
      createdAt: DateTime.now(),
    );

    try {
      data.addPOSTransaction(transaction);
      clearCart();
      Get.snackbar('Success', 'Sale processed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to process sale');
    }
  }
}
