import 'package:get/get.dart';
import 'dart:io';
import '../models/product.dart';

class AddProductController extends GetxController {
  // Product data
  final RxList<File> selectedImages = <File>[].obs;
  final RxList<String> existingImageUrls = <String>[].obs;
  final RxString productName = ''.obs;
  final RxString description = ''.obs;
  final RxString selectedCategory = 'Fruits & Vegetables'.obs;
  final RxString price = ''.obs;
  final RxString unit = ''.obs;
  final RxString stockQuantity = ''.obs;
  final RxString brand = ''.obs;
  final RxString origin = ''.obs;
  final RxString expiryDate = ''.obs;
  final RxString barcode = ''.obs;
  final RxString manufacturer = ''.obs;
  final RxString detailedDescription = ''.obs;
  final RxString features = ''.obs;
  final RxString storageInstructions = ''.obs;
  final RxString allergens = ''.obs;
  final RxString nutritionInfo = ''.obs;
  final RxList<String> tags = <String>[].obs;

  // Initialize from product (for edit mode)
  void initializeFromProduct(Product? product) {
    if (product != null) {
      productName.value = product.name;
      description.value = product.description;
      selectedCategory.value = product.category;
      price.value = product.price.toString();
      unit.value = product.unit;
      stockQuantity.value = product.stock.toString();
      brand.value = product.brand ?? '';
      origin.value = product.origin ?? '';
      expiryDate.value = product.expiryDate ?? '';
      barcode.value = product.barcode ?? '';
      manufacturer.value = product.manufacturer ?? '';
      detailedDescription.value = product.detailedDescription ?? '';
      features.value = product.features?.join(', ') ?? '';
      storageInstructions.value = product.storageInstructions ?? '';
      allergens.value = product.allergens?.join(', ') ?? '';
      nutritionInfo.value = product.nutritionInfo?.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ') ??
          '';
      tags.value = List<String>.from(product.tags ?? []);
      existingImageUrls.value = List<String>.from(product.images);
    } else {
      reset();
    }
  }

  void reset() {
    selectedImages.clear();
    existingImageUrls.clear();
    productName.value = '';
    description.value = '';
    selectedCategory.value = 'Fruits & Vegetables';
    price.value = '';
    unit.value = '';
    stockQuantity.value = '';
    brand.value = '';
    origin.value = '';
    expiryDate.value = '';
    barcode.value = '';
    manufacturer.value = '';
    detailedDescription.value = '';
    features.value = '';
    storageInstructions.value = '';
    allergens.value = '';
    nutritionInfo.value = '';
    tags.clear();
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}

