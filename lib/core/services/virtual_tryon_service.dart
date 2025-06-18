// lib/core/services/virtual_tryon_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../data/models/virtual_tryon/virtual_tryon_session_model.dart';
import 'auth_service.dart';

class VirtualTryonService {
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

  // Headers para multipart
  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'X-Tenant-ID': ApiConstants.tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Crear sesión de try-on desde URLs
  Future<VirtualTryonSessionModel> createTryonFromUrls({
    required String userImageUrl,
    required String garmentImageUrl,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.virtualTryonBase}/create-from-urls'),
        headers: await _getHeaders(),
        body: json.encode({
          'userImageUrl': userImageUrl,
          'garmentImageUrl': garmentImageUrl,
          if (productoId != null) 'productoId': productoId,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      print('Create Tryon URLs Response Status: ${response.statusCode}');
      print('Create Tryon URLs Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return VirtualTryonSessionModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error creando try-on desde URLs',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      print('Create Tryon URLs Error: $e');
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  // Crear sesión de try-on desde base64
  Future<VirtualTryonSessionModel> createTryonFromBase64({
    required String userImageBase64,
    required String garmentImageBase64,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tryonBase64}'),
        headers: await _getHeaders(),
        body: json.encode({
          'userImageBase64': userImageBase64,
          'garmentImageBase64': garmentImageBase64,
          if (productoId != null) 'productoId': productoId,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      print('Create Tryon Base64 Response Status: ${response.statusCode}');
      print('Create Tryon Base64 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return VirtualTryonSessionModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error creando try-on desde base64',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      print('Create Tryon Base64 Error: $e');
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  // Subir archivos y crear try-on
  Future<VirtualTryonSessionModel> uploadAndCreateTryon({
    required File userImage,
    required File garmentImage,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tryonUpload}'),
      );

      // Agregar headers
      request.headers.addAll(await _getMultipartHeaders());

      // Agregar archivos
      request.files.add(
        await http.MultipartFile.fromPath('images', userImage.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('images', garmentImage.path),
      );

      // Agregar campos adicionales
      if (productoId != null) {
        request.fields['productoId'] = productoId;
      }
      if (metadata != null) {
        request.fields['metadata'] = json.encode(metadata);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload Tryon Response Status: ${response.statusCode}');
      print('Upload Tryon Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return VirtualTryonSessionModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error subiendo y creando try-on',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      print('Upload Tryon Error: $e');
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener estado de sesión
  Future<VirtualTryonSessionModel> getSessionStatus(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tryonSession}/$sessionId'),
        headers: await _getHeaders(),
      );

      print('Session Status Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VirtualTryonSessionModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error obteniendo estado de sesión',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      print('Session Status Error: $e');
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener mis sesiones
  Future<List<VirtualTryonSessionModel>> getMySessions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tryonHistory}'),
        headers: await _getHeaders(),
      );

      print('My Sessions Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VirtualTryonSessionModel.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error obteniendo mis sesiones',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      print('My Sessions Error: $e');
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  // Reintentar sesión
  Future<VirtualTryonSessionModel> retrySession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.virtualTryonBase}/retry/$sessionId'),
        headers: await _getHeaders(),
      );

      print('Retry Session Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VirtualTryonSessionModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error reintentando sesión',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      print('Retry Session Error: $e');
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }
}

// Exception personalizada para virtual try-on
class VirtualTryonException implements Exception {
  final String message;
  final int? statusCode;

  VirtualTryonException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}