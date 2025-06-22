// lib/presentation/providers/recommendation_provider.dart
import 'package:flutter/foundation.dart';
import '../../core/services/recommendation_service.dart';
import '../../data/models/recommendation/recommendation_model.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();

  // State variables
  Map<String, RecommendationAnalysis> _recommendations = {};
  Map<String, int> _quickStats = {};

  // Loading states
  bool _isLoadingRecommendations = false;
  bool _isLoadingQuickStats = false;
  String? _errorMessage;

  // Cache
  Map<String, RecommendationAnalysis> _cache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Current context
  String? _currentProductId;
  String? _currentCategoryId;
  List<String> _excludedProductIds = [];

  // Getters
  Map<String, RecommendationAnalysis> get recommendations => _recommendations;
  Map<String, int> get quickStats => _quickStats;
  
  bool get isLoadingRecommendations => _isLoadingRecommendations;
  bool get isLoadingQuickStats => _isLoadingQuickStats;
  bool get isLoading => _isLoadingRecommendations || _isLoadingQuickStats;
  
  String? get errorMessage => _errorMessage;
  String? get currentProductId => _currentProductId;
  String? get currentCategoryId => _currentCategoryId;

  // Computed getters
  bool get hasRecommendations => _recommendations.isNotEmpty;
  
  List<ProductRecommendation> get allRecommendations {
    final all = <ProductRecommendation>[];
    for (final analysis in _recommendations.values) {
      all.addAll(analysis.recommendations);
    }
    
    // Remover duplicados
    final seen = <String>{};
    return all.where((rec) => seen.add(rec.id)).toList();
  }

  List<ProductRecommendation> get topRecommendations {
    return allRecommendations
      ..sort((a, b) => b.score.compareTo(a.score))
      ..take(10).toList();
  }

  List<ProductRecommendation> get bestsellerRecommendations =>
      _recommendations['bestsellers']?.recommendations ?? [];

  List<ProductRecommendation> get newArrivalRecommendations =>
      _recommendations['new_arrivals']?.recommendations ?? [];

  List<ProductRecommendation> get similarProductRecommendations =>
      _recommendations['similar']?.recommendations ?? [];

  int get totalRecommendations => allRecommendations.length;
  bool get isEmpty => totalRecommendations == 0;

  // Cache validation
  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  // =================== RECOMMENDATION METHODS ===================

  /// Obtener bestsellers
  Future<void> loadBestsellers({
    String? categoryId,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    bool refresh = false,
  }) async {
    await _loadRecommendations(
      key: 'bestsellers',
      loader: () => _recommendationService.getBestsellers(
        categoryId: categoryId,
        subcategory: subcategory,
        minPrice: minPrice,
        maxPrice: maxPrice,
        limit: limit,
        excludeProductIds: _excludedProductIds,
      ),
      refresh: refresh,
    );
  }

  /// Obtener productos nuevos
  Future<void> loadNewArrivals({
    String? categoryId,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    bool refresh = false,
  }) async {
    await _loadRecommendations(
      key: 'new_arrivals',
      loader: () => _recommendationService.getNewArrivals(
        categoryId: categoryId,
        subcategory: subcategory,
        minPrice: minPrice,
        maxPrice: maxPrice,
        limit: limit,
        excludeProductIds: _excludedProductIds,
      ),
      refresh: refresh,
    );
  }

  /// Obtener productos similares
  Future<void> loadSimilarProducts(
    String productId, {
    String? categoryId,
    String? subcategory,
    double? minPrice,
    double? maxPrice,
    int limit = 10,
    bool refresh = false,
  }) async {
    _currentProductId = productId;
    
    await _loadRecommendations(
      key: 'similar',
      loader: () => _recommendationService.getSimilarProducts(
        productId,
        categoryId: categoryId,
        subcategory: subcategory,
        minPrice: minPrice,
        maxPrice: maxPrice,
        limit: limit,
        excludeProductIds: _excludedProductIds,
      ),
      refresh: refresh,
    );
  }

  /// Obtener recomendaciones por categoría
  Future<void> loadRecommendationsByCategory(
    String categoryId, {
    int limit = 10,
    bool refresh = false,
  }) async {
    _currentCategoryId = categoryId;
    
    await _loadRecommendations(
      key: 'category_$categoryId',
      loader: () => _recommendationService.getRecommendationsByCategory(
        categoryId,
        limit: limit,
      ),
      refresh: refresh,
    );
  }

  /// Obtener recomendaciones combinadas
  Future<void> loadCombinedRecommendations({
    int limit = 10,
    bool refresh = false,
  }) async {
    if (!refresh && _recommendations.isNotEmpty && _isCacheValid) return;

    _setLoadingRecommendations(true);
    _clearError();

    try {
      final combined = await _recommendationService.getCombinedRecommendations(limit: limit);
      
      for (final entry in combined.entries) {
        _recommendations[entry.key] = entry.value;
        _cache[entry.key] = entry.value;
      }

      _lastCacheUpdate = DateTime.now();
      debugPrint('Combined recommendations loaded: ${combined.keys}');
      notifyListeners();
    } catch (error) {
      _handleError(error);
    } finally {
      _setLoadingRecommendations(false);
    }
  }

  /// Cargar estadísticas rápidas
  Future<void> loadQuickStats({bool refresh = false}) async {
    if (!refresh && _quickStats.isNotEmpty && _isCacheValid) return;

    _isLoadingQuickStats = true;
    notifyListeners();

    try {
      _quickStats = await _recommendationService.getQuickStats();
      debugPrint('Quick stats loaded: $_quickStats');
    } catch (error) {
      debugPrint('Error loading quick stats: $error');
    } finally {
      _isLoadingQuickStats = false;
      notifyListeners();
    }
  }

  /// Cargar dashboard completo
  Future<void> loadDashboard({bool refresh = false}) async {
    _setLoadingRecommendations(true);
    _clearError();

    try {
      final dashboardData = await _recommendationService.getRecommendationsDashboard();
      
      // Actualizar recomendaciones
      if (dashboardData['bestsellers'] != null) {
        _recommendations['bestsellers'] = dashboardData['bestsellers'];
      }
      if (dashboardData['new_arrivals'] != null) {
        _recommendations['new_arrivals'] = dashboardData['new_arrivals'];
      }

      _lastCacheUpdate = DateTime.now();
      debugPrint('Dashboard loaded successfully');
      notifyListeners();
    } catch (error) {
      _handleError(error);
    } finally {
      _setLoadingRecommendations(false);
    }
  }

  // =================== UTILITY METHODS ===================

  /// Obtener recomendación específica por ID
  ProductRecommendation? getRecommendationById(String productId) {
    for (final analysis in _recommendations.values) {
      try {
        return analysis.recommendations.firstWhere((rec) => rec.id == productId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Obtener recomendaciones por categoría
  List<ProductRecommendation> getRecommendationsByCategory(String category) {
    return allRecommendations.where((rec) => 
        rec.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Obtener recomendaciones en rango de precio
  List<ProductRecommendation> getRecommendationsInPriceRange(double minPrice, double maxPrice) {
    return allRecommendations.where((rec) => 
        rec.price.min >= minPrice && rec.price.max <= maxPrice).toList();
  }

  /// Obtener recomendaciones de alta confianza
  List<ProductRecommendation> getHighConfidenceRecommendations({double threshold = 0.7}) {
    return allRecommendations.where((rec) => rec.confidence >= threshold).toList();
  }

  /// Establecer productos excluidos
  void setExcludedProducts(List<String> productIds) {
    _excludedProductIds = List.from(productIds);
    notifyListeners();
  }

  /// Agregar producto a excluidos
  void excludeProduct(String productId) {
    if (!_excludedProductIds.contains(productId)) {
      _excludedProductIds.add(productId);
      notifyListeners();
    }
  }

  /// Remover producto de excluidos
  void includeProduct(String productId) {
    _excludedProductIds.remove(productId);
    notifyListeners();
  }

  /// Limpiar productos excluidos
  void clearExcludedProducts() {
    _excludedProductIds.clear();
    notifyListeners();
  }

  // =================== WIDGET HELPERS ===================

  /// Obtener recomendaciones para mostrar en home
  List<ProductRecommendation> getHomeRecommendations({int limit = 6}) {
    return bestsellerRecommendations.take(limit).toList();
  }

  /// Obtener recomendaciones para carrusel
  List<ProductRecommendation> getCarouselRecommendations({
    String type = 'bestsellers',
    int limit = 10,
  }) {
    switch (type) {
      case 'bestsellers':
        return bestsellerRecommendations.take(limit).toList();
      case 'new':
        return newArrivalRecommendations.take(limit).toList();
      case 'similar':
        return similarProductRecommendations.take(limit).toList();
      case 'mixed':
      default:
        return topRecommendations.take(limit).toList();
    }
  }

  /// Obtener recomendaciones agrupadas por categoría
  Map<String, List<ProductRecommendation>> getRecommendationsByCategories() {
    final grouped = <String, List<ProductRecommendation>>{};
    
    for (final rec in allRecommendations) {
      grouped.putIfAbsent(rec.category, () => []).add(rec);
    }
    
    return grouped;
  }

  /// Obtener estadísticas de recomendaciones
  Map<String, dynamic> getRecommendationStats() {
    return {
      'total_recommendations': totalRecommendations,
      'bestseller_count': bestsellerRecommendations.length,
      'new_arrivals_count': newArrivalRecommendations.length,
      'similar_count': similarProductRecommendations.length,
      'average_score': allRecommendations.isNotEmpty 
          ? allRecommendations.map((r) => r.score).reduce((a, b) => a + b) / allRecommendations.length
          : 0.0,
      'average_confidence': allRecommendations.isNotEmpty 
          ? allRecommendations.map((r) => r.confidence).reduce((a, b) => a + b) / allRecommendations.length
          : 0.0,
    };
  }

  // =================== INITIALIZATION AND REFRESH ===================

  /// Inicializar provider
  Future<void> initialize() async {
    await Future.wait([
      loadQuickStats(),
      loadCombinedRecommendations(),
    ]);
  }

  /// Refrescar todos los datos
  Future<void> refreshAll() async {
    _clearCache();
    await initialize();
  }

  /// Refrescar solo las recomendaciones
  Future<void> refreshRecommendations() async {
    _recommendations.clear();
    await loadCombinedRecommendations(refresh: true);
  }

  // =================== PRIVATE METHODS ===================

  /// Método genérico para cargar recomendaciones
  Future<void> _loadRecommendations({
    required String key,
    required Future<RecommendationAnalysis> Function() loader,
    bool refresh = false,
  }) async {
    if (!refresh && _cache.containsKey(key) && _isCacheValid) {
      _recommendations[key] = _cache[key]!;
      notifyListeners();
      return;
    }

    _setLoadingRecommendations(true);
    _clearError();

    try {
      final result = await loader();
      _recommendations[key] = result;
      _cache[key] = result;
      
      _lastCacheUpdate = DateTime.now();
      debugPrint('Recommendations loaded for key: $key (${result.recommendations.length} items)');
      notifyListeners();
    } catch (error) {
      _handleError(error);
    } finally {
      _setLoadingRecommendations(false);
    }
  }

  void _setLoadingRecommendations(bool loading) {
    _isLoadingRecommendations = loading;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _errorMessage = error.toString();
    debugPrint('Recommendation Provider Error: $_errorMessage');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _clearCache() {
    _cache.clear();
    _lastCacheUpdate = null;
  }

  /// Reset provider
  void reset() {
    _recommendations.clear();
    _quickStats.clear();
    _currentProductId = null;
    _currentCategoryId = null;
    _excludedProductIds.clear();
    _clearCache();
    _clearError();
    _isLoadingRecommendations = false;
    _isLoadingQuickStats = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _clearCache();
    super.dispose();
  }
}