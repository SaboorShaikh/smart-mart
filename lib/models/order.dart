import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: (json['quantity'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final List<CartItem> items;
  final double total;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final OrderStatus status;
  final DeliveryType deliveryType;
  final String? deliveryAddress;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final String? estimatedDelivery;
  final String? trackingNumber;
  final String? notes;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.items,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.status,
    required this.deliveryType,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    this.estimatedDelivery,
    this.trackingNumber,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      vendorId: json['vendorId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      total: json['total']?.toDouble() ?? 0.0,
      subtotal: json['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: json['deliveryFee']?.toDouble() ?? 0.0,
      tax: json['tax']?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.toString().split('.').last == json['deliveryType'],
      ),
      deliveryAddress: json['deliveryAddress'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentStatus'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      estimatedDelivery: json['estimatedDelivery'],
      trackingNumber: json['trackingNumber'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'vendorId': vendorId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'status': status.toString().split('.').last,
      'deliveryType': deliveryType.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDelivery': estimatedDelivery,
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? vendorId,
    List<CartItem>? items,
    double? total,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    OrderStatus? status,
    DeliveryType? deliveryType,
    String? deliveryAddress,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    String? estimatedDelivery,
    String? trackingNumber,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      items: items ?? this.items,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      status: status ?? this.status,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

enum DeliveryType {
  delivery,
  pickup,
}

enum PaymentMethod {
  card,
  cash,
  wallet,
  cod,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}
