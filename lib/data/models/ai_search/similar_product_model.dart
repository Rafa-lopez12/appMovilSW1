class ProductPriceModel {
  final double min;
  final double max;

  ProductPriceModel({
    required this.min,
    required this.max,
  });

  factory ProductPriceModel.fromJson(Map<String, dynamic> json) {
    return ProductPriceModel(
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  ProductPriceModel copyWith({
    double? min,
    double? max,
  }) {
    return ProductPriceModel(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }

  @override
  String toString() {
    return 'ProductPriceModel(min: $min, max: $max)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductPriceModel &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode => min.hashCode ^ max.hashCode;

  /// Obtiene el precio formateado como rango
  String get priceRange {
    if (min == max) {
      return '\$${min.toStringAsFixed(2)}';
    }
    return '\$${min.toStringAsFixed(2)} - \$${max.toStringAsFixed(2)}';
  }

  /// Obtiene el precio promedio
  double get average {
    return (min + max) / 2;
  }

  /// Verifica si es un precio fijo (min == max)
  bool get isFixedPrice {
    return min == max;
  }
}

class SimilarProductModel {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final String category;
  final String subcategory;
  final double similarity;
  final ProductPriceModel price;
  final int variants;
  final List<String>? matchReasons;

  SimilarProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.category,
    required this.subcategory,
    required this.similarity,
    required this.price,
    required this.variants,
    this.matchReasons,
  });

  factory SimilarProductModel.fromJson(Map<String, dynamic> json) {
    return SimilarProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      similarity: (json['similarity'] ?? 0).toDouble(),
      price: ProductPriceModel.fromJson(json['price'] ?? {}),
      variants: json['variants'] ?? 0,
      matchReasons: json['matchReasons'] != null 
          ? List<String>.from(json['matchReasons'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'category': category,
      'subcategory': subcategory,
      'similarity': similarity,
      'price': price.toJson(),
      'variants': variants,
      'matchReasons': matchReasons,
    };
  }

  SimilarProductModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? images,
    String? category,
    String? subcategory,
    double? similarity,
    ProductPriceModel? price,
    int? variants,
    List<String>? matchReasons,
  }) {
    return SimilarProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      similarity: similarity ?? this.similarity,
      price: price ?? this.price,
      variants: variants ?? this.variants,
      matchReasons: matchReasons ?? this.matchReasons,
    );
  }

  @override
  String toString() {
    return 'SimilarProductModel(id: $id, name: $name, similarity: $similarity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SimilarProductModel &&
        other.id == id &&
        other.name == name &&
        other.similarity == similarity;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ similarity.hashCode;

  /// Obtiene la primera imagen o una imagen por defecto
  String get primaryImage {
    return images.isNotEmpty ? images.first : '';
  }

  /// Verifica si tiene imágenes
  bool get hasImages {
    return images.isNotEmpty;
  }

  /// Obtiene el porcentaje de similitud
  String get similarityPercentage {
    return '${(similarity * 100).toStringAsFixed(1)}%';
  }

  /// Verifica si la similitud es alta (>= 80%)
  bool get isHighSimilarity {
    return similarity >= 0.8;
  }

  /// Verifica si la similitud es media (60% - 80%)
  bool get isMediumSimilarity {
    return similarity >= 0.6 && similarity < 0.8;
  }

  /// Verifica si la similitud es baja (< 60%)
  bool get isLowSimilarity {
    return similarity < 0.6;
  }

  /// Obtiene el nivel de similitud como texto
  String get similarityLevel {
    if (isHighSimilarity) return 'Alta';
    if (isMediumSimilarity) return 'Media';
    return 'Baja';
  }

  /// Obtiene las razones de coincidencia como texto
  String get matchReasonsText {
    if (matchReasons == null || matchReasons!.isEmpty) {
      return 'Sin razones específicas';
    }
    return matchReasons!.join(', ');
  }

  /// Verifica si tiene múltiples variantes
  bool get hasMultipleVariants {
    return variants > 1;
  }
}