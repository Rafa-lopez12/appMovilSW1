import 'clothing_analysis_model.dart';
import 'similar_product_model.dart';

class AiSearchResultModel {
  final bool success;
  final ClothingAnalysisModel analysis;
  final List<SimilarProductModel> results;

  AiSearchResultModel({
    required this.success,
    required this.analysis,
    required this.results,
  });

  factory AiSearchResultModel.fromJson(Map<String, dynamic> json) {
    return AiSearchResultModel(
      success: json['success'] ?? false,
      analysis: ClothingAnalysisModel.fromJson(json['analysis'] ?? {}),
      results: (json['results'] as List<dynamic>?)
          ?.map((item) => SimilarProductModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'analysis': analysis.toJson(),
      'results': results.map((result) => result.toJson()).toList(),
    };
  }

  AiSearchResultModel copyWith({
    bool? success,
    ClothingAnalysisModel? analysis,
    List<SimilarProductModel>? results,
  }) {
    return AiSearchResultModel(
      success: success ?? this.success,
      analysis: analysis ?? this.analysis,
      results: results ?? this.results,
    );
  }

  @override
  String toString() {
    return 'AiSearchResultModel(success: $success, resultsCount: ${results.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiSearchResultModel &&
        other.success == success &&
        other.analysis == analysis &&
        other.results.length == results.length;
  }

  @override
  int get hashCode => success.hashCode ^ analysis.hashCode ^ results.hashCode;

  /// Verifica si tiene resultados
  bool get hasResults {
    return results.isNotEmpty;
  }

  /// Obtiene el número de resultados
  int get resultCount {
    return results.length;
  }

  /// Obtiene los resultados con alta similitud
  List<SimilarProductModel> get highSimilarityResults {
    return results.where((product) => product.isHighSimilarity).toList();
  }

  /// Obtiene los resultados con similitud media
  List<SimilarProductModel> get mediumSimilarityResults {
    return results.where((product) => product.isMediumSimilarity).toList();
  }

  /// Obtiene los resultados con baja similitud
  List<SimilarProductModel> get lowSimilarityResults {
    return results.where((product) => product.isLowSimilarity).toList();
  }

  /// Obtiene todas las categorías únicas de los resultados
  List<String> get uniqueCategories {
    return results.map((product) => product.category).toSet().toList();
  }

  /// Obtiene todas las subcategorías únicas de los resultados
  List<String> get uniqueSubcategories {
    return results.map((product) => product.subcategory).toSet().toList();
  }

  /// Filtra resultados por categoría
  List<SimilarProductModel> getResultsByCategory(String category) {
    return results.where((product) => 
        product.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Filtra resultados por subcategoría
  List<SimilarProductModel> getResultsBySubcategory(String subcategory) {
    return results.where((product) => 
        product.subcategory.toLowerCase() == subcategory.toLowerCase()).toList();
  }

  /// Filtra resultados por similitud mínima
  List<SimilarProductModel> getResultsWithMinSimilarity(double minSimilarity) {
    return results.where((product) => 
        product.similarity >= minSimilarity).toList();
  }

  /// Obtiene estadísticas de los resultados
  Map<String, dynamic> get statistics {
    if (results.isEmpty) {
      return {
        'count': 0,
        'averageSimilarity': 0.0,
        'maxSimilarity': 0.0,
        'minSimilarity': 0.0,
        'categoriesCount': 0,
        'subcategoriesCount': 0,
      };
    }

    final similarities = results.map((p) => p.similarity).toList();
    
    return {
      'count': results.length,
      'averageSimilarity': similarities.reduce((a, b) => a + b) / similarities.length,
      'maxSimilarity': similarities.reduce((a, b) => a > b ? a : b),
      'minSimilarity': similarities.reduce((a, b) => a < b ? a : b),
      'categoriesCount': uniqueCategories.length,
      'subcategoriesCount': uniqueSubcategories.length,
      'highSimilarityCount': highSimilarityResults.length,
      'mediumSimilarityCount': mediumSimilarityResults.length,
      'lowSimilarityCount': lowSimilarityResults.length,
    };
  }
}