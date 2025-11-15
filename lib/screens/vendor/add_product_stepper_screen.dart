import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/categories.dart';
import '../product_detail_screen.dart';
import 'add_product_step1_screen.dart';
import 'add_product_step2_screen.dart';
import 'add_product_step3_screen.dart';
import 'add_product_step4_screen.dart';
import 'add_product_step5_screen.dart';
import 'add_product_step6_screen.dart';

class AddProductStepperScreen extends StatefulWidget {
  final Product? product; // Optional product for editing

  const AddProductStepperScreen({super.key, this.product});

  @override
  State<AddProductStepperScreen> createState() =>
      _AddProductStepperScreenState();
}

class _AddProductStepperScreenState extends State<AddProductStepperScreen> {
  bool _didCheckRole = false;
  int _currentStep = 0;
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
    _initializeFields();
  }

  void _initializeFields() {
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
        ),
        AddProductStep5Screen(
          nutritionInfo: _nutritionInfo,
          onDataChanged: (nutrition) {
            setState(() {
              _nutritionInfo = nutrition;
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
        ),
      ];

  @override
  Widget build(BuildContext context) {
    debugPrint('AddProductStepperScreen - build() called');
    final theme = Theme.of(context);
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
      appBar: AppBar(
        title: Text(
            '${_isEditMode ? "Edit" : "Add"} Product - Step ${_currentStep + 1} of 6'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                });
              },
              child: Text(
                'Start Over',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_currentStep == 5)
            TextButton(
              onPressed: _isLoading ? null : _saveProduct,
              child: Text(
                _isEditMode ? 'Update' : 'Save',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.only(
                                right: index < 5 ? 8 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: index <= _currentStep
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline
                                        .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Step ${_currentStep + 1} of 6',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Current step content
                Expanded(
                  child: _steps[_currentStep],
                ),
                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _currentStep > 0
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousStep,
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
                                child:
                                    Text(_currentStep == 5 ? 'Review' : 'Next'),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canProceedToNext()
                                ? (_currentStep == 5 ? _showReview : _nextStep)
                                : null,
                            child: Text(_currentStep == 5 ? 'Review' : 'Next'),
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
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
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
        Get.snackbar(
          'Success',
          '${product.name} updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );

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
        Get.snackbar(
          'Success',
          '${product.name} added successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );

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
      Get.snackbar(
        'Error',
        'Error ${_isEditMode ? "updating" : "adding"} product: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
