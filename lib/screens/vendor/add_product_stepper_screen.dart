import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/categories.dart';
import '../../services/notification_service.dart';
import '../product_detail_screen.dart';
import 'add_product_step1_screen.dart';
import 'add_product_step2_screen.dart';
import 'add_product_step3_screen.dart';
import 'add_product_step4_screen.dart';
import 'add_product_step5_screen.dart';
import 'add_product_step6_screen.dart';

class AddProductStepperScreen extends StatefulWidget {
  final Product? product; // Optional product for editing
  final int initialStep; // Initial step to start from

  const AddProductStepperScreen({
    super.key,
    this.product,
    this.initialStep = 0,
  });

  @override
  State<AddProductStepperScreen> createState() =>
      _AddProductStepperScreenState();
}

class _AddProductStepperScreenState extends State<AddProductStepperScreen> {
  bool _didCheckRole = false;
  late int _currentStep;
  bool _isLoading = false;
  bool get _isEditMode => widget.product != null;

  // Helper method to compare two File lists
  bool _listEquals(List<File> list1, List<File> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].path != list2[i].path) return false;
    }
    return true;
  }

  // Product data to be collected across all steps
  final List<File> _selectedImages = [];
  final List<String> _existingImageUrls =
      []; // For edit mode - existing images from URLs
  late String _productName;
  late String _description;
  late String _selectedCategory;
  late String _price;
  late String _unit;
  late String _stockQuantity;
  late String _brand;
  late String _origin;
  late String _expiryDate;
  late String _barcode;
  late String _manufacturer;
  late String _detailedDescription;
  late String _features;
  late String _storageInstructions;
  late String _allergens;
  late String _nutritionInfo;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    debugPrint(
        'AddProductStepper initState - initialStep: ${widget.initialStep}, _currentStep: $_currentStep');
    _initializeFields();
    debugPrint(
        'AddProductStepper initState - After init, _currentStep: $_currentStep');
  }

  void _initializeFields() {
    // Check if we have data from navigation arguments
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('productName')) {
      debugPrint('Initializing from navigation arguments');
      _productName = args['productName'] as String? ?? '';
      _description = args['description'] as String? ?? '';
      _selectedCategory =
          args['selectedCategory'] as String? ?? 'Fruits & Vegetables';
      _price = args['price'] as String? ?? '';
      _unit = args['unit'] as String? ?? '';
      _stockQuantity = args['stockQuantity'] as String? ?? '';
      _brand = args['brand'] as String? ?? '';
      _origin = args['origin'] as String? ?? '';
      _expiryDate = args['expiryDate'] as String? ?? '';
      _barcode = args['barcode'] as String? ?? '';
      _manufacturer = args['manufacturer'] as String? ?? '';
      _detailedDescription = args['detailedDescription'] as String? ?? '';
      _features = args['features'] as String? ?? '';
      _storageInstructions = args['storageInstructions'] as String? ?? '';
      _allergens = args['allergens'] as String? ?? '';
      _nutritionInfo = args['nutritionInfo'] as String? ?? '';
      _tags = List<String>.from(args['tags'] as List? ?? []);
      _existingImageUrls.clear();
      _existingImageUrls
          .addAll(List<String>.from(args['existingImageUrls'] as List? ?? []));
      debugPrint(
          'Initialized from args - Name: $_productName, Images: ${_existingImageUrls.length}');
      return;
    }

    if (_isEditMode && widget.product != null) {
      final product = widget.product!;
      _productName = product.name;
      _description = product.description;
      _selectedCategory = product.category;
      _price = product.price.toString();
      _unit = product.unit;
      _stockQuantity = product.stock.toString();
      _brand = product.brand ?? '';
      _origin = product.origin ?? '';
      _expiryDate = product.expiryDate ?? '';
      _barcode = product.barcode ?? '';
      _manufacturer = product.manufacturer ?? '';
      _detailedDescription = product.detailedDescription ?? '';
      _features = product.features?.join(', ') ?? '';
      _storageInstructions = product.storageInstructions ?? '';
      _allergens = product.allergens?.join(', ') ?? '';
      _nutritionInfo = product.nutritionInfo?.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ') ??
          '';
      _tags = List<String>.from(product.tags ?? []);
      // Store existing image URLs for display in edit mode
      _existingImageUrls.clear();
      _existingImageUrls.addAll(product.images);
      debugPrint(
          'Edit Mode: Initialized with ${_existingImageUrls.length} existing images');
      debugPrint('Edit Mode: Product name = $_productName');
      debugPrint('Edit Mode: Price = $_price, Stock = $_stockQuantity');
    } else {
      _productName = '';
      _description = '';
      _selectedCategory = 'Fruits & Vegetables';
      _price = '';
      _unit = '';
      _stockQuantity = '';
      _brand = '';
      _origin = '';
      _expiryDate = '';
      _barcode = '';
      _manufacturer = '';
      _detailedDescription = '';
      _features = '';
      _storageInstructions = '';
      _allergens = '';
      _nutritionInfo = '';
      _tags = [];
    }
  }

  final List<String> _categories = Categories.getAllCategoryDisplayNames();

  List<Widget> get _steps => [
        AddProductStep1Screen(
          selectedImages: _selectedImages,
          existingImageUrls: _existingImageUrls,
          productName: _productName,
          description: _description,
          isEditMode: _isEditMode,
          onDataChanged: (images, name, description) {
            debugPrint('Stepper - Step1 data changed: ${images.length} images');
            debugPrint(
                'Stepper - Previous _selectedImages length: ${_selectedImages.length}');
            setState(() {
              // Only update if we have a different set of images
              if (_selectedImages.length != images.length ||
                  !_listEquals(_selectedImages, images)) {
                _selectedImages.clear();
                _selectedImages.addAll(images);
                debugPrint(
                    'Stepper - Updated _selectedImages to ${_selectedImages.length} images');
              }
              _productName = name;
              _description = description;
            });
          },
          onExistingImagesChanged: (urls) {
            setState(() {
              _existingImageUrls.clear();
              _existingImageUrls.addAll(urls);
            });
          },
        ),
        AddProductStep2Screen(
          selectedCategory: _selectedCategory,
          price: _price,
          unit: _unit,
          stockQuantity: _stockQuantity,
          categories: _categories,
          onDataChanged: (category, price, unit, stock) {
            setState(() {
              _selectedCategory = category;
              _price = price;
              _unit = unit;
              _stockQuantity = stock;
            });
          },
          onStartOver: () {
            setState(() {
              _currentStep = 0;
            });
          },
        ),
        AddProductStep3Screen(
          brand: _brand,
          origin: _origin,
          expiryDate: _expiryDate,
          barcode: _barcode,
          manufacturer: _manufacturer,
          onDataChanged: (brand, origin, expiry, barcode, manufacturer) {
            setState(() {
              _brand = brand;
              _origin = origin;
              _expiryDate = expiry;
              _barcode = barcode;
              _manufacturer = manufacturer;
            });
          },
          onStartOver: () {
            setState(() {
              _currentStep = 0;
            });
          },
        ),
        AddProductStep4Screen(
          detailedDescription: _detailedDescription,
          features: _features,
          storageInstructions: _storageInstructions,
          allergens: _allergens,
          onDataChanged: (detailedDesc, features, storage, allergens) {
            setState(() {
              _detailedDescription = detailedDesc;
              _features = features;
              _storageInstructions = storage;
              _allergens = allergens;
            });
          },
          onStartOver: () {
            setState(() {
              _currentStep = 0;
            });
          },
        ),
        AddProductStep5Screen(
          nutritionInfo: _nutritionInfo,
          onDataChanged: (nutrition) {
            setState(() {
              _nutritionInfo = nutrition;
            });
          },
          onStartOver: () {
            setState(() {
              _currentStep = 0;
            });
          },
        ),
        AddProductStep6Screen(
          tags: _tags,
          onDataChanged: (tags) {
            setState(() {
              _tags = tags;
            });
          },
          onStartOver: () {
            setState(() {
              _currentStep = 0;
            });
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    debugPrint('AddProductStepperScreen - build() called');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    // Perform role validation once after first frame to avoid scheduling in build
    if (!_didCheckRole) {
      _didCheckRole = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        debugPrint('Add Product Stepper - Role validation started');
        debugPrint(
            'Add Product Stepper - Current user role: ${authProvider.user?.role}');
        debugPrint(
            'Add Product Stepper - Current user email: ${authProvider.user?.email}');

        if (authProvider.user?.role != UserRole.vendor) {
          debugPrint(
              'Add Product Stepper - User is not vendor, attempting to switch');
          final switched = await authProvider.switchToVendorRole();
          debugPrint('Add Product Stepper - Switch result: $switched');

          if (!switched) {
            debugPrint(
                'Add Product Stepper - Switch failed, showing error and going back');
            // Only redirect if user doesn't have vendor account
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vendor account required to add products'),
                backgroundColor: Colors.red,
              ),
            );
            Get.back();
          } else {
            debugPrint(
                'Add Product Stepper - Successfully switched to vendor role');
          }
        } else {
          debugPrint(
              'Add Product Stepper - User is already vendor, proceeding');
        }
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    // Current step content (stages 2-6 have their own headers)
                    Expanded(
                      child: _steps[_currentStep],
                    ),
                    // Spacer for fixed bottom button
                    if (_currentStep == 0) const SizedBox(height: 80),
                    // Spacer for floating buttons (stages 2-6, steps 1-5)
                    if (_currentStep > 0) const SizedBox(height: 100),
                  ],
                ),
                // Fixed Bottom Navigation Button (for step 0 - only Next)
                if (_currentStep == 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? const Color(0xFF1E293B).withOpacity(0.8)
                                : const Color(0xFFE2E8F0).withOpacity(0.8),
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Builder(
                        builder: (context) {
                          final canProceed = _canProceedToNext();
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: canProceed
                                  ? () {
                                      debugPrint('Next button pressed');
                                      debugPrint('Can proceed: $canProceed');
                                      debugPrint('Current step: $_currentStep');
                                      debugPrint(
                                          'Step 0 validation - Images: ${_selectedImages.length}, Name: $_productName, Desc: $_description');
                                      _nextStep();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canProceed
                                    ? const Color(0xFF225FEC)
                                    : (isDark
                                        ? const Color(0xFF3F3F46)
                                        : const Color(0xFFD4D4D8)),
                                foregroundColor: canProceed
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFF71717A)
                                        : const Color(0xFFA1A1AA)),
                                elevation: canProceed ? 8 : 0,
                                shadowColor: canProceed
                                    ? const Color(0xFF225FEC).withOpacity(0.3)
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFF3F3F46)
                                    : const Color(0xFFD4D4D8),
                                disabledForegroundColor: isDark
                                    ? const Color(0xFF71717A)
                                    : const Color(0xFFA1A1AA),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: canProceed
                                          ? Colors.white
                                          : (isDark
                                              ? const Color(0xFF71717A)
                                              : const Color(0xFFA1A1AA)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    LucideIcons.arrowRight,
                                    size: 20,
                                    color: canProceed
                                        ? Colors.white
                                        : (isDark
                                            ? const Color(0xFF71717A)
                                            : const Color(0xFFA1A1AA)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                // Navigation buttons for steps 1-5 (Previous and Next)
                if (_currentStep > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousStep,
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Previous'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _canProceedToNext()
                                    ? (_currentStep == 5
                                        ? _showReview
                                        : _nextStep)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF225FEC),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    Text(_currentStep == 5 ? 'Review' : 'Next'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        // In edit mode, allow proceeding if existing images exist OR new images selected
        final hasImages = _isEditMode
            ? (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
            : _selectedImages.isNotEmpty;
        return hasImages && _productName.isNotEmpty && _description.isNotEmpty;
      case 1:
        return _selectedCategory.isNotEmpty &&
            _price.isNotEmpty &&
            _unit.isNotEmpty &&
            _stockQuantity.isNotEmpty;
      case 2:
      case 3:
      case 4:
      case 5:
        return true; // Optional fields
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 5) {
      final nextStep = _currentStep + 1;
      debugPrint('Navigating to step $nextStep');
      debugPrint(
          'Current data - Name: $_productName, Images: ${_selectedImages.length}');
      debugPrint('Current data - Category: $_selectedCategory, Price: $_price');

      // Simply update the current step using setState
      // This preserves all state including File objects
      setState(() {
        _currentStep = nextStep;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      final previousStep = _currentStep - 1;
      debugPrint('Navigating back to step $previousStep');

      // Simply update the current step using setState
      // This preserves all state including File objects
      setState(() {
        _currentStep = previousStep;
      });
    }
  }

  void _showReview() {
    // Build product object with current data for preview
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      Get.snackbar(
        'Error',
        'User not authenticated',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Parse nutrition information
    final Map<String, double> nutritionMap = {};
    if (_nutritionInfo.isNotEmpty) {
      final parts = _nutritionInfo.split(',');
      for (final part in parts) {
        final nutrientParts = part.trim().split(':');
        if (nutrientParts.length == 2) {
          final nutrient = nutrientParts[0].trim();
          final value = double.tryParse(
              nutrientParts[1].trim().replaceAll(RegExp(r'[^0-9.]'), ''));
          if (value != null) {
            nutritionMap[nutrient] = value;
          }
        }
      }
    }

    // Handle images
    List<String> imageUrls = [];
    if (_existingImageUrls.isNotEmpty) {
      imageUrls.addAll(_existingImageUrls);
    }
    if (_selectedImages.isNotEmpty) {
      imageUrls.addAll(_selectedImages.map((image) => image.path).toList());
    }
    if (imageUrls.isEmpty && _isEditMode && widget.product != null) {
      imageUrls = widget.product!.images;
    }

    final reviewProduct = Product(
      id: _isEditMode
          ? widget.product!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      vendorId: authProvider.user!.id,
      name: _productName.trim(),
      description: _description.trim(),
      price: double.tryParse(_price) ?? 0.0,
      category: _selectedCategory,
      images: imageUrls,
      stock: int.tryParse(_stockQuantity) ?? 0,
      isActive: _isEditMode ? widget.product!.isActive : true,
      createdAt: _isEditMode ? widget.product!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      unit: _unit.trim(),
      brand: _brand.trim().isEmpty ? null : _brand.trim(),
      origin: _origin.trim().isEmpty ? null : _origin.trim(),
      expiryDate: _expiryDate.trim().isEmpty ? null : _expiryDate.trim(),
      tags: _tags.isEmpty ? null : _tags,
      rating: _isEditMode ? widget.product!.rating : 0.0,
      reviewCount: _isEditMode ? widget.product!.reviewCount : 0,
      nutritionInfo: nutritionMap.isEmpty ? null : nutritionMap,
      detailedDescription: _detailedDescription.trim().isEmpty
          ? null
          : _detailedDescription.trim(),
      features: _features.trim().isEmpty
          ? null
          : _features.trim().split(',').map((f) => f.trim()).toList(),
      isRealProduct: true,
      barcode: _barcode.trim().isEmpty ? null : _barcode.trim(),
      manufacturer: _manufacturer.trim().isEmpty ? null : _manufacturer.trim(),
      storageInstructions: _storageInstructions.trim().isEmpty
          ? null
          : _storageInstructions.trim(),
      allergens: _allergens.trim().isEmpty
          ? null
          : _allergens.trim().split(',').map((a) => a.trim()).toList(),
      isDiscounted: _isEditMode ? widget.product!.isDiscounted : false,
      discountPercentage:
          _isEditMode ? widget.product!.discountPercentage : null,
      discountPrice: _isEditMode ? widget.product!.discountPrice : null,
      discountStartDate: _isEditMode ? widget.product!.discountStartDate : null,
      discountEndDate: _isEditMode ? widget.product!.discountEndDate : null,
    );

    // Navigate to product detail screen in review mode
    Get.to(
      () => ProductDetailScreen(
        product: reviewProduct,
        isReviewMode: true,
        onUpdate: _saveProduct,
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_canProceedToNext()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      // Parse nutrition information
      final Map<String, double> nutritionMap = {};
      if (_nutritionInfo.isNotEmpty) {
        final parts = _nutritionInfo.split(',');
        for (final part in parts) {
          final nutrientParts = part.trim().split(':');
          if (nutrientParts.length == 2) {
            final nutrient = nutrientParts[0].trim();
            final value = double.tryParse(
                nutrientParts[1].trim().replaceAll(RegExp(r'[^0-9.]'), ''));
            if (value != null) {
              nutritionMap[nutrient] = value;
            }
          }
        }
      }

      // Handle images - separate existing URLs from new file paths
      List<String> existingImageUrls = [];
      List<File> newImageFiles = [];

      // Add existing image URLs (not removed by user)
      if (_existingImageUrls.isNotEmpty) {
        existingImageUrls.addAll(_existingImageUrls);
      }

      // Add new images selected by user
      if (_selectedImages.isNotEmpty) {
        newImageFiles.addAll(_selectedImages);
      }

      // If no images at all and in edit mode, keep original images
      if (existingImageUrls.isEmpty &&
          newImageFiles.isEmpty &&
          _isEditMode &&
          widget.product != null) {
        existingImageUrls = widget.product!.images;
      }

      // Ensure user is a vendor before creating product
      if (authProvider.user?.role != UserRole.vendor ||
          authProvider.user == null) {
        throw Exception('User must be a vendor to add/update products');
      }

      final product = Product(
        id: _isEditMode
            ? widget.product!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: authProvider.user!.id,
        name: _productName.trim(),
        description: _description.trim(),
        price: double.tryParse(_price) ?? 0.0,
        category: _selectedCategory,
        images:
            existingImageUrls, // Will be updated with uploaded URLs in DataProvider
        stock: int.tryParse(_stockQuantity) ?? 0,
        isActive: _isEditMode ? widget.product!.isActive : true,
        createdAt: _isEditMode ? widget.product!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        unit: _unit.trim(),
        brand: _brand.trim().isEmpty ? null : _brand.trim(),
        origin: _origin.trim().isEmpty ? null : _origin.trim(),
        expiryDate: _expiryDate.trim().isEmpty ? null : _expiryDate.trim(),
        tags: _tags.isEmpty ? null : _tags,
        rating: _isEditMode ? widget.product!.rating : 0.0,
        reviewCount: _isEditMode ? widget.product!.reviewCount : 0,
        nutritionInfo: nutritionMap.isEmpty ? null : nutritionMap,
        detailedDescription: _detailedDescription.trim().isEmpty
            ? null
            : _detailedDescription.trim(),
        features: _features.trim().isEmpty
            ? null
            : _features.trim().split(',').map((f) => f.trim()).toList(),
        isRealProduct: true,
        barcode: _barcode.trim().isEmpty ? null : _barcode.trim(),
        manufacturer:
            _manufacturer.trim().isEmpty ? null : _manufacturer.trim(),
        storageInstructions: _storageInstructions.trim().isEmpty
            ? null
            : _storageInstructions.trim(),
        allergens: _allergens.trim().isEmpty
            ? null
            : _allergens.trim().split(',').map((a) => a.trim()).toList(),
        // Preserve discount info if editing
        isDiscounted: _isEditMode ? widget.product!.isDiscounted : false,
        discountPercentage:
            _isEditMode ? widget.product!.discountPercentage : null,
        discountPrice: _isEditMode ? widget.product!.discountPrice : null,
        discountStartDate:
            _isEditMode ? widget.product!.discountStartDate : null,
        discountEndDate: _isEditMode ? widget.product!.discountEndDate : null,
      );

      if (_isEditMode) {
        // Update existing product immediately with new image files
        await dataProvider.updateProduct(product.id, product, newImageFiles);

        debugPrint(
            'AddProductStepper: Product updated, navigating to products screen');

        // Clear loading state before navigation
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Show success message
        NotificationService.showProductUpdated(product.name);

        // Navigate to products screen using GetX route
        await Get.offNamed('/vendor/products');

        // Refresh products in the background after navigation
        Future.microtask(() async {
          if (authProvider.user != null) {
            await dataProvider
                .forceRefreshVendorProducts(authProvider.user!.id);
            debugPrint(
                'AddProductStepper: Products refreshed after update in background');
          }
        });
      } else {
        // Add new product with new image files
        await dataProvider.addProduct(product, newImageFiles);

        // Clear loading state before navigation
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        // Show success message
        NotificationService.showProductAdded(product.name);

        // Navigate to products screen using GetX route
        await Get.offNamed('/vendor/products');
      }
    } catch (e) {
      debugPrint('AddProductStepper: Error - $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      NotificationService.showError(
        message: 'Error ${_isEditMode ? "updating" : "adding"} product: $e',
      );
    }
  }
}
