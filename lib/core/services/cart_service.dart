// lib/services/carrito_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

class CarritoService {
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

  // Obtener carrito completo
  Future<Map<String, dynamic>> obtenerCarrito() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/carrito'),
        headers: await _getHeaders(),
      );

      print('Cart Response Status: ${response.statusCode}');
      print('Cart Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw CartException(
          errorData['message'] ?? 'Error obteniendo carrito',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is CartException) rethrow;
      print('Cart Error: $e');
      throw CartException('Error de conexión: ${e.toString()}');
    }
  }

  // Agregar producto al carrito
  Future<Map<String, dynamic>> agregarAlCarrito({
    required String productoVariedadId,
    required int cantidad,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/carrito/agregar'),
        headers: await _getHeaders(),
        body: json.encode({
          'productoVariedadId': productoVariedadId,
          'cantidad': cantidad,
        }),
      );

      print('Add to Cart Response Status: ${response.statusCode}');
      print('Add to Cart Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw CartException(
          errorData['message'] ?? 'Error agregando al carrito',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is CartException) rethrow;
      print('Add to Cart Error: $e');
      throw CartException('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener contador de items
  Future<int> contarItems() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/carrito/contador'),
        headers: await _getHeaders(),
      );

      print('Cart Count Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // El backend puede retornar solo un número o un objeto con el número
        if (data is int) {
          return data;
        } else if (data is Map && data.containsKey('count')) {
          return data['count'] as int;
        } else {
          return 0;
        }
      } else {
        final errorData = json.decode(response.body);
        throw CartException(
          errorData['message'] ?? 'Error contando items',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is CartException) rethrow;
      print('Cart Count Error: $e');
      // Para el contador, retornamos 0 en caso de error
      return 0;
    }
  }

  // Actualizar cantidad de producto
  Future<Map<String, dynamic>> actualizarCantidad({
    required String productoVariedadId,
    required int cantidad,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/carrito/cantidad/$productoVariedadId'),
        headers: await _getHeaders(),
        body: json.encode({
          'cantidad': cantidad,
        }),
      );

      print('Update Quantity Response Status: ${response.statusCode}');
      print('Update Quantity Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw CartException(
          errorData['message'] ?? 'Error actualizando cantidad',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is CartException) rethrow;
      print('Update Quantity Error: $e');
      throw CartException('Error de conexión: ${e.toString()}');
    }
  }

  // Remover producto del carrito
  Future<Map<String, dynamic>> removerProducto({
    required String productoVariedadId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/carrito/producto/$productoVariedadId'),
        headers: await _getHeaders(),
      );

      print('Remove Product Response Status: ${response.statusCode}');
      print('Remove Product Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw CartException(
          errorData['message'] ?? 'Error removiendo producto',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is CartException) rethrow;
      print('Remove Product Error: $e');
      throw CartException('Error de conexión: ${e.toString()}');
    }
  }

  // Vaciar carrito completo
  Future<Map<String, dynamic>> vaciarCarrito() async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/carrito/vaciar'),
        headers: await _getHeaders(),
      );

      print('Clear Cart Response Status: ${response.statusCode}');
      print('Clear Cart Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw CartException(
          errorData['message'] ?? 'Error vaciando carrito',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is CartException) rethrow;
      print('Clear Cart Error: $e');
      throw CartException('Error de conexión: ${e.toString()}');
    }
  }
}

// Exception personalizada para carrito (siguiendo el patrón de ProductException)
class CartException implements Exception {
  final String message;
  final int? statusCode;

  CartException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}