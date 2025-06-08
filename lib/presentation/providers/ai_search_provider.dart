import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:prueba/core/services/ai_search_service.dart';
import '../../../data/models/ai_search/ai_search_result_model.dart';
import '../../../data/models/ai_search/clothing_analysis_model.dart';
import '../../../data/models/ai_search/similar_product_model.dart';


enum AiSearchStatus {
  idle,
  loading,
  success,
  error,
}

class AiSearchProvider extends ChangeNotifier {
  final AiSearchService _aiSearchService;

  AiSearchProvider({AiSearchService? aiSearchService})
      : _aiSearchService = aiSearchService ?? AiSearchService();

  // Estado
  AiSearchStatus _status = AiSearchStatus.idle;
  String? _errorMessage;
  AiSearchResultModel? _lastSearchResult;
  ClothingAnalysisModel? _lastAnalysis;
  List<SimilarProductModel> _searchResults = [];
  File? _lastSearchedImage;
  String? _lastSearchedImageUrl;

  // Configuración de búsqueda
  int _searchLimit = 10;
  double _minSimilarity = 0.3;

  // Getters
  AiSearchStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AiSearchResultModel? get lastSearchResult => _lastSearchResult;
  ClothingAnalysisModel? get lastAnalysis => _lastAnalysis;
  List<SimilarProductModel> get searchResults => _searchResults;
  File? get lastSearchedImage => _lastSearchedImage;
  String? get lastSearchedImageUrl => _lastSearchedImageUrl;
  int get searchLimit => _searchLimit;
  double get minSimilarity => _minSimilarity;

  bool get isLoading => _status == AiSearchStatus.loading;
  bool get hasError => _status == AiSearchStatus.error;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasAnalysis => _lastAnalysis != null;

  // Setters para configuración
  void setSearchLimit(int limit) {
    if (limit >= 1 && limit <= 50) {
      _searchLimit = limit;
      notifyListeners();
    }
  }

  void setMinSimilarity(double similarity) {
    if (similarity >= 0.1 && similarity <= 1.0) {
      _minSimilarity = similarity;
      notifyListeners();
    }
  }

  /// Busca productos similares usando un archivo de imagen
  Future<void> searchByImageFile(File imageFile) async {
    if (!_aiSearchService.validateImageFile(imageFile)) {
      _setError('Archivo de imagen no válido. Verificar formato y tamaño.');
      return;
    }

    _setLoading();
    _lastSearchedImage = imageFile;
    _lastSearchedImageUrl = null;

    try {
      final result = await _aiSearchService.searchByImageFile(
        imageFile: imageFile,
        limit: _searchLimit,
        minSimilarity: _minSimilarity,
      );

      _setSuccess(result);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Busca productos similares usando una URL de imagen
  Future<void> searchByImageUrl(String imageUrl) async {
    if (imageUrl.isEmpty) {
      _setError('URL de imagen no puede estar vacía');
      return;
    }

    _setLoading();
    _lastSearchedImageUrl = imageUrl;
    _lastSearchedImage = null;

    try {
      final result = await _aiSearchService.searchByImageUrl(
        imageUrl: imageUrl,
        limit: _searchLimit,
        minSimilarity: _minSimilarity,
      );

      _setSuccess(result);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Busca productos similares usando imagen en base64
  Future<void> searchByImageBase64(String base64Image) async {
    if (base64Image.isEmpty) {
      _setError('Imagen base64 no puede estar vacía');
      return;
    }

    _setLoading();
    _lastSearchedImage = null;
    _lastSearchedImageUrl = null;

    try {
      final result = await _aiSearchService.searchByImageBase64(
        base64Image: base64Image,
        limit: _searchLimit,
        minSimilarity: _minSimilarity,
      );

      _setSuccess(result);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Analiza solo la ropa de una imagen sin buscar productos
  Future<void> analyzeClothing(File imageFile) async {
    if (!_aiSearchService.validateImageFile(imageFile)) {
      _setError('Archivo de imagen no válido');
      return;
    }

    _setLoading();

    try {
      final analysis = await _aiSearchService.analyzeClothing(imageFile: imageFile);
      
      _status = AiSearchStatus.success;
      _lastAnalysis = analysis;
      _errorMessage = null;
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Reintenta la última búsqueda
  Future<void> retryLastSearch() async {
    if (_lastSearchedImage != null) {
      await searchByImageFile(_lastSearchedImage!);
    } else if (_lastSearchedImageUrl != null) {
      await searchByImageUrl(_lastSearchedImageUrl!);
    } else {
      _setError('No hay búsqueda anterior para reintentar');
    }
  }

  /// Filtra los resultados actuales por similitud mínima
  void filterResultsBySimilarity(double minSimilarity) {
    if (_lastSearchResult != null) {
      _searchResults = _lastSearchResult!.results
          .where((product) => product.similarity >= minSimilarity)
          .toList();
      
      notifyListeners();
    }
  }

  /// Ordena los resultados por diferentes criterios
  void sortResults(String sortBy, {bool ascending = true}) {
    switch (sortBy) {
      case 'similarity':
        _searchResults.sort((a, b) => ascending 
            ? a.similarity.compareTo(b.similarity)
            : b.similarity.compareTo(a.similarity));
        break;
      case 'price':
        _searchResults.sort((a, b) => ascending 
            ? a.price.min.compareTo(b.price.min)
            : b.price.min.compareTo(a.price.min));
        break;
      case 'name':
        _searchResults.sort((a, b) => ascending 
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      default:
        // Mantener orden original (por similitud descendente)
        _searchResults.sort((a, b) => b.similarity.compareTo(a.similarity));
    }
    
    notifyListeners();
  }

  /// Obtiene productos por categoría de los resultados actuales
  List<SimilarProductModel> getResultsByCategory(String category) {
    return _searchResults
        .where((product) => product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Obtiene productos por subcategoría de los resultados actuales
  List<SimilarProductModel> getResultsBySubcategory(String subcategory) {
    return _searchResults
        .where((product) => product.subcategory.toLowerCase() == subcategory.toLowerCase())
        .toList();
  }

  /// Obtiene estadísticas de los resultados actuales
  Map<String, dynamic> getResultsStatistics() {
    if (_searchResults.isEmpty) return {};

    final similarities = _searchResults.map((p) => p.similarity).toList();
    final prices = _searchResults.map((p) => p.price.min).toList();
    
    return {
      'totalResults': _searchResults.length,
      'averageSimilarity': similarities.reduce((a, b) => a + b) / similarities.length,
      'maxSimilarity': similarities.reduce((a, b) => a > b ? a : b),
      'minSimilarity': similarities.reduce((a, b) => a < b ? a : b),
      'averagePrice': prices.reduce((a, b) => a + b) / prices.length,
      'maxPrice': prices.reduce((a, b) => a > b ? a : b),
      'minPrice': prices.reduce((a, b) => a < b ? a : b),
      'categories': _searchResults.map((p) => p.category).toSet().toList(),
      'subcategories': _searchResults.map((p) => p.subcategory).toSet().toList(),
    };
  }

  /// Convierte archivo a base64 para preview
  Future<String?> getImagePreview(File? imageFile) async {
    if (imageFile == null) return null;
    
    try {
      return await _aiSearchService.fileToBase64(imageFile);
    } catch (e) {
      debugPrint('Error obteniendo preview: $e');
      return null;
    }
  }

  /// Obtiene información sobre límites de búsqueda
  Map<String, dynamic> getSearchLimits() {
    return _aiSearchService.getSearchLimits();
  }

  /// Limpia todos los resultados y estado
  void clearResults() {
    _status = AiSearchStatus.idle;
    _errorMessage = null;
    _lastSearchResult = null;
    _lastAnalysis = null;
    _searchResults.clear();
    _lastSearchedImage = null;
    _lastSearchedImageUrl = null;
    
    notifyListeners();
  }

  /// Limpia solo el error
  void clearError() {
    _errorMessage = null;
    if (_status == AiSearchStatus.error) {
      _status = AiSearchStatus.idle;
    }
    notifyListeners();
  }

  // Métodos privados para manejo de estado
  void _setLoading() {
    _status = AiSearchStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess(AiSearchResultModel result) {
    _status = AiSearchStatus.success;
    _lastSearchResult = result;
    _lastAnalysis = result.analysis;
    _searchResults = result.results;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _status = AiSearchStatus.error;
    _errorMessage = error;
    _lastSearchResult = null;
    _searchResults.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}