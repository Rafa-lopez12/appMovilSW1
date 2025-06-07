// lib/data/models/product/category_model.dart
class CategoryModel {
  final String id;
  final String name;
  final List<String> subcategories;
  final bool isActive;
  final String tenantId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.subcategories,
    required this.isActive,
    required this.tenantId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList() ?? [],
      isActive: json['isActive'] ?? true,
      tenantId: json['tenantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subcategories': subcategories,
      'isActive': isActive,
      'tenantId': tenantId,
    };
  }
}