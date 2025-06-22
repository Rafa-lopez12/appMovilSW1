// lib/core/services/recommendation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../data/models/recommendation/recommendation_model.dart';

class RecommendationService {

  // Headers base para las peticiones (solo tenant, sin auth)
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-Tenant-ID': ApiConstants.tenantId,
    };
  }

  // =================== RECOMENDACIONES PÚBLICAS (SIN AUTENTICACIÓN) ===================

  /// Obtener productos más vendidos
  Future<RecommendationAnalysis> getBestsellers({
    String? categoryId,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    List<String>? excludeProductIds,
    bool includeOutOfStock = false,
    double minConfidence = 0.3,
  }) async {
    try {
      final queryParams = <String, String>{
        'type': 'bestseller',
        'limit': limit.toString(),
        'includeOutOfStock': includeOutOfStock.toString(),
        'minConfidence': minConfidence.toString(),
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (subcategory != null) queryParams['subcategory'] = subcategory;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (excludeProductIds != null && excludeProductIds.isNotEmpty) {
        queryParams['excludeProductIds'] = excludeProductIds.join(',');
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/recommendations/public/bestsellers')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      print('Bestsellers Response Status: ${response.statusCode}');
      print('Bestsellers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecommendationAnalysis.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw RecommendationException(
          errorData['message'] ?? 'Error obteniendo bestsellers',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is RecommendationException) rethrow;
      print('Bestsellers Error: $e');
      throw RecommendationException('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener productos similares
  Future<RecommendationAnalysis> getSimilarProducts(
    String productId, {
    String? categoryId,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    List<String>? excludeProductIds,
    bool includeOutOfStock = false,
    double minConfidence = 0.3,
  }) async {
    try {
      final queryParams = <String, String>{
        'type': 'similar',
        'limit': limit.toString(),
        'includeOutOfStock': includeOutOfStock.toString(),
        'minConfidence': minConfidence.toString(),
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (subcategory != null) queryParams['subcategory'] = subcategory;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (excludeProductIds != null && excludeProductIds.isNotEmpty) {
        queryParams['excludeProductIds'] = excludeProductIds.join(',');
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/recommendations/public/similar/$productId')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      print('Similar Products Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecommendationAnalysis.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw RecommendationException(
          errorData['message'] ?? 'Error obteniendo productos similares',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is RecommendationException) rethrow;
      print('Similar Products Error: $e');
      throw RecommendationException('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener productos nuevos
  Future<RecommendationAnalysis> getNewArrivals({
    String? categoryId,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    List<String>? excludeProductIds,
    bool includeOutOfStock = false,
  }) async {
    try {
      final queryParams = <String, String>{
        'type': 'new_arrivals',
        'limit': limit.toString(),
        'includeOutOfStock': includeOutOfStock.toString(),
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (subcategory != null) queryParams['subcategory'] = subcategory;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (excludeProductIds != null && excludeProductIds.isNotEmpty) {
        queryParams['excludeProductIds'] = excludeProductIds.join(',');
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/recommendations/public/new-arrivals')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders());

      print('New Arrivals Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RecommendationAnalysis.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw RecommendationException(
          errorData['message'] ?? 'Error obteniendo productos nuevos',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is RecommendationException) rethrow;
      print('New Arrivals Error: $e');
      throw RecommendationException('Error de conexión: ${e.toString()}');
    }
  }

  // =================== MÉTODOS DE CONVENIENCIA ===================

  /// Obtener recomendaciones combinadas (bestsellers + nuevos)
  Future<Map<String, RecommendationAnalysis>> getCombinedRecommendations({
    int limit = 10,
  }) async {
    try {
      final results = <String, RecommendationAnalysis>{};
      
      // Obtener bestsellers y productos nuevos en paralelo
      final futures = await Future.wait([
        getBestsellers(limit: limit),
        getNewArrivals(limit: limit),
      ]);
      
      results['bestsellers'] = futures[0];
      results['new_arrivals'] = futures[1];
      
      return results;
    } catch (e) {
      print('Combined Recommendations Error: $e');
      throw RecommendationException('Error obteniendo recomendaciones combinadas: ${e.toString()}');
    }
  }

  /// Obtener recomendaciones por categoría (solo bestsellers)
  Future<RecommendationAnalysis> getRecommendationsByCategory(
    String categoryId, {
    int limit = 10,
  }) async {
    try {
      return await getBestsellers(
        categoryId: categoryId,
        limit: limit,
      );
    } catch (e) {
      print('Category Recommendations Error: $e');
      throw RecommendationException('Error obteniendo recomendaciones por categoría: ${e.toString()}');
    }
  }

  /// Obtener dashboard básico de recomendaciones
  Future<Map<String, dynamic>> getRecommendationsDashboard() async {
    try {
      final results = <String, dynamic>{};
      
      // Cargar bestsellers y productos nuevos
      final combined = await getCombinedRecommendations(limit: 8);
      results.addAll(combined);

      return results;
    } catch (e) {
      print('Dashboard Error: $e');
      throw RecommendationException('Error obteniendo dashboard de recomendaciones: ${e.toString()}');
    }
  }

  /// Obtener estadísticas rápidas
  Future<Map<String, int>> getQuickStats() async {
    try {
      final bestsellers = await getBestsellers(limit: 1);
      return {
        'total_products': bestsellers.totalProducts,
        'categories_analyzed': bestsellers.categoriesAnalyzed,
        'sales_data_points': bestsellers.salesDataPoints,
      };
    } catch (e) {
      print('Quick Stats Error: $e');
      return {
        'total_products': 0,
        'categories_analyzed': 0,
        'sales_data_points': 0,
      };
    }
  }
}

// Exception personalizada para recomendaciones
class RecommendationException implements Exception {
  final String message;
  final int? statusCode;

  RecommendationException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}