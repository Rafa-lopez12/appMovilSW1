import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../core/services/virtual_tryon_service.dart';
import '../../data/models/virtual_tryon/virtual_tryon_session_model.dart';

class VirtualTryonProvider extends ChangeNotifier {
  final VirtualTryonService _tryonService = VirtualTryonService();

  // State variables
  List<VirtualTryonSessionModel> _sessions = [];
  VirtualTryonSessionModel? _currentSession;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  bool _isCreatingSession = false;
  bool _isPollingStatus = false;
  String? _errorMessage;
  
  // Upload progress
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  
  // Polling for session status
  bool _isPollingActive = false;
  
  // Cache
  Map<String, VirtualTryonSessionModel> _sessionCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Getters
  List<VirtualTryonSessionModel> get sessions => _sessions;
  VirtualTryonSessionModel? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isCreatingSession => _isCreatingSession;
  bool get isPollingStatus => _isPollingStatus;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  String get uploadStatus => _uploadStatus;
  bool get isPollingActive => _isPollingActive;

  // Computed getters
  int get totalSessions => _sessions.length;
  bool get hasSessions => _sessions.isNotEmpty;
  List<VirtualTryonSessionModel> get completedSessions => 
      _sessions.where((s) => s.status == 'completed').toList();
  List<VirtualTryonSessionModel> get processingSessions => 
      _sessions.where((s) => s.status == 'processing' || s.status == 'pending').toList();
  List<VirtualTryonSessionModel> get failedSessions => 
      _sessions.where((s) => s.status == 'failed').toList();
  int get completedCount => completedSessions.length;
  int get processingCount => processingSessions.length;
  int get failedCount => failedSessions.length;

  // Cache validation
  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  // Crear try-on desde URLs
  Future<VirtualTryonSessionModel?> createTryonFromUrls({
    required String userImageUrl,
    required String garmentImageUrl,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    _setCreatingSession(true);
    _clearError();
    _updateUploadStatus('Iniciando try-on virtual...');

    try {
      final session = await _tryonService.createTryonFromUrls(
        userImageUrl: userImageUrl,
        garmentImageUrl: garmentImageUrl,
        productoId: productoId,
        metadata: metadata,
      );

      _currentSession = session;
      _addSessionToCache(session);
      _updateUploadStatus('Try-on creado exitosamente');
      
      // Iniciar polling si está en processing
      if (session.status == 'processing' || session.status == 'pending') {
        _startPolling(session.id);
      }

      debugPrint('Try-on creado desde URLs: ${session.id}');
      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setCreatingSession(false);
    }
  }

  // Crear try-on desde base64
  Future<VirtualTryonSessionModel?> createTryonFromBase64({
    required String userImageBase64,
    required String garmentImageBase64,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    _setCreatingSession(true);
    _clearError();
    _updateUploadStatus('Procesando imágenes...');

    try {
      final session = await _tryonService.createTryonFromBase64(
        userImageBase64: userImageBase64,
        garmentImageBase64: garmentImageBase64,
        productoId: productoId,
        metadata: metadata,
      );

      _currentSession = session;
      _addSessionToCache(session);
      _updateUploadStatus('Try-on creado exitosamente');
      
      // Iniciar polling si está en processing
      if (session.status == 'processing' || session.status == 'pending') {
        _startPolling(session.id);
      }

      debugPrint('Try-on creado desde base64: ${session.id}');
      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setCreatingSession(false);
    }
  }

  // Subir archivos y crear try-on
  Future<VirtualTryonSessionModel?> uploadAndCreateTryon({
    required File userImage,
    required File garmentImage,
    String? productoId,
    Map<String, dynamic>? metadata,
  }) async {
    _setCreatingSession(true);
    _clearError();
    _updateUploadProgress(0.0);
    _updateUploadStatus('Subiendo imágenes...');

    try {
      // Simular progreso de subida
      for (int i = 1; i <= 5; i++) {
        _updateUploadProgress(i * 0.15);
        _updateUploadStatus('Subiendo imágenes... ${(i * 15).toInt()}%');
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final session = await _tryonService.uploadAndCreateTryon(
        userImage: userImage,
        garmentImage: garmentImage,
        productoId: productoId,
        metadata: metadata,
      );

      _updateUploadProgress(1.0);
      _updateUploadStatus('Try-on creado exitosamente');
      
      _currentSession = session;
      _addSessionToCache(session);
      
      // Iniciar polling si está en processing
      if (session.status == 'processing' || session.status == 'pending') {
        _startPolling(session.id);
      }

      debugPrint('Try-on creado con archivos: ${session.id}');
      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setCreatingSession(false);
      _updateUploadProgress(0.0);
    }
  }

  // Obtener estado de sesión
  Future<VirtualTryonSessionModel?> getSessionStatus(String sessionId) async {
    _setPollingStatus(true);
    _clearError();

    try {
      // Check cache first
      if (_sessionCache.containsKey(sessionId) && _isCacheValid) {
        final cachedSession = _sessionCache[sessionId]!;
        if (cachedSession.status == 'completed' || cachedSession.status == 'failed') {
          _setPollingStatus(false);
          return cachedSession;
        }
      }

      final session = await _tryonService.getSessionStatus(sessionId);
      
      _addSessionToCache(session);
      
      // Update current session if it's the same
      if (_currentSession?.id == sessionId) {
        _currentSession = session;
      }
      
      // Update in sessions list
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = session;
      }

      debugPrint('Session status updated: ${session.id} - ${session.status}');
      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setPollingStatus(false);
    }
  }

  // Cargar historial de sesiones
  Future<void> loadSessionHistory({bool refresh = false}) async {
    if (_sessions.isNotEmpty && !refresh && _isCacheValid) return;

    _setLoadingHistory(true);
    _clearError();

    try {
      final sessions = await _tryonService.getMySessions();
      _sessions = sessions;
      
      // Update cache
      for (final session in sessions) {
        _addSessionToCache(session);
      }
      
      _lastCacheUpdate = DateTime.now();
      debugPrint('Loaded ${sessions.length} try-on sessions');
    } catch (error) {
      _handleError(error);
    } finally {
      _setLoadingHistory(false);
    }
  }

  // Reintentar sesión
  Future<VirtualTryonSessionModel?> retrySession(String sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      final session = await _tryonService.retrySession(sessionId);
      
      _addSessionToCache(session);
      
      // Update current session if it's the same
      if (_currentSession?.id == sessionId) {
        _currentSession = session;
      }
      
      // Update in sessions list
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = session;
      }
      
      // Iniciar polling si está en processing
      if (session.status == 'processing' || session.status == 'pending') {
        _startPolling(session.id);
      }

      debugPrint('Session retried: ${session.id}');
      return session;
    } catch (error) {
      _handleError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Iniciar polling para una sesión
  void _startPolling(String sessionId) {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    notifyListeners();
    
    _pollSessionStatus(sessionId);
  }

  // Polling de estado de sesión
  Future<void> _pollSessionStatus(String sessionId) async {
    int attempts = 0;
    const maxAttempts = 60; // 5 minutos máximo
    const pollInterval = Duration(seconds: 5);

    while (attempts < maxAttempts && _isPollingActive) {
      try {
        final session = await getSessionStatus(sessionId);
        
        if (session != null) {
          if (session.status == 'completed' || session.status == 'failed') {
            _stopPolling();
            _updateUploadStatus(
              session.status == 'completed' 
                ? 'Try-on completado exitosamente' 
                : 'Try-on falló: ${session.errorMessage ?? 'Error desconocido'}'
            );
            break;
          }
        }

        await Future.delayed(pollInterval);
        attempts++;
      } catch (error) {
        debugPrint('Polling error: $error');
        attempts++;
        await Future.delayed(pollInterval);
      }
    }

    if (attempts >= maxAttempts) {
      _stopPolling();
      _updateUploadStatus('Timeout: El procesamiento tomó demasiado tiempo');
    }
  }

  // Detener polling
  void _stopPolling() {
    _isPollingActive = false;
    notifyListeners();
  }

  // Seleccionar sesión actual
  void setCurrentSession(VirtualTryonSessionModel session) {
    _currentSession = session;
    notifyListeners();
  }

  // Limpiar sesión actual
  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  // Obtener sesión por ID
  VirtualTryonSessionModel? getSessionById(String sessionId) {
    // Check cache first
    if (_sessionCache.containsKey(sessionId)) {
      return _sessionCache[sessionId];
    }
    
    // Check sessions list
    try {
      return _sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  // Eliminar sesión del historial (local)
  void removeSessionFromHistory(String sessionId) {
    _sessions.removeWhere((session) => session.id == sessionId);
    _sessionCache.remove(sessionId);
    
    if (_currentSession?.id == sessionId) {
      _currentSession = null;
    }
    
    notifyListeners();
  }

  // Limpiar historial (local)
  void clearHistory() {
    _sessions.clear();
    _sessionCache.clear();
    _currentSession = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await loadSessionHistory(refresh: true);
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadSessionHistory();
  }

  // Reset provider
  void reset() {
    _stopPolling();
    _sessions.clear();
    _currentSession = null;
    _sessionCache.clear();
    _clearError();
    _isLoading = false;
    _isLoadingHistory = false;
    _isCreatingSession = false;
    _isPollingStatus = false;
    _uploadProgress = 0.0;
    _uploadStatus = '';
    _lastCacheUpdate = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingHistory(bool loading) {
    _isLoadingHistory = loading;
    notifyListeners();
  }

  void _setCreatingSession(bool creating) {
    _isCreatingSession = creating;
    notifyListeners();
  }

  void _setPollingStatus(bool polling) {
    _isPollingStatus = polling;
    notifyListeners();
  }

  void _updateUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void _updateUploadStatus(String status) {
    _uploadStatus = status;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _errorMessage = error.toString();
    debugPrint('Virtual Tryon Provider Error: $_errorMessage');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _addSessionToCache(VirtualTryonSessionModel session) {
    _sessionCache[session.id] = session;
    _lastCacheUpdate = DateTime.now();
  }

  // Performance monitoring
  void logPerformanceMetrics() {
    debugPrint('=== Virtual Tryon Provider Performance ===');
    debugPrint('Sessions loaded: ${_sessions.length}');
    debugPrint('Sessions in cache: ${_sessionCache.length}');
    debugPrint('Cache valid: $_isCacheValid');
    debugPrint('Is polling active: $_isPollingActive');
    debugPrint('Completed sessions: $completedCount');
    debugPrint('Processing sessions: $processingCount');
    debugPrint('Failed sessions: $failedCount');
    debugPrint('=========================================');
  }

  // Dispose resources
  @override
  void dispose() {
    _stopPolling();
    _sessionCache.clear();
    super.dispose();
  }
}