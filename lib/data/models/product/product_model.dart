// lib/data/models/product/product_model.dart
import 'package:prueba/data/models/product/category_model.dart';
import 'package:prueba/data/models/product/product_image_model.dart';
import 'package:prueba/data/models/product/product_variant_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String subcategory;
  final bool isActive;
  final CategoryModel category;
  final List<ProductVariantModel> variants;
  final List<ProductImageModel> images;
  final String tenantId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.subcategory,
    required this.isActive,
    required this.category,
    required this.variants,
    required this.images,
    required this.tenantId,
  });

  // Getters de conveniencia
  double get minPrice => variants.isEmpty ? 0.0 : variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  double get maxPrice => variants.isEmpty ? 0.0 : variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  bool get hasDiscount => variants.any((v) => v.originalPrice != null && v.originalPrice! > v.price);
  int get totalStock => variants.fold(0, (sum, variant) => sum + variant.quantity);
  bool get inStock => totalStock > 0;
  String get mainImage => images.isNotEmpty ? images.first.url : '';
  List<String> get availableSizes => variants.map((v) => v.size.name).toSet().toList();
  List<String> get availableColors => variants.map((v) => v.color).toSet().toList();

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subcategory: json['subcategory'] ?? '',
      isActive: json['isActive'] ?? true,
      tenantId: json['tenantId'] ?? '',
      category: CategoryModel.fromJson(json['category'] ?? {}),
      variants: (json['productoVariedad'] as List<dynamic>?)
          ?.map((v) => ProductVariantModel.fromJson(v))
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((i) => ProductImageModel.fromJson(i))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subcategory': subcategory,
      'isActive': isActive,
      'tenantId': tenantId,
      'category': category.toJson(),
      'productoVariedad': variants.map((v) => v.toJson()).toList(),
      'images': images.map((i) => i.toJson()).toList(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? subcategory,
    bool? isActive,
    CategoryModel? category,
    List<ProductVariantModel>? variants,
    List<ProductImageModel>? images,
    String? tenantId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subcategory: subcategory ?? this.subcategory,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      variants: variants ?? this.variants,
      images: images ?? this.images,
      tenantId: tenantId ?? this.tenantId,
    );
  }
}