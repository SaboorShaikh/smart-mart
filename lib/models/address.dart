enum AddressLabelType { home, work, other }

class AddressModel {
  final String id;
  final String userId;
  final AddressLabelType labelType;
  final String label; // e.g., Home, Work, or custom
  final String street; // required
  final String? houseNumber;
  final String? landmark;
  final String? floor;
  final double latitude;
  final double longitude;
  final String? placeName; // reverse geocode short name
  final DateTime createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.labelType,
    required this.label,
    required this.street,
    this.houseNumber,
    this.landmark,
    this.floor,
    required this.latitude,
    required this.longitude,
    this.placeName,
    required this.createdAt,
    this.updatedAt,
  });

  AddressModel copyWith({
    String? id,
    String? userId,
    AddressLabelType? labelType,
    String? label,
    String? street,
    String? houseNumber,
    String? landmark,
    String? floor,
    double? latitude,
    double? longitude,
    String? placeName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      labelType: labelType ?? this.labelType,
      label: label ?? this.label,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      landmark: landmark ?? this.landmark,
      floor: floor ?? this.floor,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      labelType: AddressLabelType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['labelType'] ?? 'other'),
        orElse: () => AddressLabelType.other,
      ),
      label: json['label'] ?? '',
      street: json['street'] ?? '',
      houseNumber: json['houseNumber'],
      landmark: json['landmark'],
      floor: json['floor'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      placeName: json['placeName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'labelType': labelType.toString().split('.').last,
      'label': label,
      'street': street,
      'houseNumber': houseNumber,
      'landmark': landmark,
      'floor': floor,
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
