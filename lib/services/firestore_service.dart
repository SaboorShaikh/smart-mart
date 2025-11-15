import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../models/analytics.dart';
import 'supabase_storage_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Products Collection
  static const String _productsCollection = 'products';
  static const String _usersCollection = 'users';
  static const String _productRatingsCollection = 'ratings';

  // Add a new product to Firestore
  static Future<String> addProduct(Product product) async {
    try {
      final docRef = await _firestore
          .collection(_productsCollection)
          .add(product.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Update an existing product
  static Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete a product
  static Future<void> deleteProduct(String productId) async {
    try {
      debugPrint(
          'FirestoreService: deleteProduct - Attempting to delete product: $productId');

      // First check if the product exists
      final doc =
          await _firestore.collection(_productsCollection).doc(productId).get();
      if (!doc.exists) {
        debugPrint(
            'FirestoreService: deleteProduct - Product $productId does not exist in database');
        throw Exception('Product with ID $productId not found in database');
      }

      debugPrint(
          'FirestoreService: deleteProduct - Product exists, proceeding with deletion');
      await _firestore.collection(_productsCollection).doc(productId).delete();
      debugPrint(
          'FirestoreService: deleteProduct - Product $productId deleted successfully');
    } catch (e) {
      debugPrint(
          'FirestoreService: deleteProduct - Error deleting product $productId: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // Get ALL products by vendor (for debugging - no filters)
  static Future<List<Product>> getAllProductsByVendor(String vendorId) async {
    try {
      debugPrint(
          'FirestoreService: getAllProductsByVendor - Loading ALL products for vendor: $vendorId');
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint(
          'FirestoreService: getAllProductsByVendor - Found ${snapshot.docs.length} products');

      final products = snapshot.docs
          .map((doc) {
            try {
              final product = Product.fromJson({...doc.data(), 'id': doc.id});
              debugPrint(
                  'FirestoreService: getAllProductsByVendor - Product: ${product.name} (ID: ${product.id}, isRealProduct: ${product.isRealProduct}, isActive: ${product.isActive})');
              return product;
            } catch (e) {
              debugPrint(
                  'FirestoreService: getAllProductsByVendor - Error parsing product ${doc.id}: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();

      debugPrint(
          'FirestoreService: getAllProductsByVendor - Returning ${products.length} valid products');
      return products;
    } catch (e) {
      debugPrint('FirestoreService: getAllProductsByVendor - Error: $e');
      throw Exception('Failed to get all vendor products: $e');
    }
  }

  // Get products by vendor
  static Future<List<Product>> getProductsByVendor(String vendorId) async {
    try {
      debugPrint(
          'FirestoreService: getProductsByVendor - Loading products for vendor: $vendorId');
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .get();

      debugPrint(
          'FirestoreService: getProductsByVendor - Found ${snapshot.docs.length} products');

      final products = snapshot.docs
          .map((doc) {
            try {
              final product = Product.fromJson({...doc.data(), 'id': doc.id});
              debugPrint(
                  'FirestoreService: getProductsByVendor - Product: ${product.name} (ID: ${product.id}, isRealProduct: ${product.isRealProduct}, isActive: ${product.isActive})');
              return product;
            } catch (e) {
              debugPrint(
                  'FirestoreService: getProductsByVendor - Error parsing product ${doc.id}: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .where((product) =>
              product.isRealProduct == true && product.isActive == true)
          .toList();

      debugPrint(
          'FirestoreService: getProductsByVendor - Returning ${products.length} valid products');
      return products;
    } catch (e) {
      debugPrint('FirestoreService: getProductsByVendor - Error: $e');
      throw Exception('Failed to get vendor products: $e');
    }
  }

  // Check if any products exist in database
  static Future<bool> hasAnyProducts() async {
    try {
      debugPrint(
          'FirestoreService: hasAnyProducts - Checking if any products exist');
      final snapshot =
          await _firestore.collection(_productsCollection).limit(1).get();

      final hasProducts = snapshot.docs.isNotEmpty;
      debugPrint(
          'FirestoreService: hasAnyProducts - Has products: $hasProducts');
      return hasProducts;
    } catch (e) {
      debugPrint('FirestoreService: hasAnyProducts - Error: $e');
      return false;
    }
  }

  // Check if vendor has any products
  static Future<bool> hasVendorProducts(String vendorId) async {
    try {
      debugPrint(
          'FirestoreService: hasVendorProducts - Checking if vendor $vendorId has products');

      // Debug: Check what vendor IDs exist in the database
      final allSnapshot =
          await _firestore.collection(_productsCollection).get();

      debugPrint(
          'FirestoreService: hasVendorProducts - Found ${allSnapshot.docs.length} total products');
      final vendorIds =
          allSnapshot.docs.map((doc) => doc.data()['vendorId']).toSet();
      debugPrint(
          'FirestoreService: hasVendorProducts - Existing vendor IDs: $vendorIds');
      debugPrint(
          'FirestoreService: hasVendorProducts - Looking for vendor ID: $vendorId');

      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .limit(1)
          .get();

      final hasProducts = snapshot.docs.isNotEmpty;
      debugPrint(
          'FirestoreService: hasVendorProducts - Vendor $vendorId has products: $hasProducts');
      return hasProducts;
    } catch (e) {
      debugPrint('FirestoreService: hasVendorProducts - Error: $e');
      return false;
    }
  }

  // Debug method to check ALL products in database
  static Future<void> debugAllProducts() async {
    try {
      debugPrint(
          'FirestoreService: debugAllProducts - Checking ALL products in database');
      final snapshot = await _firestore.collection(_productsCollection).get();

      debugPrint(
          'FirestoreService: debugAllProducts - Found ${snapshot.docs.length} total products in database');

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          debugPrint(
              'FirestoreService: debugAllProducts - Product ID: ${doc.id}');
          debugPrint(
              'FirestoreService: debugAllProducts - Product name: ${data['name']}');
          debugPrint(
              'FirestoreService: debugAllProducts - Product vendorId: ${data['vendorId']}');
          debugPrint(
              'FirestoreService: debugAllProducts - Product isRealProduct: ${data['isRealProduct']}');
          debugPrint(
              'FirestoreService: debugAllProducts - Product isActive: ${data['isActive']}');
          debugPrint('FirestoreService: debugAllProducts - ---');
        } catch (e) {
          debugPrint(
              'FirestoreService: debugAllProducts - Error parsing product ${doc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('FirestoreService: debugAllProducts - Error: $e');
    }
  }

  // Get all products (for debugging)
  static Future<List<Product>> getAllProductsDebug() async {
    try {
      debugPrint('FirestoreService: getAllProductsDebug - Starting query');
      final snapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint(
          'FirestoreService: getAllProductsDebug - Found ${snapshot.docs.length} documents');

      final products = snapshot.docs
          .map((doc) {
            try {
              final product = Product.fromJson({...doc.data(), 'id': doc.id});
              debugPrint(
                  'FirestoreService: getAllProductsDebug - Product: ${product.name} (ID: ${product.id}, isRealProduct: ${product.isRealProduct}, isActive: ${product.isActive})');
              return product;
            } catch (e) {
              debugPrint(
                  'FirestoreService: getAllProductsDebug - Error parsing product ${doc.id}: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();

      debugPrint(
          'FirestoreService: getAllProductsDebug - Returning ${products.length} valid products');
      return products;
    } catch (e) {
      debugPrint('FirestoreService: getAllProductsDebug - Error: $e');
      throw Exception('Failed to get all products: $e');
    }
  }

  // Get only real products (not dummy data)
  static Future<List<Product>> getRealProducts() async {
    try {
      debugPrint('FirestoreService: getRealProducts - Starting query');
      final snapshot = await _firestore.collection(_productsCollection).get();

      debugPrint(
          'FirestoreService: getRealProducts - Found ${snapshot.docs.length} documents');

      final products = snapshot.docs
          .map((doc) {
            try {
              final product = Product.fromJson({...doc.data(), 'id': doc.id});
              debugPrint(
                  'FirestoreService: getRealProducts - Product: ${product.name} (ID: ${product.id}, isRealProduct: ${product.isRealProduct}, isActive: ${product.isActive})');
              return product;
            } catch (e) {
              debugPrint(
                  'FirestoreService: getRealProducts - Error parsing product ${doc.id}: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .where((product) =>
              product.isRealProduct == true && product.isActive == true)
          .toList();

      debugPrint(
          'FirestoreService: getRealProducts - Returning ${products.length} valid products');
      return products;
    } catch (e) {
      debugPrint('FirestoreService: getRealProducts - Error: $e');
      throw Exception('Failed to get real products: $e');
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('category', isEqualTo: category)
          .where('isRealProduct', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  // Search products
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('isRealProduct', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      final products = snapshot.docs
          .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Filter products based on search query
      return products.where((product) {
        final searchQuery = query.toLowerCase();
        return product.name.toLowerCase().contains(searchQuery) ||
            product.description.toLowerCase().contains(searchQuery) ||
            product.category.toLowerCase().contains(searchQuery) ||
            (product.brand?.toLowerCase().contains(searchQuery) ?? false) ||
            (product.tags
                    ?.any((tag) => tag.toLowerCase().contains(searchQuery)) ??
                false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Upload product images to Supabase Storage
  static Future<List<String>> uploadProductImages(
      List<File> images, String productId) async {
    try {
      return await SupabaseStorageService.uploadProductImages(
          images, productId);
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }

  // Delete product images (handles Supabase public URLs and Firebase URLs)
  static Future<void> deleteProductImages(List<String> imageUrls) async {
    try {
      debugPrint(
          'FirestoreService: Starting deletion of ${imageUrls.length} images');

      for (int i = 0; i < imageUrls.length; i++) {
        final url = imageUrls[i];
        debugPrint(
            'FirestoreService: Deleting image ${i + 1}/${imageUrls.length}: $url');

        try {
          if (url.contains('/storage/v1/object/public/')) {
            debugPrint('FirestoreService: Deleting Supabase image');
            await SupabaseStorageService.deleteByPublicUrl(url);
            debugPrint('FirestoreService: Supabase image deleted successfully');
          } else {
            debugPrint('FirestoreService: Deleting Firebase Storage image');
            final ref = _storage.refFromURL(url);
            await ref.delete();
            debugPrint('FirestoreService: Firebase image deleted successfully');
          }
        } catch (imageError) {
          debugPrint(
              'FirestoreService: Warning - Failed to delete image $url: $imageError');
          // Continue with other images even if one fails
        }
      }

      debugPrint('FirestoreService: Image deletion process completed');
    } catch (e) {
      debugPrint('FirestoreService: Error in deleteProductImages: $e');
      debugPrint('FirestoreService: Error type: ${e.runtimeType}');
      throw Exception('Failed to delete images: $e');
    }
  }

  // Get product by ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc =
          await _firestore.collection(_productsCollection).doc(productId).get();

      if (doc.exists) {
        return Product.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  static Future<double?> getUserProductRating(
      String productId, String userId) async {
    try {
      final doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .collection(_productRatingsCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final ratingValue = data?['rating'];
        if (ratingValue != null) {
          return (ratingValue as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      debugPrint('FirestoreService: Error getting user product rating: $e');
      throw Exception('Failed to get user rating: $e');
    }
  }

  static Future<Product?> setProductRating({
    required String productId,
    required String userId,
    required double rating,
  }) async {
    try {
      final productDocRef =
          _firestore.collection(_productsCollection).doc(productId);
      final productSnapshot = await productDocRef.get();
      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }
      final productData = productSnapshot.data()!;
      final vendorId = productData['vendorId']?.toString() ?? '';

      final ratingsRef = _firestore
          .collection(_productsCollection)
          .doc(productId)
          .collection(_productRatingsCollection);

      await ratingsRef.doc(userId).set({
        'rating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final ratingsSnapshot = await ratingsRef.get();
      double totalRating = 0;
      for (final doc in ratingsSnapshot.docs) {
        final value = doc.data()['rating'];
        if (value != null) {
          totalRating += (value as num).toDouble();
        }
      }

      final count = ratingsSnapshot.docs.length;
      final averageRaw = count > 0 ? totalRating / count : 0.0;
      final average =
          count > 0 ? double.parse(averageRaw.toStringAsFixed(2)) : 0.0;

      await productDocRef.update({
        'rating': average,
        'reviewCount': count,
      });

      if (vendorId.isNotEmpty) {
        await _updateVendorRating(vendorId);
      }

      return await getProductById(productId);
    } catch (e) {
      debugPrint('FirestoreService: Error setting product rating: $e');
      throw Exception('Failed to update product rating: $e');
    }
  }

  static Future<void> _updateVendorRating(String vendorId) async {
    try {
      final productsSnapshot = await _firestore
          .collection(_productsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .get();

      double weightedSum = 0;
      int totalReviews = 0;
      double fallbackSum = 0;
      int fallbackCount = 0;

      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        final productRating =
            (data['rating'] as num?)?.toDouble() ?? 0.0;
        final productReviewCount =
            (data['reviewCount'] as num?)?.toInt() ?? 0;

        if (productReviewCount > 0) {
          weightedSum += productRating * productReviewCount;
          totalReviews += productReviewCount;
        } else if (productRating > 0) {
          fallbackSum += productRating;
          fallbackCount++;
        }
      }

      double average;
      int ratingCount;
      if (totalReviews > 0) {
        average = weightedSum / totalReviews;
        ratingCount = totalReviews;
      } else if (fallbackCount > 0) {
        average = fallbackSum / fallbackCount;
        ratingCount = fallbackCount;
      } else {
        average = 0.0;
        ratingCount = 0;
      }

      final roundedAverage =
          ratingCount > 0 ? double.parse(average.toStringAsFixed(2)) : 0.0;

      await _firestore.collection(_usersCollection).doc(vendorId).set(
        {
          'rating': roundedAverage,
          'ratingCount': ratingCount,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FirestoreService: Error updating vendor rating: $e');
    }
  }

  // Stream products for real-time updates
  static Stream<List<Product>> streamProducts() {
    return _firestore
        .collection(_productsCollection)
        .where('isRealProduct', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Stream ALL vendor products (no filters) for debugging
  static Stream<List<Product>> streamAllVendorProducts(String vendorId) {
    try {
      debugPrint(
          'FirestoreService: streamAllVendorProducts - Starting stream for vendor: $vendorId (no filters)');
      return _firestore
          .collection(_productsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        debugPrint(
            'FirestoreService: streamAllVendorProducts - Found ${snapshot.docs.length} products for vendor $vendorId (no filters)');
        try {
          final products = snapshot.docs
              .map((doc) {
                try {
                  final product =
                      Product.fromJson({...doc.data(), 'id': doc.id});
                  debugPrint(
                      'FirestoreService: streamAllVendorProducts - Product: ${product.name} (ID: ${product.id}, isRealProduct: ${product.isRealProduct}, isActive: ${product.isActive})');
                  return product;
                } catch (e) {
                  debugPrint(
                      'FirestoreService: streamAllVendorProducts - Error parsing product ${doc.id}: $e');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<Product>()
              .toList();

          debugPrint(
              'FirestoreService: streamAllVendorProducts - Returning ${products.length} valid products');
          return products;
        } catch (e) {
          debugPrint(
              'FirestoreService: streamAllVendorProducts - Error processing snapshot: $e');
          return <Product>[];
        }
      }).handleError((error) {
        debugPrint(
            'FirestoreService: streamAllVendorProducts - Stream error: $error');
        return <Product>[];
      });
    } catch (e) {
      debugPrint(
          'FirestoreService: streamAllVendorProducts - Initial error: $e');
      return Stream.value(<Product>[]);
    }
  }

  // Stream vendor products for real-time updates
  static Stream<List<Product>> streamVendorProducts(String vendorId) {
    try {
      debugPrint(
          'FirestoreService: streamVendorProducts - Starting stream for vendor: $vendorId');
      return _firestore
          .collection(_productsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .snapshots()
          .map((snapshot) {
        debugPrint(
            'FirestoreService: streamVendorProducts - Found ${snapshot.docs.length} products for vendor $vendorId');
        try {
          final products = snapshot.docs
              .map((doc) {
                try {
                  final product =
                      Product.fromJson({...doc.data(), 'id': doc.id});
                  debugPrint(
                      'FirestoreService: streamVendorProducts - Product: ${product.name} (ID: ${product.id}, isRealProduct: ${product.isRealProduct}, isActive: ${product.isActive})');
                  return product;
                } catch (e) {
                  debugPrint(
                      'FirestoreService: streamVendorProducts - Error parsing product ${doc.id}: $e');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<Product>()
              .where((product) =>
                  product.isRealProduct == true && product.isActive == true)
              .toList();

          debugPrint(
              'FirestoreService: streamVendorProducts - Returning ${products.length} valid products');
          return products;
        } catch (e) {
          debugPrint(
              'FirestoreService: streamVendorProducts - Error processing snapshot: $e');
          return <Product>[];
        }
      }).handleError((error) {
        debugPrint(
            'FirestoreService: streamVendorProducts - Stream error: $error');
        return <Product>[];
      });
    } catch (e) {
      debugPrint('FirestoreService: streamVendorProducts - Initial error: $e');
      return Stream.value(<Product>[]);
    }
  }

  // User Management Methods
  static Future<void> addUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  static Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = userId; // Add the document ID to the data
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  static Future<void> updateUser(
      String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      debugPrint('FirestoreService.updateUser - Updating user $userId');
      debugPrint('  deliveryMode: ${updates['deliveryMode']}');
      debugPrint('  deliveryRadiusKm: ${updates['deliveryRadiusKm']}');
      debugPrint('  Full updates: $updates');
      await _firestore.collection('users').doc(userId).update(updates);
      debugPrint('User $userId updated successfully in Firestore');
    } catch (e) {
      debugPrint('Error updating user $userId: $e');
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Addresses (per user)
  static CollectionReference<Map<String, dynamic>> _addressesCol(
          String userId) =>
      _firestore.collection('users').doc(userId).collection('addresses');

  static Stream<List<AddressModel>> streamAddresses(String userId) {
    return _addressesCol(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AddressModel.fromJson(
                {...d.data(), 'id': d.id, 'userId': userId}))
            .toList());
  }

  static Future<String> addAddress(String userId, AddressModel address) async {
    final data = address
        .copyWith(id: '', userId: userId, createdAt: DateTime.now())
        .toJson();
    final ref = await _addressesCol(userId).add(data);
    return ref.id;
  }

  static Future<void> updateAddress(String userId, AddressModel address) async {
    await _addressesCol(userId).doc(address.id).update({
      ...address.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> deleteAddress(String userId, String addressId) async {
    await _addressesCol(userId).doc(addressId).delete();
  }

  // Notifications
  static Future<List<Notification>> getNotifications() async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Notification.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      throw Exception('Failed to get notifications: $e');
    }
  }

  static Future<void> addNotification(Notification notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      debugPrint('Error adding notification: $e');
      throw Exception('Failed to add notification: $e');
    }
  }

  static Future<void> updateNotification(Notification notification) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .update(notification.toJson());
      debugPrint('Notification updated in Firestore: ${notification.id}');
    } catch (e) {
      debugPrint('Error updating notification: $e');
      throw Exception('Failed to update notification: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      debugPrint('Notification deleted from Firestore: $notificationId');
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Profile Image Management (uses Supabase Storage)
  static Future<String> uploadProfileImage(
      File imageFile, String userId) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }
      return await SupabaseStorageService.uploadProfileImage(imageFile, userId);
    } catch (e) {
      debugPrint('FirestoreService - Error uploading profile image: $e');
      debugPrint('FirestoreService - Error type: ${e.runtimeType}');
      debugPrint('FirestoreService - Error details: ${e.toString()}');
      if (e is FirebaseException) {
        debugPrint('FirestoreService - Firebase error code: ${e.code}');
        debugPrint('FirestoreService - Firebase error message: ${e.message}');
      }
      rethrow;
    }
  }

  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.contains('/storage/v1/object/')) {
        await SupabaseStorageService.deleteByPublicUrl(imageUrl);
      } else {
        await _storage.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }

  // Location Management
  static Future<void> updateUserLocation(
      String userId, LocationData location) async {
    await _firestore.collection('users').doc(userId).update({
      'location': location.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Address Management
  static Future<void> updateUserAddress(
    String userId, {
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (address != null) updates['address'] = address;
    if (city != null) updates['city'] = city;
    if (state != null) updates['state'] = state;
    if (country != null) updates['country'] = country;
    if (postalCode != null) updates['postalCode'] = postalCode;

    await _firestore.collection('users').doc(userId).update(updates);
  }
}
