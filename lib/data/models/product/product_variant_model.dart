import 'package:prueba/data/models/product/size_model.dart';

class ProductVariantModel {
  final String id;
  final String color;
  final int quantity;
  final double price;
  final double? originalPrice;
  final SizeModel size;
  final String tenantId;

  ProductVariantModel({
    required this.id,
    required this.color,
    required this.quantity,
    required this.price,
    this.originalPrice,
    required this.size,
    required this.tenantId,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercentage => hasDiscount ? ((originalPrice! - price) / originalPrice! * 100) : 0.0;
  bool get inStock => quantity > 0;

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['Id'] ?? json['id'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      tenantId: json['tenantId'] ?? '',
      size: SizeModel.fromJson(json['size'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'color': color,
      'quantity': quantity,
      'price': price,
      'originalPrice': originalPrice,
      'tenantId': tenantId,
      'size': size.toJson(),
    };
  }
}