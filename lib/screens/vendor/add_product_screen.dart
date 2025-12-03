import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_input.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  bool _didCheckRole = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _brandController = TextEditingController();
  final _originController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _stockController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _storageInstructionsController = TextEditingController();
  final _detailedDescriptionController = TextEditingController();
  final _featuresController = TextEditingController();
  final _allergensController = TextEditingController();
  final _nutritionController = TextEditingController();

  String _selectedCategory = 'Fruits & Vegetables';
  final List<File> _selectedImages = [];
  List<String> _tags = [];
  final Map<String, double> _nutritionInfo = {};
  bool _isLoading = false;

  final List<String> _categories = [
    'Fruits & Vegetables',
    'Dairy & Eggs',
    'Meat & Seafood',
    'Bakery',
    'Beverages',
    'Snacks',
    'Pantry',
    'Frozen Foods',
    'Health & Beauty',
    'Household',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _brandController.dispose();
    _originController.dispose();
    _expiryDateController.dispose();
    _stockController.dispose();
    _barcodeController.dispose();
    _manufacturerController.dispose();
    _storageInstructionsController.dispose();
    _detailedDescriptionController.dispose();
    _featuresController.dispose();
    _allergensController.dispose();
    _nutritionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Perform role validation once after first frame to avoid scheduling in build
    if (!_didCheckRole) {
      _didCheckRole = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (authProvider.user?.role != UserRole.vendor) {
          final switched = await authProvider.switchToVendorRole();
          if (!switched) {
            Get.offAllNamed('/customer');
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: Text(
              'Save',
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
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images Section
                    _buildImageSection(theme),
                    const SizedBox(height: 24),

                    // Basic Information
                    _buildSectionTitle('Basic Information', theme),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _nameController.text,
                      label: 'Product Name *',
                      hint: 'e.g., Naturel Red Apple',
                      onChanged: (value) => _nameController.text = value,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _descriptionController.text,
                      label: 'Short Description *',
                      hint: 'Brief description of the product',
                      maxLines: 2,
                      onChanged: (value) => _descriptionController.text = value,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(theme),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            value: _priceController.text,
                            label: 'Price *',
                            hint: '0.00',
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _priceController.text = value,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomInput(
                            value: _unitController.text,
                            label: 'Unit *',
                            hint: 'e.g., 1kg, 500g, 1 piece',
                            onChanged: (value) => _unitController.text = value,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _stockController.text,
                      label: 'Stock Quantity *',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _stockController.text = value,
                    ),

                    const SizedBox(height: 24),

                    // Product Details
                    _buildSectionTitle('Product Details', theme),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _brandController.text,
                      label: 'Brand',
                      hint: 'Product brand name',
                      onChanged: (value) => _brandController.text = value,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _originController.text,
                      label: 'Origin/Country',
                      hint: 'e.g., Pakistan, India',
                      onChanged: (value) => _originController.text = value,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _expiryDateController.text,
                      label: 'Expiry Date',
                      hint: 'DD/MM/YYYY',
                      readOnly: true,
                      onTap: () => _selectExpiryDate(),
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _barcodeController.text,
                      label: 'Barcode',
                      hint: 'Product barcode',
                      onChanged: (value) => _barcodeController.text = value,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _manufacturerController.text,
                      label: 'Manufacturer',
                      hint: 'Manufacturer name',
                      onChanged: (value) =>
                          _manufacturerController.text = value,
                    ),

                    const SizedBox(height: 24),

                    // Detailed Information
                    _buildSectionTitle('Detailed Information', theme),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _detailedDescriptionController.text,
                      label: 'Detailed Description',
                      hint: 'Comprehensive product description',
                      maxLines: 4,
                      onChanged: (value) =>
                          _detailedDescriptionController.text = value,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _featuresController.text,
                      label: 'Features',
                      hint: 'Key features (comma separated)',
                      maxLines: 2,
                      onChanged: (value) => _featuresController.text = value,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _storageInstructionsController.text,
                      label: 'Storage Instructions',
                      hint: 'How to store the product',
                      maxLines: 2,
                      onChanged: (value) =>
                          _storageInstructionsController.text = value,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      value: _allergensController.text,
                      label: 'Allergens',
                      hint: 'List any allergens (comma separated)',
                      onChanged: (value) => _allergensController.text = value,
                    ),

                    const SizedBox(height: 24),

                    // Nutrition Information
                    _buildSectionTitle('Nutrition Information', theme),
                    const SizedBox(height: 16),
                    _buildNutritionSection(theme),

                    const SizedBox(height: 24),

                    // Tags
                    _buildSectionTitle('Tags', theme),
                    const SizedBox(height: 16),
                    _buildTagsSection(theme),

                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add up to 5 images. First image will be the main display image.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return _buildAddImageButton(theme);
              }
              return _buildImagePreview(_selectedImages[index], index, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _showImagePicker,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.camera,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Image',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image, int index, ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.x,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Main',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Category is required';
        }
        return null;
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNutritionSection(ThemeData theme) {
    return Column(
      children: [
        CustomInput(
          value: _nutritionController.text,
          label: 'Nutrition per 100g',
          hint: 'e.g., Calories: 52, Protein: 0.3g, Carbs: 14g',
          maxLines: 3,
          onChanged: (value) => _nutritionController.text = value,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter nutrition information in format: "Nutrient: Value, Nutrient: Value"',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Column(
      children: [
        CustomInput(
          value: _tags.join(', '),
          label: 'Product Tags',
          hint: 'e.g., organic, fresh, local (comma separated)',
          onChanged: (value) {
            if (value.isNotEmpty) {
              _tags = value.split(',').map((tag) => tag.trim()).toList();
            }
          },
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      _expiryDateController.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product image')),
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
      _parseNutritionInfo();

      // Upload images (in a real app, you would upload to Firebase Storage)
      final imageUrls = _selectedImages.map((image) => image.path).toList();

      // Ensure user is a vendor before creating product
      if (authProvider.user?.role != UserRole.vendor ||
          authProvider.user == null) {
        throw Exception('User must be a vendor to add products');
      }

      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: authProvider.user!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        category: _selectedCategory,
        images: imageUrls,
        stock: int.tryParse(_stockController.text) ?? 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        unit: _unitController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        origin: _originController.text.trim().isEmpty
            ? null
            : _originController.text.trim(),
        expiryDate: _expiryDateController.text.trim().isEmpty
            ? null
            : _expiryDateController.text.trim(),
        tags: _tags.isEmpty ? null : _tags,
        rating: 0.0,
        reviewCount: 0,
        nutritionInfo: _nutritionInfo.isEmpty ? null : _nutritionInfo,
        detailedDescription: _detailedDescriptionController.text.trim().isEmpty
            ? null
            : _detailedDescriptionController.text.trim(),
        features: _featuresController.text.trim().isEmpty
            ? null
            : _featuresController.text
                .trim()
                .split(',')
                .map((f) => f.trim())
                .toList(),
        isRealProduct: true, // Mark as real product
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        storageInstructions: _storageInstructionsController.text.trim().isEmpty
            ? null
            : _storageInstructionsController.text.trim(),
        allergens: _allergensController.text.trim().isEmpty
            ? null
            : _allergensController.text
                .trim()
                .split(',')
                .map((a) => a.trim())
                .toList(),
      );

      await dataProvider.addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _parseNutritionInfo() {
    final nutritionText = _nutritionController.text.trim();
    if (nutritionText.isNotEmpty) {
      final parts = nutritionText.split(',');
      for (final part in parts) {
        final nutrientParts = part.trim().split(':');
        if (nutrientParts.length == 2) {
          final nutrient = nutrientParts[0].trim();
          final value = double.tryParse(
              nutrientParts[1].trim().replaceAll(RegExp(r'[^0-9.]'), ''));
          if (value != null) {
            _nutritionInfo[nutrient] = value;
          }
        }
      }
    }
  }
}
