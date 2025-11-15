import 'product.dart';
import 'order.dart';

class SalesData {
  final String date;
  final double amount;
  final int orders;

  SalesData({
    required this.date,
    required this.amount,
    required this.orders,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      date: json['date'],
      amount: json['amount']?.toDouble() ?? 0.0,
      orders: json['orders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'orders': orders,
    };
  }
}

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
    };
  }
}

class POSTransaction {
  final String id;
  final String vendorId;
  final List<CartItem> items;
  final double total;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final String? customerName;
  final String? customerPhone;

  POSTransaction({
    required this.id,
    required this.vendorId,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    this.customerName,
    this.customerPhone,
  });

  factory POSTransaction.fromJson(Map<String, dynamic> json) {
    return POSTransaction(
      id: json['id'],
      vendorId: json['vendorId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      total: json['total']?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'customerName': customerName,
      'customerPhone': customerPhone,
    };
  }
}

class VendorStats {
  final double totalSales;
  final int totalOrders;
  final int activeProducts;
  final double avgOrderValue;
  final List<TopSellingProduct> topSellingProducts;
  final List<CategorySales> salesByCategory;

  VendorStats({
    required this.totalSales,
    required this.totalOrders,
    required this.activeProducts,
    required this.avgOrderValue,
    required this.topSellingProducts,
    required this.salesByCategory,
  });

  factory VendorStats.fromJson(Map<String, dynamic> json) {
    return VendorStats(
      totalSales: json['totalSales']?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] ?? 0,
      activeProducts: json['activeProducts'] ?? 0,
      avgOrderValue: json['avgOrderValue']?.toDouble() ?? 0.0,
      topSellingProducts: (json['topSellingProducts'] as List)
          .map((item) => TopSellingProduct.fromJson(item))
          .toList(),
      salesByCategory: (json['salesByCategory'] as List)
          .map((item) => CategorySales.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'activeProducts': activeProducts,
      'avgOrderValue': avgOrderValue,
      'topSellingProducts':
          topSellingProducts.map((item) => item.toJson()).toList(),
      'salesByCategory': salesByCategory.map((item) => item.toJson()).toList(),
    };
  }
}

class TopSellingProduct {
  final Product product;
  final int quantity;
  final double revenue;

  TopSellingProduct({
    required this.product,
    required this.quantity,
    required this.revenue,
  });

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) {
    return TopSellingProduct(
      product: Product.fromJson(json['product']),
      quantity: (json['quantity'] ?? 0).toInt(),
      revenue: json['revenue']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'revenue': revenue,
    };
  }
}

class CategorySales {
  final String category;
  final double amount;
  final double percentage;

  CategorySales({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      category: json['category'],
      amount: json['amount']?.toDouble() ?? 0.0,
      percentage: json['percentage']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'percentage': percentage,
    };
  }
}

enum NotificationType {
  order,
  payment,
  promotion,
  system,
  login,
  product_added,
  product_deleted,
  product_discount,
}

enum PaymentMethod {
  card,
  cash,
  wallet,
  cod,
}
