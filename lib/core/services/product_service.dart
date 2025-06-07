// lib/core/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../data/models/product/product_model.dart';
import '../../data/models/product/category_model.dart';
import 'auth_service.dart';

class ProductService {
  final AuthService _authService = AuthService();

  // Headers base para las peticiones
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'Content-Type': 'application/json',
      'X-Tenant-ID': ApiConstants.tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener productos con filtros
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? subcategory,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? size,
    String? color,
    String? orderBy,
    String? orderDirection,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (subcategory != null) queryParams['subcategory'] = subcategory;
      if (search != null) queryParams['search'] = search;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (size != null) queryParams['size'] = size;
      if (color != null) queryParams['color'] = color;
      if (orderBy != null) queryParams['orderBy'] = orderBy;
      if (orderDirection != null) queryParams['orderDirection'] = orderDirection;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(uri, headers: await _getHeaders());

      print('Products Response Status: ${response.statusCode}');
      print('Products Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw ProductException(
          errorData['message'] ?? 'Error obteniendo productos',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ProductException) rethrow;
      print('Products Error: $e');
      throw ProductException('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener detalle de un producto
  Future<ProductModel> getProductDetail(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productDetail}/$productId'),
        headers: await _getHeaders(),
      );

      print('Product Detail Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw ProductException(
          errorData['message'] ?? 'Error obteniendo producto',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ProductException) rethrow;
      print('Product Detail Error: $e');
      throw ProductException('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener categorías
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}'),
        headers: await _getHeaders(),
      );

      print('Categories Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw ProductException(
          errorData['message'] ?? 'Error obteniendo categorías',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ProductException) rethrow;
      print('Categories Error: $e');
      throw ProductException('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener productos por categoría
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    return getProducts(categoryId: categoryId);
  }

  // Obtener productos por subcategoría
  Future<List<ProductModel>> getProductsBySubcategory(String subcategory) async {
    return getProducts(subcategory: subcategory);
  }

  // Búsqueda de productos
  Future<List<ProductModel>> searchProducts(String query) async {
    return getProducts(search: query);
  }

  // Obtener productos nuevos/destacados
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    return getProducts(
      orderBy: 'rating',
      orderDirection: 'DESC',
      limit: limit,
    );
  }

  // Obtener productos similares (placeholder)
  Future<List<ProductModel>> getSimilarProducts(String productId) async {
    // Por ahora retorna productos aleatorios
    // En el futuro se puede implementar con IA
    return getProducts(limit: 6);
  }
}

// Exception personalizada para productos
class ProductException implements Exception {
  final String message;
  final int? statusCode;

  ProductException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}