import 'package:flutter/foundation.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
    };
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final LocationData? location;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.avatar,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Determine user type based on role and create appropriate instance
      final roleString = json['role'] ?? 'customer';
      final role = UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == roleString,
        orElse: () => UserRole.customer,
      );

      if (role == UserRole.vendor) {
        return Vendor.fromJson(json);
      } else {
        return Customer.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error creating user from JSON: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'phone': phone,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'location': location?.toJson(),
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    LocationData? location,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}

class Vendor extends User {
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String? shopLogo;
  final double rating;
  final int ratingCount;
  final ApprovalStatus isApproved;
  final bool deliveryEnabled;
  final bool pickupEnabled;
  final String businessLicense;
  final String? taxId;
  final String? bankAccount;
  final double commissionRate;
  final String? deliveryMode; // 'country', 'city', 'manual', or 'disabled'
  final String? deliveryCountry;
  final String? deliveryCity;
  final double? deliveryRadiusKm;

  Vendor({
    required super.id,
    required super.email,
    required super.name,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    this.shopLogo,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.isApproved,
    required this.deliveryEnabled,
    required this.pickupEnabled,
    required this.businessLicense,
    this.taxId,
    this.bankAccount,
    required this.commissionRate,
    this.deliveryMode,
    this.deliveryCountry,
    this.deliveryCity,
    this.deliveryRadiusKm,
    super.phone,
    super.avatar,
    required super.createdAt,
    super.updatedAt,
    super.location,
    super.address,
    super.city,
    super.state,
    super.country,
    super.postalCode,
  }) : super(role: UserRole.vendor);

  factory Vendor.fromJson(Map<String, dynamic> json) {
    debugPrint('Vendor.fromJson - Loading vendor data from Firestore:');
    debugPrint('  deliveryMode: ${json['deliveryMode']}');
    debugPrint('  deliveryCountry: ${json['deliveryCountry']}');
    debugPrint('  deliveryCity: ${json['deliveryCity']}');
    debugPrint('  deliveryRadiusKm: ${json['deliveryRadiusKm']}');

    return Vendor(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      shopName: json['shopName'],
      shopAddress: json['shopAddress'],
      shopPhone: json['shopPhone'],
      shopLogo: json['shopLogo'],
      isApproved: ApprovalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['isApproved'],
      ),
      deliveryEnabled: json['deliveryEnabled'],
      pickupEnabled: json['pickupEnabled'],
      businessLicense: json['businessLicense'],
      taxId: json['taxId'],
      bankAccount: json['bankAccount'],
      commissionRate: json['commissionRate']?.toDouble() ?? 0.0,
      deliveryMode: json['deliveryMode'],
      deliveryCountry: json['deliveryCountry'],
      deliveryCity: json['deliveryCity'],
      deliveryRadiusKm: json['deliveryRadiusKm']?.toDouble(),
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      location: json['location'] != null
          ? LocationData.fromJson(json['location'])
          : null,
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : 0.0,
      ratingCount: json['ratingCount']?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'shopName': shopName,
      'shopAddress': shopAddress,
      'shopPhone': shopPhone,
      'shopLogo': shopLogo,
      'rating': rating,
      'ratingCount': ratingCount,
      'isApproved': isApproved.toString().split('.').last,
      'deliveryEnabled': deliveryEnabled,
      'pickupEnabled': pickupEnabled,
      'businessLicense': businessLicense,
      'taxId': taxId,
      'bankAccount': bankAccount,
      'commissionRate': commissionRate,
      'deliveryMode': deliveryMode,
      'deliveryCountry': deliveryCountry,
      'deliveryCity': deliveryCity,
      'deliveryRadiusKm': deliveryRadiusKm,
    };
  }

  // Vendor-specific copyWith method
  Vendor copyWithVendor({
    String? id,
    String? email,
    String? name,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopLogo,
    double? rating,
    int? ratingCount,
    ApprovalStatus? isApproved,
    bool? deliveryEnabled,
    bool? pickupEnabled,
    String? businessLicense,
    String? taxId,
    String? bankAccount,
    double? commissionRate,
    String? deliveryMode,
    String? deliveryCountry,
    String? deliveryCity,
    double? deliveryRadiusKm,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    LocationData? location,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) {
    return Vendor(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      shopLogo: shopLogo ?? this.shopLogo,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isApproved: isApproved ?? this.isApproved,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      pickupEnabled: pickupEnabled ?? this.pickupEnabled,
      businessLicense: businessLicense ?? this.businessLicense,
      taxId: taxId ?? this.taxId,
      bankAccount: bankAccount ?? this.bankAccount,
      commissionRate: commissionRate ?? this.commissionRate,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      deliveryCountry: deliveryCountry ?? this.deliveryCountry,
      deliveryCity: deliveryCity ?? this.deliveryCity,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}

class Customer extends User {
  @override
  final String? address;
  final List<String> favoriteVendors;

  Customer({
    required super.id,
    required super.email,
    required super.name,
    this.address,
    this.favoriteVendors = const [],
    super.phone,
    super.avatar,
    required super.createdAt,
    super.updatedAt,
    super.location,
    super.city,
    super.state,
    super.country,
    super.postalCode,
  }) : super(role: UserRole.customer);

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      address: json['address'],
      favoriteVendors: List<String>.from(json['favoriteVendors'] ?? []),
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      location: json['location'] != null
          ? LocationData.fromJson(json['location'])
          : null,
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'address': address,
      'favoriteVendors': favoriteVendors,
    };
  }
}

enum UserRole {
  vendor,
  customer,
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
}
