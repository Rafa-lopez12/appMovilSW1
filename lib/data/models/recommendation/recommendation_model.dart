// lib/data/models/recommendation/recommendation_model.dart

class ProductRecommendation {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final String category;
  final String subcategory;
  final PriceRange price;
  final double score;
  final String reason;
  final double confidence;
  final List<String> tags;

  ProductRecommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.score,
    required this.reason,
    required this.confidence,
    required this.tags,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      price: PriceRange.fromJson(json['price'] ?? {}),
      score: (json['score'] ?? 0.0).toDouble(),
      reason: json['reason'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
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
      'price': price.toJson(),
      'score': score,
      'reason': reason,
      'confidence': confidence,
      'tags': tags,
    };
  }

  // Getters de conveniencia
  String get mainImage => images.isNotEmpty ? images.first : '';
  bool get hasDiscount => tags.contains('discount') || tags.contains('sale');
  bool get isNew => tags.contains('new') || tags.contains('new_arrivals');
  bool get isBestseller => tags.contains('bestseller');
  bool get isPersonalized => tags.contains('personalized') || tags.contains('ai-powered');
  String get formattedPrice => '\$${price.min.toStringAsFixed(2)}';
  String get priceRange => price.min == price.max 
      ? '\$${price.min.toStringAsFixed(2)}'
      : '\$${price.min.toStringAsFixed(2)} - \$${price.max.toStringAsFixed(2)}';
  
  // Nivel de confianza como texto
  String get confidenceLevel {
    if (confidence >= 0.8) return 'Muy alta';
    if (confidence >= 0.6) return 'Alta';
    if (confidence >= 0.4) return 'Media';
    if (confidence >= 0.2) return 'Baja';
    return 'Muy baja';
  }

  // Score como porcentaje
  String get scorePercentage => '${(score * 100).toInt()}%';

  @override
  String toString() => 'ProductRecommendation(id: $id, name: $name, score: $score)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductRecommendation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PriceRange {
  final double min;
  final double max;

  PriceRange({
    required this.min,
    required this.max,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  bool get isSinglePrice => min == max;
  double get averagePrice => (min + max) / 2;
  double get priceSpread => max - min;

  @override
  String toString() => 'PriceRange(min: $min, max: $max)';
}

class RecommendationInsights {
  final List<String> trendingCategories;
  final PriceRange popularPriceRange;
  final List<String> topColors;
  final List<String> topSizes;

  RecommendationInsights({
    required this.trendingCategories,
    required this.popularPriceRange,
    required this.topColors,
    required this.topSizes,
  });

  factory RecommendationInsights.fromJson(Map<String, dynamic> json) {
    return RecommendationInsights(
      trendingCategories: List<String>.from(json['trendingCategories'] ?? []),
      popularPriceRange: PriceRange.fromJson(json['popularPriceRange'] ?? {}),
      topColors: List<String>.from(json['topColors'] ?? []),
      topSizes: List<String>.from(json['topSizes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trendingCategories': trendingCategories,
      'popularPriceRange': popularPriceRange.toJson(),
      'topColors': topColors,
      'topSizes': topSizes,
    };
  }

  // Getters de conveniencia
  String? get topCategory => trendingCategories.isNotEmpty ? trendingCategories.first : null;
  String? get topColor => topColors.isNotEmpty ? topColors.first : null;
  String? get topSize => topSizes.isNotEmpty ? topSizes.first : null;

  @override
  String toString() => 'RecommendationInsights(categories: ${trendingCategories.length})';
}

class RecommendationAnalysis {
  final int totalProducts;
  final int categoriesAnalyzed;
  final int salesDataPoints;
  final DateTime analysisDate;
  final List<ProductRecommendation> recommendations;
  final RecommendationInsights insights;

  RecommendationAnalysis({
    required this.totalProducts,
    required this.categoriesAnalyzed,
    required this.salesDataPoints,
    required this.analysisDate,
    required this.recommendations,
    required this.insights,
  });

  factory RecommendationAnalysis.fromJson(Map<String, dynamic> json) {
    return RecommendationAnalysis(
      totalProducts: json['totalProducts'] ?? 0,
      categoriesAnalyzed: json['categoriesAnalyzed'] ?? 0,
      salesDataPoints: json['salesDataPoints'] ?? 0,
      analysisDate: json['analysisDate'] != null 
          ? DateTime.parse(json['analysisDate'])
          : DateTime.now(),
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((item) => ProductRecommendation.fromJson(item))
          .toList() ?? [],
      insights: RecommendationInsights.fromJson(json['insights'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'categoriesAnalyzed': categoriesAnalyzed,
      'salesDataPoints': salesDataPoints,
      'analysisDate': analysisDate.toIso8601String(),
      'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
      'insights': insights.toJson(),
    };
  }

  // Getters de conveniencia
  bool get hasRecommendations => recommendations.isNotEmpty;
  int get recommendationCount => recommendations.length;
  bool get hasInsights => insights.trendingCategories.isNotEmpty || 
                          insights.topColors.isNotEmpty || 
                          insights.topSizes.isNotEmpty;

  // Obtener recomendaciones por score
  List<ProductRecommendation> get topRecommendations => 
      List<ProductRecommendation>.from(recommendations)
        ..sort((a, b) => b.score.compareTo(a.score));

  // Obtener recomendaciones de alta confianza
  List<ProductRecommendation> get highConfidenceRecommendations =>
      recommendations.where((r) => r.confidence >= 0.7).toList();

  // Obtener recomendaciones personalizadas
  List<ProductRecommendation> get personalizedRecommendations =>
      recommendations.where((r) => r.isPersonalized).toList();

  // Obtener bestsellers
  List<ProductRecommendation> get bestsellerRecommendations =>
      recommendations.where((r) => r.isBestseller).toList();

  // Estadísticas rápidas
  double get averageScore => recommendations.isNotEmpty 
      ? recommendations.map((r) => r.score).reduce((a, b) => a + b) / recommendations.length
      : 0.0;

  double get averageConfidence => recommendations.isNotEmpty 
      ? recommendations.map((r) => r.confidence).reduce((a, b) => a + b) / recommendations.length
      : 0.0;

  String get formattedAnalysisDate => '${analysisDate.day}/${analysisDate.month}/${analysisDate.year}';

  @override
  String toString() => 'RecommendationAnalysis(products: $totalProducts, recommendations: ${recommendations.length})';
}