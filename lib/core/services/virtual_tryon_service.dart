import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../data/models/virtual_tryon/virtual_tryon_session_model.dart';
import 'auth_service.dart';
import 'package:http_parser/http_parser.dart';

class VirtualTryonService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'Content-Type': 'application/json',
      'X-Tenant-ID': ApiConstants.tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'X-Tenant-ID': ApiConstants.tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

Future<VirtualTryonSessionModel?> createTryonWithUserImage({
  required File userImage,
  required String garmentImageUrl,
  String? productoId,
  Map<String, dynamic>? metadata,
}) async {
  try {
    debugPrint('🚀 Iniciando createTryonWithUserImage...');
    
    final url = '${ApiConstants.baseUrl}${ApiConstants.tryonUpload}';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    // Headers
    request.headers.addAll(await _getMultipartHeaders());

    // 🔥 AGREGAR ARCHIVO CON MIME TYPE CORRECTO
    final mimeType = _getMimeTypeFromPath(userImage.path);
    debugPrint('📄 Detected MIME type: $mimeType');
    
    request.files.add(await http.MultipartFile.fromPath(
      'images',
      userImage.path,
      contentType: MediaType.parse(mimeType), // 👈 Forzar MIME type correcto
    ));

    // Campos
    request.fields['image'] = garmentImageUrl;
    if (productoId != null) {
      request.fields['productoId'] = productoId;
    }
    if (metadata != null) {
      request.fields['metadata'] = json.encode(metadata);
    }

    debugPrint('📝 Fields: ${request.fields}');

    // Enviar request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('📊 Response Status: ${response.statusCode}');
    debugPrint('📄 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return VirtualTryonSessionModel.fromJson(data);
    } else {
      final errorData = json.decode(response.body);
      throw VirtualTryonException(
        errorData['message'] ?? 'Error creando try-on',
        response.statusCode,
      );
    }
  } catch (e) {
    debugPrint('💥 Exception: $e');
    if (e is VirtualTryonException) rethrow;
    throw VirtualTryonException('Error de conexión: ${e.toString()}');
  }
}

String _getMimeTypeFromPath(String path) {
  final extension = path.split('.').last.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/jpeg'; // Default
  }
}

  Future<VirtualTryonSessionModel?> createTryonFromUrls({
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
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  Future<VirtualTryonSessionModel?> createTryonFromBase64({
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
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  Future<VirtualTryonSessionModel?> uploadAndCreateTryon({
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

      request.headers.addAll(await _getMultipartHeaders());
      request.files.add(await http.MultipartFile.fromPath('images', userImage.path));
      request.files.add(await http.MultipartFile.fromPath('images', garmentImage.path));

      if (productoId != null) {
        request.fields['productoId'] = productoId;
      }
      if (metadata != null) {
        request.fields['metadata'] = json.encode(metadata);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return VirtualTryonSessionModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error subiendo archivos',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  Future<VirtualTryonSessionModel?> getSessionStatus(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tryonSession}/$sessionId'),
        headers: await _getHeaders(),
      );

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
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  Future<List<VirtualTryonSessionModel>> getMySessions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.tryonHistory}'),
        headers: await _getHeaders(),
      );

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
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  Future<VirtualTryonSessionModel?> retrySession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.virtualTryonBase}/retry/$sessionId'),
        headers: await _getHeaders(),
      );

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
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> verifyReplicateAccount() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.virtualTryonBase}/verify-account'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw VirtualTryonException(
          errorData['message'] ?? 'Error verificando cuenta',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is VirtualTryonException) rethrow;
      throw VirtualTryonException('Error de conexión: ${e.toString()}');
    }
  }
}

class VirtualTryonException implements Exception {
  final String message;
  final int? statusCode;

  VirtualTryonException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}