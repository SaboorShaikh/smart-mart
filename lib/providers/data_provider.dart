import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/analytics.dart';
import '../services/firestore_service.dart';

class DataProvider with ChangeNotifier {
  void _safeNotifyListeners() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuilding = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.postFrameCallbacks;
    if (isBuilding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  List<Product> _products = [];
  List<Order> _orders = [];
  List<CartItem> _cart = [];
  List<SalesData> _salesData = [];
  List<POSTransaction> _posTransactions = [];
  List<Notification> _notifications = [];
  VendorStats? _vendorStats;
  List<User> _users = [];

  // Storage keys
  static const String _productsStorageKey = 'smartmart_products';
  static const String _ordersStorageKey = 'smartmart_orders';
  static const String _cartStorageKey = 'smartmart_cart';
  static const String _posTransactionsStorageKey = 'smartmart_pos_transactions';
  static const String _notificationsStorageKey = 'smartmart_notifications';
  static const String _usersStorageKey = 'smartmart_users';

  // Getters
  List<Product> get products => _products;
  List<Product> get realProducts =>
      _products.where((p) => p.isRealProduct).toList();
  List<Order> get orders => _orders;
  List<CartItem> get cart => _cart;
  List<SalesData> get salesData => _salesData;
  List<POSTransaction> get posTransactions => _posTransactions;
  List<Notification> get notifications => _notifications;
  VendorStats? get vendorStats => _vendorStats;
  List<User> get users => _users;

  // Get vendor by ID with fallback to Firestore
  Future<User?> getVendorById(String vendorId) async {
    try {
      // First try to find in local users list
      final localVendor = _users.firstWhere(
        (u) => u.id == vendorId && u.role == UserRole.vendor,
        orElse: () => User(
          id: '',
          email: '',
          name: '',
          role: UserRole.customer,
          createdAt: DateTime.now(),
        ),
      );

      if (localVendor.id.isNotEmpty) {
        return localVendor;
      }

      // If not found locally, try to load from Firestore
      final vendorData = await FirestoreService.getUser(vendorId);
      if (vendorData != null && vendorData.role == UserRole.vendor) {
        // Add to local users list for future use
        _users.add(vendorData);
        _saveUsers();
        return vendorData;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting vendor by ID: $e');
      return null;
    }
  }

  Future<void> loadData() async {
    try {
      debugPrint('DataProvider: loadData() called');
      final prefs = await SharedPreferences.getInstance();

      // Clear any existing local product data to ensure cloud-only
      await clearLocalProductData();

      // Load real products from Firestore only (no local storage)
      await loadRealProducts();

      // Load notifications from Firestore
      await loadNotifications();

      final ordersData = prefs.getString(_ordersStorageKey);
      final cartData = prefs.getString(_cartStorageKey);
      final posData = prefs.getString(_posTransactionsStorageKey);
      final notificationsData = prefs.getString(_notificationsStorageKey);
      final usersData = prefs.getString(_usersStorageKey);

      if (ordersData != null) {
        _orders = (json.decode(ordersData) as List)
            .map((item) => Order.fromJson(item))
            .toList();
      }

      if (cartData != null) {
        try {
          _cart = (json.decode(cartData) as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        } catch (e) {
          debugPrint('Error loading cart data, clearing cart: $e');
          _cart = [];
          _saveCart(); // Clear corrupted data
        }
      }

      if (posData != null) {
        _posTransactions = (json.decode(posData) as List)
            .map((item) => POSTransaction.fromJson(item))
            .toList();
      }

      if (notificationsData != null) {
        _notifications = (json.decode(notificationsData) as List)
            .map((item) => Notification.fromJson(item))
            .toList();
      }

      if (usersData != null) {
        final parsedUsers = json.decode(usersData) as List;
        _users = parsedUsers
            .map((userData) => _createUserFromJson(userData))
            .where((user) => user != null)
            .cast<User>()
            .toList();
      }

      _safeNotifyListeners();
      debugPrint(
          'DataProvider: loadData() completed successfully with ${_products.length} products');
    } catch (error) {
      debugPrint('DataProvider: Error loading data: $error');
    }
  }

  User? _createUserFromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return null;

    final role = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == json['role'],
    );

    if (role == UserRole.vendor) {
      return Vendor.fromJson(json);
    } else {
      return Customer.fromJson(json);
    }
  }

  // Product management
  Future<void> addProduct(Product product, [List<File>? newImageFiles]) async {
    try {
      // Upload new images to cloud storage if provided
      List<String> imageUrls = List<String>.from(product.images);

      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        debugPrint(
            'DataProvider: Uploading ${newImageFiles.length} new images for product ${product.id}');
        final uploadedUrls = await FirestoreService.uploadProductImages(
            newImageFiles, product.id);
        imageUrls.addAll(uploadedUrls);
        debugPrint(
            'DataProvider: Successfully uploaded ${uploadedUrls.length} images');
      }

      // Update product with all image URLs (existing + newly uploaded)
      final updatedProduct = product.copyWith(images: imageUrls);

      // Add to Firestore
      await FirestoreService.addProduct(updatedProduct);

      // Create notification for product added
      await createProductAddedNotification(
          updatedProduct.vendorId, updatedProduct.name, updatedProduct.id);

      // Add to local list (temporary for UI updates)
      _products.add(updatedProduct);
      _safeNotifyListeners();

      debugPrint(
          'DataProvider: Product added successfully - ${updatedProduct.name}');
      debugPrint('DataProvider: Total products now: ${_products.length}');

      // Refresh vendor products to ensure UI is updated
      if (updatedProduct.vendorId.isNotEmpty) {
        debugPrint(
            'DataProvider: Refreshing vendor products for vendor: ${updatedProduct.vendorId}');
        await loadVendorProducts(updatedProduct.vendorId);
      }
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  // Load real products from Firestore
  Future<void> loadRealProducts() async {
    try {
      debugPrint('DataProvider: Loading real products from Firestore');

      // First check if any products exist in database
      final hasProducts = await FirestoreService.hasAnyProducts();
      debugPrint('DataProvider: Database has products: $hasProducts');

      if (!hasProducts) {
        debugPrint('DataProvider: No products found in database');
        _products = [];
        _safeNotifyListeners();
        return;
      }

      // Load real products from Firestore
      _products = await FirestoreService.getRealProducts();
      debugPrint('DataProvider: Loaded ${_products.length} real products');

      // Load vendor information for all products
      await _loadVendorInfoForProducts();

      _safeNotifyListeners();
      debugPrint('DataProvider: Real products loaded successfully');
    } catch (e) {
      debugPrint('DataProvider: Error loading real products: $e');
    }
  }

  // Load notifications from Firestore
  Future<void> loadNotifications() async {
    try {
      debugPrint('DataProvider: Loading notifications from Firestore');

      final notifications = await FirestoreService.getNotifications();
      _notifications = notifications;

      debugPrint('DataProvider: Loaded ${_notifications.length} notifications');
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('DataProvider: Error loading notifications: $e');
    }
  }

  // Clear all data (useful when switching roles)
  void clearAllData() {
    debugPrint('DataProvider: Clearing all data');
    _products.clear();
    _orders.clear();
    _cart.clear();
    _salesData.clear();
    _posTransactions.clear();
    _notifications.clear();
    _vendorStats = null;
    _users.clear();
    _safeNotifyListeners();
    debugPrint('DataProvider: All data cleared');
  }

  // Handle role switch - clear data and prepare for new role
  Future<void> handleRoleSwitch() async {
    debugPrint('DataProvider: Handling role switch');
    clearAllData();
    await clearAllLocalData();
    debugPrint('DataProvider: Role switch handled - data cleared');
  }

  // Force refresh products (useful after adding/updating products)
  Future<void> refreshProducts() async {
    debugPrint('DataProvider: Refreshing all products');
    try {
      await loadRealProducts();
      debugPrint('DataProvider: Products refreshed successfully');
    } catch (e) {
      debugPrint('DataProvider: Error refreshing products: $e');
    }
  }

  // Force refresh all data (useful for debugging)
  Future<void> forceRefreshAllData() async {
    debugPrint('DataProvider: Force refreshing all data');
    try {
      clearAllData();
      await clearAllLocalData();
      await loadRealProducts();
      _safeNotifyListeners();
      debugPrint('DataProvider: All data force refreshed successfully');
    } catch (e) {
      debugPrint('DataProvider: Error force refreshing all data: $e');
    }
  }

  // Clear all local data from device storage
  Future<void> clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productsStorageKey);
      await prefs.remove(_ordersStorageKey);
      await prefs.remove(_cartStorageKey);
      await prefs.remove(_posTransactionsStorageKey);
      await prefs.remove(_notificationsStorageKey);
      await prefs.remove(_usersStorageKey);
      debugPrint('DataProvider: Cleared all local data from device storage');
    } catch (error) {
      debugPrint('Error clearing local data: $error');
    }
  }

  // Load vendor information for products
  Future<void> _loadVendorInfoForProducts() async {
    try {
      // Get unique vendor IDs from products
      final vendorIds = _products
          .map((p) => p.vendorId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      // Load vendor information from Firestore
      for (final vendorId in vendorIds) {
        // Check if vendor is already loaded
        if (!_users.any((u) => u.id == vendorId)) {
          try {
            final vendorData = await FirestoreService.getUser(vendorId);
            if (vendorData != null) {
              _users.add(vendorData);
            }
          } catch (e) {
            debugPrint('Error loading vendor $vendorId: $e');
          }
        }
      }

      // Save users to local storage
      _saveUsers();
    } catch (e) {
      debugPrint('Error loading vendor info: $e');
    }
  }

  // Restore products after refresh to prevent data loss
  Future<void> restoreProducts(List<Product> products) async {
    try {
      debugPrint('DataProvider: Restoring ${products.length} products');
      _products.clear();
      _products.addAll(products);
      _safeNotifyListeners();
      debugPrint('DataProvider: Products restored successfully');
    } catch (e) {
      debugPrint('DataProvider: Error restoring products: $e');
    }
  }

  // Load products by vendor
  Future<void> loadVendorProducts(String vendorId) async {
    try {
      debugPrint(
          'DataProvider: Loading vendor products for vendorId: $vendorId');

      // Check if we already have products for this vendor to avoid unnecessary reloads
      final existingVendorProducts =
          _products.where((p) => p.vendorId == vendorId).toList();
      if (existingVendorProducts.isNotEmpty) {
        debugPrint(
            'DataProvider: Products already loaded for vendor $vendorId, skipping reload');
        return;
      }

      // First check if vendor has any products at all
      final hasProducts = await FirestoreService.hasVendorProducts(vendorId);
      debugPrint('DataProvider: Vendor $vendorId has products: $hasProducts');

      if (!hasProducts) {
        debugPrint('DataProvider: No products found for vendor $vendorId');
        // Only clear products if this is the first load and we have no products
        // Otherwise, keep existing products to prevent data loss
        if (_products.isEmpty) {
          debugPrint(
              'DataProvider: First load with no products, keeping empty state');
          _products.clear();
        } else {
          debugPrint(
              'DataProvider: Keeping existing ${_products.length} products to prevent vanishing');
          // Don't clear - keep existing products
        }
        _safeNotifyListeners();
        return;
      }

      // Get all products for this vendor (no filtering by isRealProduct or isActive)
      final vendorProducts =
          await FirestoreService.getAllProductsByVendor(vendorId);
      debugPrint(
          'DataProvider: Found ${vendorProducts.length} vendor products');

      // Debug: Log details of each product found
      for (final product in vendorProducts) {
        debugPrint(
            'DataProvider: Product - Name: ${product.name}, ID: ${product.id}, VendorId: ${product.vendorId}, isRealProduct: ${product.isRealProduct}, isActive: ${product.isActive}');
      }

      // Clear existing products and load vendor products
      _products.clear();
      _products.addAll(vendorProducts);

      // Load vendor information for the products
      await _loadVendorInfoForProducts();

      _safeNotifyListeners();

      debugPrint('DataProvider: Vendor products loaded successfully');
    } catch (e) {
      debugPrint('DataProvider: Error loading vendor products: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct,
      [List<File>? newImageFiles]) async {
    try {
      // Upload new images to cloud storage if provided
      List<String> imageUrls = List<String>.from(updatedProduct.images);

      if (newImageFiles != null && newImageFiles.isNotEmpty) {
        debugPrint(
            'DataProvider: Uploading ${newImageFiles.length} new images for product update $id');
        final uploadedUrls =
            await FirestoreService.uploadProductImages(newImageFiles, id);
        imageUrls.addAll(uploadedUrls);
        debugPrint(
            'DataProvider: Successfully uploaded ${uploadedUrls.length} images for update');

        // Update product with all image URLs (existing + newly uploaded)
        final finalProduct = updatedProduct.copyWith(images: imageUrls);

        // Update Firestore with final product
        await FirestoreService.updateProduct(id, finalProduct);

        // Update local product in list
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = finalProduct;
          debugPrint(
              'DataProvider: Updated product in local list - ${finalProduct.name}');
        } else {
          debugPrint('DataProvider: Product not found in local list - $id');
        }
      } else {
        // No new images, just update with existing URLs
        await FirestoreService.updateProduct(id, updatedProduct);

        // Update local product in list
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) {
          _products[index] = updatedProduct;
          debugPrint(
              'DataProvider: Updated product in local list - ${updatedProduct.name}');
        } else {
          debugPrint('DataProvider: Product not found in local list - $id');
        }
      }

      // Notify listeners immediately
      _safeNotifyListeners();
      debugPrint('DataProvider: Notified listeners after product update');
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  // Update product locally without Firestore update (for immediate UI updates)
  void updateProductLocally(String id, Product updatedProduct) {
    try {
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        debugPrint(
            'DataProvider: Updated product locally - ${updatedProduct.name}');
        _safeNotifyListeners();
        debugPrint(
            'DataProvider: Notified listeners after local product update');
      } else {
        debugPrint(
            'DataProvider: Product not found in local list for local update - $id');
      }
    } catch (e) {
      debugPrint('Error updating product locally: $e');
    }
  }

  // Force refresh vendor products (ignores existing products check)
  Future<void> forceRefreshVendorProducts(String vendorId) async {
    try {
      debugPrint(
          'DataProvider: Force refreshing vendor products for vendorId: $vendorId');

      // First check if vendor has any products at all
      final hasProducts = await FirestoreService.hasVendorProducts(vendorId);
      debugPrint('DataProvider: Vendor $vendorId has products: $hasProducts');

      if (!hasProducts) {
        debugPrint('DataProvider: No products found for vendor $vendorId');
        _products.clear();
        _safeNotifyListeners();
        return;
      }

      // Get all products for this vendor (no filtering by isRealProduct or isActive)
      final vendorProducts =
          await FirestoreService.getAllProductsByVendor(vendorId);
      debugPrint(
          'DataProvider: Found ${vendorProducts.length} vendor products after force refresh');

      // Debug: Log details of each product found
      for (final product in vendorProducts) {
        debugPrint(
            'DataProvider: Force Refresh Product - Name: ${product.name}, ID: ${product.id}, isDiscounted: ${product.isDiscounted}, discountPercentage: ${product.discountPercentage}');
      }

      // Clear existing products and load vendor products
      _products.clear();
      _products.addAll(vendorProducts);

      // Load vendor information for the products
      await _loadVendorInfoForProducts();

      _safeNotifyListeners();

      debugPrint('DataProvider: Vendor products force refreshed successfully');
    } catch (e) {
      debugPrint('DataProvider: Error force refreshing vendor products: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      debugPrint('DataProvider: Starting product deletion for ID: $id');

      // Check if product exists in local list
      final productIndex = _products.indexWhere((p) => p.id == id);
      Product? product;

      if (productIndex != -1) {
        product = _products[productIndex];
        debugPrint(
            'DataProvider: Found product in local list: ${product.name}');
      } else {
        debugPrint(
            'DataProvider: Product not found in local list, will attempt to delete from database only');
      }

      // Delete images from storage if they exist
      if (product != null && product.images.isNotEmpty) {
        debugPrint('DataProvider: Deleting ${product.images.length} images');
        try {
          await FirestoreService.deleteProductImages(product.images);
          debugPrint('DataProvider: Images deleted successfully');
        } catch (imageError) {
          debugPrint(
              'DataProvider: Warning - Failed to delete images: $imageError');
          // Continue with product deletion even if image deletion fails
        }
      } else {
        debugPrint('DataProvider: No images to delete');
      }

      // Delete from Firestore
      debugPrint('DataProvider: Deleting product from Firestore');
      await FirestoreService.deleteProduct(id);
      debugPrint('DataProvider: Product deleted from Firestore successfully');

      // Create notification for product deleted (only if we have product info)
      if (product != null) {
        await createProductDeletedNotification(
            product.vendorId, product.name, product.id);
      }

      // Remove from local list if it exists
      if (productIndex != -1) {
        final initialCount = _products.length;
        _products.removeAt(productIndex);
        final finalCount = _products.length;
        debugPrint(
            'DataProvider: Removed product from local list ($initialCount -> $finalCount)');
      } else {
        debugPrint(
            'DataProvider: Product was not in local list, no local removal needed');
      }

      _safeNotifyListeners();

      debugPrint('DataProvider: Product deletion completed successfully');
    } catch (e) {
      debugPrint('DataProvider: Error deleting product: $e');
      debugPrint('DataProvider: Error type: ${e.runtimeType}');
      debugPrint('DataProvider: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Cart management
  void addToCart(Product product, int quantity) {
    try {
      // Validate input
      if (quantity <= 0) {
        debugPrint('Invalid quantity: $quantity');
        return;
      }

      final existingItemIndex =
          _cart.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex != -1) {
        _cart[existingItemIndex] = CartItem(
          product: product,
          quantity: _cart[existingItemIndex].quantity + quantity,
        );
      } else {
        _cart.add(CartItem(product: product, quantity: quantity));
      }

      _saveCart();
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  void removeFromCart(String productId) {
    try {
      _cart.removeWhere((item) => item.product.id == productId);
      _saveCart();
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  void updateCartQuantity(String productId, int quantity) {
    try {
      if (quantity <= 0) {
        removeFromCart(productId);
        return;
      }

      final index = _cart.indexWhere((item) => item.product.id == productId);
      if (index != -1) {
        _cart[index] = CartItem(
          product: _cart[index].product,
          quantity: quantity,
        );
        _saveCart();
        _safeNotifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating cart quantity: $e');
    }
  }

  void clearCart() {
    _cart.clear();
    _saveCart();
    _safeNotifyListeners();
  }

  // Order management
  void createOrder(Order order) {
    _orders.add(order);
    _saveOrders();

    // Create notification for vendor
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: order.vendorId,
      title: 'New Order Received!',
      message: 'You have a new order worth ₨${order.total.toStringAsFixed(0)}',
      type: NotificationType.order,
      isRead: false,
      createdAt: DateTime.now(),
      data: {'orderId': order.id},
    );
    addNotification(notification);

    // Update product stock
    for (final item in order.items) {
      final productIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (productIndex != -1) {
        _products[productIndex] = _products[productIndex].copyWith(
          stock: (_products[productIndex].stock - item.quantity)
              .clamp(0, double.infinity)
              .toInt(),
          updatedAt: DateTime.now(),
        );
      }
    }
    _safeNotifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      _saveOrders();
      _safeNotifyListeners();
    }
  }

  // POS transaction management
  void addPOSTransaction(POSTransaction transaction) {
    _posTransactions.add(transaction);
    _savePOSTransactions();

    // Update product stock
    for (final item in transaction.items) {
      final productIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (productIndex != -1) {
        _products[productIndex] = _products[productIndex].copyWith(
          stock: (_products[productIndex].stock - item.quantity)
              .clamp(0, double.infinity)
              .toInt(),
          updatedAt: DateTime.now(),
        );
      }
    }
    _safeNotifyListeners();
  }

  // Notification management
  void addNotification(Notification notification) {
    _notifications.insert(0, notification);
    _saveNotifications();
    _safeNotifyListeners();
  }

  // Product activity notifications
  Future<void> createProductAddedNotification(
      String userId, String productName, String productId) async {
    try {
      final notification = Notification(
        id: 'product_added_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: 'Product Added',
        message: 'Successfully added product: $productName',
        type: NotificationType.product_added,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'productId': productId,
          'productName': productName,
          'action': 'added',
        },
      );

      addNotification(notification);
      await _saveNotificationToFirestore(notification);
    } catch (e) {
      debugPrint('Error creating product added notification: $e');
    }
  }

  Future<void> createProductDeletedNotification(
      String userId, String productName, String productId) async {
    try {
      final notification = Notification(
        id: 'product_deleted_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: 'Product Deleted',
        message: 'Successfully deleted product: $productName',
        type: NotificationType.product_deleted,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'productId': productId,
          'productName': productName,
          'action': 'deleted',
        },
      );

      addNotification(notification);
      await _saveNotificationToFirestore(notification);
    } catch (e) {
      debugPrint('Error creating product deleted notification: $e');
    }
  }

  Future<void> createProductDiscountNotification(
      String userId,
      String productName,
      String productId,
      bool hasDiscount,
      double? discountPercentage) async {
    try {
      final notification = Notification(
        id: 'product_discount_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: hasDiscount ? 'Discount Applied' : 'Discount Removed',
        message: hasDiscount
            ? 'Applied ${discountPercentage?.toStringAsFixed(0) ?? ''}% discount to: $productName'
            : 'Removed discount from: $productName',
        type: NotificationType.product_discount,
        isRead: false,
        createdAt: DateTime.now(),
        data: {
          'productId': productId,
          'productName': productName,
          'hasDiscount': hasDiscount,
          'discountPercentage': discountPercentage,
          'action': hasDiscount ? 'discount_applied' : 'discount_removed',
        },
      );

      addNotification(notification);
      await _saveNotificationToFirestore(notification);
    } catch (e) {
      debugPrint('Error creating product discount notification: $e');
    }
  }

  // Save notification to Firestore
  Future<void> _saveNotificationToFirestore(Notification notification) async {
    try {
      await FirestoreService.addNotification(notification);
    } catch (e) {
      debugPrint('Error saving notification to Firestore: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = Notification(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        isRead: true,
        createdAt: _notifications[index].createdAt,
        data: _notifications[index].data,
      );

      // Save to local storage
      _saveNotifications();

      // Update in Firestore to persist the read status
      try {
        await FirestoreService.updateNotification(_notifications[index]);
        debugPrint(
            'DataProvider: Notification marked as read in Firestore: $notificationId');
      } catch (e) {
        debugPrint(
            'DataProvider: Error updating notification in Firestore: $e');
      }

      _safeNotifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final unreadNotifications =
          _notifications.where((n) => n.userId == userId && !n.isRead).toList();

      if (unreadNotifications.isEmpty) {
        debugPrint('DataProvider: No unread notifications to mark as read');
        return;
      }

      debugPrint(
          'DataProvider: Marking ${unreadNotifications.length} notifications as read');

      // Update all unread notifications to read
      for (var notification in unreadNotifications) {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = Notification(
            id: _notifications[index].id,
            userId: _notifications[index].userId,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            isRead: true,
            createdAt: _notifications[index].createdAt,
            data: _notifications[index].data,
          );

          // Update in Firestore
          try {
            await FirestoreService.updateNotification(_notifications[index]);
          } catch (e) {
            debugPrint(
                'DataProvider: Error updating notification ${notification.id} in Firestore: $e');
          }
        }
      }

      // Save to local storage
      _saveNotifications();
      _safeNotifyListeners();

      debugPrint('DataProvider: All notifications marked as read successfully');
    } catch (e) {
      debugPrint('DataProvider: Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications.removeAt(index);

      // Save to local storage
      _saveNotifications();

      // Delete from Firestore to persist the deletion
      try {
        await FirestoreService.deleteNotification(notificationId);
        debugPrint(
            'DataProvider: Notification deleted from Firestore successfully');
      } catch (e) {
        debugPrint(
            'DataProvider: Error deleting notification from Firestore: $e');
      }

      _safeNotifyListeners();
      debugPrint('DataProvider: Notification deleted successfully');
    }
  }

  // Analytics
  void generateSalesData(String vendorId) {
    final vendorOrders =
        _orders.where((order) => order.vendorId == vendorId).toList();
    final salesMap = <String, Map<String, dynamic>>{};

    for (final order in vendorOrders) {
      final date = order.createdAt.toIso8601String().split('T')[0];
      final existing = salesMap[date] ?? {'amount': 0.0, 'orders': 0};
      salesMap[date] = {
        'amount': existing['amount'] + order.total,
        'orders': existing['orders'] + 1,
      };
    }

    _salesData = salesMap.entries
        .map((entry) => SalesData(
              date: entry.key,
              amount: entry.value['amount'],
              orders: entry.value['orders'],
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _safeNotifyListeners();
  }

  void generateVendorStats(String vendorId) {
    final vendorOrders =
        _orders.where((order) => order.vendorId == vendorId).toList();
    final vendorPOSTransactions =
        _posTransactions.where((t) => t.vendorId == vendorId).toList();
    final vendorProducts =
        _products.where((p) => p.vendorId == vendorId).toList();

    final totalSales = [...vendorOrders, ...vendorPOSTransactions].fold<double>(
        0.0, (sum, transaction) => sum + (transaction as dynamic).total);
    final totalOrders = vendorOrders.length + vendorPOSTransactions.length;
    final activeProducts = vendorProducts.where((p) => p.isActive).length;
    final avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;

    // Calculate top selling products
    final productSales = <String, Map<String, dynamic>>{};

    for (final transaction in [...vendorOrders, ...vendorPOSTransactions]) {
      for (final item in (transaction as dynamic).items) {
        final existing = productSales[item.product.id] ??
            {
              'product': item.product,
              'quantity': 0,
              'revenue': 0.0,
            };
        productSales[item.product.id] = {
          'product': item.product,
          'quantity': existing['quantity'] + item.quantity,
          'revenue':
              existing['revenue'] + (item.product.currentPrice * item.quantity),
        };
      }
    }

    final topSellingProducts = productSales.values
        .map((data) => TopSellingProduct(
              product: data['product'],
              quantity: data['quantity'],
              revenue: data['revenue'],
            ))
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    // Calculate sales by category
    final categorySales = <String, double>{};
    for (final transaction in [...vendorOrders, ...vendorPOSTransactions]) {
      for (final item in (transaction as dynamic).items) {
        categorySales[item.product.category] =
            (categorySales[item.product.category] ?? 0.0) +
                (item.product.currentPrice * item.quantity);
      }
    }

    final salesByCategory = categorySales.entries
        .map((entry) => CategorySales(
              category: entry.key,
              amount: entry.value,
              percentage:
                  totalSales > 0 ? (entry.value / totalSales) * 100 : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    _vendorStats = VendorStats(
      totalSales: totalSales,
      totalOrders: totalOrders,
      activeProducts: activeProducts,
      avgOrderValue: avgOrderValue,
      topSellingProducts: topSellingProducts.take(5).toList(),
      salesByCategory: salesByCategory,
    );

    _safeNotifyListeners();
  }

  // Search nearby vendors
  List<Map<String, dynamic>> searchNearbyVendors([String? location]) {
    final vendorsWithProducts = _users
        .where((user) =>
            user.role == UserRole.vendor &&
            user is Vendor &&
            _products.any(
                (product) => product.vendorId == user.id && product.isActive))
        .toList();

    return vendorsWithProducts.whereType<Vendor>().map((vendor) {
      final summary = _calculateVendorRatingSummary(vendor.id);
      final average =
          summary.count > 0 ? summary.average : (vendor).rating;
      final ratingCount =
          summary.count > 0 ? summary.count : (vendor).ratingCount;

      return {
        'id': vendor.id,
        'name': (vendor).shopName,
        'shopLogo': vendor.shopLogo,
        'distance': '1.0 km', // Placeholder distance
        'rating': average,
        'ratingCount': ratingCount,
      };
    }).toList();
  }

  // Search nearby vendors with actual distance calculation
  List<Map<String, dynamic>> searchNearbyVendorsWithDistance({
    double? customerLatitude,
    double? customerLongitude,
    double maxDistanceKm = 10.0, // Default 10km radius
  }) {
    // If no customer location provided, return all vendors (fallback)
    if (customerLatitude == null || customerLongitude == null) {
      return searchNearbyVendors();
    }

    final vendorsWithProducts = _users
        .where((user) =>
            user.role == UserRole.vendor &&
            user is Vendor &&
            _products.any(
                (product) => product.vendorId == user.id && product.isActive))
        .toList();

    final nearbyVendors = <Map<String, dynamic>>[];

    for (final vendor in vendorsWithProducts.whereType<Vendor>()) {
      // Check if vendor has location data
      if (vendor.location != null) {
        final distance = _calculateDistance(
          customerLatitude,
          customerLongitude,
          vendor.location!.latitude,
          vendor.location!.longitude,
        );

        // Only include vendors within the specified radius
        if (distance <= maxDistanceKm) {
          final summary = _calculateVendorRatingSummary(vendor.id);
          final average =
              summary.count > 0 ? summary.average : vendor.rating;
          final ratingCount =
              summary.count > 0 ? summary.count : vendor.ratingCount;

          nearbyVendors.add({
            'id': vendor.id,
            'name': vendor.shopName,
            'shopLogo': vendor.shopLogo,
            'distance': distance,
            'distanceText': _formatDistance(distance),
            'rating': average,
            'ratingCount': ratingCount,
          });
        }
      }
    }

    // Sort by distance (nearest first)
    nearbyVendors.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return nearbyVendors;
  }

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  _VendorRatingSummary _calculateVendorRatingSummary(String vendorId) {
    double weightedSum = 0;
    int totalReviews = 0;
    double fallbackSum = 0;
    int fallbackCount = 0;

    for (final product in _products.where((p) => p.vendorId == vendorId)) {
      final productRating = product.rating ?? 0.0;
      final reviewCount = product.reviewCount ?? 0;

      if (reviewCount > 0) {
        weightedSum += productRating * reviewCount;
        totalReviews += reviewCount;
      } else if (productRating > 0) {
        fallbackSum += productRating;
        fallbackCount++;
      }
    }

    if (totalReviews > 0) {
      return _VendorRatingSummary(
        weightedSum / totalReviews,
        totalReviews,
      );
    }

    if (fallbackCount > 0) {
      return _VendorRatingSummary(
        fallbackSum / fallbackCount,
        fallbackCount,
      );
    }

    return const _VendorRatingSummary(0.0, 0);
  }

  void updateProductRatingCache(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      _safeNotifyListeners();
    }
  }

  Future<void> refreshVendorRating(String vendorId) async {
    try {
      final vendor = await FirestoreService.getUser(vendorId);
      if (vendor is Vendor) {
        final existingIndex = _users.indexWhere((u) => u.id == vendorId);
        if (existingIndex != -1) {
          _users[existingIndex] = vendor;
        } else {
          _users.add(vendor);
        }
        _saveUsers();
        _safeNotifyListeners();
      }
    } catch (e) {
      debugPrint('DataProvider: Error refreshing vendor rating: $e');
    }
  }

  // Format distance for display
  String _formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10.0) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  // Clear all local product data from device storage
  Future<void> clearLocalProductData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productsStorageKey);
      debugPrint('DataProvider: Cleared all local product data from device');
    } catch (error) {
      debugPrint('Error clearing local product data: $error');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ordersStorageKey,
          json.encode(_orders.map((o) => o.toJson()).toList()));
    } catch (error) {
      debugPrint('Error saving orders: $error');
    }
  }

  Future<void> _saveUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersStorageKey,
          json.encode(_users.map((u) => u.toJson()).toList()));
    } catch (error) {
      debugPrint('Error saving users: $error');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _cartStorageKey, json.encode(_cart.map((c) => c.toJson()).toList()));
    } catch (error) {
      debugPrint('Error saving cart: $error');
    }
  }

  Future<void> _savePOSTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_posTransactionsStorageKey,
          json.encode(_posTransactions.map((t) => t.toJson()).toList()));
    } catch (error) {
      debugPrint('Error saving POS transactions: $error');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsStorageKey,
          json.encode(_notifications.map((n) => n.toJson()).toList()));
    } catch (error) {
      debugPrint('Error saving notifications: $error');
    }
  }
}

class _VendorRatingSummary {
  final double average;
  final int count;
  const _VendorRatingSummary(this.average, this.count);
}
