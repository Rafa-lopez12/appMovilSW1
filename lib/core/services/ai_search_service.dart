import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/ai_search/ai_search_result_model.dart';
import '../../../data/models/ai_search/clothing_analysis_model.dart';

class AiSearchService {
  final AuthService _authService = AuthService();

  // Headers base para las peticiones
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'Accept': 'application/json',
      'X-Tenant-ID': ApiConstants.tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Headers para peticiones multipart
  Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _authService.getStoredToken();
    return {
      'Accept': 'application/json',
      'X-Tenant-ID': ApiConstants.tenantId,
      if (token != null) 'Authorization': 'Bearer $token',
      // Content-Type se establece automáticamente para multipart
    };
  }

  /// Busca productos similares usando una imagen desde archivo
  Future<AiSearchResultModel> searchByImageFile({
    required File imageFile,
    int limit = 10,
    double minSimilarity = 0.3,
  }) async {
    try {
      if (!validateImageFile(imageFile)) {
        throw AiSearchException('Archivo de imagen no válido. Verificar formato y tamaño.');
      }

      // Crear la request multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/ai-search/search-by-image'),
      );

      // Añadir headers
      request.headers.addAll(await _getMultipartHeaders());

      // Añadir archivo
      String fileName = imageFile.path.split('/').last;
      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // Añadir parámetros
      request.fields['limit'] = limit.toString();
      request.fields['minSimilarity'] = minSimilarity.toString();


      // Enviar request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return AiSearchResultModel.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw AiSearchException(
          errorData['message'] ?? 'Error en la búsqueda por imagen',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AiSearchException) rethrow;
      throw AiSearchException('Error de conexión: ${e.toString()}');
    }
  }

  /// Busca productos similares usando una URL de imagen
  Future<AiSearchResultModel> searchByImageUrl({
    required String imageUrl,
    int limit = 10,
    double minSimilarity = 0.3,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/ai-search/search-by-url'),
        headers: {
          ...await _getHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'imageUrl': imageUrl,
          'limit': limit,
          'minSimilarity': minSimilarity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return AiSearchResultModel.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw AiSearchException(
          errorData['message'] ?? 'Error en la búsqueda por URL',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AiSearchException) rethrow;
      throw AiSearchException('Error de conexión: ${e.toString()}');
    }
  }

  /// Busca productos similares usando datos base64 de imagen
  Future<AiSearchResultModel> searchByImageBase64({
    required String base64Image,
    int limit = 10,
    double minSimilarity = 0.3,
  }) async {
    try {
      // Convertir base64 a archivo temporal y usar searchByImageFile
      List<int> bytes = base64Decode(base64Image.split(',').last);
      
      // Crear archivo temporal
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/search_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);

      try {
        final result = await searchByImageFile(
          imageFile: tempFile,
          limit: limit,
          minSimilarity: minSimilarity,
        );
        
        // Limpiar archivo temporal
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        
        return result;
      } catch (e) {
        // Limpiar archivo temporal en caso de error
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        rethrow;
      }
    } catch (e) {
      if (e is AiSearchException) rethrow;
      throw AiSearchException('Error procesando imagen base64: ${e.toString()}');
    }
  }

  /// Obtiene el análisis de la ropa de una imagen
  Future<ClothingAnalysisModel> analyzeClothing({
    required File imageFile,
  }) async {
    try {
      final result = await searchByImageFile(
        imageFile: imageFile,
        limit: 1, // Solo necesitamos el análisis
        minSimilarity: 0.1,
      );
      
      return result.analysis;
    } catch (e) {
      if (e is AiSearchException) rethrow;
      throw AiSearchException('Error analizando imagen: ${e.toString()}');
    }
  }

  /// Valida si una imagen es válida para búsqueda
  bool validateImageFile(File imageFile) {
    // Verificar que el archivo existe
    if (!imageFile.existsSync()) {
      return false;
    }

    // Verificar tamaño (máximo 5MB como en el backend)
    int fileSizeInBytes = imageFile.lengthSync();
    int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    
    if (fileSizeInBytes > maxSizeInBytes) {
      return false;
    }

    // Verificar extensión
    String extension = imageFile.path.split('.').last.toLowerCase();
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    
    return allowedExtensions.contains(extension);
  }

  /// Obtiene información sobre los límites de búsqueda
  Map<String, dynamic> getSearchLimits() {
    return {
      'maxFileSize': 5 * 1024 * 1024, // 5MB en bytes
      'allowedFormats': ['jpg', 'jpeg', 'png', 'webp'],
      'maxLimit': 50,
      'minSimilarity': 0.1,
      'maxSimilarity': 1.0,
      'defaultLimit': 10,
      'defaultMinSimilarity': 0.3,
    };
  }

  /// Convierte archivo a base64 para preview
  Future<String> fileToBase64(File file) async {
    try {
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);
      
      // Determinar el tipo MIME
      String extension = file.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'jpg':
        case 'jpeg':
        default:
          mimeType = 'image/jpeg';
          break;
      }
      
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw AiSearchException('Error convirtiendo imagen a base64: ${e.toString()}');
    }
  }

  /// Obtiene el tipo de contenido para una imagen
  String getContentType(String filePath) {
    String extension = filePath.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Verifica si el servicio está disponible
  Future<bool> checkServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/health'),
        headers: await _getHeaders(),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Exception personalizada para AI Search
class AiSearchException implements Exception {
  final String message;
  final int? statusCode;

  AiSearchException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}