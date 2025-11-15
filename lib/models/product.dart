class Product {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final int stock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? sku;
  final double? weight;
  final String? dimensions;

  // New fields based on Figma design
  final String unit; // e.g., "1kg", "500g", "1 piece"
  final String? brand;
  final String? origin;
  final String? expiryDate;
  final List<String>? tags;
  final double? rating;
  final int? reviewCount;
  final Map<String, double>? nutritionInfo; // per 100g
  final String? detailedDescription;
  final List<String>? features;
  final bool isRealProduct; // To distinguish real products from dummy data
  final String? barcode;
  final String? manufacturer;
  final String? storageInstructions;
  final List<String>? allergens;

  // Discount fields
  final double? discountPercentage;
  final double? discountPrice;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final bool isDiscounted;

  Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sku,
    this.weight,
    this.dimensions,
    required this.unit,
    this.brand,
    this.origin,
    this.expiryDate,
    this.tags,
    this.rating,
    this.reviewCount,
    this.nutritionInfo,
    this.detailedDescription,
    this.features,
    this.isRealProduct = false,
    this.barcode,
    this.manufacturer,
    this.storageInstructions,
    this.allergens,
    this.discountPercentage,
    this.discountPrice,
    this.discountStartDate,
    this.discountEndDate,
    this.isDiscounted = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      vendorId: json['vendorId'],
      name: json['name'],
      description: json['description'],
      price: json['price']?.toDouble() ?? 0.0,
      category: json['category'],
      images: List<String>.from(json['images'] ?? []),
      stock: (json['stock'] ?? 0).toInt(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sku: json['sku'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
      unit: json['unit'] ?? '1 piece',
      brand: json['brand'],
      origin: json['origin'],
      expiryDate: json['expiryDate'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount']?.toInt(),
      nutritionInfo: json['nutritionInfo'] != null
          ? Map<String, double>.from(json['nutritionInfo'])
          : null,
      detailedDescription: json['detailedDescription'],
      features:
          json['features'] != null ? List<String>.from(json['features']) : null,
      isRealProduct: json['isRealProduct'] ?? false,
      barcode: json['barcode'],
      manufacturer: json['manufacturer'],
      storageInstructions: json['storageInstructions'],
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'])
          : null,
      discountPercentage: json['discountPercentage']?.toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      discountStartDate: json['discountStartDate'] != null
          ? DateTime.parse(json['discountStartDate'])
          : null,
      discountEndDate: json['discountEndDate'] != null
          ? DateTime.parse(json['discountEndDate'])
          : null,
      isDiscounted: json['isDiscounted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'stock': stock,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions,
      'unit': unit,
      'brand': brand,
      'origin': origin,
      'expiryDate': expiryDate,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'nutritionInfo': nutritionInfo,
      'detailedDescription': detailedDescription,
      'features': features,
      'isRealProduct': isRealProduct,
      'barcode': barcode,
      'manufacturer': manufacturer,
      'storageInstructions': storageInstructions,
      'allergens': allergens,
      'discountPercentage': discountPercentage,
      'discountPrice': discountPrice,
      'discountStartDate': discountStartDate?.toIso8601String(),
      'discountEndDate': discountEndDate?.toIso8601String(),
      'isDiscounted': isDiscounted,
    };
  }

  Product copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    int? stock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sku,
    double? weight,
    String? dimensions,
    String? unit,
    String? brand,
    String? origin,
    String? expiryDate,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    Map<String, double>? nutritionInfo,
    String? detailedDescription,
    List<String>? features,
    bool? isRealProduct,
    String? barcode,
    String? manufacturer,
    String? storageInstructions,
    List<String>? allergens,
    double? discountPercentage,
    double? discountPrice,
    DateTime? discountStartDate,
    DateTime? discountEndDate,
    bool? isDiscounted,
  }) {
    return Product(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sku: sku ?? this.sku,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      unit: unit ?? this.unit,
      brand: brand ?? this.brand,
      origin: origin ?? this.origin,
      expiryDate: expiryDate ?? this.expiryDate,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      features: features ?? this.features,
      isRealProduct: isRealProduct ?? this.isRealProduct,
      barcode: barcode ?? this.barcode,
      manufacturer: manufacturer ?? this.manufacturer,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      allergens: allergens ?? this.allergens,
      discountPercentage: discountPercentage,
      discountPrice: discountPrice,
      discountStartDate: discountStartDate,
      discountEndDate: discountEndDate,
      isDiscounted: isDiscounted ?? this.isDiscounted,
    );
  }

  // Helper methods for discount calculations
  double get currentPrice {
    if (isDiscounted && _isDiscountActive()) {
      return discountPrice ?? (price * (1 - (discountPercentage ?? 0) / 100));
    }
    return price;
  }

  double get originalPrice => price;

  double get savingsAmount {
    if (isDiscounted && _isDiscountActive()) {
      return price - currentPrice;
    }
    return 0.0;
  }

  bool _isDiscountActive() {
    if (!isDiscounted) return false;

    final now = DateTime.now();
    if (discountStartDate != null && now.isBefore(discountStartDate!)) {
      return false;
    }
    if (discountEndDate != null && now.isAfter(discountEndDate!)) {
      return false;
    }
    return true;
  }

  String get discountBadgeText {
    if (!isDiscounted || !_isDiscountActive()) return '';

    if (discountPercentage != null) {
      return '${discountPercentage!.toInt()}% OFF';
    }
    return 'SALE';
  }
}
